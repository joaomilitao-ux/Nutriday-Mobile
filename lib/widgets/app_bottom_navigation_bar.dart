import 'package:flutter/material.dart';
import 'package:nutriday/app_routes.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
  });

  void _handleTap(BuildContext context, int index) {
    if (index == currentIndex) {
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.bottomNavRoutes[index],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _handleTap(context, index),
      selectedItemColor: const Color(0xFF4CAF50),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'In\u00edcio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Hist\u00f3rico',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          label: 'Sugest\u00f5es',
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
}
