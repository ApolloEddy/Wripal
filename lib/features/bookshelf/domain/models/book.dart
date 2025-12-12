/// 书籍数据模型
///
/// 代表书架中的一本书，包含书籍元信息和关联的章节、角色、情节等 ID
/// 支持 JSON 序列化用于 Hive 持久化存储

/// 书籍模型
class Book {
  /// 唯一标识符
  final String id;

  /// 书籍标题
  final String title;

  /// 书籍描述/简介
  final String? description;

  /// 封面图片路径（本地文件路径）
  final String? coverImagePath;

  /// 关联的章节 ID 列表（有序）
  final List<String> chapterIds;

  /// 关联的角色 ID 列表
  final List<String> characterIds;

  /// 关联的情节点 ID 列表（有序）
  final List<String> plotPointIds;

  /// 关联的大纲 ID
  final String? outlineId;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  /// 标签列表
  final List<String> tags;

  /// 书籍状态
  final BookStatus status;

  const Book({
    required this.id,
    required this.title,
    this.description,
    this.coverImagePath,
    this.chapterIds = const [],
    this.characterIds = const [],
    this.plotPointIds = const [],
    this.outlineId,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.status = BookStatus.draft,
  });

  /// 创建空书籍
  factory Book.create({
    required String id,
    required String title,
    String? description,
  }) {
    final now = DateTime.now();
    return Book(
      id: id,
      title: title,
      description: description,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 从 JSON 反序列化
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      coverImagePath: json['coverImagePath'] as String?,
      chapterIds: (json['chapterIds'] as List?)?.cast<String>() ?? [],
      characterIds: (json['characterIds'] as List?)?.cast<String>() ?? [],
      plotPointIds: (json['plotPointIds'] as List?)?.cast<String>() ?? [],
      outlineId: json['outlineId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      status: BookStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => BookStatus.draft,
      ),
    );
  }

  /// 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'coverImagePath': coverImagePath,
      'chapterIds': chapterIds,
      'characterIds': characterIds,
      'plotPointIds': plotPointIds,
      'outlineId': outlineId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
      'status': status.name,
    };
  }

  /// 创建副本
  Book copyWith({
    String? title,
    String? description,
    String? coverImagePath,
    List<String>? chapterIds,
    List<String>? characterIds,
    List<String>? plotPointIds,
    String? outlineId,
    DateTime? updatedAt,
    List<String>? tags,
    BookStatus? status,
  }) {
    return Book(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      chapterIds: chapterIds ?? this.chapterIds,
      characterIds: characterIds ?? this.characterIds,
      plotPointIds: plotPointIds ?? this.plotPointIds,
      outlineId: outlineId ?? this.outlineId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      tags: tags ?? this.tags,
      status: status ?? this.status,
    );
  }

  /// 计算总字数
  int get totalWordCount => 0; // 需要通过 Repository 获取章节数据计算

  /// 计算完成进度 (0.0 - 1.0)
  double get progress => 0.0; // 需要通过 Repository 获取章节数据计算

  @override
  String toString() => 'Book($id, $title)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Book && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 书籍状态枚举
enum BookStatus {
  /// 草稿
  draft,

  /// 写作中
  writing,

  /// 已完成
  completed,

  /// 已归档
  archived,
}
