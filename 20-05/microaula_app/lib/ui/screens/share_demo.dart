import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareDemoScreen extends StatefulWidget {
  const ShareDemoScreen({super.key});

  @override
  State<ShareDemoScreen> createState() => _ShareDemoScreenState();
}

class _ShareDemoScreenState extends State<ShareDemoScreen> {
  String _lastResult = 'Nenhuma ação executada ainda.';

  Future<void> _shareText() async {
    final result = await SharePlus.instance.share(
      ShareParams(text: 'Texto enviado da micro aula 20/05 ✨'),
    );
    _setResult(result);
  }

  Future<void> _shareLink() async {
    final result = await SharePlus.instance.share(
      ShareParams(
        text: 'Repo da turma: https://github.com/gustavo96ma/4ESWADS_5ADS_20261',
        subject: 'Aula Flutter',
      ),
    );
    _setResult(result);
  }

  Future<void> _shareGeneratedFile() async {
    // Gera um .txt temporário e compartilha como arquivo.
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/microaula.txt');
    await file.writeAsString(
      'Arquivo gerado em ${DateTime.now()}\n'
      'Demo de compartilhamento via share_plus.\n',
    );
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Arquivo de exemplo',
      ),
    );
    _setResult(result);
  }

  Future<void> _shareImageFromPicker() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      _setResult(const ShareResult('dismissed', ShareResultStatus.dismissed));
      return;
    }
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(image.path)],
        text: 'Imagem compartilhada do app',
      ),
    );
    _setResult(result);
  }

  void _setResult(ShareResult r) {
    setState(() => _lastResult = 'status: ${r.status.name}\nraw: ${r.raw}');
  }

  @override
  Widget build(BuildContext context) {
    final buttons = <(String, IconData, Future<void> Function())>[
      ('Texto simples', Icons.text_fields, _shareText),
      ('Link com subject', Icons.link, _shareLink),
      ('Arquivo gerado (.txt)', Icons.description, _shareGeneratedFile),
      if (!kIsWeb) ('Imagem da galeria', Icons.image, _shareImageFromPicker),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Compartilhar via OS'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final (label, icon, action) in buttons) ...[
            FilledButton.icon(
              onPressed: action,
              icon: Icon(icon),
              label: Text(label),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),
          const Text('Último resultado:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_lastResult, style: const TextStyle(fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }
}
