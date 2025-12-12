/// 书架卡片实现
///
/// 书架功能的卡片封装，作为可拔插功能模块集成到主界面

import 'package:flutter/material.dart';

import '../base/feature_card.dart';
import 'presentation/pages/bookshelf_page.dart';

/// 书架卡片
class BookshelfCard extends FeatureCard {
  @override
  String get id => 'bookshelf';

  @override
  String get name => '书架';

  @override
  IconData get icon => Icons.library_books_outlined;

  @override
  CardType get type => CardType.fileManager;

  @override
  String get description => '管理您的书籍创作，包括章节、大纲、角色和情节';

  @override
  bool get enabledByDefault => true;

  @override
  int get sortOrder => 0; // 放在最前面

  @override
  Widget buildContent(BuildContext context) {
    return const BookshelfPage();
  }
}
