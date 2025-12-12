/// 大纲数据模型
///
/// 代表书籍的整体大纲，使用富文本（Delta JSON）格式存储内容
/// 每本书有且仅有一个大纲
/// 支持 JSON 序列化用于 Hive 持久化存储

/// 大纲模型
class Outline {
  /// 唯一标识符
  final String id;

  /// 所属书籍 ID
  final String bookId;

  /// 大纲内容（Delta JSON 格式）
  final String content;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  const Outline({
    required this.id,
    required this.bookId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 创建空大纲
  factory Outline.create({required String id, required String bookId}) {
    final now = DateTime.now();
    return Outline(
      id: id,
      bookId: bookId,
      content: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 从 JSON 反序列化
  factory Outline.fromJson(Map<String, dynamic> json) {
    return Outline(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      content: json['content'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 创建副本
  Outline copyWith({String? content, DateTime? updatedAt}) {
    return Outline(
      id: id,
      bookId: bookId,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// 是否为空大纲
  bool get isEmpty => content.isEmpty;

  @override
  String toString() => 'Outline($id, bookId: $bookId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Outline && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
