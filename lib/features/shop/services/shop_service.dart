import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/api_helpers.dart';
import '../models/shop_location.dart';

class ShopService {
  final String baseUrl;

  ShopService({required this.baseUrl});

  Future<List<ShopLocation>> fetchActiveShops() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/shop-location/active'),
        headers: apiHeaders(),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data = decodeListPayload(decoded);
        return data.map((item) => ShopLocation.fromJson(item)).toList();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching shop locations: $e');
    }
    return [];
  }
}
