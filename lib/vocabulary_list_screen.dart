import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VocabularyListScreen extends StatefulWidget {
  final int level;

  const VocabularyListScreen({super.key, required this.level});

  @override
  State<VocabularyListScreen> createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends State<VocabularyListScreen> {
  List<dynamic> _vocabularyList = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isFromCache = false;
  String _searchQuery = '';
  bool _showFavoritesOnly = false;
  Set<String> _favoriteWords = <String>{};
  Set<String> _learnedWords = <String>{};

  @override
  void initState() {
    super.initState();
    _loadVocabularyList();
  }

  String get _cacheKey => 'vocabulary_level_${widget.level}';
  String get _favoriteWordsKey => 'favorite_words_level_${widget.level}';
  String get _learnedWordsKey => 'learned_words_level_${widget.level}';

  Future<void> _loadVocabularyList() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await _loadWordStates();

    final cachedData = await _loadFromCache();
    if (cachedData != null && cachedData.isNotEmpty) {
      setState(() {
        _vocabularyList = cachedData;
        _isLoading = false;
        _isFromCache = true;
      });
    }

    await _fetchFromNetwork();
  }

  Future<void> _loadWordStates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteWords = prefs.getStringList(_favoriteWordsKey) ?? <String>[];
      final learnedWords = prefs.getStringList(_learnedWordsKey) ?? <String>[];
      setState(() {
        _favoriteWords = favoriteWords.toSet();
        _learnedWords = learnedWords.toSet();
      });
    } catch (e) {
      debugPrint('Failed to load word states: $e');
    }
  }

  Future<void> _saveFavoriteWords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoriteWordsKey, _favoriteWords.toList());
  }

  Future<void> _saveLearnedWords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_learnedWordsKey, _learnedWords.toList());
  }

  Future<List<dynamic>?> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson != null) {
        return json.decode(cachedJson) as List<dynamic>;
      }
    } catch (e) {
      debugPrint('Failed to load from cache: $e');
    }
    return null;
  }

  Future<void> _saveToCache(List<dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(data);
      await prefs.setString(_cacheKey, jsonString);
      debugPrint('Saved ${data.length} words to cache for level ${widget.level}');
    } catch (e) {
      debugPrint('Failed to save to cache: $e');
    }
  }

  Future<void> _fetchFromNetwork() async {
    try {
      final url =
          'https://raw.githubusercontent.com/AppPeterPan/TaiwanSchoolEnglishVocabulary/main/${widget.level}%E7%B4%9A.json';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedData = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        await _saveToCache(decodedData);

        if (mounted) {
          setState(() {
            _vocabularyList = decodedData;
            _isLoading = false;
            _isFromCache = false;
            _errorMessage = null;
          });
        }
      } else if (_vocabularyList.isEmpty) {
        setState(() {
          _errorMessage = '無法載入單字列表 (錯誤碼: ${response.statusCode})';
          _isLoading = false;
        });
      } else {
        _showCacheWarning();
      }
    } catch (e) {
      if (_vocabularyList.isEmpty) {
        setState(() {
          _errorMessage = '網路連線失敗，請檢查網路設定';
          _isLoading = false;
        });
      } else {
        _showCacheWarning();
      }
    }
  }

  void _showCacheWarning() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.offline_bolt, color: Colors.white),
              SizedBox(width: 8),
              Text('網路連線失敗，顯示快取資料'),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _refreshVocabularyList() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await _fetchFromNetwork();
  }

  String _extractWord(dynamic wordData) {
    if (wordData is Map<String, dynamic>) {
      return (wordData['word'] ?? '').toString();
    }
    if (wordData is Map) {
      return (wordData['word'] ?? '').toString();
    }
    return '';
  }

  String _extractDefinition(dynamic wordData) {
    if (wordData is! Map) {
      return '無定義';
    }
    final definitions = wordData['definitions'];
    if (definitions is List && definitions.isNotEmpty && definitions.first is Map) {
      return (definitions.first['text'] ?? '無定義').toString();
    }
    return '無定義';
  }

  List<dynamic> get _filteredVocabularyList {
    final query = _searchQuery.trim().toLowerCase();

    return _vocabularyList.where((wordData) {
      final word = _extractWord(wordData);
      final wordMatches = query.isEmpty || word.toLowerCase().contains(query);
      if (!wordMatches) {
        return false;
      }
      if (_showFavoritesOnly && !_favoriteWords.contains(word)) {
        return false;
      }
      return true;
    }).toList();
  }

  int get _learnedCount {
    return _vocabularyList.where((item) => _learnedWords.contains(_extractWord(item))).length;
  }

  double get _progressValue {
    if (_vocabularyList.isEmpty) {
      return 0;
    }
    return _learnedCount / _vocabularyList.length;
  }

  Future<void> _toggleFavorite(String word) async {
    setState(() {
      if (_favoriteWords.contains(word)) {
        _favoriteWords.remove(word);
      } else {
        _favoriteWords.add(word);
      }
    });
    await _saveFavoriteWords();
  }

  Future<void> _markAsLearned(String word) async {
    if (_learnedWords.contains(word)) {
      return;
    }
    setState(() {
      _learnedWords.add(word);
    });
    await _saveLearnedWords();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            '載入單字中...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? '發生錯誤',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshVocabularyList,
              icon: const Icon(Icons.refresh),
              label: const Text('重新載入'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndProgressPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: '搜尋單字...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              FilterChip(
                label: const Text('只看收藏'),
                selected: _showFavoritesOnly,
                onSelected: (value) {
                  setState(() {
                    _showFavoritesOnly = value;
                  });
                },
              ),
              const Spacer(),
              Text(
                '已學習 $_learnedCount / ${_vocabularyList.length}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: _progressValue,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<dynamic> filteredList) {
    if (filteredList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _searchQuery.isNotEmpty || _showFavoritesOnly ? '找不到符合條件的單字' : '目前沒有單字資料',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final wordData = filteredList[index];
        final word = _extractWord(wordData);
        final definition = _extractDefinition(wordData);
        final isFavorite = _favoriteWords.contains(word);
        final isLearned = _learnedWords.contains(word);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () async {
              await _markAsLearned(word);
              if (!context.mounted) {
                return;
              }
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BigWordPage(
                    word: word,
                    definition: definition,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                word,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            if (isLearned)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '已學習',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          definition,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          color: isFavorite ? Colors.amber.shade700 : Colors.grey.shade400,
                        ),
                        tooltip: isFavorite ? '取消收藏' : '加入收藏',
                        onPressed: () {
                          _toggleFavorite(word);
                        },
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredVocabularyList;

    return Scaffold(
      appBar: AppBar(
        title: Text('英文 ${widget.level} 級單字'),
        centerTitle: true,
        actions: [
          if (_isFromCache)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.offline_bolt,
                        size: 16,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '離線',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: '目前顯示 ${filteredList.length} 個單字',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('目前顯示 ${filteredList.length} 個單字（總數 ${_vocabularyList.length}）'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '重新載入',
            onPressed: _refreshVocabularyList,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : Column(
                  children: [
                    _buildSearchAndProgressPanel(),
                    Expanded(
                      child: _buildList(filteredList),
                    ),
                  ],
                ),
    );
  }
}

class BigWordPage extends StatelessWidget {
  final String word;
  final String definition;

  const BigWordPage({
    super.key,
    required this.word,
    required this.definition,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(word),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(32.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade400,
                          Colors.blue.shade600,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.book,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          word,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.description,
                              color: Colors.blue.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '定義',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            definition,
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('返回單字列表'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
