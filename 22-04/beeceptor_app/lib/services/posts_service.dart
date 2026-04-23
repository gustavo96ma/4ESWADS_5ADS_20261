import 'package:beeceptor_app/models/post.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class PostsService {
  final Dio _dio;
  final String _baseUrl = 'https://json-placeholder.mock.beeceptor.com/posts';

  PostsService(this._dio);

  Future<List<Post>> getPosts() async {
    final response = await _dio.get(_baseUrl);
    debugPrint('RESPOSTA API: ${response.data}');
    return (response.data as List).map((e) => Post.fromJson(e)).toList();
  }

  Future<Post> createPost(Post post) async {
    final response = await _dio.post(
      _baseUrl,
      data: post.toJson(),
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    debugPrint('CREATE POST: ${response.data}');
    if (response.data is Map<String, dynamic>) {
      return Post.fromJson(response.data);
    }
    return post;
  }

  Future<Post> updatePost(Post post) async {
    final response = await _dio.put(
      '$_baseUrl/${post.id}',
      data: post.toJson(),
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    debugPrint('UPDATE POST: ${response.data}');
    if (response.data is Map<String, dynamic>) {
      return Post.fromJson(response.data);
    }
    return post;
  }

  Future<void> deletePost(int id) async {
    final response = await _dio.delete('$_baseUrl/$id');
    debugPrint('DELETE POST: ${response.statusCode}');
  }
}
