import 'package:cat_bracelet_mobile/features/profile/models/user_session.dart';

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
  return readStringField(data, const [
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
