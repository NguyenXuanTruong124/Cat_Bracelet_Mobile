import 'dart:convert';
import 'package:cat_bracelet_mobile/core/services/session_manager.dart';
import 'package:http/http.dart' as http;
import '../../features/profile/models/user_session.dart';
import '../exceptions/auth_exception.dart';

Map<String, String> apiHeaders({bool json = false}) {
  final headers = <String, String>{};

  if (json) {
    headers['Content-Type'] = 'application/json';
  }

  final token = UserSession.accessToken;

  if (token?.isNotEmpty ?? false) {
    headers['Authorization'] = 'Bearer $token';
  }

  return headers;
}

Future<bool> refreshAccessToken() async {
  return await UserSession.refreshTokens();
}

Future<http.Response> sendAuthenticatedRequest(
  Future<http.Response> Function() request, {
  bool retry = true,
}) async {
  try {
    final response = await request();

    if (!retry || (response.statusCode != 401 && response.statusCode != 403)) {
      return response;
    }

    final refreshed = await refreshAccessToken();

    if (!refreshed) {
      await SessionManager.logout();
      throw const SessionExpiredException();
    }

    return await request();
  } on http.ClientException {
    throw Exception('Không thể kết nối đến máy chủ');
  } on FormatException {
    throw Exception('Dữ liệu trả về không hợp lệ');
  } catch (_) {
    rethrow;
  }
}

Future<http.Response> apiGet(Uri url, {bool json = false}) async {
  return await sendAuthenticatedRequest(
    () => http
        .get(url, headers: apiHeaders(json: json))
        .timeout(const Duration(seconds: 20)),
  );
}

Future<http.Response> apiPost(
  Uri url, {
  Object? body,
  Encoding? encoding,
  bool json = false,
}) async {
  return await sendAuthenticatedRequest(
    () => http
        .post(
          url,
          headers: apiHeaders(json: json),
          body: body,
          encoding: encoding,
        )
        .timeout(const Duration(seconds: 20)),
  );
}

Future<http.Response> apiPatch(
  Uri url, {
  Object? body,
  Encoding? encoding,
  bool json = false,
}) async {
  return await sendAuthenticatedRequest(
    () => http
        .patch(
          url,
          headers: apiHeaders(json: json),
          body: body,
          encoding: encoding,
        )
        .timeout(const Duration(seconds: 20)),
  );
}

Future<http.Response> apiDelete(
  Uri url, {
  Object? body,
  Encoding? encoding,
  bool json = false,
}) async {
  return await sendAuthenticatedRequest(
    () => http
        .delete(
          url,
          headers: apiHeaders(json: json),
          body: body,
          encoding: encoding,
        )
        .timeout(const Duration(seconds: 20)),
  );
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

Map<String, dynamic>? asStringMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return null;
}

String? readStringField(Map<String, dynamic>? data, List<String> keys) {
  if (data == null) {
    return null;
  }
  for (final key in keys) {
    final value = data[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  }
  return null;
}

String? readThumbnailPath(Map<String, dynamic>? data) {
  final direct = readStringField(data, const [
    'thumbnail',
    'thumbnailUrl',
    'thumbnail_url',
    'image',
    'imageUrl',
    'image_url',
    'productImage',
    'product_image',
    'cover',
    'coverImage',
    'cover_image',
  ]);
  if (direct != null) {
    return direct;
  }

  final images = data?['productImages'] ?? data?['product_images'];
  if (images is List) {
    for (final image in images) {
      final imageMap = asStringMap(image);
      final status = imageMap?['status']?.toString().toUpperCase();
      final url = readStringField(imageMap, const [
        'imageUrl',
        'image_url',
        'url',
      ]);
      if (url != null && (status == null || status == 'ACTIVE')) {
        return url;
      }
    }
  }

  return null;
}

Map<String, dynamic>? readProductPayload(Map<String, dynamic> item) {
  final directProduct = asStringMap(item['product']);
  if (directProduct != null) {
    return directProduct;
  }

  final variant = asStringMap(item['variantDetails'] ?? item['variant']);
  final variantProduct = asStringMap(variant?['product']);
  if (variantProduct != null) {
    return variantProduct;
  }

  final mappings =
      variant?['productVariantMappings'] ?? item['productVariantMappings'];
  if (mappings is List && mappings.isNotEmpty) {
    return asStringMap(asStringMap(mappings.first)?['product']);
  }

  return null;
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
