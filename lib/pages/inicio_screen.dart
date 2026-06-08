import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutriday/app_routes.dart';
import 'package:nutriday/models/user_profile.dart';
import 'package:nutriday/widgets/app_bottom_navigation_bar.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: user == null
              ? null
              : FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(user.uid)
                    .snapshots(),
          builder: (context, snapshot) {
            final profileData = snapshot.data?.data();
            final profile = profileData == null
                ? UserProfile.guest(email: user?.email ?? '')
                : UserProfile.fromMap(profileData);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildLunchBanner(),
                  const SizedBox(height: 20),
                  _buildDailySummary(profile),
                  const SizedBox(height: 16),
                  _buildMacros(profile),
                  const SizedBox(height: 16),
                  _buildWaterIntake(profile),
                  const SizedBox(height: 20),
                  _buildRegisterButton(context),
                  const SizedBox(height: 24),
                  _buildTodayMeals(),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildHeader() {
    final username = UserProfile.usernameFromEmail(
      FirebaseAuth.instance.currentUser?.email,
    );
    final greetingName = username.isEmpty ? '' : '$username ';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Boa tarde $greetingName',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const Text('\u{1F33F}', style: TextStyle(fontSize: 20)),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              'Resumo nutricional de hoje',
              style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
            ),
          ],
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFFDDEEDD),
          child: ClipOval(
            child: Container(
              width: 44,
              height: 44,
              color: const Color(0xFFB0C4B1),
              child: const Icon(Icons.person, color: Colors.white, size: 28),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLunchBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Text('\u{1F957}', style: TextStyle(fontSize: 18)),
          SizedBox(width: 8),
          Text(
            'Hora do almoco - mantenha o equilibrio!',
            style: TextStyle(
              color: Color(0xFF2E7D32),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySummary(UserProfile profile) {
    const consumedCalories = 1050;
    final calorieGoal = profile.calorieGoal <= 0 ? 2000 : profile.calorieGoal;
    final progress = (consumedCalories / calorieGoal).clamp(0.0, 1.0);
    final percentage = (progress * 100).round();
    final remaining = (calorieGoal - consumedCalories).clamp(0, calorieGoal);

    return Container(
      width: double.infinity,
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
            'Resumo do dia',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Calorias consumidas',
            style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '$consumedCalories',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 4),
                child: Text(
                  '/ $calorieGoal',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF888888),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF4CAF50),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$percentage% da meta diaria',
                style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9C4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$remaining kcal restantes',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFF57F17),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Gasto diario estimado: ${profile.dailyEnergyExpenditure} kcal',
            style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
          ),
        ],
      ),
    );
  }

  Widget _buildMacros(UserProfile profile) {
    return Row(
      children: [
        _macroCard(
          '\u{1F969}',
          'Proteina',
          '${profile.proteinGoalGrams}g',
          const Color(0xFFFFEBEE),
          const Color(0xFFE53935),
        ),
        const SizedBox(width: 10),
        _macroCard(
          '\u{1F33E}',
          'Carbo',
          '${profile.carbGoalGrams}g',
          const Color(0xFFFFFDE7),
          const Color(0xFFFFA000),
        ),
        const SizedBox(width: 10),
        _macroCard(
          '\u{1F9C8}',
          'Gordura',
          '${profile.fatGoalGrams}g',
          const Color(0xFFFFEBEE),
          const Color(0xFFE53935),
        ),
      ],
    );
  }

  Widget _macroCard(
    String emoji,
    String label,
    String value,
    Color bg,
    Color accent,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border(top: BorderSide(color: accent, width: 3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterIntake(UserProfile profile) {
    final waterGoal = profile.waterGoalCups;
    final waterConsumed = waterGoal < 6 ? waterGoal : 6;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('\u{1F4A7}', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'Consumo de agua',
                style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$waterConsumed / $waterGoal copos',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            child: LinearProgressIndicator(
              value: waterConsumed / waterGoal,
              minHeight: 8,
              backgroundColor: const Color(0xFFE3F2FD),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF1E88E5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.registrarRefeicao);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: const Text(
          '+ Registrar refeicao',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildTodayMeals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Refeicoes de Hoje',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        _mealItem(
          '\u2615',
          'Cafe da Manha',
          '08:30',
          'Ovos, pao integral, cafe',
          350,
        ),
      ],
    );
  }

  Widget _mealItem(
    String emoji,
    String name,
    String time,
    String description,
    int kcal,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
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
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$kcal kcal',
            style: const TextStyle(
              color: Color(0xFF4CAF50),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
