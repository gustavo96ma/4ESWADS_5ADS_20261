import 'package:beeceptor_app/providers/posts_provider.dart';
import 'package:beeceptor_app/services/posts_service.dart';
import 'package:beeceptor_app/ui/screens/home_page.dart';
import 'package:beeceptor_app/ui/screens/posts_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MainApp());
}

/// The route configuration.
final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/posts',
          builder: (BuildContext context, GoRouterState state) {
            return const PostsPage();
          },
        ),
      ],
    ),
  ],
);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Dio>(create: (_) => Dio()),
        ChangeNotifierProvider<PostsProvider>(
          create: (context) => PostsProvider(PostsService(context.read<Dio>())),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
