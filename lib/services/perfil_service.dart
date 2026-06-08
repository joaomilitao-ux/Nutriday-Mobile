import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Exceção lançada quando não há usuário autenticado ao ler/gravar o perfil.
class UsuarioNaoLogadoException implements Exception {
  const UsuarioNaoLogadoException();
}

/// Dados do perfil do usuário persistidos em `usuarios/{uid}`.
///
/// Todos os campos são opcionais: um usuário recém-criado pode não ter
/// preenchido nada ainda. As metas guardam o valor escolhido pelo usuário
/// (que pode ter sido sugerido automaticamente e depois ajustado).
class DadosPerfil {
  const DadosPerfil({
    this.idade,
    this.peso,
    this.altura,
    this.sexo,
    this.nivelAtividade,
    this.objetivo,
    this.metaCalorias,
    this.metaProteinas,
    this.metaCarboidratos,
    this.metaGorduras,
    this.metaAgua,
  });

  final String? idade;
  final String? peso;
  final String? altura;

  /// 'masculino' | 'feminino'
  final String? sexo;

  /// 'sedentario' | 'moderado' | 'ativo'
  final String? nivelAtividade;

  /// 'emagrecer' | 'ganhar_massa' | 'manter_peso'
  final String? objetivo;

  final num? metaCalorias;
  final num? metaProteinas;
  final num? metaCarboidratos;
  final num? metaGorduras;
  final num? metaAgua;

  static const DadosPerfil vazio = DadosPerfil();

  factory DadosPerfil.fromMap(Map<String, dynamic> map) {
    String? texto(dynamic valor) {
      if (valor == null) {
        return null;
      }
      final s = valor.toString().trim();
      return s.isEmpty ? null : s;
    }

    num? numero(dynamic valor) {
      if (valor is num) {
        return valor;
      }
      if (valor is String) {
        return num.tryParse(valor.replaceAll(',', '.'));
      }
      return null;
    }

    return DadosPerfil(
      idade: texto(map['idade']),
      peso: texto(map['peso']),
      altura: texto(map['altura']),
      sexo: texto(map['sexo']),
      nivelAtividade: texto(map['nivel_atividade']),
      objetivo: texto(map['objetivo']),
      metaCalorias: numero(map['meta_calorias']),
      metaProteinas: numero(map['meta_proteinas']),
      metaCarboidratos: numero(map['meta_carboidratos']),
      metaGorduras: numero(map['meta_gorduras']),
      metaAgua: numero(map['meta_agua']),
    );
  }
}

/// Metas diárias calculadas a partir do peso e do objetivo.
///
/// Usadas como sugestão inicial quando o usuário ainda não definiu metas
/// próprias. A lógica espelha os fatores já utilizados no app.
class MetasDiarias {
  const MetasDiarias({
    required this.calorias,
    required this.proteinas,
    required this.carboidratos,
    required this.gorduras,
    required this.agua,
  });

  final num calorias;
  final num proteinas;
  final num carboidratos;
  final num gorduras;
  final num agua;

  /// Valores padrão usados quando não há peso informado.
  static const MetasDiarias padrao = MetasDiarias(
    calorias: 2000,
    proteinas: 150,
    carboidratos: 200,
    gorduras: 65,
    agua: 8,
  );

  /// Calcula metas sugeridas com base no peso (kg) e no objetivo.
  factory MetasDiarias.sugeridas({String? peso, String? objetivo}) {
    final kg = double.tryParse((peso ?? '').replaceAll(',', '.'));
    if (kg == null || kg <= 0) {
      return padrao;
    }

    double fatorCalorias;
    double fatorProteinas;
    double fatorCarboidratos;
    double fatorGorduras;

    switch (objetivo) {
      case 'emagrecer':
        fatorCalorias = 28.0;
        fatorProteinas = 1.8;
        fatorCarboidratos = 2.5;
        fatorGorduras = 0.8;
        break;
      case 'ganhar_massa':
        fatorCalorias = 34.0;
        fatorProteinas = 2.0;
        fatorCarboidratos = 4.0;
        fatorGorduras = 0.9;
        break;
      default: // manter_peso ou não informado
        fatorCalorias = 30.0;
        fatorProteinas = 1.6;
        fatorCarboidratos = 3.0;
        fatorGorduras = 0.9;
    }

    return MetasDiarias(
      calorias: (kg * fatorCalorias).round(),
      proteinas: (kg * fatorProteinas).round(),
      carboidratos: (kg * fatorCarboidratos).round(),
      gorduras: (kg * fatorGorduras).round(),
      agua: (kg / 10).ceil(),
    );
  }
}

/// Serviço responsável por ler e persistir o perfil em `usuarios/{uid}`.
///
/// Toda escrita inclui obrigatoriamente:
/// - `criado_por`     -> e-mail do usuário logado
/// - `usuario_uid`    -> UID do FirebaseAuth
/// - `atualizado_em`  -> FieldValue.serverTimestamp()
///
/// As gravações usam `set(..., merge: true)`, de forma que cada modal salva
/// apenas os campos que edita, sem apagar os demais.
class PerfilService {
  PerfilService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String _colecao = 'usuarios';

  /// Carrega o perfil do usuário logado. Retorna [DadosPerfil.vazio] quando
  /// o documento ainda não existe.
  Future<DadosPerfil> carregarPerfil() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const UsuarioNaoLogadoException();
    }

    final doc = await _firestore.collection(_colecao).doc(user.uid).get();
    final data = doc.data();
    if (data == null) {
      return DadosPerfil.vazio;
    }
    return DadosPerfil.fromMap(data);
  }

  /// Salva os dados pessoais (idade, peso, altura, sexo, nível de atividade).
  Future<void> salvarDadosPessoais({
    String? idade,
    String? peso,
    String? altura,
    String? sexo,
    String? nivelAtividade,
  }) {
    return _salvar({
      'idade': idade?.trim(),
      'peso': peso?.trim(),
      'altura': altura?.trim(),
      'sexo': sexo,
      'nivel_atividade': nivelAtividade,
    });
  }

  /// Salva o objetivo do usuário.
  Future<void> salvarObjetivo(String objetivo) {
    return _salvar({'objetivo': objetivo});
  }

  /// Salva as metas diárias definidas/ajustadas pelo usuário.
  Future<void> salvarMetas({
    required num calorias,
    required num proteinas,
    required num carboidratos,
    required num gorduras,
    required num agua,
  }) {
    return _salvar({
      'meta_calorias': calorias,
      'meta_proteinas': proteinas,
      'meta_carboidratos': carboidratos,
      'meta_gorduras': gorduras,
      'meta_agua': agua,
    });
  }

  /// Grava [campos] em `usuarios/{uid}` acrescentando os metadados
  /// obrigatórios. Valores `null` são descartados para não sobrescrever
  /// dados já existentes.
  Future<void> _salvar(Map<String, dynamic> campos) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const UsuarioNaoLogadoException();
    }

    final dados = <String, dynamic>{}
      ..addEntries(campos.entries.where((e) => e.value != null))
      ..['criado_por'] = user.email
      ..['usuario_uid'] = user.uid
      ..['atualizado_em'] = FieldValue.serverTimestamp();

    await _firestore
        .collection(_colecao)
        .doc(user.uid)
        .set(dados, SetOptions(merge: true));
  }
}
