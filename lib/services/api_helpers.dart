import '../models/user_session.dart';

Map<String, String> apiHeaders({bool json = false}) {
  final headers = <String, String>{};
  if (json) {
    headers['Content-Type'] = 'application/json';
  }
  final token = UserSession.accessToken;
  if (token != null && token.isNotEmpty) {
    headers['Authorization'] = 'Bearer $token';
  }
  return headers;
}

List<dynamic> decodeListPayload(dynamic decoded) {
  if (decoded is List) {
    if (decoded.length == 1 && decoded.first is List) {
      return decoded.first as List<dynamic>;
    }
    return decoded;
  }
  if (decoded is Map<String, dynamic>) {
    final data = decoded['data'] ?? decoded['items'] ?? decoded['content'];
    if (data is List) {
      return data;
    }
    return [decoded];
  }
  return [];
}

double toDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String buildImageUrl(String baseUrl, String? path) {
  if (path == null || path.isEmpty) {
    return '';
  }
  final nestedHttp = path.indexOf('/http');
  if (nestedHttp > 0) {
    return path.substring(nestedHttp + 1);
  }
  if (path.startsWith('http')) {
    return path;
  }
  final cleanPath = path.startsWith('/') ? path : '/$path';
  return '$baseUrl$cleanPath';
}
