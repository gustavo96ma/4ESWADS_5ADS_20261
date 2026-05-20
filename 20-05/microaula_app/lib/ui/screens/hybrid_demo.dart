import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HybridDemoScreen extends StatelessWidget {
  const HybridDemoScreen({super.key});

  String get _platform {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Desconhecida';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 720; // ponto onde admin assume layout desktop
    final cards = [
      _InfoCard(
        icon: Icons.devices,
        title: 'Plataforma detectada',
        value: _platform,
      ),
      _InfoCard(
        icon: Icons.layers,
        title: 'kIsWeb',
        value: kIsWeb.toString(),
      ),
      _InfoCard(
        icon: Icons.straighten,
        title: 'Largura da tela',
        value: '${width.toStringAsFixed(0)} px',
      ),
      _InfoCard(
        icon: Icons.view_compact,
        title: 'Layout escolhido',
        value: isWide ? 'Desktop (2 colunas)' : 'Mobile (1 coluna)',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Deploy híbrido'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PlatformBanner(isWide: isWide, platform: _platform),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: isWide ? 2 : 1,
                childAspectRatio: isWide ? 3 : 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: cards,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Redimensione a janela / vire o celular pra ver o layout mudar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformBanner extends StatelessWidget {
  const _PlatformBanner({required this.isWide, required this.platform});
  final bool isWide;
  final String platform;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: kIsWeb
              ? [Colors.indigo.shade400, Colors.indigo.shade700]
              : [Colors.teal.shade400, Colors.teal.shade700],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(kIsWeb ? Icons.desktop_windows : Icons.smartphone, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kIsWeb ? 'Modo admin (Web)' : 'Modo cliente ($platform)',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                ),
                Text(
                  isWide
                      ? 'Layout desktop habilitado — mais densidade de informação.'
                      : 'Layout mobile — foco em uma coluna por vez.',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.title, required this.value});
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
