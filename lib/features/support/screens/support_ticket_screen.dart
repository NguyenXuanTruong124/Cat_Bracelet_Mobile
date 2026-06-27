import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../models/support_ticket.dart';
import '../services/support_service.dart';
import 'chat_support_screen.dart';

class SupportTicketScreen extends StatefulWidget {
  const SupportTicketScreen({super.key});

  @override
  State<SupportTicketScreen> createState() => _SupportTicketScreenState();
}

class _SupportTicketScreenState extends State<SupportTicketScreen> {
  late SupportService _supportService;
  List<SupportTicket> _tickets = [];
  bool _isLoading = true;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    _supportService = SupportService(baseUrl: baseUrl);
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);
    final tickets = await _supportService.fetchMyTickets();
    if (mounted) {
      setState(() {
        _tickets = tickets;
        _isLoading = false;
      });
    }
  }

  /// Tạo ticket mới: POST /support-tickets
  /// Sau đó navigate vào chat screen
  Future<void> _createNewTicket() async {
    if (_isCreating) return;
    setState(() => _isCreating = true);

    final ticket = await _supportService.createTicket();

    if (!mounted) return;
    setState(() => _isCreating = false);

    if (ticket != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatSupportScreen(ticket: ticket),
        ),
      ).then((_) => _loadTickets());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể tạo yêu cầu hỗ trợ. Vui lòng thử lại!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Hỗ trợ khách hàng',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTickets,
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'YÊU CẦU CỦA TÔI',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9BA4B5),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  _tickets.isEmpty
                      ? const SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.support_agent,
                                  size: 64,
                                  color: Color(0xFFD1D5DB),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Bạn chưa có yêu cầu nào.',
                                  style: TextStyle(
                                    color: Color(0xFF9BA4B5),
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Nhấn + để tạo yêu cầu mới',
                                  style: TextStyle(
                                    color: Color(0xFFD1D5DB),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final ticket = _tickets[index];

                            return Column(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  leading: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: ticket.isOpen
                                          ? const Color(0xFFE8F5E9)
                                          : const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.chat_bubble_outline,
                                      color: ticket.isOpen
                                          ? const Color(0xFF27AE60)
                                          : const Color(0xFF9BA4B5),
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    'Ticket #${ticket.shortId}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF2D3139),
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: ticket.isOpen
                                                ? const Color(0xFFE8F5E9)
                                                : const Color(0xFFF5F5F5),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            ticket.isOpen
                                                ? 'Đang mở'
                                                : 'Đã đóng',
                                            style: TextStyle(
                                              color: ticket.isOpen
                                                  ? const Color(0xFF27AE60)
                                                  : const Color(0xFF9BA4B5),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          DateFormat(
                                            'dd/MM/yyyy HH:mm',
                                          ).format(ticket.createdAt),
                                          style: const TextStyle(
                                            color: Color(0xFF9BA4B5),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFFD1D5DB),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ChatSupportScreen(ticket: ticket),
                                      ),
                                    ).then((_) => _loadTickets());
                                  },
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 80),
                                  child: Divider(
                                    height: 1,
                                    color: Color(0xFFF3F4F6),
                                  ),
                                ),
                              ],
                            );
                          }, childCount: _tickets.length),
                        ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isCreating ? null : _createNewTicket,
        backgroundColor: _isCreating ? Colors.grey : const Color(0xFFC83C3C),
        elevation: 4,
        child: _isCreating
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
