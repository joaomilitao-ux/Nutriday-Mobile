import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutriday/app_routes.dart';
import 'package:nutriday/app_session.dart';
import 'package:nutriday/models/user_profile.dart';
import 'package:nutriday/widgets/app_bottom_navigation_bar.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _notificacoesAtivas = true;

  static const Color _verde = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        centerTitle: false,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
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

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              _secaoPerfil(profile),
              const SizedBox(height: 16),
              _secaoDadosPessoais(profile),
              const SizedBox(height: 16),
              _secaoMetasDiarias(profile),
              const SizedBox(height: 16),
              _secaoConfiguracoes(),
              const SizedBox(height: 24),
              _botaoSairDaConta(),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 4),
    );
  }

  Widget _secaoPerfil(UserProfile profile) {
    final email = FirebaseAuth.instance.currentUser?.email?.trim() ?? '';
    final username = UserProfile.usernameFromEmail(email);
    final displayName = username.isEmpty ? profile.displayName : username;
    final displayEmail = email.isEmpty ? profile.email : email;

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
          Expanded(
            child: Column(
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
                  displayEmail.isEmpty ? 'E-mail nao informado' : displayEmail,
                  style: const TextStyle(fontSize: 14, color: _verde),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _secaoDadosPessoais(UserProfile profile) {
    return Container(
      decoration: _decoracaoCard(),
      child: Column(
        children: [
          _itemMenu(
            icone: Icons.person_outline,
            corIcone: _verde,
            titulo: 'Dados pessoais',
            subtitulo: profile.personalSummary,
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          _itemMenu(
            icone: Icons.track_changes_outlined,
            corIcone: const Color(0xFF42A5F5),
            titulo: 'Meu objetivo',
            subtitulo: _labelForGoal(profile.goal),
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          _itemMenu(
            icone: Icons.monitor_heart_outlined,
            corIcone: const Color(0xFFFFA726),
            titulo: 'Nivel de atividade',
            subtitulo: _labelForActivity(profile.activityLevel),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _secaoMetasDiarias(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _decoracaoCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metas diarias',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _linhaMetaDiaria(
            'Gasto diario',
            '${profile.dailyEnergyExpenditure} kcal',
          ),
          _linhaMetaDiaria('Meta de calorias', '${profile.calorieGoal} kcal'),
          _linhaMetaDiaria(
            'Taxa basal',
            profile.basalMetabolicRate <= 0
                ? 'Nao calculada'
                : '${profile.basalMetabolicRate} kcal',
          ),
          _linhaMetaDiaria('Proteinas', '${profile.proteinGoalGrams}g'),
          _linhaMetaDiaria('Carboidratos', '${profile.carbGoalGrams}g'),
          _linhaMetaDiaria('Gorduras', '${profile.fatGoalGrams}g'),
          _linhaMetaDiaria(
            'Agua',
            '${profile.waterGoalCups} copos',
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
              Flexible(
                child: Text(
                  valor,
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        if (mostrarDivisor) const Divider(height: 1),
      ],
    );
  }

  Widget _secaoConfiguracoes() {
    return Container(
      decoration: _decoracaoCard(),
      child: Column(
        children: [
          _itemMenuSwitch(
            icone: Icons.notifications_outlined,
            corIcone: const Color(0xFFAB47BC),
            titulo: 'Notificacoes',
            subtitulo: 'Lembretes de refeicoes',
            valor: _notificacoesAtivas,
            onChanged: (valor) => setState(() => _notificacoesAtivas = valor),
          ),
          const Divider(height: 1, indent: 56),
          _itemMenu(
            icone: Icons.help_outline,
            corIcone: const Color(0xFFFFA726),
            titulo: 'Ajuda e suporte',
            subtitulo: 'FAQ e contato',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _botaoSairDaConta() {
    return OutlinedButton.icon(
      onPressed: () async {
        AppSession.clear();
        await FirebaseAuth.instance.signOut();

        if (!mounted) {
          return;
        }

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      },
      icon: const Icon(Icons.logout, color: Colors.redAccent),
      label: const Text(
        'Sair da conta',
        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.redAccent),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

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
      trailing: Switch(value: valor, onChanged: onChanged, activeColor: _verde),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _circuloIcone(IconData icone, Color cor) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: cor.withOpacity(0.12),
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
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  String _labelForGoal(String goal) {
    switch (goal) {
      case 'emagrecer':
        return 'Emagrecer';
      case 'ganhar_massa':
        return 'Ganhar massa muscular';
      case 'manter_peso':
        return 'Manter peso';
      default:
        return goal;
    }
  }

  String _labelForActivity(String activityLevel) {
    switch (activityLevel) {
      case 'sedentario':
        return 'Sedentario';
      case 'moderado':
        return 'Moderado';
      case 'ativo':
        return 'Ativo';
      default:
        return activityLevel;
    }
  }
}
