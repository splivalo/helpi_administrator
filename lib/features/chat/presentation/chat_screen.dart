import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
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

/// Represents a row in the chat list — either an existing room or a user
/// with no conversation yet.
class _ChatEntry {
  _ChatEntry.fromRoom({
    required this.room,
    required this.name,
    required this.isSenior,
    required this.otherUserId,
    this.senior,
    this.student,
  });

  _ChatEntry.fromSenior(SeniorModel s)
    : room = null,
      // When there's an orderer, we chat with them (they manage the phone).
      // Display their name; add "za <seniorName>" as subtitle context.
      name = s.hasOrderer
          ? '${s.ordererFirstName ?? ''} ${s.ordererLastName ?? ''}'.trim()
          : '${s.firstName} ${s.lastName}',
      isSenior = true,
      otherUserId = s.userId ?? 0,
      senior = s,
      student = null;

  _ChatEntry.fromStudent(StudentModel s)
    : room = null,
      name = '${s.firstName} ${s.lastName}',
      isSenior = false,
      otherUserId = int.tryParse(s.id) ?? 0,
      senior = null,
      student = s;

  final ApiChatRoom? room;
  final String name;
  final bool isSenior;
  final int otherUserId;
  final SeniorModel? senior;
  final StudentModel? student;
}

class _ChatRoomList extends ConsumerStatefulWidget {
  const _ChatRoomList({
    required this.adminUserId,
    required this.selectedRoomId,
    required this.onRoomSelected,
  });

  final int adminUserId;
  final int? selectedRoomId;
  final ValueChanged<ApiChatRoom> onRoomSelected;

  @override
  ConsumerState<_ChatRoomList> createState() => _ChatRoomListState();
}

class _ChatRoomListState extends ConsumerState<_ChatRoomList> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  bool _startingConversation = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openOrCreateRoom(int otherUserId) async {
    setState(() => _startingConversation = true);
    try {
      final room = await ChatApiService().getOrCreateRoom(otherUserId);
      if (room == null || !mounted) return;
      ref.read(adminChatRoomsProvider.notifier).addRoom(room);
      widget.onRoomSelected(room);
    } finally {
      if (mounted) setState(() => _startingConversation = false);
    }
  }

  void _navigateToProfile(BuildContext ctx, _ChatEntry entry) {
    if (entry.isSenior) {
      final senior =
          entry.senior ??
          ref
              .read(seniorsProvider)
              .where((s) => s.userId == entry.otherUserId)
              .firstOrNull;
      if (senior == null) return;
      final orders = ref
          .read(ordersProvider)
          .where((o) => o.senior.id == senior.id)
          .toList();
      Navigator.push(
        ctx,
        MaterialPageRoute(
          builder: (_) => SeniorDetailScreen(senior: senior, orders: orders),
        ),
      );
    } else {
      final student =
          entry.student ??
          ref
              .read(studentsProvider)
              .where((s) => s.id == entry.otherUserId.toString())
              .firstOrNull;
      if (student == null) return;
      Navigator.push(
        ctx,
        MaterialPageRoute(
          builder: (_) => StudentDetailScreen(student: student),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rooms = ref.watch(adminChatRoomsProvider);
    final seniors = ref.watch(seniorsProvider);
    final students = ref.watch(studentsProvider);

    // Build set of userIds that already have a room
    final roomUserIds = rooms
        .map((r) => r.otherUserId(widget.adminUserId))
        .toSet();

    // Build combined list: existing rooms first, then users without rooms
    final entries = <_ChatEntry>[
      for (final r in rooms)
        _ChatEntry.fromRoom(
          room: r,
          name: r.otherName(widget.adminUserId),
          isSenior: r.otherRole(widget.adminUserId) == 'customer',
          otherUserId: r.otherUserId(widget.adminUserId),
          senior: seniors
              .where((s) => s.userId == r.otherUserId(widget.adminUserId))
              .firstOrNull,
          student: students
              .where(
                (s) => s.id == r.otherUserId(widget.adminUserId).toString(),
              )
              .firstOrNull,
        ),
      for (final s in seniors)
        if (s.userId != null && !roomUserIds.contains(s.userId))
          _ChatEntry.fromSenior(s),
      for (final s in students)
        if (!roomUserIds.contains(int.tryParse(s.id) ?? -1))
          _ChatEntry.fromStudent(s),
    ];

    // Filter by search query — also matches senior's own name when orderer exists
    final filtered = _query.isEmpty
        ? entries
        : entries.where((e) {
            final q = _query.toLowerCase();
            if (e.name.toLowerCase().contains(q)) return true;
            // When orderer manages the account, also search by senior's full name
            if (e.senior?.hasOrderer == true) {
              return e.senior!.fullName.toLowerCase().contains(q);
            }
            return false;
          }).toList();

    return Column(
      children: [
        // ── Search bar ──
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: AppStrings.chatSearchHint,
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: HelpiColors.of(context).border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: HelpiColors.of(context).border),
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
        if (_startingConversation)
          const LinearProgressIndicator(minHeight: 2, color: HelpiTheme.accent),
        // ── List ──
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: filtered.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: HelpiColors.of(context).border,
            ),
            itemBuilder: (ctx, i) {
              final entry = filtered[i];
              final hasRoom = entry.room != null;
              final isSelected =
                  hasRoom && entry.room!.id == widget.selectedRoomId;
              final unread = entry.room?.unreadCount ?? 0;

              return InkWell(
                onTap: _startingConversation
                    ? null
                    : () {
                        if (hasRoom) {
                          widget.onRoomSelected(entry.room!);
                        } else {
                          _openOrCreateRoom(entry.otherUserId);
                        }
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: isSelected
                      ? HelpiColors.of(
                          context,
                        ).pastelTeal.withValues(alpha: 0.3)
                      : null,
                  child: Row(
                    children: [
                      // ── Avatar ──
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _navigateToProfile(ctx, entry),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: HelpiColors.of(context).pastelTeal,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            entry.isSenior ? Icons.elderly : Icons.school,
                            size: 18,
                            color: HelpiTheme.accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // ── Name + subtitle ──
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.name,
                              style: TextStyle(
                                fontWeight: unread > 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // If orderer → show "za <seniorName>"
                            if (entry.senior?.hasOrderer == true)
                              Text(
                                'za ${entry.senior!.fullName}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: HelpiColors.of(context).textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            else if (entry.room?.lastMessageText != null)
                              Text(
                                entry.room!.lastMessageText!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: HelpiColors.of(context).textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            else if (!hasRoom)
                              Text(
                                AppStrings.chatNoConversationYet,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: HelpiColors.of(context).textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // ── Date + unread badge ──
                      if (entry.room?.lastMessageAt != null) ...[
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatDate(entry.room!.lastMessageAt!),
                              style: TextStyle(
                                fontSize: 11,
                                color: HelpiColors.of(context).textSecondary,
                              ),
                            ),
                            if (unread > 0)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: HelpiTheme.accent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$unread',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final local = dt.toLocal();
    if (local.year == now.year &&
        local.month == now.month &&
        local.day == now.day) {
      return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    }
    return '${local.day}.${local.month}.';
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
