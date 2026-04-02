import 'package:beeceptor_app/ui/widgets/text_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
        child: Column(
          spacing: 30,
          mainAxisAlignment: .center,
          children: [
            TextIconButton(
              text: 'Ver Posts',
              icon: Icons.read_more,
              onPressed: () => context.go('/posts'),
            ),
            TextIconButton(text: 'Botao 2', icon: Icons.abc, onPressed: () {}),
            TextIconButton(text: 'Botao 3', icon: Icons.abc, onPressed: () {}),
            TextIconButton(text: 'Botao 4', icon: Icons.abc, onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
