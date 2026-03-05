import 'package:fetubola/models/news.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('Renderizou');

    final List<News> news = [
      News(
        title: 'Notícia 1',
        content: 'Conteúdo da notícia 1',
        imageUrl: 'https://placehold.co/600x400.png',
      ),
      News(
        title: 'Notícia 2',
        content: 'Conteúdo da notícia 2',
        imageUrl: 'https://placehold.co/600x400.png',
      ),
      News(
        title: 'Notícia 3',
        content: 'Conteúdo da notícia 3',
        imageUrl: 'https://placehold.co/600x400.png',
      ),
      News(
        title: 'Notícia 4',
        content: 'Conteúdo da notícia 4',
        imageUrl: 'https://placehold.co/600x400.png',
      ),
      News(
        title: 'Notícia 5',
        content: 'Conteúdo da notícia 5',
        imageUrl: 'https://placehold.co/600x400.png',
      ),
      News(
        title: 'Notícia 6',
        content: 'Conteúdo da notícia 6',
        imageUrl: 'https://placehold.co/600x400.png',
      ),
      News(
        title: 'Notícia 7',
        content: 'Conteúdo da notícia 7',
        imageUrl: 'https://placehold.co/600x400.png',
      ),
      News(
        title: 'Notícia 8',
        content: 'Conteúdo da notícia 8',
        imageUrl: 'https://placehold.co/600x400.png',
      ),
      News(
        title: 'Notícia 9',
        content: 'Conteúdo da notícia 9',
        imageUrl: 'https://placehold.co/600x400.png',
      ),
      News(
        title: 'Notícia 10',
        content: 'Conteúdo da notícia 10',
        imageUrl: 'https://placehold.co/600x400.png',
      ),
      News(
        title: 'Notícia 11',
        content: 'Conteúdo da notícia 11',
        imageUrl: 'https://placehold.co/600x400.png',
      ),
      News(
        title: 'Notícia 12',
        content: 'Conteúdo da notícia 12',
        imageUrl: 'https://placehold.co/600x400.png',
      ),
    ];

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Futebola', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Últimas Notícias',
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: news.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(
                          news[index].title,
                          style: TextStyle(fontFamily: 'Roboto'),
                        ),
                        subtitle: Text(news[index].content),
                        leading: Image.network(news[index].imageUrl),
                        trailing: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.arrow_right),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
