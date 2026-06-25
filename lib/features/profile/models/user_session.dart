import 'app_user.dart';

class UserSession {
  static AppUser? currentUser;
  static String? accessToken;
  static String? refreshToken;

  static bool get isLoggedIn => currentUser != null;

  static void setFromLogin(Map<String, dynamic> json) {
    final userJson = json['user'];
    if (userJson is Map<String, dynamic>) {
      currentUser = AppUser.fromJson(userJson);
    }
    accessToken = json['accessToken']?.toString();
    refreshToken = json['refreshToken']?.toString();
  }

  static void clear() {
    currentUser = null;
    accessToken = null;
    refreshToken = null;
  }
}
