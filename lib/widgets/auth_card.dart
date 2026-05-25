import 'package:flutter/material.dart';
import 'package:nutriday/theme.dart';
import 'package:nutriday/widgets/input_field.dart';

typedef AuthSubmitCallback = void Function(String email, String password);

class AuthCard extends StatefulWidget {
  final String title;
  final String buttonText;
  final bool showConfirmPassword;
  final AuthSubmitCallback? onSubmit;

  const AuthCard({
    super.key,
    required this.title,
    required this.buttonText,
    required this.showConfirmPassword,
    this.onSubmit,
  });

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    widget.onSubmit?.call(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Informe seu email';
    }

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(email)) {
      return 'Informe um email válido';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value?.trim() ?? '';

    if (password.isEmpty) {
      return 'Informe sua senha';
    }

    if (password.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final confirmPassword = value?.trim() ?? '';

    if (confirmPassword.isEmpty) {
      return 'Confirme sua senha';
    }

    if (confirmPassword != _passwordController.text.trim()) {
      return 'As senhas não coincidem';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.12),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            InputField(
              label: 'Email',
              hint: 'seu@email.com',
              obscureText: false,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),
            InputField(
              label: 'Senha',
              hint: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
              obscureText: true,
              controller: _passwordController,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: widget.showConfirmPassword
                  ? TextInputAction.next
                  : TextInputAction.done,
              validator: _validatePassword,
            ),
            if (widget.showConfirmPassword) ...[
              const SizedBox(height: 16),
              InputField(
                label: 'Confirmar Senha',
                hint: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
                obscureText: true,
                controller: _confirmPasswordController,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                validator: _validateConfirmPassword,
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              onPressed: _handleSubmit,
              child: Text(
                widget.buttonText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
