/// 书籍存储仓库
///
/// 使用 Hive 实现书籍及相关数据（章节、角色、情节、大纲）的 CRUD 操作
/// 提供统一的数据访问接口，支持级联删除

import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../domain/models/book.dart';
import '../domain/models/chapter.dart';
import '../domain/models/character.dart';
import '../domain/models/plot_point.dart';
import '../domain/models/outline.dart';

/// Hive Box 名称常量
class BookStorageKeys {
  BookStorageKeys._();

  static const String booksBox = 'books_box';
  static const String chaptersBox = 'chapters_box';
  static const String charactersBox = 'characters_box';
  static const String plotPointsBox = 'plot_points_box';
  static const String outlinesBox = 'outlines_box';
}

/// 书籍存储仓库
class BookRepository {
  BookRepository._();
  static final BookRepository instance = BookRepository._();

  Box<String>? _booksBox;
  Box<String>? _chaptersBox;
  Box<String>? _charactersBox;
  Box<String>? _plotPointsBox;
  Box<String>? _outlinesBox;

  bool _initialized = false;

  /// 初始化仓库，打开所有 Hive Box
  Future<void> initialize() async {
    if (_initialized) return;

    _booksBox = await Hive.openBox<String>(BookStorageKeys.booksBox);
    _chaptersBox = await Hive.openBox<String>(BookStorageKeys.chaptersBox);
    _charactersBox = await Hive.openBox<String>(BookStorageKeys.charactersBox);
    _plotPointsBox = await Hive.openBox<String>(BookStorageKeys.plotPointsBox);
    _outlinesBox = await Hive.openBox<String>(BookStorageKeys.outlinesBox);

    _initialized = true;
  }

  // ==================== 书籍 CRUD ====================

  /// 保存书籍
  Future<void> saveBook(Book book) async {
    await _ensureInitialized();
    final jsonStr = jsonEncode(book.toJson());
    await _booksBox!.put(book.id, jsonStr);
  }

  /// 获取单本书籍
  Future<Book?> getBook(String id) async {
    await _ensureInitialized();
    final jsonStr = _booksBox!.get(id);
    if (jsonStr == null) return null;
    return Book.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }

  /// 获取所有书籍
  Future<List<Book>> getAllBooks() async {
    await _ensureInitialized();
    final books = <Book>[];
    for (final jsonStr in _booksBox!.values) {
      books.add(Book.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>));
    }
    // 按更新时间降序排列
    books.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return books;
  }

  /// 删除书籍（级联删除关联数据）
  Future<void> deleteBook(String id) async {
    await _ensureInitialized();

    final book = await getBook(id);
    if (book == null) return;

    // 级联删除章节
    for (final chapterId in book.chapterIds) {
      await _chaptersBox!.delete(chapterId);
    }

    // 级联删除角色
    for (final characterId in book.characterIds) {
      await _charactersBox!.delete(characterId);
    }

    // 级联删除情节点
    for (final plotPointId in book.plotPointIds) {
      await _plotPointsBox!.delete(plotPointId);
    }

    // 级联删除大纲
    if (book.outlineId != null) {
      await _outlinesBox!.delete(book.outlineId);
    }

    // 删除书籍本身
    await _booksBox!.delete(id);
  }

  // ==================== 章节 CRUD ====================

  /// 保存章节
  Future<void> saveChapter(Chapter chapter) async {
    await _ensureInitialized();
    final jsonStr = jsonEncode(chapter.toJson());
    await _chaptersBox!.put(chapter.id, jsonStr);
  }

  /// 获取单个章节
  Future<Chapter?> getChapter(String id) async {
    await _ensureInitialized();
    final jsonStr = _chaptersBox!.get(id);
    if (jsonStr == null) return null;
    return Chapter.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }

  /// 获取书籍的所有章节（按 orderIndex 排序）
  Future<List<Chapter>> getChaptersForBook(String bookId) async {
    await _ensureInitialized();
    final chapters = <Chapter>[];
    for (final jsonStr in _chaptersBox!.values) {
      final chapter = Chapter.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );
      if (chapter.bookId == bookId) {
        chapters.add(chapter);
      }
    }
    chapters.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return chapters;
  }

  /// 删除章节
  Future<void> deleteChapter(String id) async {
    await _ensureInitialized();
    await _chaptersBox!.delete(id);
  }

  // ==================== 角色 CRUD ====================

  /// 保存角色
  Future<void> saveCharacter(Character character) async {
    await _ensureInitialized();
    final jsonStr = jsonEncode(character.toJson());
    await _charactersBox!.put(character.id, jsonStr);
  }

  /// 获取单个角色
  Future<Character?> getCharacter(String id) async {
    await _ensureInitialized();
    final jsonStr = _charactersBox!.get(id);
    if (jsonStr == null) return null;
    return Character.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }

  /// 获取书籍的所有角色
  Future<List<Character>> getCharactersForBook(String bookId) async {
    await _ensureInitialized();
    final characters = <Character>[];
    for (final jsonStr in _charactersBox!.values) {
      final character = Character.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );
      if (character.bookId == bookId) {
        characters.add(character);
      }
    }
    // 按角色类型排序（主角优先）
    characters.sort((a, b) => a.role.index.compareTo(b.role.index));
    return characters;
  }

  /// 删除角色
  Future<void> deleteCharacter(String id) async {
    await _ensureInitialized();
    await _charactersBox!.delete(id);
  }

  // ==================== 情节点 CRUD ====================

  /// 保存情节点
  Future<void> savePlotPoint(PlotPoint plotPoint) async {
    await _ensureInitialized();
    final jsonStr = jsonEncode(plotPoint.toJson());
    await _plotPointsBox!.put(plotPoint.id, jsonStr);
  }

  /// 获取单个情节点
  Future<PlotPoint?> getPlotPoint(String id) async {
    await _ensureInitialized();
    final jsonStr = _plotPointsBox!.get(id);
    if (jsonStr == null) return null;
    return PlotPoint.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }

  /// 获取书籍的所有情节点（按 orderIndex 排序）
  Future<List<PlotPoint>> getPlotPointsForBook(String bookId) async {
    await _ensureInitialized();
    final plotPoints = <PlotPoint>[];
    for (final jsonStr in _plotPointsBox!.values) {
      final plotPoint = PlotPoint.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );
      if (plotPoint.bookId == bookId) {
        plotPoints.add(plotPoint);
      }
    }
    plotPoints.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return plotPoints;
  }

  /// 删除情节点
  Future<void> deletePlotPoint(String id) async {
    await _ensureInitialized();
    await _plotPointsBox!.delete(id);
  }

  // ==================== 大纲 CRUD ====================

  /// 保存大纲
  Future<void> saveOutline(Outline outline) async {
    await _ensureInitialized();
    final jsonStr = jsonEncode(outline.toJson());
    await _outlinesBox!.put(outline.id, jsonStr);
  }

  /// 获取大纲
  Future<Outline?> getOutline(String id) async {
    await _ensureInitialized();
    final jsonStr = _outlinesBox!.get(id);
    if (jsonStr == null) return null;
    return Outline.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }

  /// 获取书籍的大纲
  Future<Outline?> getOutlineForBook(String bookId) async {
    await _ensureInitialized();
    for (final jsonStr in _outlinesBox!.values) {
      final outline = Outline.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );
      if (outline.bookId == bookId) {
        return outline;
      }
    }
    return null;
  }

  /// 删除大纲
  Future<void> deleteOutline(String id) async {
    await _ensureInitialized();
    await _outlinesBox!.delete(id);
  }

  // ==================== 辅助方法 ====================

  /// 确保已初始化
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  /// 关闭所有 Box
  Future<void> close() async {
    await _booksBox?.close();
    await _chaptersBox?.close();
    await _charactersBox?.close();
    await _plotPointsBox?.close();
    await _outlinesBox?.close();
    _initialized = false;
  }
}
