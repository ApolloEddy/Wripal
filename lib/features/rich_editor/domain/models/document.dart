/// 富文本文档模型
/// 
/// 管理富文本编辑器的文档状态

/// 文档模型
class RichDocument {
  /// 唯一标识符
  final String id;

  /// 文档标题
  final String title;

  /// 文档内容（Delta JSON 格式）
  final String content;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  /// 标签
  final List<String> tags;

  const RichDocument({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
  });

  /// 创建空文档
  factory RichDocument.empty(String id) {
    final now = DateTime.now();
    return RichDocument(
      id: id,
      title: '未命名文档',
      content: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 从 JSON 反序列化
  factory RichDocument.fromJson(Map<String, dynamic> json) {
    return RichDocument(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
    );
  }

  /// 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
    };
  }

  RichDocument copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
    List<String>? tags,
  }) {
    return RichDocument(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      tags: tags ?? this.tags,
    );
  }

  @override
  String toString() => 'RichDocument($id, $title)';
}
