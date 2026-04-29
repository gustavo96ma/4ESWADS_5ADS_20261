import 'package:beeceptor_app/models/post.dart';
import 'package:beeceptor_app/providers/posts_provider.dart';
import 'package:beeceptor_app/ui/widgets/post_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostsProvider>().fetchPosts();
    });
  }

  Future<void> _showCreateDialog() async {
    final post = await showDialog<Post>(
      context: context,
      builder: (_) => const PostFormDialog(),
    );
    if (post != null && mounted) {
      context.read<PostsProvider>().addPost(post);
    }
  }

  Future<void> _showEditDialog(Post post) async {
    final updatedPost = await showDialog<Post>(
      context: context,
      builder: (_) => PostFormDialog(post: post),
    );
    if (updatedPost != null && mounted) {
      context.read<PostsProvider>().updatePost(updatedPost);
    }
  }

  Future<void> _confirmDelete(Post post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja excluir o post "${post.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<PostsProvider>().deletePost(post.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts Page'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
      body: Consumer<PostsProvider>(
        builder: (context, provider, child) {
          /// Estado de loading
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          /// Estado de erro
          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsetsGeometry.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          /// Estado de sucesso
          return ListView.builder(
            itemCount: provider.posts.length,
            itemBuilder: (context, index) {
              final post = provider.posts[index];
              return ListTile(
                title: Text(post.title),
                subtitle: Text(
                  post.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => context.go('/posts/${post.id}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                      onPressed: () => _showEditDialog(post),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.grey.shade600),
                      onPressed: () => _confirmDelete(post),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
