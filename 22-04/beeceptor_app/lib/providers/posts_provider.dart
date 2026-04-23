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

  /// Carrega os posts da API externa
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

  /// Cria um novo post via API e adiciona na lista local
  Future<void> addPost(Post post) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPost = await _postsService.createPost(post);
      _posts.insert(0, newPost);
    } catch (e) {
      _error = 'Erro ao criar post: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Atualiza um post via API e na lista local
  Future<void> updatePost(Post post) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedPost = await _postsService.updatePost(post);
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _posts[index] = updatedPost;
      }
    } catch (e) {
      _error = 'Erro ao atualizar post: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deleta um post via API e remove da lista local
  Future<void> deletePost(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _postsService.deletePost(id);
      _posts.removeWhere((p) => p.id == id);
    } catch (e) {
      _error = 'Erro ao deletar post: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
