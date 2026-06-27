class SupportMessage {
  final String id;
  final String ticketId;
  final String senderId;
  final String senderRole;
  final String message;
  final DateTime createdAt;
  final bool isOptimistic;

  SupportMessage({
    required this.id,
    required this.ticketId,
    required this.senderId,
    required this.message,
    required this.createdAt,
    this.senderRole = '',
    this.isOptimistic = false,
  });

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      id: json['id']?.toString() ?? '',
      ticketId:
          json['ticket_id']?.toString() ?? json['ticketId']?.toString() ?? '',
      senderId:
          json['sender_id']?.toString() ?? json['senderId']?.toString() ?? '',
      senderRole:
          json['sender_role']?.toString() ??
          json['senderRole']?.toString() ??
          '',
      message: json['message']?.toString() ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ??
            json['created_at'] ??
            DateTime.now().toIso8601String(),
      ).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'sender_id': senderId,
      'sender_role': senderRole,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
