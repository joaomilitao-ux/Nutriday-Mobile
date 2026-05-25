import 'package:nutriday/models/user_profile.dart';

class AppSession {
  static UserProfile? _registeredProfile;

  static void saveRegisteredProfile(UserProfile profile) {
    _registeredProfile = profile;
  }

  static UserProfile resolveProfileForLogin(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    final registeredProfile = _registeredProfile;

    if (registeredProfile != null &&
        registeredProfile.email.toLowerCase() == normalizedEmail) {
      return registeredProfile;
    }

    return UserProfile.guest(email: email.trim());
  }

  static void clear() {
    _registeredProfile = null;
  }
}
