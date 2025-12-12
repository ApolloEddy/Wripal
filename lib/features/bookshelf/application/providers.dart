/// 书架功能状态管理
///
/// 使用 Riverpod 提供书籍、章节等数据的状态管理
/// 包含书架列表、当前选中书籍、章节列表等 Provider

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../domain/models/book.dart';
import '../domain/models/chapter.dart';
import '../domain/models/character.dart';
import '../domain/models/plot_point.dart';
import '../domain/models/outline.dart';
import 'book_repository.dart';

const _uuid = Uuid();

// ==================== Repository Provider ====================

/// BookRepository 单例 Provider
final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository.instance;
});

// ==================== 书籍列表状态 ====================

/// 书籍列表状态
class BooksState {
  final List<Book> books;
  final bool isLoading;
  final String? error;

  const BooksState({this.books = const [], this.isLoading = false, this.error});

  BooksState copyWith({List<Book>? books, bool? isLoading, String? error}) {
    return BooksState(
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 书籍列表 Notifier
class BooksNotifier extends StateNotifier<BooksState> {
  final BookRepository _repository;

  BooksNotifier(this._repository) : super(const BooksState());

  /// 加载所有书籍
  Future<void> loadBooks() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final books = await _repository.getAllBooks();
      state = state.copyWith(books: books, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 创建新书籍
  Future<Book> createBook({required String title, String? description}) async {
    final book = Book.create(
      id: _uuid.v4(),
      title: title,
      description: description,
    );
    await _repository.saveBook(book);
    state = state.copyWith(books: [book, ...state.books]);
    return book;
  }

  /// 更新书籍
  Future<void> updateBook(Book book) async {
    final updatedBook = book.copyWith(updatedAt: DateTime.now());
    await _repository.saveBook(updatedBook);

    final newBooks = state.books.map((b) {
      return b.id == book.id ? updatedBook : b;
    }).toList();
    state = state.copyWith(books: newBooks);
  }

  /// 删除书籍
  Future<void> deleteBook(String id) async {
    await _repository.deleteBook(id);
    final newBooks = state.books.where((b) => b.id != id).toList();
    state = state.copyWith(books: newBooks);
  }

  /// 添加章节到书籍
  Future<void> addChapterToBook(String bookId, String chapterId) async {
    final book = state.books.firstWhere((b) => b.id == bookId);
    final updatedBook = book.copyWith(
      chapterIds: [...book.chapterIds, chapterId],
    );
    await updateBook(updatedBook);
  }

  /// 从书籍移除章节
  Future<void> removeChapterFromBook(String bookId, String chapterId) async {
    final book = state.books.firstWhere((b) => b.id == bookId);
    final updatedBook = book.copyWith(
      chapterIds: book.chapterIds.where((id) => id != chapterId).toList(),
    );
    await updateBook(updatedBook);
  }
}

/// 书籍列表 Provider
final booksProvider = StateNotifierProvider<BooksNotifier, BooksState>((ref) {
  final repository = ref.watch(bookRepositoryProvider);
  return BooksNotifier(repository);
});

// ==================== 当前选中书籍 ====================

/// 当前选中的书籍 ID
final selectedBookIdProvider = StateProvider<String?>((ref) => null);

/// 当前选中的书籍（派生 Provider）
final selectedBookProvider = Provider<Book?>((ref) {
  final selectedId = ref.watch(selectedBookIdProvider);
  if (selectedId == null) return null;

  final booksState = ref.watch(booksProvider);
  try {
    return booksState.books.firstWhere((b) => b.id == selectedId);
  } catch (_) {
    return null;
  }
});

// ==================== 章节列表 ====================

/// 章节列表状态
class ChaptersState {
  final List<Chapter> chapters;
  final bool isLoading;
  final String? error;

  const ChaptersState({
    this.chapters = const [],
    this.isLoading = false,
    this.error,
  });

  ChaptersState copyWith({
    List<Chapter>? chapters,
    bool? isLoading,
    String? error,
  }) {
    return ChaptersState(
      chapters: chapters ?? this.chapters,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 章节列表 Notifier
class ChaptersNotifier extends StateNotifier<ChaptersState> {
  final BookRepository _repository;
  final String bookId;
  final Ref _ref;

  ChaptersNotifier(this._repository, this.bookId, this._ref)
    : super(const ChaptersState());

  /// 加载书籍的所有章节
  Future<void> loadChapters() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final chapters = await _repository.getChaptersForBook(bookId);
      state = state.copyWith(chapters: chapters, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 创建新章节
  Future<Chapter> createChapter({required String title}) async {
    final chapter = Chapter.create(
      id: _uuid.v4(),
      bookId: bookId,
      title: title,
      orderIndex: state.chapters.length,
    );
    await _repository.saveChapter(chapter);

    // 更新书籍的章节 ID 列表
    _ref.read(booksProvider.notifier).addChapterToBook(bookId, chapter.id);

    state = state.copyWith(chapters: [...state.chapters, chapter]);
    return chapter;
  }

  /// 更新章节
  Future<void> updateChapter(Chapter chapter) async {
    final updatedChapter = chapter.copyWith(updatedAt: DateTime.now());
    await _repository.saveChapter(updatedChapter);

    final newChapters = state.chapters.map((c) {
      return c.id == chapter.id ? updatedChapter : c;
    }).toList();
    state = state.copyWith(chapters: newChapters);
  }

  /// 删除章节
  Future<void> deleteChapter(String id) async {
    await _repository.deleteChapter(id);

    // 从书籍移除章节 ID
    _ref.read(booksProvider.notifier).removeChapterFromBook(bookId, id);

    final newChapters = state.chapters.where((c) => c.id != id).toList();
    state = state.copyWith(chapters: newChapters);
  }

  /// 重新排序章节
  Future<void> reorderChapters(int oldIndex, int newIndex) async {
    final chapters = [...state.chapters];
    final chapter = chapters.removeAt(oldIndex);
    chapters.insert(newIndex, chapter);

    // 更新所有章节的 orderIndex
    for (var i = 0; i < chapters.length; i++) {
      final updated = chapters[i].copyWith(orderIndex: i);
      chapters[i] = updated;
      await _repository.saveChapter(updated);
    }

    state = state.copyWith(chapters: chapters);
  }
}

/// 章节列表 Provider（根据 bookId 创建）
final chaptersProvider =
    StateNotifierProvider.family<ChaptersNotifier, ChaptersState, String>((
      ref,
      bookId,
    ) {
      final repository = ref.watch(bookRepositoryProvider);
      return ChaptersNotifier(repository, bookId, ref);
    });

// ==================== 角色列表 ====================

/// 获取书籍的所有角色
final charactersProvider = FutureProvider.family<List<Character>, String>((
  ref,
  bookId,
) async {
  final repository = ref.watch(bookRepositoryProvider);
  return await repository.getCharactersForBook(bookId);
});

// ==================== 情节点列表 ====================

/// 获取书籍的所有情节点
final plotPointsProvider = FutureProvider.family<List<PlotPoint>, String>((
  ref,
  bookId,
) async {
  final repository = ref.watch(bookRepositoryProvider);
  return await repository.getPlotPointsForBook(bookId);
});

// ==================== 大纲 ====================

/// 获取书籍的大纲
final outlineProvider = FutureProvider.family<Outline?, String>((
  ref,
  bookId,
) async {
  final repository = ref.watch(bookRepositoryProvider);
  return await repository.getOutlineForBook(bookId);
});
