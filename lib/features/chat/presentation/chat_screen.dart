import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/network/token_storage.dart';
import 'package:helpi_admin/core/providers/data_providers.dart';
import 'package:helpi_admin/core/widgets/helpi_app_bar.dart';
import 'package:helpi_admin/core/widgets/notification_bell.dart';
import 'package:helpi_admin/features/chat/data/chat_api_service.dart';
import 'package:helpi_admin/features/seniors/presentation/seniors_screen.dart';
import 'package:helpi_admin/features/students/presentation/student_detail_screen.dart';

/// Chat Moderation Screen — admin chat s korisnicima.
class ChatModScreen extends ConsumerStatefulWidget {
  const ChatModScreen({super.key});

  @override
  ConsumerState<ChatModScreen> createState() => _ChatModScreenState();
}

class _ChatModScreenState extends ConsumerState<ChatModScreen> {
  ApiChatRoom? _selectedRoom;
  int _adminUserId = 0;

  @override
  void initState() {
    super.initState();
    _loadAdminUserId();
  }

  Future<void> _loadAdminUserId() async {
    final id = await TokenStorage().getUserId() ?? 0;
    if (!mounted) return;
    setState(() => _adminUserId = id);
  }

  void _selectRoom(ApiChatRoom room) {
    ref.read(adminChatMessagesProvider.notifier).loadMessages(room.id);
    ref.read(adminChatMessagesProvider.notifier).markAsRead();
    ref.read(adminChatRoomsProvider.notifier).clearUnread(room.id);
    ref.read(unreadMessagesProvider.notifier).refresh();
    setState(() => _selectedRoom = room);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 700;

    if (isWide) {
      // ── Desktop: split view ──
      return Scaffold(
        appBar: HelpiAppBar(
          title: Text(AppStrings.chatTitle),
          actions: const [NotificationBell()],
        ),
        body: Row(
          children: [
            SizedBox(
              width: 340,
              child: _ChatRoomList(
                adminUserId: _adminUserId,
                selectedRoomId: _selectedRoom?.id,
                onRoomSelected: _selectRoom,
              ),
            ),
            VerticalDivider(width: 1, color: HelpiColors.of(context).border),
            Expanded(
              child: _selectedRoom != null
                  ? _ChatView(
                      roomId: _selectedRoom!.id,
                      adminUserId: _adminUserId,
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_outlined,
                            size: 64,
                            color: HelpiColors.of(context).border,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppStrings.chatSelectConversation,
                            style: TextStyle(
                              color: HelpiColors.of(context).textSecondary,
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
      appBar: HelpiAppBar(
        title: Text(AppStrings.chatTitle),
        actions: const [NotificationBell()],
      ),
      body: _ChatRoomList(
        adminUserId: _adminUserId,
        selectedRoomId: null,
        onRoomSelected: (room) {
          _selectRoom(room);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  _ChatDetailPage(room: room, adminUserId: _adminUserId),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  CHAT DETAIL PAGE (mobile only)
// ═══════════════════════════════════════════════════════════════
class _ChatDetailPage extends ConsumerWidget {
  const _ChatDetailPage({required this.room, required this.adminUserId});
  final ApiChatRoom room;
  final int adminUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: HelpiAppBar(
        title: Text(room.otherName(adminUserId)),
        titleSpacing: HelpiAppBar.innerTitleSpacing,
      ),
      body: _ChatView(roomId: room.id, adminUserId: adminUserId),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  CHAT ROOM LIST
// ═══════════════════════════════════════════════════════════════
class _ChatRoomList extends ConsumerWidget {
  const _ChatRoomList({
    required this.adminUserId,
    required this.selectedRoomId,
    required this.onRoomSelected,
  });

  final int adminUserId;
  final int? selectedRoomId;
  final ValueChanged<ApiChatRoom> onRoomSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(adminChatRoomsProvider);

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: rooms.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        indent: 16,
        endIndent: 16,
        color: HelpiColors.of(context).border,
      ),
      itemBuilder: (ctx, i) {
        final room = rooms[i];
        final isSelected = room.id == selectedRoomId;
        final unread = room.unreadCount;
        final otherRole = room.otherRole(adminUserId);
        final isSenior = otherRole == 'customer';

        return InkWell(
          onTap: () => onRoomSelected(room),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isSelected
                ? HelpiColors.of(context).pastelTeal.withValues(alpha: 0.3)
                : null,
            child: Row(
              children: [
                // ── Avatar with icon — tap navigates to profile ──
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    final participantUserId = room.otherUserId(adminUserId);
                    if (isSenior) {
                      final senior = ref
                          .read(seniorsProvider)
                          .where((s) => s.userId == participantUserId)
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
                          .where((s) => s.id == participantUserId.toString())
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
                    decoration: BoxDecoration(
                      color: HelpiColors.of(context).pastelTeal,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSenior ? Icons.elderly : Icons.school,
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
                        room.otherName(adminUserId),
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
                        room.lastMessageText ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: HelpiColors.of(context).textSecondary,
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
                      _formatTime(room.lastMessageAt ?? room.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: HelpiColors.of(context).textSecondary,
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
class _ChatView extends ConsumerStatefulWidget {
  const _ChatView({required this.roomId, required this.adminUserId});
  final int roomId;
  final int adminUserId;

  @override
  ConsumerState<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<_ChatView> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    _msgCtrl.clear();
    await ref.read(adminChatMessagesProvider.notifier).sendMessage(text);
    if (!mounted) return;

    // Refresh rooms list to update last message preview
    ref.read(adminChatRoomsProvider.notifier).loadRooms();

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
    final messages = ref.watch(adminChatMessagesProvider);
    final isLoading = ref
        .read(adminChatMessagesProvider.notifier)
        .isInitialLoad;

    // Auto-scroll when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });

    return Column(
      children: [
        // ── Messages list ──
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : messages.isEmpty
              ? Center(
                  child: Text(
                    AppStrings.chatNoMessages,
                    style: TextStyle(
                      color: HelpiColors.of(context).textSecondary,
                    ),
                  ),
                )
              : LayoutBuilder(
                  builder: (ctx, constraints) {
                    final maxBubble = constraints.maxWidth * 0.65;
                    return ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (ctx, i) => _MessageBubble(
                        message: messages[i],
                        adminUserId: widget.adminUserId,
                        maxBubbleWidth: maxBubble,
                      ),
                    );
                  },
                ),
        ),

        // ── Input bar ──
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: BoxDecoration(
            color: HelpiColors.of(context).surface,
            border: Border(
              top: BorderSide(color: HelpiColors.of(context).border),
            ),
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
                        borderSide: BorderSide(
                          color: HelpiColors.of(context).border,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: HelpiColors.of(context).border,
                        ),
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
  const _MessageBubble({
    required this.message,
    required this.adminUserId,
    required this.maxBubbleWidth,
  });
  final ApiChatMessage message;
  final int adminUserId;
  final double maxBubbleWidth;

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine(adminUserId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxBubbleWidth),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMine
                    ? HelpiTheme.accent
                    : HelpiColors.of(context).surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMine ? 16 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 16),
                ),
                border: isMine
                    ? null
                    : Border.all(color: HelpiColors.of(context).border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMine)
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
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: isMine
                          ? Colors.white
                          : HelpiColors.of(context).textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        message.timeFormatted,
                        style: TextStyle(
                          fontSize: 10,
                          color: isMine
                              ? Colors.white70
                              : HelpiColors.of(context).textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
