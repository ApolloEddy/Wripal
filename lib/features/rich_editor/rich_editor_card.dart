/// 富文本编辑器卡片实现
/// 
/// 富文本编辑功能的卡片封装

import 'package:flutter/material.dart';

import '../base/feature_card.dart';
import 'presentation/widgets/rich_text_editor.dart';

/// 富文本编辑器卡片
class RichEditorCard extends FeatureCard {
  @override
  String get id => 'rich_editor';

  @override
  String get name => '富文本编辑';

  @override
  IconData get icon => Icons.article_outlined;

  @override
  CardType get type => CardType.richEditor;

  @override
  String get description => 'Markdown 风格的富文本编辑器';

  @override
  bool get enabledByDefault => true;

  @override
  int get sortOrder => 1;

  @override
  Widget buildContent(BuildContext context) {
    return const RichTextEditor();
  }
}
