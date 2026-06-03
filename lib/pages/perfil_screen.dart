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

  // Índice da aba ativa na barra de navegação inferior
  int _abaSelecionada = 4;

  static const Color _verde = Color(0xFF4CAF50);

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
            subtitulo: 'Idade, peso, altura',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          _itemMenu(
            icone: Icons.track_changes_outlined,
            corIcone: const Color(0xFF42A5F5),
            titulo: 'Meu Objetivo',
            subtitulo: 'Ganhar massa muscular',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // ─── Metas diárias ────────────────────────────────────────────────────────

  Widget _secaoMetasDiarias() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _decoracaoCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metas Diárias',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _linhaMetaDiaria('Calorias', '2000 kcal'),
          _linhaMetaDiaria('Proteínas', '150g'),
          _linhaMetaDiaria('Carboidratos', '200g'),
          _linhaMetaDiaria('Gorduras', '65g'),
          _linhaMetaDiaria('Água', '8 copos', mostrarDivisor: false),
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
      trailing: Switch(value: valor, onChanged: onChanged, activeColor: _verde),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  // Ícone dentro de um círculo colorido translúcido
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
}
