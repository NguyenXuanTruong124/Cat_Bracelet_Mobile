import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

import '../../../config/api_config.dart';
import '../../../core/services/api_helpers.dart';
import 'package:cat_bracelet_mobile/features/profile/models/app_user.dart';
import '../models/user_session.dart';

class UserService {
  static Future<AppUser?> fetchProfile(context) async {
    final user = UserSession.currentUser;
    if (user == null) return null;

    final baseUrl = ApiConfig.getBaseUrl(context);
    final response = await http.get(
      Uri.parse('$baseUrl/user/profile/${user.id}'),
      headers: apiHeaders(),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return AppUser.fromJson(decoded);
      }
    }
    return null;
  }

  static Future<AppUser?> saveProfile(context,
      {required String fullName,
      required String phone,
      required String avatar}) async {
    final user = UserSession.currentUser;
    if (user == null) return null;

    final baseUrl = ApiConfig.getBaseUrl(context);
    final response = await http.patch(
      Uri.parse('$baseUrl/user/profile/${user.id}'),
      headers: apiHeaders(json: true),
      body: jsonEncode({
        'fullName': fullName,
        'phone': phone,
        'avatar': avatar,
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return AppUser.fromJson(decoded);
      }
    }
    return null;
  }

  static Future<bool> uploadAvatar(context, XFile image) async {
    final user = UserSession.currentUser;
    if (user == null) return false;

    final baseUrl = ApiConfig.getBaseUrl(context);
    final request = http.MultipartRequest(
      'PATCH',
      Uri.parse('$baseUrl/user/${user.id}/avatar'),
    )..headers.addAll(apiHeaders());

    final path = image.path.toLowerCase();
    MediaType mediaType;
    if (path.endsWith('.png')) {
      mediaType = MediaType('image', 'png');
    } else if (path.endsWith('.jpg') || path.endsWith('.jpeg')) {
      mediaType = MediaType('image', 'jpeg');
    } else if (path.endsWith('.webp')) {
      mediaType = MediaType('image', 'webp');
    } else {
      throw Exception('Định dạng ảnh không hỗ trợ');
    }

    request.files.add(await http.MultipartFile.fromPath(
      'avatar',
      image.path,
      contentType: mediaType,
    ));

    final response = await request.send();
    return response.statusCode == 200;
  }
}
