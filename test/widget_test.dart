import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:math_kingdom_builder/app.dart';
import 'package:math_kingdom_builder/data/models/child_profile.dart';
import 'package:math_kingdom_builder/data/models/kingdom_state.dart';
import 'package:math_kingdom_builder/data/models/lesson_progress.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('math_kingdom_test_');
    Hive.init(tempDir.path);
    Hive.registerAdapter(ChildProfileAdapter());
    Hive.registerAdapter(KingdomStateAdapter());
    Hive.registerAdapter(KingdomItemAdapter());
    Hive.registerAdapter(LessonProgressAdapter());
  });

  tearDownAll(() {
    Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets('App loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MathKingdomApp()));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
