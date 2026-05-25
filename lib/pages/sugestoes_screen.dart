import 'package:flutter/material.dart';
import 'package:nutriday/widgets/app_bottom_navigation_bar.dart';

// ─── Modelo de dados ──────────────────────────────────────────────────────────

class SugestaoRefeicao {
  final String emoji;
  final String nome;
  final String tipo;
  final int calorias;
  final int tempoPreparo;
  final List<String> ingredientes;

  const SugestaoRefeicao({
    required this.emoji,
    required this.nome,
    required this.tipo,
    required this.calorias,
    required this.tempoPreparo,
    required this.ingredientes,
  });
}

// ─── Tela ─────────────────────────────────────────────────────────────────────

class SugestoesScreen extends StatefulWidget {
  const SugestoesScreen({super.key});

  @override
  State<SugestoesScreen> createState() => _SugestoesScreenState();
}

class _SugestoesScreenState extends State<SugestoesScreen> {
  int _abaSelecionada = 2;

  static const Color _verde = Color(0xFF4CAF50);

  // Sugestões pré-definidas
  final List<SugestaoRefeicao> _sugestoes = const [
    SugestaoRefeicao(
      emoji: '🥞',
      nome: 'Panqueca de Aveia e Banana',
      tipo: 'Café da Manhã',
      calorias: 320,
      tempoPreparo: 10,
      ingredientes: ['Aveia', 'Banana', 'Ovos', 'Mel'],
    ),
    SugestaoRefeicao(
      emoji: '🍗',
      nome: 'Frango Grelhado com Batata Doce',
      tipo: 'Almoço',
      calorias: 450,
      tempoPreparo: 25,
      ingredientes: ['Peito de frango', 'Batata doce'],
    ),
    SugestaoRefeicao(
      emoji: '🥗',
      nome: 'Salada Caesar com Salmão',
      tipo: 'Jantar',
      calorias: 380,
      tempoPreparo: 15,
      ingredientes: ['Salmão', 'Alface romana'],
    ),
  ];

  void _adicionarRefeicao(SugestaoRefeicao sugestao) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${sugestao.nome} adicionada às refeições!'),
        backgroundColor: _verde,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Tela de Sugestões',
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
          const SizedBox(height: 20),
          ..._sugestoes.map(_cardSugestao),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 2),
    );
  }

  // ─── Cabeçalho ────────────────────────────────────────────────────────────

  Widget _secaoCabecalho() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sugestões de Refeições',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          'Receitas rápidas e saudáveis',
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
      ],
    );
  }

  // ─── Card de sugestão ─────────────────────────────────────────────────────

  Widget _cardSugestao(SugestaoRefeicao sugestao) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: _decoracaoCard(),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Linha superior: imagem + nome + tag
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _imagemRefeicao(sugestao.emoji),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome e tag na mesma linha
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              sugestao.nome,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _tagTipo(sugestao.tipo),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Calorias e tempo de preparo
                      Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            size: 16,
                            color: Colors.orangeAccent,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${sugestao.calorias} kcal',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.black38,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${sugestao.tempoPreparo} min',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Ingredientes
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                children: [
                  const TextSpan(
                    text: 'Ingredientes:\n',
                    style: TextStyle(color: Colors.black54),
                  ),
                  TextSpan(
                    text: sugestao.ingredientes.join(', '),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Botão adicionar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _adicionarRefeicao(sugestao),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _verde,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '+ Adicionar às minhas refeições',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Imagem/emoji da refeição ─────────────────────────────────────────────

  Widget _imagemRefeicao(String emoji) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 38)),
    );
  }

  // ─── Tag de tipo de refeição ──────────────────────────────────────────────

  Widget _tagTipo(String tipo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tipo,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  // ─── Barra de navegação inferior ──────────────────────────────────────────

  // ignore: unused_element
  Widget _barraNavegacao() {
    return BottomNavigationBar(
      currentIndex: _abaSelecionada,
      onTap: (indice) => setState(() => _abaSelecionada = indice),
      selectedItemColor: const Color(0xFF4CAF50),
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
      borderRadius: BorderRadius.circular(14),
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
