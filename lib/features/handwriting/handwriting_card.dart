/// 手写卡片实现
/// 
/// 手写笔记功能的卡片封装

import 'package:flutter/material.dart';

import '../base/feature_card.dart';
import 'presentation/widgets/drawing_canvas.dart';
import 'presentation/widgets/tool_palette.dart';

/// 手写卡片
class HandwritingCard extends FeatureCard {
  @override
  String get id => 'handwriting';

  @override
  String get name => '手写笔记';

  @override
  IconData get icon => Icons.edit_note_rounded;

  @override
  CardType get type => CardType.handwriting;

  @override
  String get description => '自由手写绘制笔记，支持多种笔触工具';

  @override
  bool get enabledByDefault => true;

  @override
  int get sortOrder => 0;

  @override
  Widget buildContent(BuildContext context) {
    return const Column(
      children: [
        // 工具栏
        ToolPalette(),
        
        // 画布区域
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: DrawingCanvas(),
          ),
        ),
      ],
    );
  }
}
