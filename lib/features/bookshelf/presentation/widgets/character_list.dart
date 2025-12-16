/// 角色列表组件
///
/// 展示书籍的所有角色，支持创建、编辑和删除

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../shared/widgets/card_container.dart';
import '../../application/providers.dart';
import '../../domain/models/character.dart';

const _uuid = Uuid();

/// 角色列表组件
class CharacterList extends ConsumerWidget {
  final String bookId;

  const CharacterList({super.key, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charactersAsync = ref.watch(charactersProvider(bookId));
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // 工具栏
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              charactersAsync.when(
                data: (chars) => Text(
                  '共 ${chars.length} 个角色',
                  style: TextStyle(color: colorScheme.outline),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _showCreateCharacterDialog(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('新建角色'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 角色网格
        Expanded(
          child: charactersAsync.when(
            data: (characters) => _buildCharacterGrid(context, ref, characters),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('加载失败：$error')),
          ),
        ),
      ],
    );
  }

  /// 构建角色网格
  Widget _buildCharacterGrid(
    BuildContext context,
    WidgetRef ref,
    List<Character> characters,
  ) {
    if (characters.isEmpty) {
      return _buildEmptyState(context, ref);
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: characters.length,
      itemBuilder: (context, index) {
        final character = characters[index];
        return _CharacterCard(
          character: character,
          onTap: () => _showEditCharacterDialog(context, ref, character),
          onDelete: () => _deleteCharacter(context, ref, character),
        );
      },
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text('还没有创建任何角色', style: TextStyle(color: colorScheme.outline)),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () => _showCreateCharacterDialog(context, ref),
            child: const Text('创建第一个角色'),
          ),
        ],
      ),
    );
  }

  /// 显示创建角色对话框
  Future<void> _showCreateCharacterDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    CharacterRole selectedRole = CharacterRole.supporting;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('新建角色'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '角色名称',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<CharacterRole>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(
                    labelText: '角色类型',
                    border: OutlineInputBorder(),
                  ),
                  items: CharacterRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(_getRoleDisplayName(role)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedRole = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '角色描述',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('创建'),
            ),
          ],
        ),
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      final character = Character(
        id: _uuid.v4(),
        bookId: bookId,
        name: nameController.text,
        role: selectedRole,
        description: descriptionController.text.isEmpty
            ? null
            : descriptionController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final repository = ref.read(bookRepositoryProvider);
      await repository.saveCharacter(character);

      // 刷新列表
      ref.invalidate(charactersProvider(bookId));
    }

    nameController.dispose();
    descriptionController.dispose();
  }

  /// 显示编辑角色对话框
  Future<void> _showEditCharacterDialog(
    BuildContext context,
    WidgetRef ref,
    Character character,
  ) async {
    final nameController = TextEditingController(text: character.name);
    final descriptionController = TextEditingController(
      text: character.description ?? '',
    );
    CharacterRole selectedRole = character.role;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('编辑角色'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '角色名称',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<CharacterRole>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(
                    labelText: '角色类型',
                    border: OutlineInputBorder(),
                  ),
                  items: CharacterRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(_getRoleDisplayName(role)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedRole = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '角色描述',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      final updatedCharacter = character.copyWith(
        name: nameController.text,
        role: selectedRole,
        description: descriptionController.text.isEmpty
            ? null
            : descriptionController.text,
      );

      final repository = ref.read(bookRepositoryProvider);
      await repository.saveCharacter(updatedCharacter);

      ref.invalidate(charactersProvider(bookId));
    }

    nameController.dispose();
    descriptionController.dispose();
  }

  /// 删除角色
  Future<void> _deleteCharacter(
    BuildContext context,
    WidgetRef ref,
    Character character,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除角色'),
        content: Text('确定要删除角色「${character.name}」吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repository = ref.read(bookRepositoryProvider);
      await repository.deleteCharacter(character.id);
      ref.invalidate(charactersProvider(bookId));
    }
  }

  String _getRoleDisplayName(CharacterRole role) {
    return switch (role) {
      CharacterRole.protagonist => '主角',
      CharacterRole.supporting => '配角',
      CharacterRole.antagonist => '反派',
      CharacterRole.minor => '路人',
      CharacterRole.other => '其他',
    };
  }
}

/// 角色卡片
class _CharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CharacterCard({
    required this.character,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 根据角色类型生成颜色
    final roleColor = switch (character.role) {
      CharacterRole.protagonist => Colors.amber,
      CharacterRole.supporting => Colors.blue,
      CharacterRole.antagonist => Colors.red,
      CharacterRole.minor => Colors.grey,
      CharacterRole.other => Colors.purple,
    };

    return CardContainer(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 头像
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: roleColor.withAlpha(30),
                  shape: BoxShape.circle,
                  border: Border.all(color: roleColor.withAlpha(100), width: 2),
                ),
                child: Center(
                  child: Text(
                    character.name.isNotEmpty ? character.name[0] : '?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: roleColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 名称
              Text(
                character.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // 类型标签
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: roleColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  character.roleDisplayName,
                  style: TextStyle(
                    fontSize: 10,
                    color: roleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 描述
              Expanded(
                child: Text(
                  character.description ?? '暂无描述',
                  style: TextStyle(fontSize: 11, color: colorScheme.outline),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),

              // 删除按钮
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: colorScheme.error,
                ),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
