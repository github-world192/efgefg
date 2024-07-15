import 'package:flutter/material.dart';

class BigWordPage extends StatelessWidget {
  final String word;
  final String definition;

  BigWordPage({required this.word, required this.definition});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Big Word - $word'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              word,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Definition:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              definition,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
