import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutriday/app_routes.dart';
import 'package:nutriday/models/user_profile.dart';
import 'package:nutriday/theme.dart';

class OnboardingQuestionsPage extends StatefulWidget {
  const OnboardingQuestionsPage({super.key});

  @override
  State<OnboardingQuestionsPage> createState() =>
      _OnboardingQuestionsPageState();
}

class _OnboardingQuestionsPageState extends State<OnboardingQuestionsPage> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  int _currentStep = 0;
  String? _selectedGoal;
  String? _selectedGender;
  String? _selectedActivityLevel;
  bool _isSaving = false;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_currentStep == 0) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _currentStep -= 1;
    });
  }

  Future<void> _goForward() async {
    if (!_isCurrentStepValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_validationMessageForCurrentStep()),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_currentStep == 3) {
      await _saveProfileAndFinish();
      return;
    }

    setState(() {
      _currentStep += 1;
    });
  }

  bool _isCurrentStepValid() {
    switch (_currentStep) {
      case 0:
        return _selectedGoal != null;
      case 1:
        return _parseDouble(_weightController.text) != null &&
            _parseDouble(_heightController.text) != null;
      case 2:
        return _parseInt(_ageController.text) != null &&
            _selectedGender != null;
      case 3:
        return _selectedActivityLevel != null;
      default:
        return false;
    }
  }

  String _validationMessageForCurrentStep() {
    switch (_currentStep) {
      case 0:
        return 'Selecione seu objetivo para continuar.';
      case 1:
        return 'Preencha peso e altura com numeros validos para continuar.';
      case 2:
        return 'Informe uma idade valida e o sexo para continuar.';
      case 3:
        return 'Selecione seu n\u00EDvel de atividade para continuar.';
      default:
        return 'Revise as informa\u00E7\u00F5es para continuar.';
    }
  }

  Future<void> _saveProfileAndFinish() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email?.trim().toLowerCase();

    if (user == null || email == null || email.isEmpty) {
      _showMessage('Entre na sua conta antes de concluir o cadastro.');
      return;
    }

    final weight = _parseDouble(_weightController.text);
    final height = _parseDouble(_heightController.text);
    final age = _parseInt(_ageController.text);
    final goal = _selectedGoal;
    final gender = _selectedGender;
    final activityLevel = _selectedActivityLevel;

    if (weight == null ||
        height == null ||
        age == null ||
        goal == null ||
        gender == null ||
        activityLevel == null) {
      _showMessage('Revise as informacoes antes de continuar.');
      return;
    }

    final targets = UserProfile.calculateNutritionTargets(
      goal: goal,
      age: age,
      weightKg: weight,
      heightCm: height,
      gender: gender,
      activityLevel: activityLevel,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .set({
            'uid': user.uid,
            'usuario_uid': user.uid,
            'email': email,
            'usuario_logado': UserProfile.usernameFromEmail(email),
            'criado_por': email,
            'objetivo': goal,
            'peso_kg': weight,
            'altura_cm': height,
            'idade': age,
            'sexo': gender,
            'nivel_atividade': activityLevel,
            'taxa_metabolica_basal_kcal': targets.basalMetabolicRate,
            'gasto_calorico_diario_kcal': targets.dailyEnergyExpenditure,
            'meta_calorias_diarias_kcal': targets.calorieGoal,
            'onboarding_concluido': true,
            'atualizado_em': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (!mounted) {
        return;
      }

      await _showCompletionDialog(targets);
    } on FirebaseException catch (error) {
      debugPrint(
        'Firestore onboarding: plugin=${error.plugin}, code=${error.code}, message=${error.message}',
      );
      _showMessage(_mapFirebaseError(error));
    } catch (error, stackTrace) {
      debugPrint('Onboarding inesperado: $error');
      debugPrintStack(stackTrace: stackTrace);
      _showMessage('Nao foi possivel salvar suas informacoes agora.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _showCompletionDialog(NutritionTargets targets) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cadastro concluido'),
          content: Text(
            'Dados salvos. Gasto diario estimado: ${targets.dailyEnergyExpenditure} kcal. Meta diaria: ${targets.calorieGoal} kcal.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.inicio, (route) => false);
  }

  String _mapFirebaseError(FirebaseException error) {
    if (error.code == 'permission-denied') {
      return 'O Firestore bloqueou o salvamento. Revise as regras da colecao usuarios.';
    }
    if (error.code == 'unavailable') {
      return 'Firestore indisponivel agora. Tente novamente em instantes.';
    }
    return 'Nao foi possivel salvar suas informacoes agora.';
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  double? _parseDouble(String input) {
    final value = double.tryParse(input.trim().replaceAll(',', '.'));
    if (value == null || value <= 0) {
      return null;
    }
    return value;
  }

  int? _parseInt(String input) {
    final value = int.tryParse(input.trim());
    if (value == null || value <= 0) {
      return null;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_currentStep + 1) / 4;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_currentStep > 0) ...[
                        _RoundIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: _goBack,
                        ),
                        const SizedBox(height: 18),
                      ] else
                        const SizedBox(height: 58),
                      Row(
                        children: [
                          Text(
                            'Etapa ${_currentStep + 1} de 4',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${(progress * 100).round()}%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _ProgressBar(progress: progress),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _buildStepContent(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _goForward,
                      child: _isSaving
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
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Continuar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _StepBody(
          key: const ValueKey('goal-step'),
          icon: Icons.track_changes_rounded,
          title: 'Qual seu objetivo?',
          subtitle: 'Vamos personalizar sua experi\u00EAncia',
          child: Column(
            children: [
              _SelectionCard(
                title: 'Emagrecer',
                subtitle: 'Perder peso de forma saud\u00E1vel',
                leading: '🎯',
                selected: _selectedGoal == 'emagrecer',
                onTap: () {
                  setState(() {
                    _selectedGoal = 'emagrecer';
                  });
                },
              ),
              const SizedBox(height: 14),
              _SelectionCard(
                title: 'Ganhar massa',
                subtitle: 'Ganhar massa muscular',
                leading: '💪',
                selected: _selectedGoal == 'ganhar_massa',
                onTap: () {
                  setState(() {
                    _selectedGoal = 'ganhar_massa';
                  });
                },
              ),
              const SizedBox(height: 14),
              _SelectionCard(
                title: 'Manter peso',
                subtitle: 'Manter o peso atual',
                leading: '⚖️',
                selected: _selectedGoal == 'manter_peso',
                onTap: () {
                  setState(() {
                    _selectedGoal = 'manter_peso';
                  });
                },
              ),
            ],
          ),
        );
      case 1:
        return _StepBody(
          key: const ValueKey('physical-step'),
          icon: Icons.monitor_weight_outlined,
          title: 'Dados f\u00EDsicos',
          subtitle: 'Precisamos calcular suas necessidades',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _QuestionInput(
                label: 'Peso atual (kg)',
                hint: 'Ex: 70',
                controller: _weightController,
              ),
              const SizedBox(height: 14),
              _QuestionInput(
                label: 'Altura (cm)',
                hint: 'Ex: 170',
                controller: _heightController,
              ),
            ],
          ),
        );
      case 2:
        return _StepBody(
          key: const ValueKey('personal-step'),
          icon: Icons.person_outline_rounded,
          title: 'Informa\u00E7\u00F5es pessoais',
          subtitle: 'Quase l\u00E1!',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _QuestionInput(
                label: 'Idade',
                hint: 'Ex: 28',
                controller: _ageController,
              ),
              const SizedBox(height: 14),
              const Text(
                'Sexo',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ChoicePill(
                      label: 'Masculino',
                      selected: _selectedGender == 'masculino',
                      onTap: () {
                        setState(() {
                          _selectedGender = 'masculino';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ChoicePill(
                      label: 'Feminino',
                      selected: _selectedGender == 'feminino',
                      onTap: () {
                        setState(() {
                          _selectedGender = 'feminino';
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      case 3:
        return _StepBody(
          key: const ValueKey('activity-step'),
          icon: Icons.monitor_heart_outlined,
          title: 'N\u00EDvel de atividade',
          subtitle: '\u00DAltima pergunta!',
          child: Column(
            children: [
              _SelectionCard(
                title: 'Sedent\u00E1rio',
                subtitle: 'Pouca ou nenhuma atividade f\u00EDsica',
                leading: '🪑',
                selected: _selectedActivityLevel == 'sedentario',
                onTap: () {
                  setState(() {
                    _selectedActivityLevel = 'sedentario';
                  });
                },
              ),
              const SizedBox(height: 14),
              _SelectionCard(
                title: 'Moderado',
                subtitle: 'Exerc\u00EDcio 3-5 vezes por semana',
                leading: '🏃',
                selected: _selectedActivityLevel == 'moderado',
                onTap: () {
                  setState(() {
                    _selectedActivityLevel = 'moderado';
                  });
                },
              ),
              const SizedBox(height: 14),
              _SelectionCard(
                title: 'Ativo',
                subtitle: 'Exerc\u00EDcio intenso 6-7 vezes por semana',
                leading: '🏋️',
                selected: _selectedActivityLevel == 'ativo',
                onTap: () {
                  setState(() {
                    _selectedActivityLevel = 'ativo';
                  });
                },
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _StepBody extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _StepBody({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: Color(0xFFE9FCEF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primary, size: 28),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 28),
        child,
      ],
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String leading;
  final bool selected;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF0FDF4) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppTheme.primary : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Text(leading, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionInput extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  const _QuestionInput({
    required this.label,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.textSecondary),
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppTheme.primary),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChoicePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoicePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          height: 48,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF0FDF4) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppTheme.primary : const Color(0xFFE5E7EB),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected ? AppTheme.primary : AppTheme.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;

  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 4,
        child: Stack(
          children: [
            Container(color: const Color(0xFFD1D5DB)),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(color: const Color(0xFF101223)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F4F6),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 16, color: AppTheme.textPrimary),
        ),
      ),
    );
  }
}
