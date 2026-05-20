import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/note.dart';
import 'ui/screens/cache_demo.dart';
import 'ui/screens/hybrid_demo.dart';
import 'ui/screens/share_demo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive setup — usado pela aba Hive do cache_demo
  await Hive.initFlutter();
  Hive.registerAdapter(NoteAdapter());

  runApp(const MicroaulaApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
    GoRoute(path: '/cache', builder: (_, _) => const CacheDemoScreen()),
    GoRoute(path: '/share', builder: (_, _) => const ShareDemoScreen()),
    GoRoute(path: '/hybrid', builder: (_, _) => const HybridDemoScreen()),
  ],
);

class MicroaulaApp extends StatelessWidget {
  const MicroaulaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Micro aula 20/05',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF117D5D),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Cache local', 'shared_preferences · Hive · sqflite', Icons.storage, '/cache'),
      ('Compartilhar', 'share_plus + url_launcher', Icons.share, '/share'),
      ('Deploy híbrido', 'kIsWeb · UI condicional', Icons.devices, '/hybrid'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Micro aula 20/05')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final (title, subtitle, icon, route) = items[i];
          return Card(
            child: ListTile(
              leading: Icon(icon, size: 32),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(route),
            ),
          );
        },
      ),
    );
  }
}
