/// 章节数据模型
///
/// 代表书籍中的一个章节，包含实际内容文本
/// 支持 JSON 序列化用于 Hive 持久化存储

/// 章节模型
class Chapter {
  /// 唯一标识符
  final String id;

  /// 所属书籍 ID
  final String bookId;

  /// 章节标题
  final String title;

  /// 排序索引（用于章节顺序）
  final int orderIndex;

  /// 章节内容文本
  final String content;

  /// 关联的富文本文档 ID（存储实际内容）
  final String? contentId;

  /// 是否已完成
  final bool isCompleted;

  /// 字数统计
  final int wordCount;

  /// 章节摘要/备注
  final String? summary;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  const Chapter({
    required this.id,
    required this.bookId,
    required this.title,
    required this.orderIndex,
    this.content = '',
    this.contentId,
    this.isCompleted = false,
    this.wordCount = 0,
    this.summary,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 创建新章节
  factory Chapter.create({
    required String id,
    required String bookId,
    required String title,
    required int orderIndex,
  }) {
    final now = DateTime.now();
    return Chapter(
      id: id,
      bookId: bookId,
      title: title,
      orderIndex: orderIndex,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 从 JSON 反序列化
  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      title: json['title'] as String,
      orderIndex: json['orderIndex'] as int,
      content: json['content'] as String? ?? '',
      contentId: json['contentId'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      wordCount: json['wordCount'] as int? ?? 0,
      summary: json['summary'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'title': title,
      'orderIndex': orderIndex,
      'content': content,
      'contentId': contentId,
      'isCompleted': isCompleted,
      'wordCount': wordCount,
      'summary': summary,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 创建副本
  Chapter copyWith({
    String? title,
    int? orderIndex,
    String? content,
    String? contentId,
    bool? isCompleted,
    int? wordCount,
    String? summary,
    DateTime? updatedAt,
  }) {
    return Chapter(
      id: id,
      bookId: bookId,
      title: title ?? this.title,
      orderIndex: orderIndex ?? this.orderIndex,
      content: content ?? this.content,
      contentId: contentId ?? this.contentId,
      isCompleted: isCompleted ?? this.isCompleted,
      wordCount: wordCount ?? this.wordCount,
      summary: summary ?? this.summary,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() => 'Chapter($id, $title, order: $orderIndex)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Chapter && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
