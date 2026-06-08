import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutriday/services/refeicao_service.dart';

class RegistrarRefeicaoScreen extends StatefulWidget {
  const RegistrarRefeicaoScreen({super.key});

  @override
  State<RegistrarRefeicaoScreen> createState() =>
      _RegistrarRefeicaoScreenState();
}

class _RegistrarRefeicaoScreenState extends State<RegistrarRefeicaoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores dos campos de texto
  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _caloriasController = TextEditingController();
  final _proteinasController = TextEditingController();
  final _carboidratosController = TextEditingController();
  final _gordurasController = TextEditingController();

  // Valor selecionado no dropdown
  String? _tipoRefeicao;

  // Serviço de persistência da refeição no Firestore
  final _refeicaoService = RefeicaoService();

  // Estado de carregamento para evitar múltiplos cliques no botão salvar
  bool _salvando = false;

  static const Color _verde = Color(0xFF4CAF50);

  static const List<String> _tiposRefeicao = [
    'Café da manhã',
    'Lanche da manhã',
    'Almoço',
    'Lanche da tarde',
    'Jantar',
    'Ceia',
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    _caloriasController.dispose();
    _proteinasController.dispose();
    _carboidratosController.dispose();
    _gordurasController.dispose();
    super.dispose();
  }

  Future<void> _salvarRefeicao() async {
    // Evita salvamentos duplicados enquanto uma escrita está em andamento
    if (_salvando) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _salvando = true);

    try {
      await _refeicaoService.salvarRefeicao(
        nomeAlimento: _nomeController.text,
        quantidade: _quantidadeController.text,
        tipoRefeicao: _tipoRefeicao!,
        calorias: _caloriasController.text,
        proteinas: _proteinasController.text,
        carboidratos: _carboidratosController.text,
        gorduras: _gordurasController.text,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Refeição salva com sucesso!'),
          backgroundColor: _verde,
        ),
      );

      // Limpa o formulário após salvar com sucesso
      _formKey.currentState!.reset();
      _nomeController.clear();
      _quantidadeController.clear();
      _caloriasController.clear();
      _proteinasController.clear();
      _carboidratosController.clear();
      _gordurasController.clear();
      setState(() => _tipoRefeicao = null);
    } on UsuarioNaoLogadoException {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa estar logado para salvar uma refeição.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar a refeição. Tente novamente.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Registrar Refeição',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            _campoNomeAlimento(),
            const SizedBox(height: 16),
            _campoQuantidade(),
            const SizedBox(height: 16),
            _campoTipoRefeicao(),
            const SizedBox(height: 20),
            _cardInformacoesNutricionais(),
            const SizedBox(height: 24),
            _botaoSalvar(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─── Campo: Nome do Alimento ──────────────────────────────────────────────

  Widget _campoNomeAlimento() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelCampo('Nome do Alimento'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _nomeController,
          decoration: _decoracaoCampo('Ex: Peito de frango'),
          validator: (valor) =>
              (valor == null || valor.isEmpty) ? 'Informe o nome do alimento' : null,
        ),
      ],
    );
  }

  // ─── Campo: Quantidade ────────────────────────────────────────────────────

  Widget _campoQuantidade() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelCampo('Quantidade'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _quantidadeController,
          decoration: _decoracaoCampo('Ex: 150g ou 1 unidade'),
          validator: (valor) =>
              (valor == null || valor.isEmpty) ? 'Informe a quantidade' : null,
        ),
      ],
    );
  }

  // ─── Campo: Tipo de Refeição (Dropdown) ───────────────────────────────────

  Widget _campoTipoRefeicao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelCampo('Tipo de Refeição'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _tipoRefeicao,
          hint: const Text(
            'Selecione o tipo',
            style: TextStyle(color: Colors.black38, fontSize: 14),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black45),
          decoration: _decoracaoCampo(null),
          items: _tiposRefeicao
              .map(
                (tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)),
              )
              .toList(),
          onChanged: (valor) => setState(() => _tipoRefeicao = valor),
          validator: (valor) =>
              (valor == null) ? 'Selecione o tipo de refeição' : null,
        ),
      ],
    );
  }

  // ─── Card: Informações Nutricionais ───────────────────────────────────────

  Widget _cardInformacoesNutricionais() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _decoracaoCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informações Nutricionais\n(opcional)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Grid 2 colunas: Calorias | Proteínas
          Row(
            children: [
              Expanded(child: _campoPequeno('Calorias', 'kcal', _caloriasController)),
              const SizedBox(width: 12),
              Expanded(child: _campoPequeno('Proteínas', 'g', _proteinasController)),
            ],
          ),
          const SizedBox(height: 16),

          // Grid 2 colunas: Carboidratos | Gorduras
          Row(
            children: [
              Expanded(child: _campoPequeno('Carboidratos', 'g', _carboidratosController)),
              const SizedBox(width: 12),
              Expanded(child: _campoPequeno('Gorduras', 'g', _gordurasController)),
            ],
          ),
        ],
      ),
    );
  }

  // Campo numérico menor usado dentro do card nutricional
  Widget _campoPequeno(
    String label,
    String sufixo,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
          decoration: _decoracaoCampo(sufixo),
        ),
      ],
    );
  }

  // ─── Botão Salvar ─────────────────────────────────────────────────────────

  Widget _botaoSalvar() {
    return ElevatedButton(
      onPressed: _salvando ? null : _salvarRefeicao,
      style: ElevatedButton.styleFrom(
        backgroundColor: _verde,
        foregroundColor: Colors.white,
        disabledBackgroundColor: _verde.withValues(alpha: 0.6),
        disabledForegroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
      child: _salvando
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Salvar Refeição',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
    );
  }

  // ─── Helpers de estilo ────────────────────────────────────────────────────

  Widget _labelCampo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _decoracaoCampo(String? hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _verde),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
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
}
