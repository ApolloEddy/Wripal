/// 角色数据模型
///
/// 代表书籍中的一个角色/人物，包含角色的基本信息和描述
/// 支持 JSON 序列化用于 Hive 持久化存储

/// 角色类型枚举
enum CharacterRole {
  /// 主角
  protagonist,

  /// 配角
  supporting,

  /// 反派
  antagonist,

  /// 路人
  minor,

  /// 其他
  other,
}

/// 角色模型
class Character {
  /// 唯一标识符
  final String id;

  /// 所属书籍 ID
  final String bookId;

  /// 角色名称
  final String name;

  /// 角色类型
  final CharacterRole role;

  /// 角色描述/设定
  final String? description;

  /// 角色头像路径
  final String? avatarPath;

  /// 角色年龄
  final String? age;

  /// 角色性别
  final String? gender;

  /// 角色背景故事
  final String? background;

  /// 角色特征标签
  final List<String> traits;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  const Character({
    required this.id,
    required this.bookId,
    required this.name,
    this.role = CharacterRole.supporting,
    this.description,
    this.avatarPath,
    this.age,
    this.gender,
    this.background,
    this.traits = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// 创建新角色
  factory Character.create({
    required String id,
    required String bookId,
    required String name,
    CharacterRole role = CharacterRole.supporting,
  }) {
    final now = DateTime.now();
    return Character(
      id: id,
      bookId: bookId,
      name: name,
      role: role,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 从 JSON 反序列化
  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      name: json['name'] as String,
      role: CharacterRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => CharacterRole.supporting,
      ),
      description: json['description'] as String?,
      avatarPath: json['avatarPath'] as String?,
      age: json['age'] as String?,
      gender: json['gender'] as String?,
      background: json['background'] as String?,
      traits: (json['traits'] as List?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'name': name,
      'role': role.name,
      'description': description,
      'avatarPath': avatarPath,
      'age': age,
      'gender': gender,
      'background': background,
      'traits': traits,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 创建副本
  Character copyWith({
    String? name,
    CharacterRole? role,
    String? description,
    String? avatarPath,
    String? age,
    String? gender,
    String? background,
    List<String>? traits,
    DateTime? updatedAt,
  }) {
    return Character(
      id: id,
      bookId: bookId,
      name: name ?? this.name,
      role: role ?? this.role,
      description: description ?? this.description,
      avatarPath: avatarPath ?? this.avatarPath,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      background: background ?? this.background,
      traits: traits ?? this.traits,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// 获取角色类型的显示名称
  String get roleDisplayName {
    switch (role) {
      case CharacterRole.protagonist:
        return '主角';
      case CharacterRole.supporting:
        return '配角';
      case CharacterRole.antagonist:
        return '反派';
      case CharacterRole.minor:
        return '路人';
      case CharacterRole.other:
        return '其他';
    }
  }

  @override
  String toString() => 'Character($id, $name, $roleDisplayName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Character && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
