import 'package:flutter/material.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/models/admin_models.dart';
import 'package:helpi_admin/core/utils/formatters.dart';
import 'package:helpi_admin/core/widgets/shared_widgets.dart';

/// Admin notes section — add / edit / delete personal notes on any user.
class NotesSection extends StatefulWidget {
  const NotesSection({super.key, required this.notes});

  final List<AdminNote> notes;

  @override
  State<NotesSection> createState() => _NotesSectionState();
}

class _NotesSectionState extends State<NotesSection> {
  late List<AdminNote> _notes;

  @override
  void initState() {
    super.initState();
    _notes = widget.notes;
  }

  int _nextId = 1000;

  void _addNote() {
    _showNoteDialog(null);
  }

  void _editNote(AdminNote note) {
    _showNoteDialog(note);
  }

  void _deleteNote(AdminNote note) {
    showDialog<bool>(
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
    ).then((confirmed) {
      if (confirmed == true) {
        setState(() => _notes.remove(note));
      }
    });
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

    result.then((text) {
      if (text == null) return;
      setState(() {
        if (isEdit) {
          existing.text = text;
          existing.updatedAt = DateTime.now();
        } else {
          _notes.insert(
            0,
            AdminNote(
              id: 'n${_nextId++}',
              text: text,
              createdAt: DateTime.now(),
            ),
          );
        }
      });
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
        if (_notes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.sticky_note_2_outlined,
                    size: 36,
                    color: HelpiTheme.border,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.adminNotesEmpty,
                    style: const TextStyle(color: HelpiTheme.textSecondary),
                  ),
                ],
              ),
            ),
          )
        else
          ..._notes.map(_buildNoteCard),
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
        color: HelpiTheme.scaffold,
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
                  style: const TextStyle(
                    fontSize: 11,
                    color: HelpiTheme.textSecondary,
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => _editNote(note),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.edit,
                    size: 16,
                    color: HelpiTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => _deleteNote(note),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: HelpiTheme.textSecondary,
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
