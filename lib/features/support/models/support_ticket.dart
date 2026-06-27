class SupportTicket {
  final String id;
  final String userId;
  final String status;
  final DateTime createdAt;

  SupportTicket({
    required this.id,
    required this.userId,
    required this.status,
    required this.createdAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'open',
      createdAt: DateTime.parse(
        json['createdAt'] ??
            json['created_at'] ??
            DateTime.now().toIso8601String(),
      ).toLocal(),
    );
  }

  /// Kiểm tra ticket còn mở không
  bool get isOpen => status.toLowerCase() == 'open';

  /// Hiển thị ID rút gọn
  String get shortId => id.length > 8 ? id.substring(0, 8) : id;
}
