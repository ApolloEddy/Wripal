// Wripal 基础 Widget 测试

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wripal/app/app.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    // 构建应用
    await tester.pumpWidget(
      const ProviderScope(
        child: WripalApp(),
      ),
    );

    // 验证应用标题
    expect(find.text('Wripal'), findsWidgets);
  });
}
