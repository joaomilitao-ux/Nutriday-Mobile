class UserProfile {
  final String email;
  final String goal;
  final String age;
  final String weight;
  final String height;
  final String gender;
  final String activityLevel;

  const UserProfile({
    required this.email,
    required this.goal,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.activityLevel,
  });

  factory UserProfile.guest({required String email}) {
    return UserProfile(
      email: email,
      goal: 'Manter hábitos saudáveis',
      age: '--',
      weight: '--',
      height: '--',
      gender: 'Não informado',
      activityLevel: 'Não informado',
    );
  }

  String get displayName {
    final source = email.contains('@') ? email.split('@').first : email;
    final normalized = source.replaceAll(RegExp(r'[._-]+'), ' ').trim();

    if (normalized.isEmpty) {
      return 'Usuário Nutriday';
    }

    return normalized
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map(_capitalize)
        .join(' ');
  }

  String get personalSummary {
    final parts = <String>[];

    if (age != '--') {
      parts.add('$age anos');
    }
    if (weight != '--') {
      parts.add('$weight kg');
    }
    if (height != '--') {
      parts.add('$height cm');
    }

    return parts.isEmpty ? 'Complete seu cadastro' : parts.join(', ');
  }

  int get calorieGoal {
    final value = _parseNumber(weight);
    if (value == null) {
      return 2000;
    }

    double factor;
    switch (goal) {
      case 'Emagrecer':
        factor = 28.0;
        break;
      case 'Ganhar massa':
        factor = 34.0;
        break;
      default:
        factor = 30.0;
    }

    return (value * factor).round();
  }

  int get proteinGoalGrams {
    final value = _parseNumber(weight);
    if (value == null) {
      return 120;
    }

    double factor;
    switch (goal) {
      case 'Ganhar massa':
        factor = 2.0;
        break;
      case 'Emagrecer':
        factor = 1.8;
        break;
      default:
        factor = 1.6;
    }

    return (value * factor).round();
  }

  int get carbGoalGrams {
    final value = _parseNumber(weight);
    if (value == null) {
      return 220;
    }

    double factor;
    switch (goal) {
      case 'Ganhar massa':
        factor = 4.0;
        break;
      case 'Emagrecer':
        factor = 2.5;
        break;
      default:
        factor = 3.0;
    }

    return (value * factor).round();
  }

  int get fatGoalGrams {
    final value = _parseNumber(weight);
    if (value == null) {
      return 65;
    }

    double factor;
    switch (goal) {
      case 'Emagrecer':
        factor = 0.8;
        break;
      default:
        factor = 0.9;
    }

    return (value * factor).round();
  }

  int get waterGoalCups {
    final value = _parseNumber(weight);
    if (value == null) {
      return 8;
    }

    return (value / 10).ceil();
  }

  static String _capitalize(String word) {
    return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
  }

  static double? _parseNumber(String input) {
    return double.tryParse(input.replaceAll(',', '.'));
  }
}
