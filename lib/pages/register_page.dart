import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutriday/app_routes.dart';
import 'package:nutriday/models/user_profile.dart';
import 'package:nutriday/theme.dart';
import 'package:nutriday/widgets/input_field.dart';
import 'package:nutriday/widgets/nutriday_header.dart';

const String _allowedDomain = '@souunit.com.br';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _submitted = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registerWithEmailAndPassword() async {
    setState(() {
      _submitted = true;
    });

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    await _runAuthAction(() async {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      final user = await _ensureAuthorizedUser(
        credential,
        deleteUnauthorizedUser: true,
      );
      await _tryPersistRegisteredUser(user, provider: 'password');

      if (!mounted) {
        return;
      }

      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    });
  }

  Future<void> _runAuthAction(Future<void> Function() action) async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      await action();
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'FirebaseAuth cadastro: code=${error.code}, message=${error.message}',
      );
      _showMessage(_mapFirebaseAuthError(error));
    } on _InstitutionalDomainException catch (error) {
      _showMessage(error.message);
    } on _AuthFlowException catch (error) {
      _showMessage(error.message);
    } on FirebaseException catch (error) {
      debugPrint(
        'Firebase cadastro flow: plugin=${error.plugin}, code=${error.code}, message=${error.message}',
      );
      _showMessage(_mapFirebaseServiceError(error));
    } catch (error, stackTrace) {
      debugPrint('Cadastro inesperado: $error');
      debugPrintStack(stackTrace: stackTrace);
      _showMessage('Nao foi possivel concluir o cadastro agora.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<User> _ensureAuthorizedUser(
    UserCredential credential, {
    bool deleteUnauthorizedUser = false,
  }) async {
    final user = credential.user;
    final email = user?.email?.trim().toLowerCase();

    // Regra de seguranca: valida o e-mail retornado pelo Firebase, nao so o input.
    if (user == null || !_isInstitutionalEmail(email)) {
      if (deleteUnauthorizedUser && user != null) {
        await user.delete().catchError((_) {});
      }
      await _signOutUnauthorizedUser();
      throw const _InstitutionalDomainException(
        'Acesso negado. Use uma conta @souunit.com.br.',
      );
    }

    return user;
  }

  Future<void> _tryPersistRegisteredUser(
    User user, {
    required String provider,
  }) async {
    try {
      await _persistRegisteredUser(user, provider: provider);
    } on FirebaseException catch (error) {
      debugPrint(
        'Firestore cadastro sync: plugin=${error.plugin}, code=${error.code}, message=${error.message}',
      );
    }
  }

  Future<void> _persistRegisteredUser(
    User user, {
    required String provider,
  }) async {
    final email = user.email?.trim().toLowerCase();
    if (email == null || email.isEmpty) {
      throw const _AuthFlowException('Usuario autenticado sem e-mail valido.');
    }

    final username = UserProfile.usernameFromEmail(email);

    await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set({
      'uid': user.uid,
      'email': email,
      'usuario_logado': username,
      'criado_por': email,
      'provedor': provider,
      'criado_em': FieldValue.serverTimestamp(),
      'ultimo_login_em': FieldValue.serverTimestamp(),
      'atualizado_em': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _signOutUnauthorizedUser() async {
    await FirebaseAuth.instance.signOut();
  }

  bool _isInstitutionalEmail(String? email) {
    final normalized = email?.trim().toLowerCase() ?? '';
    return normalized.endsWith(_allowedDomain);
  }

  String? _validateEmail(String? value) {
    final email = value?.trim().toLowerCase() ?? '';
    if (email.isEmpty) {
      return 'Informe seu e-mail.';
    }

    const emailPattern = r'^[^\s@]+@[^\s@]+\.[^\s@]+$';
    if (!RegExp(emailPattern).hasMatch(email)) {
      return 'Informe um e-mail valido.';
    }

    if (!_isInstitutionalEmail(email)) {
      return 'Use seu e-mail institucional @souunit.com.br.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Informe sua senha.';
    }

    if (password.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final confirmPassword = value ?? '';
    if (confirmPassword.isEmpty) {
      return 'Confirme sua senha.';
    }

    if (confirmPassword != _passwordController.text) {
      return 'As senhas nao coincidem.';
    }

    return null;
  }

  String _mapFirebaseAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'Ja existe uma conta cadastrada com este e-mail.';
      case 'invalid-email':
        return 'O e-mail informado e invalido.';
      case 'weak-password':
        return 'A senha e muito fraca. Use pelo menos 6 caracteres.';
      case 'network-request-failed':
        return 'Falha de conexao. Verifique sua internet.';
      case 'operation-not-allowed':
        return 'O cadastro com e-mail e senha ainda nao foi habilitado no Firebase.';
      case 'admin-restricted-operation':
        return 'O Firebase esta bloqueando cadastro publico. Habilite criacao de usuarios por e-mail/senha.';
      case 'invalid-api-key':
      case 'api-key-not-valid':
        return 'A chave de API do Firebase esta invalida para este app.';
      case 'app-not-authorized':
        return 'Este app nao esta autorizado a usar o Firebase Authentication.';
      case 'unauthorized-domain':
        return 'Este dominio nao esta autorizado no Firebase Authentication.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde um momento e tente novamente.';
      case 'account-exists-with-different-credential':
        return 'Ja existe uma conta com este e-mail usando outro provedor.';
      default:
        return error.message ?? 'Nao foi possivel concluir o cadastro.';
    }
  }

  String _mapFirebaseServiceError(FirebaseException error) {
    if (error.plugin == 'cloud_firestore') {
      switch (error.code) {
        case 'permission-denied':
          return 'Cadastro feito, mas o Firestore bloqueou o registro dos dados. Revise as regras da colecao usuarios.';
        case 'unavailable':
          return 'Cadastro feito, mas o Firestore esta indisponivel agora.';
        default:
          return 'Cadastro feito, mas nao foi possivel sincronizar seus dados agora.';
      }
    }

    return error.message ?? 'Nao foi possivel concluir o cadastro.';
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const NutriDayHeader(),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
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
                    autovalidateMode: _submitted
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Cadastro',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Crie sua conta com seu e-mail institucional.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        InputField(
                          label: 'Email',
                          hint: 'seuusuario@souunit.com.br',
                          obscureText: false,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 16),
                        InputField(
                          label: 'Senha',
                          hint: '********',
                          obscureText: true,
                          controller: _passwordController,
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 16),
                        InputField(
                          label: 'Confirmar Senha',
                          hint: '********',
                          obscureText: true,
                          controller: _confirmPasswordController,
                          validator: _validateConfirmPassword,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : _registerWithEmailAndPassword,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Criar conta',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  child: const Text('Ja tem uma conta? Entrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InstitutionalDomainException implements Exception {
  const _InstitutionalDomainException(this.message);

  final String message;
}

class _AuthFlowException implements Exception {
  const _AuthFlowException(this.message);

  final String message;
}
