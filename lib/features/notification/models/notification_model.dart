class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String? relatedId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.relatedId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return NotificationModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      relatedId: json['relatedId'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'],
      ),
    );
  }
}