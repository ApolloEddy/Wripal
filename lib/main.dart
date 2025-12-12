/// Wripal - 高性能跨平台写作助手
///
/// 应用入口文件

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/services/storage_service.dart';
import 'features/base/card_registry.dart';
import 'features/bookshelf/bookshelf_card.dart';
import 'features/bookshelf/application/book_repository.dart';
import 'features/handwriting/handwriting_card.dart';
import 'features/rich_editor/rich_editor_card.dart';

void main() async {
  // 确保 Flutter 绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化存储服务
  await StorageService.instance.initialize();

  // 初始化书籍仓库
  await BookRepository.instance.initialize();

  // 注册功能卡片
  CardRegistry.instance.registerAll([
    BookshelfCard(), // 书架（放在最前面）
    HandwritingCard(),
    RichEditorCard(),
    // 未来可以在这里添加更多卡片
  ]);

  // 运行应用
  runApp(const ProviderScope(child: WripalApp()));
}
