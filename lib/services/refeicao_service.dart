import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Exceção lançada quando não há usuário autenticado ao tentar salvar.
class UsuarioNaoLogadoException implements Exception {
  const UsuarioNaoLogadoException();
}

/// Serviço responsável por persistir refeições no Cloud Firestore.
///
/// Todo documento salvo carrega obrigatoriamente:
/// - `criado_por`  -> e-mail do usuário logado
/// - `usuario_uid` -> UID do FirebaseAuth
/// - `criado_em`   -> FieldValue.serverTimestamp()
///
/// Dados anônimos não são permitidos: se não houver usuário logado,
/// uma [UsuarioNaoLogadoException] é lançada antes de qualquer escrita.
class RefeicaoService {
  RefeicaoService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String _colecao = 'refeicoes';

  /// Salva uma refeição na coleção `refeicoes`.
  ///
  /// Os campos nutricionais aceitam texto livre e são convertidos para
  /// `double` (ou `null` quando vazios/ inválidos), sem quebrar o salvamento.
  Future<void> salvarRefeicao({
    required String nomeAlimento,
    required String quantidade,
    required String tipoRefeicao,
    String? calorias,
    String? proteinas,
    String? carboidratos,
    String? gorduras,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const UsuarioNaoLogadoException();
    }

    await _firestore.collection(_colecao).add({
      'nome_alimento': nomeAlimento.trim(),
      'quantidade': quantidade.trim(),
      'tipo_refeicao': tipoRefeicao,
      'calorias': _paraNumero(calorias),
      'proteinas': _paraNumero(proteinas),
      'carboidratos': _paraNumero(carboidratos),
      'gorduras': _paraNumero(gorduras),
      'criado_por': user.email,
      'usuario_uid': user.uid,
      'criado_em': FieldValue.serverTimestamp(),
    });
  }

  /// Converte um campo nutricional opcional em número.
  ///
  /// Retorna `null` quando vazio e `0` apenas quando o texto não é numérico,
  /// garantindo que o salvamento nunca quebre por entrada inválida.
  double? _paraNumero(String? valor) {
    final texto = valor?.trim();
    if (texto == null || texto.isEmpty) {
      return null;
    }
    return double.tryParse(texto.replaceAll(',', '.')) ?? 0;
  }
}
