import 'package:flutter/material.dart';
import 'package:nutriday/widgets/app_bottom_navigation_bar.dart';

// ─── Modelos de dados ─────────────────────────────────────────────────────────

class ItemCompra {
  String nome;
  bool marcado;

  ItemCompra({required this.nome, this.marcado = false});
}

class CategoriaCompra {
  final String nome;
  final List<ItemCompra> itens;

  CategoriaCompra({required this.nome, required this.itens});
}

// ─── Tela ─────────────────────────────────────────────────────────────────────

class ComprasScreen extends StatefulWidget {
  const ComprasScreen({super.key});

  @override
  State<ComprasScreen> createState() => _ComprasScreenState();
}

class _ComprasScreenState extends State<ComprasScreen> {
  final _adicionarController = TextEditingController();
  int _abaSelecionada = 3;

  static const Color _verde = Color(0xFF4CAF50);

  // Lista de categorias com seus itens pré-definidos
  final List<CategoriaCompra> _categorias = [
    CategoriaCompra(
      nome: 'Proteínas',
      itens: [
        ItemCompra(nome: 'Peito de frango'),
        ItemCompra(nome: 'Ovos'),
        ItemCompra(nome: 'Salmão'),
      ],
    ),
    CategoriaCompra(
      nome: 'Carboidratos',
      itens: [
        ItemCompra(nome: 'Arroz integral'),
        ItemCompra(nome: 'Batata doce'),
        ItemCompra(nome: 'Aveia'),
      ],
    ),
    CategoriaCompra(
      nome: 'Vegetais',
      itens: [
        ItemCompra(nome: 'Brócolis'),
        ItemCompra(nome: 'Espinafre'),
        ItemCompra(nome: 'Cenoura'),
        ItemCompra(nome: 'Alface', marcado: true),
      ],
    ),
  ];

  // Contadores dinâmicos para o cabeçalho
  int get _totalItens =>
      _categorias.fold(0, (soma, cat) => soma + cat.itens.length);

  int get _itensMarcados => _categorias.fold(
        0,
        (soma, cat) => soma + cat.itens.where((item) => item.marcado).length,
      );

  @override
  void dispose() {
    _adicionarController.dispose();
    super.dispose();
  }

  // ─── Adicionar item via dialog ─────────────────────────────────────────────

  void _abrirDialogAdicionar() {
    String? categoriaSelecionada = _categorias.first.nome;
    final nomeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nome do item',
                hintText: 'Ex: Frango grelhado',
              ),
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (context, setDialogState) =>
                  DropdownButtonFormField<String>(
                value: categoriaSelecionada,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: _categorias
                    .map((cat) => DropdownMenuItem(
                          value: cat.nome,
                          child: Text(cat.nome),
                        ))
                    .toList(),
                onChanged: (valor) =>
                    setDialogState(() => categoriaSelecionada = valor),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final nome = nomeController.text.trim();
              if (nome.isNotEmpty && categoriaSelecionada != null) {
                setState(() {
                  final categoria = _categorias.firstWhere(
                    (cat) => cat.nome == categoriaSelecionada,
                  );
                  categoria.itens.add(ItemCompra(nome: nome));
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _verde),
            child:
                const Text('Adicionar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── Remover item com confirmação ──────────────────────────────────────────

  void _removerItem(CategoriaCompra categoria, int indice) {
    setState(() => categoria.itens.removeAt(indice));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Tela de Compras',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _secaoCabecalho(),
          const SizedBox(height: 16),
          _campoAdicionarItem(),
          const SizedBox(height: 8),
          ..._categorias.map(_secaoCategoria),
          const SizedBox(height: 16),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 3),
    );
  }

  // ─── Cabeçalho com título e contador ──────────────────────────────────────

  Widget _secaoCabecalho() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _decoracaoCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lista de Compras',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '$_itensMarcados de $_totalItens itens marcados',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // ─── Campo para adicionar novo item ───────────────────────────────────────

  Widget _campoAdicionarItem() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _adicionarController,
            decoration: InputDecoration(
              hintText: 'Adicionar item...',
              hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _verde),
              ),
            ),
            onSubmitted: (_) => _abrirDialogAdicionar(),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _abrirDialogAdicionar,
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: _verde,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 24),
          ),
        ),
      ],
    );
  }

  // ─── Seção de uma categoria com seus itens ────────────────────────────────

  Widget _secaoCategoria(CategoriaCompra categoria) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              categoria.nome,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            decoration: _decoracaoCard(),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categoria.itens.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, indice) => _linhaItem(categoria, indice),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Linha de um item individual ──────────────────────────────────────────

  Widget _linhaItem(CategoriaCompra categoria, int indice) {
    final item = categoria.itens[indice];

    return Row(
      children: [
        // Checkbox
        Checkbox(
          value: item.marcado,
          activeColor: _verde,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (valor) => setState(() => item.marcado = valor ?? false),
        ),

        // Nome do item
        Expanded(
          child: Text(
            item.nome,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              decoration: item.marcado
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              decorationColor: Colors.black45,
            ),
          ),
        ),

        // Botão de deletar
        IconButton(
          icon:
              const Icon(Icons.delete_outline, color: Colors.black38, size: 20),
          onPressed: () => _removerItem(categoria, indice),
          tooltip: 'Remover item',
        ),
      ],
    );
  }

  // ─── Barra de navegação inferior ──────────────────────────────────────────

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
            icon: Icon(Icons.home_outlined), label: 'Início'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Histórico'),
        BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined), label: 'Sugestões'),
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined), label: 'Compras'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Perfil'),
      ],
    );
  }

  // ─── Helper de estilo ─────────────────────────────────────────────────────

  BoxDecoration _decoracaoCard() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
