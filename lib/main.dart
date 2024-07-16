import 'package:flutter/material.dart';

import 'vocabulary_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '超級單字app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LevelSelectionScreen(),
    );
  }
}

class LevelSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('選擇英文難度'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildLevelButton(context, 1, '英文1級'),
            buildLevelButton(context, 2, '英文2級'),
            buildLevelButton(context, 3, '英文3級'),
            buildLevelButton(context, 4, '英文4級'),
            buildLevelButton(context, 5, '英文5級'),
            buildLevelButton(context, 6, '英文6級'),
            buildLevelButton(context, 7, '英文7級'),
          ],
        ),
      ),
    );
  }

  Widget buildLevelButton(BuildContext context, int levelIndex, String label) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VocabularyListScreen(level: levelIndex),
          ),
        );
      },
      child: Text(label),
    );
  }
}
