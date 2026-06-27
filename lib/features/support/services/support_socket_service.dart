import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../profile/models/user_session.dart';
import '../models/support_message.dart';

class SupportSocketService {
  static final SupportSocketService _instance =
      SupportSocketService._internal();
  factory SupportSocketService() => _instance;
  SupportSocketService._internal();

  IO.Socket? socket;
  final _messageController = StreamController<SupportMessage>.broadcast();
  final _historyController = StreamController<List<SupportMessage>>.broadcast();
  final _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  Stream<SupportMessage> get onNewMessage => _messageController.stream;
  Stream<List<SupportMessage>> get onChatHistory => _historyController.stream;
  Stream<Map<String, dynamic>> get onNotification =>
      _notificationController.stream;
  Stream<bool> get onConnectionChange => _connectionController.stream;

  bool get isConnected => socket?.connected ?? false;

  String? _currentTicketId;
  String? get currentTicketId => _currentTicketId;

  void connect(String baseUrl) {
    if (socket != null && socket!.connected) {
      _connectionController.add(true);
      return;
    }

    final token = UserSession.accessToken;
    print('DEBUG: Connecting Socket to $baseUrl');

    socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket']) // Ưu tiên websocket thuần cho ổn định
          .setQuery({
            'token': token ?? '',
            // Thử bỏ chữ Bearer trong query vì một số server Socket.IO chỉ nhận chuỗi JWT thuần
          })
          .setPath('/socket.io/')
          .enableForceNew()
          .build(),
    );

    socket!.on('connect', (_) {
      print('DEBUG: Support Socket Connected! ID: ${socket!.id}');
      _connectionController.add(true);
    });

    socket!.onAny((event, data) {
      print('DEBUG: Socket Event Received: $event -> $data');
    });

    socket!.on('chatHistory', (data) {
      if (data != null) {
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data is Map && data['messages'] is List) {
          list = data['messages'];
        }

        final history = list
            .map((item) => SupportMessage.fromJson(item))
            .toList();
        _historyController.add(history);
      }
    });

    socket!.on('newMessage', (data) {
      if (data != null) {
        _messageController.add(SupportMessage.fromJson(data));
      }
    });

    socket!.onConnectError((data) => print('DEBUG: Connect Error: $data'));
    socket!.onDisconnect((reason) {
      print('DEBUG: Socket Disconnected. Reason: $reason');
      _connectionController.add(false);
    });
  }

  void joinTicket(String ticketId) {
    if (socket == null || !socket!.connected) return;

    _currentTicketId = ticketId;

    // Gửi payload chính xác như trong tool test
    final payload = {
      'ticket_id': ticketId,
      'message':
          'Joining chat...', // Thử gửi một message mồi như screenshot bạn làm
    };

    print('DEBUG: Emitting joinTicket: $payload');
    socket?.emit('joinTicket', payload);
  }

  /// Gửi tin nhắn qua event "sendMessage"
  /// Payload: {"ticket_id": ticketId, "message": message}
  void sendMessage(String ticketId, String message) {
    if (socket == null || !socket!.connected) {
      print('DEBUG: Cannot send message. Socket not connected.');
      return;
    }
    print('DEBUG: Emitting sendMessage for $ticketId: $message');
    socket?.emit('sendMessage', {'ticket_id': ticketId, 'message': message});
  }

  void disconnect() {
    _currentTicketId = null;
    socket?.disconnect();
  }

  void dispose() {
    disconnect();
    socket?.dispose();
    socket = null;
  }
}
