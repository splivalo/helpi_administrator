import 'package:flutter/material.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/services/admin_api_service.dart';
import 'package:helpi_admin/core/utils/formatters.dart';
import 'package:helpi_admin/core/widgets/shared_widgets.dart';

/// Admin notes section — add / edit / delete personal notes on any user.
/// Fully API-backed: loads from backend and persists all changes.
class NotesSection extends StatefulWidget {
  const NotesSection({
    super.key,
    required this.entityType,
    required this.entityId,
  });

  /// Entity type: "Senior", "Student", or "Order".
  final String entityType;

  /// The ID of the entity (senior/student/order).
  final int entityId;

  @override
  State<NotesSection> createState() => _NotesSectionState();
}

class _NotesSectionState extends State<NotesSection> {
  List<AdminNote>? _notes;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await AdminApiService().getAdminNotes(
      widget.entityType,
      widget.entityId,
    );

    if (!mounted) return;

    if (result.success && result.data != null) {
      setState(() {
        _notes = result.data!.map((json) => AdminNote.fromJson(json)).toList();
        _loading = false;
      });
    } else {
      setState(() {
        _notes = [];
        _error = result.error;
        _loading = false;
      });
    }
  }

  void _addNote() {
    _showNoteDialog(null);
  }

  void _editNote(AdminNote note) {
    _showNoteDialog(note);
  }

  Future<void> _deleteNote(AdminNote note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.adminNoteDelete),
        content: Text(AppStrings.adminNoteDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.adminNoteCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: HelpiTheme.error),
            child: Text(AppStrings.adminNoteDelete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final result = await AdminApiService().deleteAdminNote(note.id);
    if (!mounted) return;

    if (result.success) {
      setState(() => _notes?.remove(note));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? 'Error deleting note')),
      );
    }
  }

  void _showNoteDialog(AdminNote? existing) {
    final controller = TextEditingController(text: existing?.text ?? '');
    final isEdit = existing != null;
    final isWide = MediaQuery.sizeOf(context).width >= 600;
    final title = isEdit ? AppStrings.adminNoteEdit : AppStrings.adminNoteAdd;

    void onSave(BuildContext ctx) {
      final text = controller.text.trim();
      if (text.isEmpty) return;
      Navigator.pop(ctx, text);
    }

    final Future<String?> result;
    if (isWide) {
      result = showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 400,
            child: TextField(
              controller: controller,
              maxLines: 6,
              autofocus: true,
              decoration: InputDecoration(
                hintText: AppStrings.adminNotePlaceholder,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppStrings.adminNoteCancel),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: HelpiTheme.accent),
              onPressed: () => onSave(ctx),
              child: Text(AppStrings.adminNoteSave),
            ),
          ],
        ),
      );
    } else {
      result = showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.viewInsetsOf(ctx).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 6,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: AppStrings.adminNotePlaceholder,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(AppStrings.adminNoteCancel),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: HelpiTheme.accent,
                    ),
                    onPressed: () => onSave(ctx),
                    child: Text(AppStrings.adminNoteSave),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    result.then((text) async {
      if (text == null) return;
      if (!mounted) return;

      if (isEdit) {
        // Update existing note via API
        final updateResult = await AdminApiService().updateAdminNote(
          id: existing.id,
          text: text,
        );
        if (!mounted) return;

        if (updateResult.success && updateResult.data != null) {
          setState(() {
            existing.text = text;
            existing.updatedAt = DateTime.now();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(updateResult.error ?? 'Error updating note'),
            ),
          );
        }
      } else {
        // Create new note via API
        final createResult = await AdminApiService().createAdminNote(
          entityType: widget.entityType,
          entityId: widget.entityId,
          text: text,
        );
        if (!mounted) return;

        if (createResult.success && createResult.data != null) {
          final newNote = AdminNote.fromJson(createResult.data!);
          setState(() => _notes?.insert(0, newNote));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(createResult.error ?? 'Error creating note'),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: AppStrings.adminNotes,
      icon: Icons.sticky_note_2,
      children: [
        ActionChipButton(
          icon: Icons.add,
          label: AppStrings.adminNoteAdd,
          color: HelpiTheme.accent,
          onTap: _addNote,
        ),
        const SizedBox(height: 12),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 36,
                    color: HelpiTheme.error,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: HelpiColors.of(context).textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _loadNotes,
                    child: Text(AppStrings.retry),
                  ),
                ],
              ),
            ),
          )
        else if (_notes == null || _notes!.isEmpty)
          SectionEmptyState(
            icon: Icons.sticky_note_2_outlined,
            message: AppStrings.adminNotesEmpty,
          )
        else
          ..._notes!.map(_buildNoteCard),
      ],
    );
  }

  Widget _buildNoteCard(AdminNote note) {
    final dateStr =
        '${formatDate(note.createdAt)} ${formatTime(note.createdAt)}';
    final editedSuffix = note.wasEdited
        ? ' (${AppStrings.adminNoteEdited})'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HelpiColors.of(context).scaffold,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$dateStr$editedSuffix',
                  style: TextStyle(
                    fontSize: 11,
                    color: HelpiColors.of(context).textSecondary,
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => _editNote(note),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.edit,
                    size: 16,
                    color: HelpiColors.of(context).textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => _deleteNote(note),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: HelpiColors.of(context).textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(note.text, style: const TextStyle(fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}
