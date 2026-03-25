import 'package:fetubola/models/news.dart';
import 'package:flutter/material.dart';

class NewsProvider extends ChangeNotifier {
  final List<News> _allNews;
  NewsProvider(this._allNews);

  String _searchQuery = '';

  List<News> get filteredNews {
    if (_searchQuery.isEmpty) return _allNews;
    final query = _searchQuery.toLowerCase();
    return _allNews
        .where(
          (news) =>
              news.title.toLowerCase().contains(query) ||
              news.content.toLowerCase().contains(query),
        )
        .toList();
  }

  void updateSearch(String query) {
    debugPrint('TERMO DE BUSCA ATUALIZADO: $query');
    _searchQuery = query;
    notifyListeners();
  }
}
