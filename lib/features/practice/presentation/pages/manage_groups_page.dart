import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/practice_group.dart';
import '../../providers/practice_providers.dart';

class ManageGroupsPage extends ConsumerWidget {
  const ManageGroupsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final groupsAsync = ref.watch(practiceGroupsProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.maroon,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text(
          s.manageGroups,
          style: GoogleFonts.cormorantGaramond(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: groupsAsync.when(
        data: (groups) => groups.isEmpty
            ? Center(
                child: Text(
                  s.noGroups,
                  style: GoogleFonts.poppins(
                    color: AppColors.lightTextMuted,
                    fontSize: 13,
                  ),
                ),
              )
            : _GroupList(groups: groups),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.maroon,
        foregroundColor: Colors.white,
        onPressed: () => _showAddDialog(context, ref),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final s = S.of(context);
    final ctrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.lightBackground,
        title: Text(
          s.newGroup,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextPrimary,
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.lightTextPrimary),
          decoration: InputDecoration(
            hintText: s.groupNameHint,
            hintStyle: const TextStyle(color: AppColors.lightTextMuted),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.lightDivider),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.goldDim),
            ),
          ),
          onSubmitted: (_) => Navigator.pop(ctx, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              s.cancel,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: AppColors.lightTextMuted,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.maroon,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              s.save,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || ctrl.text.trim().isEmpty) return;
    final repo = await ref.read(groupRepositoryProvider.future);
    await repo.addGroup(ctrl.text.trim());
  }
}

// ─── Reorderable list ────────────────────────────────────────────────────────

class _GroupList extends ConsumerWidget {
  final List<PracticeGroup> groups;
  const _GroupList({required this.groups});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 100, top: 8),
      itemCount: groups.length,
      onReorderItem: (oldIndex, newIndex) async {
        final list = [...groups];
        final item = list.removeAt(oldIndex);
        list.insert(newIndex, item);
        final repo = await ref.read(groupRepositoryProvider.future);
        await repo.reorder(list);
      },
      itemBuilder: (context, i) => _GroupTile(
        key: ValueKey(groups[i].id),
        group: groups[i],
        index: i,
      ),
    );
  }
}

// ─── Group tile ───────────────────────────────────────────────────────────────

class _GroupTile extends ConsumerWidget {
  final PracticeGroup group;
  final int index;

  const _GroupTile({
    super.key,
    required this.group,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(24, 4, 8, 4),
      title: Text(
        group.name,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.lightTextPrimary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: AppColors.goldDim,
            onPressed: () => _rename(context, ref, s),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            color: AppColors.maroon.withValues(alpha: 0.7),
            onPressed: () => _delete(context, ref, s),
          ),
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.drag_handle, color: AppColors.lightTextMuted, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref, S s) async {
    final ctrl = TextEditingController(text: group.name);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.lightBackground,
        title: Text(
          group.name,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextPrimary,
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.lightTextPrimary),
          decoration: InputDecoration(
            hintText: s.groupNameHint,
            hintStyle: const TextStyle(color: AppColors.lightTextMuted),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.lightDivider),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.goldDim),
            ),
          ),
          onSubmitted: (_) => Navigator.pop(ctx, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              s.cancel,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: AppColors.lightTextMuted,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.maroon,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              s.save,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || ctrl.text.trim().isEmpty) return;
    final repo = await ref.read(groupRepositoryProvider.future);
    await repo.renameGroup(group.id, ctrl.text.trim());
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, S s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.lightBackground,
        title: Text(
          s.deleteGroupTitle,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextPrimary,
          ),
        ),
        content: Text(
          s.deleteGroupMessage,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.lightTextSecondary,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              s.cancel,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: AppColors.lightTextSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              s.delete,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: AppColors.maroon,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final repo = await ref.read(groupRepositoryProvider.future);
    await repo.deleteGroup(group.id);
  }
}
