import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/api_helpers.dart';
import '../models/support_ticket.dart';

class SupportService {
  final String baseUrl;

  SupportService({required this.baseUrl});

  /// POST /support-tickets - Tạo ticket mới
  /// Response: {"id": "...", "user_id": "...", "status": "open", "created_at": "..."}
  Future<SupportTicket?> createTicket() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/support-tickets'),
        headers: apiHeaders(json: true),
      );

      print('DEBUG: createTicket status: ${response.statusCode}');
      print('DEBUG: createTicket body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        // API có thể trả trực tiếp hoặc bọc trong "data"
        final data = decoded is Map<String, dynamic>
            ? (decoded['data'] ?? decoded)
            : decoded;
        return SupportTicket.fromJson(data);
      }
    } catch (e) {
      print('DEBUG: Error creating ticket: $e');
    }
    return null;
  }

  /// GET /support-tickets/my-tickets - Lấy danh sách tickets của user
  Future<List<SupportTicket>> fetchMyTickets() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/support-tickets/my-tickets'),
        headers: apiHeaders(),
      );

      print('DEBUG: fetchMyTickets status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data = decodeListPayload(decoded);
        return data.map((item) => SupportTicket.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error fetching tickets: $e');
    }
    return [];
  }
}
