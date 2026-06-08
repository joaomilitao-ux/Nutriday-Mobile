class UserProfile {
  final String email;
  final String goal;
  final int? age;
  final double? weight;
  final double? height;
  final String gender;
  final String activityLevel;
  final int basalMetabolicRate;
  final int dailyEnergyExpenditure;
  final int calorieGoal;

  const UserProfile({
    required this.email,
    required this.goal,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.activityLevel,
    required this.basalMetabolicRate,
    required this.dailyEnergyExpenditure,
    required this.calorieGoal,
  });

  factory UserProfile.guest({required String email}) {
    return UserProfile(
      email: email,
      goal: 'Manter peso',
      age: null,
      weight: null,
      height: null,
      gender: 'Nao informado',
      activityLevel: 'Nao informado',
      basalMetabolicRate: 0,
      dailyEnergyExpenditure: 2000,
      calorieGoal: 2000,
    );
  }

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    final weight = _numberFromDynamic(data['peso_kg']);
    final height = _numberFromDynamic(data['altura_cm']);
    final age = _intFromDynamic(data['idade']);
    final gender = (data['sexo'] as String?) ?? 'Nao informado';
    final activityLevel =
        (data['nivel_atividade'] as String?) ?? 'Nao informado';
    final goal = (data['objetivo'] as String?) ?? 'Manter peso';
    final calculated = calculateNutritionTargets(
      goal: goal,
      age: age,
      weightKg: weight,
      heightCm: height,
      gender: gender,
      activityLevel: activityLevel,
    );

    return UserProfile(
      email: (data['email'] as String?) ?? '',
      goal: goal,
      age: age,
      weight: weight,
      height: height,
      gender: gender,
      activityLevel: activityLevel,
      basalMetabolicRate:
          _intFromDynamic(data['taxa_metabolica_basal_kcal']) ??
          calculated.basalMetabolicRate,
      dailyEnergyExpenditure:
          _intFromDynamic(data['gasto_calorico_diario_kcal']) ??
          calculated.dailyEnergyExpenditure,
      calorieGoal:
          _intFromDynamic(data['meta_calorias_diarias_kcal']) ??
          calculated.calorieGoal,
    );
  }

  String get displayName {
    final username = usernameFromEmail(email);

    if (username.isEmpty) {
      return 'Usuario Nutriday';
    }

    return username;
  }

  String get personalSummary {
    final parts = <String>[];

    if (age != null) {
      parts.add('$age anos');
    }
    if (weight != null) {
      parts.add('${_formatNumber(weight!)} kg');
    }
    if (height != null) {
      parts.add('${_formatNumber(height!)} cm');
    }

    return parts.isEmpty ? 'Complete seu cadastro' : parts.join(', ');
  }

  int get proteinGoalGrams {
    if (weight == null) {
      return 120;
    }

    double factor;
    switch (goal) {
      case 'ganhar_massa':
        factor = 2.0;
        break;
      case 'emagrecer':
        factor = 1.8;
        break;
      default:
        factor = 1.6;
    }

    return (weight! * factor).round();
  }

  int get carbGoalGrams {
    if (weight == null) {
      return 220;
    }

    double factor;
    switch (goal) {
      case 'ganhar_massa':
        factor = 4.0;
        break;
      case 'emagrecer':
        factor = 2.5;
        break;
      default:
        factor = 3.0;
    }

    return (weight! * factor).round();
  }

  int get fatGoalGrams {
    if (weight == null) {
      return 65;
    }

    double factor;
    switch (goal) {
      case 'emagrecer':
        factor = 0.8;
        break;
      default:
        factor = 0.9;
    }

    return (weight! * factor).round();
  }

  int get waterGoalCups {
    if (weight == null) {
      return 8;
    }

    return (weight! / 10).ceil();
  }

  static String usernameFromEmail(String? email) {
    final normalized = email?.trim().toLowerCase() ?? '';
    if (normalized.isEmpty) {
      return '';
    }

    return normalized.split('@').first.trim();
  }

  static NutritionTargets calculateNutritionTargets({
    required String goal,
    required int? age,
    required double? weightKg,
    required double? heightCm,
    required String gender,
    required String activityLevel,
  }) {
    if (age == null || weightKg == null || heightCm == null) {
      return const NutritionTargets(
        basalMetabolicRate: 0,
        dailyEnergyExpenditure: 2000,
        calorieGoal: 2000,
      );
    }

    final normalizedGender = gender.trim().toLowerCase();
    final genderOffset = normalizedGender == 'masculino' ? 5 : -161;
    final bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + genderOffset;
    final tdee = bmr * _activityFactor(activityLevel);
    final calorieGoal = tdee + _goalAdjustment(goal);

    return NutritionTargets(
      basalMetabolicRate: bmr.round(),
      dailyEnergyExpenditure: tdee.round(),
      calorieGoal: calorieGoal.round(),
    );
  }

  static double _activityFactor(String activityLevel) {
    switch (activityLevel.trim().toLowerCase()) {
      case 'sedentario':
        return 1.2;
      case 'moderado':
        return 1.55;
      case 'ativo':
        return 1.725;
      default:
        return 1.2;
    }
  }

  static int _goalAdjustment(String goal) {
    switch (goal.trim().toLowerCase()) {
      case 'emagrecer':
        return -500;
      case 'ganhar_massa':
        return 300;
      default:
        return 0;
    }
  }

  static int? _intFromDynamic(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    if (value is String) {
      return int.tryParse(value.replaceAll(',', '.').split('.').first);
    }
    return null;
  }

  static double? _numberFromDynamic(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.'));
    }
    return null;
  }

  static String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(1);
  }
}

class NutritionTargets {
  final int basalMetabolicRate;
  final int dailyEnergyExpenditure;
  final int calorieGoal;

  const NutritionTargets({
    required this.basalMetabolicRate,
    required this.dailyEnergyExpenditure,
    required this.calorieGoal,
  });
}
