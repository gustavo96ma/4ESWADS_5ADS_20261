import 'package:beeceptor_app/models/post.dart';
import 'package:flutter/material.dart';

class PostFormDialog extends StatefulWidget {
  final Post? post;

  const PostFormDialog({super.key, this.post});

  @override
  State<PostFormDialog> createState() => _PostFormDialogState();
}

class _PostFormDialogState extends State<PostFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _userIdController;
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late final TextEditingController _linkController;
  late final TextEditingController _commentCountController;

  bool get isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();
    _userIdController = TextEditingController(
      text: widget.post?.userId.toString() ?? '',
    );
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _bodyController = TextEditingController(text: widget.post?.body ?? '');
    _linkController = TextEditingController(text: widget.post?.link ?? '');
    _commentCountController = TextEditingController(
      text: widget.post?.commentCount.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    _linkController.dispose();
    _commentCountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final post = Post(
      userId: int.parse(_userIdController.text),
      id: widget.post?.id ?? 0,
      title: _titleController.text,
      body: _bodyController.text,
      link: _linkController.text,
      commentCount: int.parse(_commentCountController.text),
    );

    Navigator.of(context).pop(post);
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(isEditing ? 'Editar Post' : 'Novo Post'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  isEditing ? Icons.edit_note : Icons.post_add,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  isEditing
                      ? 'Atualize os dados do post'
                      : 'Preencha os dados do novo post',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _userIdController,
                  decoration: _inputDecoration(
                    label: 'User ID',
                    icon: Icons.person,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe o User ID';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Informe um número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: _inputDecoration(
                    label: 'Título',
                    icon: Icons.title,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe o título';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bodyController,
                  decoration: _inputDecoration(
                    label: 'Corpo',
                    icon: Icons.article,
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe o corpo do post';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _linkController,
                  decoration: _inputDecoration(
                    label: 'Link',
                    icon: Icons.link,
                  ),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe o link';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _commentCountController,
                  decoration: _inputDecoration(
                    label: 'Quantidade de Comentários',
                    icon: Icons.comment,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe a quantidade';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Informe um número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: Icon(isEditing ? Icons.save : Icons.add),
                    label: Text(
                      isEditing ? 'Salvar Alterações' : 'Criar Post',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
