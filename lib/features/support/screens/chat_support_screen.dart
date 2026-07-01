import 'dart:async';
import 'package:flutter/material.dart';
import '../../profile/models/user_session.dart';
import '../models/support_message.dart';
import '../models/support_ticket.dart';
import '../services/support_message_cache.dart';
import '../services/support_socket_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/message_input.dart';
import '../../../config/api_config.dart';

class ChatSupportScreen extends StatefulWidget {
  final SupportTicket ticket;

  const ChatSupportScreen({super.key, required this.ticket});

  @override
  State<ChatSupportScreen> createState() => _ChatSupportScreenState();
}

class _ChatSupportScreenState extends State<ChatSupportScreen> {
  final List<SupportMessage> _messages = [];
  final SupportSocketService _socketService = SupportSocketService();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isConnected = false;

  Timer? _fallbackTimer;
  StreamSubscription? _historySub;
  StreamSubscription? _messageSub;
  StreamSubscription? _connectionSub;
  StreamSubscription? _notificationSub;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    final cachedMessages = await SupportMessageCache.load(widget.ticket.id);
    if (mounted && cachedMessages.isNotEmpty) {
      setState(() {
        _messages.clear();
        _messages.addAll(cachedMessages);
        _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        _isLoading = false;
      });
      _scrollToBottom();
    }

    // 1. Lắng nghe trạng thái kết nối
    _connectionSub = _socketService.onConnectionChange.listen((connected) {
      if (!mounted) return;

      setState(() => _isConnected = connected);

      if (connected) {
        _joinTicket();
      }
    });

    // 2. Lắng nghe chatHistory - nhận lịch sử sau khi joinTicket
    _historySub = _socketService.onChatHistory.listen((history) {
      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(history);
          _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          _isLoading = false;
        });
        SupportMessageCache.save(widget.ticket.id, history);
        _scrollToBottom();
      }
    });

    // 3. Lắng nghe newMessage - tin nhắn mới real-time
    _messageSub = _socketService.onNewMessage.listen((message) {
      if (message.ticketId == widget.ticket.id) {
        _handleIncomingMessage(message);
      }
    });

    // 4. Lắng nghe new_notification
    _notificationSub = _socketService.onNotification.listen((data) {
      print('DEBUG: Chat notification: $data');
      // Có thể hiển thị snackbar hoặc xử lý thêm
    });

    // 5. Kết nối Socket
    await _socketService.connect(baseUrl);
    if (_socketService.isConnected) {
      _joinTicket();
    }

    // 7. Timeout fallback - nếu 5s chưa có data thì tắt loading
    _fallbackTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    });
  }

  /// Emit joinTicket event để join vào room
  void _joinTicket() {
    print('DEBUG: Joining ticket ${widget.ticket.id}');
    _socketService.joinTicket(widget.ticket.id);
  }

  void _handleIncomingMessage(SupportMessage message) {
    if (!mounted) return;

    setState(() {
      // Kiểm tra trùng lặp (optimistic update)
      final index = _messages.indexWhere(
        (m) =>
            (m.isOptimistic &&
                m.message == message.message &&
                m.senderId == message.senderId) ||
            (m.id == message.id && m.id.isNotEmpty),
      );

      if (index != -1) {
        // Thay thế tin nhắn tạm bằng tin nhắn thực từ server
        _messages[index] = message;
      } else {
        _messages.add(message);
      }
      _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    });
    SupportMessageCache.save(widget.ticket.id, _messages);
    _scrollToBottom();
  }

  void _sendMessage(String text) {
    final currentUser = UserSession.currentUser;
    if (currentUser == null) return;

    final myId = currentUser.id;

    // Optimistic Update: Thêm ngay vào UI
    final tempMsg = SupportMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      ticketId: widget.ticket.id,
      senderId: myId,
      message: text,
      createdAt: DateTime.now(),
      isOptimistic: true,
    );

    setState(() {
      _messages.add(tempMsg);
    });
    _scrollToBottom();

    // Emit sendMessage event qua socket
    _socketService.sendMessage(widget.ticket.id, text);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _historySub?.cancel();
    _messageSub?.cancel();
    _connectionSub?.cancel();
    _notificationSub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myId = UserSession.currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hỗ trợ trực tuyến',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isConnected ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _isConnected ? 'Đang kết nối' : 'Mất kết nối',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '#${widget.ticket.shortId}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Connection warning banner
          if (!_isConnected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              color: Colors.orange[100],
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: Colors.orange[800],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Đang kết nối lại...',
                    style: TextStyle(fontSize: 13, color: Colors.orange[800]),
                  ),
                ],
              ),
            ),

          // Chat messages area
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                  ? const Center(
                      child: Text(
                        'Chưa có tin nhắn nào.\nHãy bắt đầu trò chuyện!',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return ChatBubble(
                          message: msg,
                          isMe: msg.senderId == myId,
                        );
                      },
                    ),
            ),
          ),

          // Message input
          MessageInput(onSend: _sendMessage),
        ],
      ),
    );
  }
}
