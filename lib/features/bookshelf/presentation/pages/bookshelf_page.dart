/// 书架主页面
///
/// 展示用户所有书籍的网格视图，支持创建新书籍和搜索

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/card_container.dart';
import '../../application/providers.dart';
import '../../domain/models/book.dart';
import '../widgets/book_card.dart';
import 'book_detail_page.dart';

/// 书架主页面
class BookshelfPage extends ConsumerStatefulWidget {
  const BookshelfPage({super.key});

  @override
  ConsumerState<BookshelfPage> createState() => _BookshelfPageState();
}

class _BookshelfPageState extends ConsumerState<BookshelfPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // 初始化时加载书籍列表
    Future.microtask(() {
      ref.read(booksProvider.notifier).loadBooks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booksState = ref.watch(booksProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // 顶部工具栏
        _buildToolbar(context, colorScheme),

        // 书籍网格
        Expanded(child: _buildBookGrid(context, booksState)),
      ],
    );
  }

  /// 构建顶部工具栏
  Widget _buildToolbar(BuildContext context, ColorScheme colorScheme) {
    return CardContainer(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 标题
          Icon(
            Icons.library_books_outlined,
            color: colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            '我的书架',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const Spacer(),

          // 搜索框
          SizedBox(
            width: 240,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索书籍...',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withAlpha(100),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          const SizedBox(width: 12),

          // 新建书籍按钮
          FilledButton.icon(
            onPressed: () => _showCreateBookDialog(context),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('新建书籍'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建书籍网格
  Widget _buildBookGrid(BuildContext context, BooksState booksState) {
    if (booksState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (booksState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text('加载失败：${booksState.error}'),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () => ref.read(booksProvider.notifier).loadBooks(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // 筛选书籍
    final filteredBooks = booksState.books.where((book) {
      if (_searchQuery.isEmpty) return true;
      return book.title.toLowerCase().contains(_searchQuery) ||
          (book.description?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();

    if (filteredBooks.isEmpty) {
      return _buildEmptyState(context);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredBooks.length,
        itemBuilder: (context, index) {
          final book = filteredBooks[index];
          return BookCard(
            book: book,
            onTap: () => _openBookDetail(context, book),
            onDelete: () => _deleteBook(context, book),
          );
        },
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colorScheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.auto_stories_outlined,
              size: 64,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isEmpty ? '还没有创建任何书籍' : '没有找到匹配的书籍',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty ? '点击上方按钮开始您的创作之旅' : '尝试使用其他关键词搜索',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showCreateBookDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('创建第一本书'),
            ),
          ],
        ],
      ),
    );
  }

  /// 显示创建书籍对话框
  Future<void> _showCreateBookDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建新书籍'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '书籍标题',
                  hintText: '输入书籍名称',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '书籍简介（可选）',
                  hintText: '简单描述这本书的内容',
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
    );

    if (result == true && titleController.text.isNotEmpty) {
      await ref
          .read(booksProvider.notifier)
          .createBook(
            title: titleController.text,
            description: descriptionController.text.isEmpty
                ? null
                : descriptionController.text,
          );
    }

    titleController.dispose();
    descriptionController.dispose();
  }

  /// 打开书籍详情页
  void _openBookDetail(BuildContext context, Book book) {
    ref.read(selectedBookIdProvider.notifier).state = book.id;

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => BookDetailPage(bookId: book.id)),
    );
  }

  /// 删除书籍
  Future<void> _deleteBook(BuildContext context, Book book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除书籍'),
        content: Text('确定要删除《${book.title}》吗？\n\n此操作将同时删除所有章节、角色和情节数据，且无法恢复。'),
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
      await ref.read(booksProvider.notifier).deleteBook(book.id);
    }
  }
}
