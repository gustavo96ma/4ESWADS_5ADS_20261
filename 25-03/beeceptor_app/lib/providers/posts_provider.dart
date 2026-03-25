import 'package:beeceptor_app/models/post.dart';
import 'package:beeceptor_app/services/posts_service.dart';
import 'package:flutter/material.dart';

class PostsProvider extends ChangeNotifier {
  final PostsService _postsService;
  PostsProvider(this._postsService);

  /// Lista de posts
  List<Post> _posts = [];
  List<Post> get posts => _posts;

  /// Controle de estado de carregamento
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Controle de erro
  String? _error;
  String? get error => _error;

  /// Método principal: carrega os posts da API externa
  Future<void> fetchPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _posts = await _postsService.getPosts();
    } catch (e) {
      _error = 'Erro ao carregar posts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
