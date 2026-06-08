import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutriday/app_routes.dart';
import 'package:nutriday/app_session.dart';
import 'package:nutriday/models/user_profile.dart';
import 'package:nutriday/services/perfil_service.dart';
import 'package:nutriday/widgets/app_bottom_navigation_bar.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _notificacoesAtivas = true;

  // Índice da aba ativa na barra de navegação inferior
  int _abaSelecionada = 4;

  static const Color _verde = Color(0xFF4CAF50);

  // Serviço de leitura/gravação do perfil em usuarios/{uid}
  final PerfilService _perfilService = PerfilService();

  // Dados do perfil carregados do Firestore
  DadosPerfil _perfil = DadosPerfil.vazio;

  // Controladores são CAMPOS da State e descartados apenas em dispose().
  // Isso evita descartá-los enquanto o bottom sheet ainda executa a animação
  // de fechamento (causa do "TextEditingController used after being disposed").
  final TextEditingController _idadeCtrl = TextEditingController();
  final TextEditingController _pesoCtrl = TextEditingController();
  final TextEditingController _alturaCtrl = TextEditingController();
  final TextEditingController _caloriasCtrl = TextEditingController();
  final TextEditingController _proteinasCtrl = TextEditingController();
  final TextEditingController _carboCtrl = TextEditingController();
  final TextEditingController _gordurasCtrl = TextEditingController();
  final TextEditingController _aguaCtrl = TextEditingController();

  static const Map<String, String> _rotulosObjetivo = {
    'emagrecer': 'Emagrecer',
    'ganhar_massa': 'Ganhar massa muscular',
    'manter_peso': 'Manter peso',
  };

  static const Map<String, String> _rotulosNivel = {
    'sedentario': 'Sedentário',
    'moderado': 'Moderado',
    'ativo': 'Ativo',
  };

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  @override
  void dispose() {
    _idadeCtrl.dispose();
    _pesoCtrl.dispose();
    _alturaCtrl.dispose();
    _caloriasCtrl.dispose();
    _proteinasCtrl.dispose();
    _carboCtrl.dispose();
    _gordurasCtrl.dispose();
    _aguaCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarPerfil() async {
    try {
      final perfil = await _perfilService.carregarPerfil();
      if (!mounted) {
        return;
      }
      setState(() => _perfil = perfil);
    } catch (_) {
      // Mantém os valores padrão/sugeridos se a leitura falhar.
    }
  }

  // Metas efetivas: usa o valor salvo pelo usuário ou, na ausência dele,
  // a sugestão calculada a partir de peso + objetivo.
  MetasDiarias get _metasEfetivas {
    final sugeridas = MetasDiarias.sugeridas(
      peso: _perfil.peso,
      objetivo: _perfil.objetivo,
    );
    return MetasDiarias(
      calorias: _perfil.metaCalorias ?? sugeridas.calorias,
      proteinas: _perfil.metaProteinas ?? sugeridas.proteinas,
      carboidratos: _perfil.metaCarboidratos ?? sugeridas.carboidratos,
      gorduras: _perfil.metaGorduras ?? sugeridas.gorduras,
      agua: _perfil.metaAgua ?? sugeridas.agua,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Tela de Perfil',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _secaoPerfil(),
          const SizedBox(height: 16),
          _secaoDadosPessoais(),
          const SizedBox(height: 16),
          _secaoMetasDiarias(),
          const SizedBox(height: 16),
          _secaoConfiguracoes(),
          const SizedBox(height: 24),
          _botaoSairDaConta(),
          const SizedBox(height: 16),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 4),
    );
  }

  // ─── Cabeçalho com foto, nome e e-mail ───────────────────────────────────

  Widget _secaoPerfil() {
    final email = FirebaseAuth.instance.currentUser?.email?.trim() ?? '';
    final username = UserProfile.usernameFromEmail(email);
    final displayName = username.isEmpty ? 'Usuario' : username;
    final displayEmail = email.isEmpty ? 'seu@email.com' : email;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: _decoracaoCard(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFFE0E0E0),
            child: Icon(Icons.person, size: 40, color: Colors.grey[500]),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayEmail,
                style: const TextStyle(fontSize: 14, color: _verde),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Dados pessoais e objetivo ────────────────────────────────────────────

  Widget _secaoDadosPessoais() {
    return Container(
      decoration: _decoracaoCard(),
      child: Column(
        children: [
          _itemMenu(
            icone: Icons.person_outline,
            corIcone: _verde,
            titulo: 'Dados Pessoais',
            subtitulo: _resumoDadosPessoais(),
            onTap: _editarDadosPessoais,
          ),
          const Divider(height: 1, indent: 56),
          _itemMenu(
            icone: Icons.track_changes_outlined,
            corIcone: const Color(0xFF42A5F5),
            titulo: 'Meu Objetivo',
            subtitulo: _resumoObjetivo(),
            onTap: _editarObjetivo,
          ),
        ],
      ),
    );
  }

  String _resumoDadosPessoais() {
    final partes = <String>[];
    if ((_perfil.idade ?? '').isNotEmpty) {
      partes.add('${_perfil.idade} anos');
    }
    if ((_perfil.peso ?? '').isNotEmpty) {
      partes.add('${_perfil.peso} kg');
    }
    if ((_perfil.altura ?? '').isNotEmpty) {
      partes.add('${_perfil.altura} cm');
    }
    if (partes.isEmpty) {
      return 'Toque para preencher';
    }
    return partes.join(', ');
  }

  String _resumoObjetivo() {
    final objetivo = _perfil.objetivo;
    if (objetivo == null || objetivo.isEmpty) {
      return 'Toque para definir';
    }
    return _rotulosObjetivo[objetivo] ?? objetivo;
  }

  // ─── Metas diárias ────────────────────────────────────────────────────────

  Widget _secaoMetasDiarias() {
    final metas = _metasEfetivas;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _decoracaoCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Metas Diárias',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: _editarMetas,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.edit_outlined, size: 18, color: _verde),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _linhaMetaDiaria('Calorias', '${_fmtNum(metas.calorias)} kcal'),
          _linhaMetaDiaria('Proteínas', '${_fmtNum(metas.proteinas)}g'),
          _linhaMetaDiaria('Carboidratos', '${_fmtNum(metas.carboidratos)}g'),
          _linhaMetaDiaria('Gorduras', '${_fmtNum(metas.gorduras)}g'),
          _linhaMetaDiaria(
            'Água',
            '${_fmtNum(metas.agua)} copos',
            mostrarDivisor: false,
          ),
        ],
      ),
    );
  }

  Widget _linhaMetaDiaria(
    String label,
    String valor, {
    bool mostrarDivisor = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.black54)),
              Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        if (mostrarDivisor) const Divider(height: 1),
      ],
    );
  }

  // ─── Notificações e ajuda ─────────────────────────────────────────────────

  Widget _secaoConfiguracoes() {
    return Container(
      decoration: _decoracaoCard(),
      child: Column(
        children: [
          _itemMenuSwitch(
            icone: Icons.notifications_outlined,
            corIcone: const Color(0xFFAB47BC),
            titulo: 'Notificações',
            subtitulo: 'Lembretes de refeições',
            valor: _notificacoesAtivas,
            onChanged: (valor) => setState(() => _notificacoesAtivas = valor),
          ),
          const Divider(height: 1, indent: 56),
          _itemMenu(
            icone: Icons.help_outline,
            corIcone: const Color(0xFFFFA726),
            titulo: 'Ajuda e Suporte',
            subtitulo: 'FAQ e contato',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // ─── Botão de sair ────────────────────────────────────────────────────────

  Widget _botaoSairDaConta() {
    return OutlinedButton.icon(
      onPressed: () async {
        // Captura o Navigator antes do await para não usar BuildContext
        // após a operação assíncrona de signOut.
        final navigator = Navigator.of(context);
        AppSession.clear();
        await FirebaseAuth.instance.signOut();
        navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      },
      icon: const Icon(Icons.logout, color: Colors.redAccent),
      label: const Text(
        'Sair da Conta',
        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.redAccent),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─── Modais de edição ─────────────────────────────────────────────────────
  //
  // Os modais apenas COLETAM dados e fecham com Navigator.pop(true).
  // Nenhuma operação assíncrona ou lookup de BuildContext acontece dentro do
  // bottom sheet, e os controladores NÃO são descartados aqui (são da State).
  // O salvamento no Firestore e o SnackBar são feitos pela tela principal,
  // depois que o modal já foi fechado.

  Future<void> _editarDadosPessoais() async {
    _idadeCtrl.text = _perfil.idade ?? '';
    _pesoCtrl.text = _perfil.peso ?? '';
    _alturaCtrl.text = _perfil.altura ?? '';
    String? sexo = _perfil.sexo;
    String? nivel = _perfil.nivelAtividade;

    final confirmado = await _abrirModal<bool>(
      titulo: 'Dados Pessoais',
      builder: (modalContext, setModal) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _campoModal('Idade', _idadeCtrl, hint: 'Ex: 28', numerico: true),
            const SizedBox(height: 14),
            _campoModal('Peso (kg)', _pesoCtrl, hint: 'Ex: 70', numerico: true),
            const SizedBox(height: 14),
            _campoModal(
              'Altura (cm)',
              _alturaCtrl,
              hint: 'Ex: 170',
              numerico: true,
            ),
            const SizedBox(height: 16),
            _rotuloCampoModal('Sexo'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _pilulaEscolha(
                    'Masculino',
                    selecionada: sexo == 'masculino',
                    onTap: () => setModal(() => sexo = 'masculino'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _pilulaEscolha(
                    'Feminino',
                    selecionada: sexo == 'feminino',
                    onTap: () => setModal(() => sexo = 'feminino'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _rotuloCampoModal('Nível de atividade'),
            const SizedBox(height: 8),
            ..._rotulosNivel.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _opcaoSelecionavel(
                  titulo: e.value,
                  selecionada: nivel == e.key,
                  onTap: () => setModal(() => nivel = e.key),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _botaoSalvarModal(
              onPressed: () => Navigator.of(modalContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmado != true) {
      return;
    }

    final idade = _idadeCtrl.text;
    final peso = _pesoCtrl.text;
    final altura = _alturaCtrl.text;

    await _salvarComFeedback(
      salvar: () => _perfilService.salvarDadosPessoais(
        idade: idade,
        peso: peso,
        altura: altura,
        sexo: sexo,
        nivelAtividade: nivel,
      ),
      mensagemSucesso: 'Dados pessoais atualizados!',
    );
  }

  Future<void> _editarObjetivo() async {
    String? objetivo = _perfil.objetivo;

    final confirmado = await _abrirModal<bool>(
      titulo: 'Meu Objetivo',
      builder: (modalContext, setModal) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ..._rotulosObjetivo.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _opcaoSelecionavel(
                  titulo: e.value,
                  selecionada: objetivo == e.key,
                  onTap: () => setModal(() => objetivo = e.key),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _botaoSalvarModal(
              onPressed: objetivo == null
                  ? null
                  : () => Navigator.of(modalContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmado != true || objetivo == null) {
      return;
    }

    final objetivoSelecionado = objetivo!;
    await _salvarComFeedback(
      salvar: () => _perfilService.salvarObjetivo(objetivoSelecionado),
      mensagemSucesso: 'Objetivo atualizado!',
    );
  }

  Future<void> _editarMetas() async {
    final metas = _metasEfetivas;
    _caloriasCtrl.text = _fmtNum(metas.calorias);
    _proteinasCtrl.text = _fmtNum(metas.proteinas);
    _carboCtrl.text = _fmtNum(metas.carboidratos);
    _gordurasCtrl.text = _fmtNum(metas.gorduras);
    _aguaCtrl.text = _fmtNum(metas.agua);

    final confirmado = await _abrirModal<bool>(
      titulo: 'Metas Diárias',
      builder: (modalContext, setModal) {
        void sugerir() {
          final sugeridas = MetasDiarias.sugeridas(
            peso: _perfil.peso,
            objetivo: _perfil.objetivo,
          );
          setModal(() {
            _caloriasCtrl.text = _fmtNum(sugeridas.calorias);
            _proteinasCtrl.text = _fmtNum(sugeridas.proteinas);
            _carboCtrl.text = _fmtNum(sugeridas.carboidratos);
            _gordurasCtrl.text = _fmtNum(sugeridas.gorduras);
            _aguaCtrl.text = _fmtNum(sugeridas.agua);
          });
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: sugerir,
              icon: const Icon(Icons.auto_awesome, size: 18, color: _verde),
              label: const Text(
                'Sugerir automaticamente',
                style: TextStyle(color: _verde, fontWeight: FontWeight.w500),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _verde),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              (_perfil.peso ?? '').isEmpty
                  ? 'Preencha seu peso em Dados Pessoais para sugestões mais precisas.'
                  : 'Calculado a partir do seu peso e objetivo. Ajuste se quiser.',
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            ),
            const SizedBox(height: 16),
            _campoModal(
              'Calorias (kcal)',
              _caloriasCtrl,
              hint: 'Ex: 2000',
              numerico: true,
            ),
            const SizedBox(height: 14),
            _campoModal(
              'Proteínas (g)',
              _proteinasCtrl,
              hint: 'Ex: 150',
              numerico: true,
            ),
            const SizedBox(height: 14),
            _campoModal(
              'Carboidratos (g)',
              _carboCtrl,
              hint: 'Ex: 200',
              numerico: true,
            ),
            const SizedBox(height: 14),
            _campoModal(
              'Gorduras (g)',
              _gordurasCtrl,
              hint: 'Ex: 65',
              numerico: true,
            ),
            const SizedBox(height: 14),
            _campoModal(
              'Água (copos)',
              _aguaCtrl,
              hint: 'Ex: 8',
              numerico: true,
            ),
            const SizedBox(height: 20),
            _botaoSalvarModal(
              onPressed: () => Navigator.of(modalContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmado != true) {
      return;
    }

    final calorias = _paraNum(_caloriasCtrl.text, metas.calorias);
    final proteinas = _paraNum(_proteinasCtrl.text, metas.proteinas);
    final carboidratos = _paraNum(_carboCtrl.text, metas.carboidratos);
    final gorduras = _paraNum(_gordurasCtrl.text, metas.gorduras);
    final agua = _paraNum(_aguaCtrl.text, metas.agua);

    await _salvarComFeedback(
      salvar: () => _perfilService.salvarMetas(
        calorias: calorias,
        proteinas: proteinas,
        carboidratos: carboidratos,
        gorduras: gorduras,
        agua: agua,
      ),
      mensagemSucesso: 'Metas atualizadas!',
    );
  }

  // Executa o salvamento na tela principal e mostra o feedback de forma segura.
  //
  // O ScaffoldMessenger é capturado ANTES do await, então nenhum BuildContext
  // é consultado após a operação assíncrona. O SnackBar só é exibido se a tela
  // ainda estiver montada.
  Future<void> _salvarComFeedback({
    required Future<void> Function() salvar,
    required String mensagemSucesso,
  }) async {
    final messenger = ScaffoldMessenger.of(context);

    String mensagem;
    bool erro = false;
    try {
      await salvar();
      mensagem = mensagemSucesso;
    } on UsuarioNaoLogadoException {
      mensagem = 'Você precisa estar logado para salvar.';
      erro = true;
    } catch (_) {
      mensagem = 'Não foi possível salvar. Tente novamente.';
      erro = true;
    }

    if (!erro) {
      await _carregarPerfil();
    }

    if (!mounted) {
      return;
    }

    _mostrarMensagem(messenger, mensagem, erro: erro);
  }

  // Exibe um SnackBar usando um messenger já capturado (sem novo lookup de
  // BuildContext). Deve ser chamado apenas quando `mounted` for verdadeiro.
  void _mostrarMensagem(
    ScaffoldMessengerState messenger,
    String mensagem, {
    bool erro = false,
  }) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: erro ? Colors.redAccent : _verde,
      ),
    );
  }

  // Abre um bottom sheet padronizado com título e conteúdo rolável,
  // ajustando o espaço para o teclado.
  Future<T?> _abrirModal<T>({
    required String titulo,
    required Widget Function(BuildContext, StateSetter) builder,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (builderContext, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(builderContext).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    builder(builderContext, setModal),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─── Componentes dos modais ───────────────────────────────────────────────

  Widget _rotuloCampoModal(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _campoModal(
    String label,
    TextEditingController controller, {
    String? hint,
    bool numerico = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _rotuloCampoModal(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: numerico
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          inputFormatters: numerico
              ? [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))]
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _verde),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pilulaEscolha(
    String label, {
    required bool selecionada,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: selecionada ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selecionada ? _verde : const Color(0xFFE0E0E0),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selecionada ? _verde : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _opcaoSelecionavel({
    required String titulo,
    required bool selecionada,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selecionada ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selecionada ? _verde : const Color(0xFFE0E0E0),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                titulo,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selecionada ? _verde : Colors.black87,
                ),
              ),
            ),
            if (selecionada)
              const Icon(Icons.check_circle, color: _verde, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _botaoSalvarModal({required VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _verde,
        foregroundColor: Colors.white,
        disabledBackgroundColor: _verde.withValues(alpha: 0.6),
        disabledForegroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: const Text(
        'Salvar',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ─── Barra de navegação inferior ─────────────────────────────────────────

  // ignore: unused_element
  Widget _barraNavegacao() {
    return BottomNavigationBar(
      currentIndex: _abaSelecionada,
      onTap: (indice) => setState(() => _abaSelecionada = indice),
      selectedItemColor: _verde,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Início',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Histórico'),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          label: 'Sugestões',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          label: 'Compras',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Perfil',
        ),
      ],
    );
  }

  // ─── Helpers de layout ────────────────────────────────────────────────────

  // Item de menu com seta de navegação
  Widget _itemMenu({
    required IconData icone,
    required Color corIcone,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: _circuloIcone(icone, corIcone),
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitulo, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  // Item de menu com Switch
  Widget _itemMenuSwitch({
    required IconData icone,
    required Color corIcone,
    required String titulo,
    required String subtitulo,
    required bool valor,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: _circuloIcone(icone, corIcone),
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitulo, style: const TextStyle(fontSize: 12)),
      trailing: Switch(
        value: valor,
        onChanged: onChanged,
        activeThumbColor: _verde,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  // Ícone dentro de um círculo colorido translúcido
  Widget _circuloIcone(IconData icone, Color cor) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icone, color: cor, size: 20),
    );
  }

  BoxDecoration _decoracaoCard() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Formata um número removendo casas decimais quando for inteiro.
  String _fmtNum(num valor) {
    if (valor == valor.roundToDouble()) {
      return valor.toInt().toString();
    }
    return valor.toString();
  }

  // Converte texto do campo em número, caindo no [padrao] se inválido/vazio.
  num _paraNum(String texto, num padrao) {
    final limpo = texto.trim().replaceAll(',', '.');
    if (limpo.isEmpty) {
      return padrao;
    }
    return num.tryParse(limpo) ?? padrao;
  }
}
