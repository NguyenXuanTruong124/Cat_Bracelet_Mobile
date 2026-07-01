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

  Future<void> connect(String baseUrl) async {
    if (socket != null && socket!.connected) {
      _connectionController.add(true);
      return;
    }

    if (socket != null) {
      socket?.dispose();
      socket = null;
    }

    final token = UserSession.accessToken;

    if (token == null || token.isEmpty) {
      _connectionController.add(false);
      return;
    }

    if (token == null || token.isEmpty) {
      print('DEBUG: Socket connect aborted: missing access token');
      _connectionController.add(false);
      return;
    }

    var sanitizedUrl = baseUrl.trim();
    if (sanitizedUrl.length >= 2) {
      final first = sanitizedUrl[0];
      final last = sanitizedUrl[sanitizedUrl.length - 1];
      if ((first == "'" && last == "'") || (first == '"' && last == '"')) {
        sanitizedUrl = sanitizedUrl.substring(1, sanitizedUrl.length - 1);
      }
    }
    print('DEBUG: Raw BASE_URL: "$baseUrl"');
    print('DEBUG: Sanitized BASE_URL: "$sanitizedUrl"');

    final headers = {'Authorization': 'Bearer $token'};

    socket = IO.io(
      sanitizedUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders(headers)
          .setPath('/socket.io')
          .enableForceNew()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(10000)
          .build(),
    );

    socket!.on('connect', (_) {
      print('DEBUG: Support Socket Connected! ID: ${socket!.id}');
      _connectionController.add(true);
    });

    socket!.onAny((event, data) {
      print('DEBUG: Socket Event Received: $event -> $data');
    });

    socket!.on('connect_error', (data) {
      print('DEBUG: Connect Error: $data');
      _connectionController.add(false);
    });

    socket!.on('error', (data) {
      print('DEBUG: Socket Error: $data');
    });

    socket!.on('reconnect_attempt', (attempt) {
      print('DEBUG: Socket reconnect attempt: $attempt');
    });

    socket!.on('reconnect_failed', (_) {
      print('DEBUG: Socket reconnect failed');
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
    if (socket == null) {
      print('DEBUG: Cannot join ticket. Socket not initialized.');
      return;
    }

    _currentTicketId = ticketId;

    final payload = {'ticket_id': ticketId};

    print('DEBUG: Emitting joinTicket with payload: $payload');

    Future.delayed(const Duration(milliseconds: 800), () {
      if (socket == null || !socket!.connected) {
        print('DEBUG: Cannot emit joinTicket. Socket not connected anymore.');
        return;
      }

      socket?.emit('joinTicket', payload);
    });
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
