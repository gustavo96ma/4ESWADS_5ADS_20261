import 'package:fetubola/models/news.dart';
import 'package:fetubola/ui/widgets/custom_app_bar.dart';
import 'package:fetubola/utils/app_style.dart';
import 'package:flutter/material.dart';

class NewsDetailsScreen extends StatelessWidget {
  final News news;
  const NewsDetailsScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: news.title),
      body: Padding(
        padding: AppStyle.screenPadding,
        child: Column(
          children: [
            Image.network(news.imageUrl),
            Text(
              news.imageDescription,
              style: AppStyle.imageDescriptionStyle,
            ),
            SizedBox(height: AppStyle.smallSpacing),
            Text(news.content),
            SizedBox(height: AppStyle.largeSpacing),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Autor: ${news.newsAuthor}',
                style: AppStyle.authorStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
