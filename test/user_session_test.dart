import 'package:cat_bracelet_mobile/features/profile/models/user_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserSession.clear();
  });

  test(
    'setFromLogin should persist tokens and user from wrapped data payload',
    () async {
      final payload = {
        'data': {
          'user': {
            'id': 'u1',
            'fullName': 'Nguyen Van A',
            'email': 'a@example.com',
            'totalSpending': '0',
          },
          'accessToken': 'access-123',
          'refreshToken': 'refresh-123',
        },
      };

      await UserSession.setFromLogin(payload);

      expect(UserSession.currentUser?.id, 'u1');
      expect(UserSession.accessToken, 'access-123');
      expect(UserSession.refreshToken, 'refresh-123');
    },
  );
}
