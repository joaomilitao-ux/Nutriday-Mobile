import 'package:flutter/material.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  bool _isDayView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildViewToggle(),
                    const SizedBox(height: 16),
                    _buildDateNavigator(),
                    const SizedBox(height: 16),
                    _buildDaySummaryCard(),
                    const SizedBox(height: 16),
                    _buildMealSection(
                      title: 'Café da Manhã',
                      time: '08:30',
                      totalKcal: 350,
                      items: const [
                        _FoodItem('Ovos mexidos', 180),
                        _FoodItem('Pão integral', 120),
                        _FoodItem('Café com leite', 50),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildMealSection(
                      title: 'Almoço',
                      time: '12:45',
                      totalKcal: 520,
                      items: const [
                        _FoodItem('Frango grelhado', 250),
                        _FoodItem('Arroz integral', 200),
                        _FoodItem('Feijão', 70),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildMealSection(
                      title: 'Lanche',
                      time: '16:00',
                      totalKcal: 180,
                      items: const [
                        _FoodItem('Iogurte grego', 120),
                        _FoodItem('Banana', 60),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Histórico',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.calendar_today_outlined,
            color: Color(0xFF4CAF50),
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildViewToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _toggleButton('Dia', _isDayView, () => setState(() => _isDayView = true)),
          _toggleButton('Semana', !_isDayView, () => setState(() => _isDayView = false)),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected
                ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 1))]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected ? const Color(0xFF1A1A1A) : const Color(0xFF888888),
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateNavigator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.chevron_left, color: Color(0xFF888888), size: 20),
            ),
          ),
          Column(
            children: const [
              Text(
                '30 de Março, 2026',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Segunda-feira',
                style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.chevron_right, color: Color(0xFF888888), size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo do Dia',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _summaryMacro('1050', 'Calorias', const Color(0xFF4CAF50)),
              _summaryDivider(),
              _summaryMacro('68g', 'Proteínas', const Color(0xFFE53935)),
              _summaryDivider(),
              _summaryMacro('95g', 'Carboidratos', const Color(0xFF1E88E5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryMacro(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _summaryDivider() {
    return Container(width: 1, height: 40, color: const Color(0xFFEEEEEE));
  }

  Widget _buildMealSection({
    required String title,
    required String time,
    required int totalKcal,
    required List<_FoodItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                    ),
                  ],
                ),
                Text(
                  '$totalKcal kcal',
                  style: const TextStyle(
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          ...items.map((item) => _buildFoodRow(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildFoodRow(_FoodItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.name,
            style: const TextStyle(fontSize: 14, color: Color(0xFF444444)),
          ),
          Text(
            '${item.kcal} kcal',
            style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
          ),
        ],
      ),
    );
  }
}

class _FoodItem {
  final String name;
  final int kcal;
  const _FoodItem(this.name, this.kcal);
}
