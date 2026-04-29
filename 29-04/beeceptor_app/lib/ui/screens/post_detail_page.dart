import 'package:beeceptor_app/models/post.dart';
import 'package:beeceptor_app/providers/posts_provider.dart';
import 'package:beeceptor_app/ui/widgets/post_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PostDetailPage extends StatelessWidget {
  final int postId;

  const PostDetailPage({super.key, required this.postId});

  Future<void> _showEditDialog(BuildContext context, Post post) async {
    final updatedPost = await showDialog<Post>(
      context: context,
      builder: (_) => PostFormDialog(post: post),
    );
    if (updatedPost != null && context.mounted) {
      context.read<PostsProvider>().updatePost(updatedPost);
    }
  }

  Future<void> _confirmDelete(BuildContext context, Post post) async {
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
    if (confirmed == true && context.mounted) {
      context.read<PostsProvider>().deletePost(post.id);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostsProvider>(
      builder: (context, provider, _) {
        final post = provider.posts.where((p) => p.id == postId).firstOrNull;

        if (post == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Post'),
            ),
            body: const Center(child: Text('Post não encontrado')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalhes do Post'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditDialog(context, post),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(context, post),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com ID e User
                Row(
                  children: [
                    Chip(
                      avatar: const Icon(Icons.tag, size: 16),
                      label: Text('Post #${post.id}'),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      avatar: const Icon(Icons.person, size: 16),
                      label: Text('User ${post.userId}'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Título
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Corpo
                Text(
                  'Conteúdo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    post.body,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
                const SizedBox(height: 24),

                // Info cards
                _InfoTile(
                  icon: Icons.link,
                  label: 'Link',
                  value: post.link,
                ),
                const SizedBox(height: 12),
                _InfoTile(
                  icon: Icons.comment,
                  label: 'Comentários',
                  value: post.commentCount.toString(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }
}
