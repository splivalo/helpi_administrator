import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/widgets/helpi_app_bar.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/providers/data_providers.dart';
import 'package:helpi_admin/features/seniors/presentation/seniors_screen.dart';
import 'package:helpi_admin/features/students/presentation/student_detail_screen.dart';

// TODO: Chat backend not implemented. Need ChatController, ChatRoom/Message entities, SignalR hub for real-time messaging.

/// Chat Moderation Screen — admin chat s korisnicima.
class ChatModScreen extends ConsumerStatefulWidget {
  const ChatModScreen({super.key});

  @override
  ConsumerState<ChatModScreen> createState() => _ChatModScreenState();
}

class _ChatModScreenState extends ConsumerState<ChatModScreen> {
  ChatRoom? _selectedRoom;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 700;

    if (isWide) {
      // ── Desktop: split view ──
      return Scaffold(
        appBar: HelpiAppBar(title: Text(AppStrings.chatTitle)),
        body: Row(
          children: [
            SizedBox(
              width: 340,
              child: _ChatRoomList(
                selectedRoomId: _selectedRoom?.id,
                onRoomSelected: (room) {
                  ref
                      .read(unreadMessagesProvider.notifier)
                      .markRoomRead(room.id);
                  setState(() => _selectedRoom = room);
                },
              ),
            ),
            const VerticalDivider(width: 1, color: HelpiTheme.border),
            Expanded(
              child: _selectedRoom != null
                  ? _ChatView(room: _selectedRoom!)
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.chat_outlined,
                            size: 64,
                            color: HelpiTheme.border,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppStrings.chatSelectConversation,
                            style: const TextStyle(
                              color: HelpiTheme.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      );
    }

    // ── Mobile: room list only, tap opens chat ──
    return Scaffold(
      appBar: HelpiAppBar(title: Text(AppStrings.chatTitle)),
      body: _ChatRoomList(
        selectedRoomId: null,
        onRoomSelected: (room) {
          ref.read(unreadMessagesProvider.notifier).markRoomRead(room.id);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => _ChatDetailPage(room: room)),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  CHAT DETAIL PAGE (mobile only)
// ═══════════════════════════════════════════════════════════════
class _ChatDetailPage extends StatelessWidget {
  const _ChatDetailPage({required this.room});
  final ChatRoom room;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HelpiAppBar(
        title: Text(room.participantName),
        titleSpacing: HelpiAppBar.innerTitleSpacing,
      ),
      body: _ChatView(room: room),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  CHAT ROOM LIST
// ═══════════════════════════════════════════════════════════════
class _ChatRoomList extends ConsumerWidget {
  const _ChatRoomList({
    required this.selectedRoomId,
    required this.onRoomSelected,
  });

  final String? selectedRoomId;
  final ValueChanged<ChatRoom> onRoomSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(chatRoomsProvider);
    final unreadMap = ref.watch(unreadMessagesProvider);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: rooms.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        indent: 16,
        endIndent: 16,
        color: HelpiTheme.border,
      ),
      itemBuilder: (ctx, i) {
        final room = rooms[i];
        final isSelected = room.id == selectedRoomId;
        final unread = unreadMap[room.id] ?? 0;

        return InkWell(
          onTap: () => onRoomSelected(room),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isSelected
                ? HelpiTheme.pastelTeal.withValues(alpha: 0.3)
                : null,
            child: Row(
              children: [
                // ── Avatar with icon — tap navigates to profile ──
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (room.isSenior) {
                      final senior = ref
                          .read(seniorsProvider)
                          .where((s) => s.id == room.participantId)
                          .firstOrNull;
                      if (senior == null) return;
                      final orders = ref
                          .read(ordersProvider)
                          .where((o) => o.senior.id == senior.id)
                          .toList();
                      Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (_) => SeniorDetailScreen(
                            senior: senior,
                            orders: orders,
                          ),
                        ),
                      );
                    } else {
                      final student = ref
                          .read(studentsProvider)
                          .where((s) => s.id == room.participantId)
                          .firstOrNull;
                      if (student == null) return;
                      Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (_) => StudentDetailScreen(student: student),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: HelpiTheme.pastelTeal,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      room.isSenior ? Icons.elderly : Icons.school,
                      size: 18,
                      color: HelpiTheme.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // ── Name + last message ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.participantName,
                        style: TextStyle(
                          fontWeight: unread > 0
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        room.lastMessage,
                        style: TextStyle(
                          fontSize: 13,
                          color: HelpiTheme.textSecondary,
                          fontWeight: unread > 0
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ── Date + Unread badge ──
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatTime(room.lastMessageAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: HelpiTheme.textSecondary,
                      ),
                    ),
                    if (unread > 0) ...[
                      const SizedBox(height: 4),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: HelpiTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}.${dt.month}.';
  }
}

// ═══════════════════════════════════════════════════════════════
//  CHAT VIEW
// ═══════════════════════════════════════════════════════════════
class _ChatView extends StatefulWidget {
  const _ChatView({required this.room});
  final ChatRoom room;

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List.of(widget.room.messages);
  }

  @override
  void didUpdateWidget(covariant _ChatView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.room.id != widget.room.id) {
      _messages = List.of(widget.room.messages);
    }
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          senderId: 'admin',
          senderName: 'Admin',
          senderRole: 'admin',
          content: text,
          sentAt: DateTime.now(),
        ),
      );
      _msgCtrl.clear();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Messages list ──
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Text(
                    AppStrings.chatNoMessages,
                    style: const TextStyle(color: HelpiTheme.textSecondary),
                  ),
                )
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (ctx, i) =>
                      _MessageBubble(message: _messages[i]),
                ),
        ),

        // ── Input bar ──
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: HelpiTheme.border)),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    onSubmitted: (_) => _sendMessage(),
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: AppStrings.chatInputHint,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: HelpiTheme.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: HelpiTheme.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: HelpiTheme.accent,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: HelpiTheme.accent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    padding: const EdgeInsets.all(10),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  MESSAGE BUBBLE
// ═══════════════════════════════════════════════════════════════
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isAdmin = message.isAdmin;

    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.65,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isAdmin ? HelpiTheme.accent : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isAdmin ? 16 : 4),
            bottomRight: Radius.circular(isAdmin ? 4 : 16),
          ),
          border: isAdmin ? null : Border.all(color: HelpiTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isAdmin)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  message.senderName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: HelpiTheme.accent,
                  ),
                ),
              ),
            Text(
              message.text,
              style: TextStyle(
                fontSize: 14,
                color: isAdmin ? Colors.white : HelpiTheme.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 3),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '${message.sentAt.hour.toString().padLeft(2, '0')}:${message.sentAt.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 10,
                  color: isAdmin ? Colors.white70 : HelpiTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
