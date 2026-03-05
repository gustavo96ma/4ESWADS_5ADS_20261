import 'package:fetubola/models/news.dart';
import 'package:fetubola/ui/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class NewsDetailsScreen extends StatelessWidget {
  final News news;
  const NewsDetailsScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: news.title),
      body: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Column(
          children: [
            Image.network(news.imageUrl),
            Text(
              news.imageDescription,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 16),
            Text(news.content),
            SizedBox(height: 32),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Autor: ${news.newsAuthor}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
