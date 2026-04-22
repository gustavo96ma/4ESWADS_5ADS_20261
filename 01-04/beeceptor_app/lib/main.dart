import 'package:beeceptor_app/providers/posts_provider.dart';
import 'package:beeceptor_app/providers/upload_provider.dart';
import 'package:beeceptor_app/services/posts_service.dart';
import 'package:beeceptor_app/services/upload_service.dart';
import 'package:beeceptor_app/ui/screens/home_page.dart';
import 'package:beeceptor_app/ui/screens/post_detail_page.dart';
import 'package:beeceptor_app/ui/screens/posts_page.dart';
import 'package:beeceptor_app/ui/screens/upload_page.dart';
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
          path: '/upload',
          builder: (BuildContext context, GoRouterState state) {
            return const UploadPage();
          },
        ),
        GoRoute(
          path: '/posts',
          builder: (BuildContext context, GoRouterState state) {
            return const PostsPage();
          },
          routes: <RouteBase>[
            GoRoute(
              path: ':id',
              builder: (BuildContext context, GoRouterState state) {
                final id = int.parse(state.pathParameters['id']!);
                return PostDetailPage(postId: id);
              },
            ),
          ],
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
        ChangeNotifierProvider<UploadProvider>(
          create: (context) => UploadProvider(UploadService(context.read<Dio>())),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.redAccent,
            primary: Colors.redAccent,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
          ),
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }
}
