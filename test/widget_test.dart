import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vocabpass/main.dart';
import 'package:vocabpass/vocabulary_list_screen.dart';

void main() {
  group('LevelSelectionScreen 測試', () {
    testWidgets('啟動後顯示主要標題與第一層級內容', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.text('選擇英文難度'), findsOneWidget);
      expect(find.text('選擇你的學習程度'), findsOneWidget);
      expect(find.text('英文1級'), findsOneWidget);
      expect(find.byIcon(Icons.school), findsOneWidget);
    });

    testWidgets('可滑動看到較後面的級別卡片', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.scrollUntilVisible(
        find.text('英文7級'),
        300,
        scrollable: find.byType(Scrollable),
      );
      await tester.pump();

      expect(find.text('英文7級'), findsOneWidget);
      expect(find.text('專業程度'), findsOneWidget);
    });
  });

  group('BigWordPage 測試', () {
    testWidgets('單字詳情頁顯示單字、定義與返回按鈕', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BigWordPage(
            word: 'apple',
            definition: '蘋果',
          ),
        ),
      );

      expect(find.text('apple'), findsWidgets);
      expect(find.text('蘋果'), findsOneWidget);
      expect(find.text('返回單字列表'), findsOneWidget);
    });
  });
}
