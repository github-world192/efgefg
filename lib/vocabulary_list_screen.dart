import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VocabularyListScreen extends StatefulWidget {
  final int level;

  VocabularyListScreen({required this.level});

  @override
  _VocabularyListScreenState createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends State<VocabularyListScreen> {
  List<dynamic> _vocabularyList = [];

  @override
  void initState() {
    super.initState();
    _fetchVocabularyList();
  }

  Future<void> _fetchVocabularyList() async {
    final url = 'https://raw.githubusercontent.com/AppPeterPan/TaiwanSchoolEnglishVocabulary/main/${widget.level}%E7%B4%9A.json';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        _vocabularyList = json.decode(utf8.decode(response.bodyBytes));
      });
    } else {
      throw Exception('Failed to load vocabulary list');
    }
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: _vocabularyList.length,
      itemBuilder: (context, index) {
        var word = _vocabularyList[index]['word'];
        var definition = _vocabularyList[index]['definitions'][0]['text'];
        return ListTile(
          title: Text(
            word,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          subtitle: Text(definition),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BigWordPage(word: word, definition: definition),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('English Vocabulary Level ${widget.level}'),
      ),
      body: _vocabularyList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : _buildList(),
    );
  }
}

class BigWordPage extends StatelessWidget {
  final String word;
  final String definition;

  BigWordPage({required this.word, required this.definition});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(word),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            definition,
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      ),
    );
  }
}
