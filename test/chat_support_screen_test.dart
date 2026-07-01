import 'package:cat_bracelet_mobile/features/support/models/support_message.dart';
import 'package:cat_bracelet_mobile/features/support/models/support_ticket.dart';
import 'package:cat_bracelet_mobile/features/support/screens/chat_support_screen.dart';
import 'package:cat_bracelet_mobile/features/support/services/support_message_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows cached support messages when reopening chat', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await SupportMessageCache.clear('ticket-1');

    await SupportMessageCache.save('ticket-1', [
      SupportMessage(
        id: 'msg-1',
        ticketId: 'ticket-1',
        senderId: 'user-1',
        message: 'Tin nhắn cũ từ cache',
        createdAt: DateTime.now(),
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: ChatSupportScreen(
          ticket: SupportTicket(
            id: 'ticket-1',
            userId: 'user-1',
            status: 'open',
            createdAt: DateTime.now(),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Tin nhắn cũ từ cache'), findsOneWidget);
  });
}
