class Post {
  final int userId;
  final int id;
  final String title;
  final String body;
  final String link;
  final int commentCount;

  Post({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
    required this.link,
    required this.commentCount,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
      link: json['link'],
      commentCount: json['comment_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'id': id,
      'title': title,
      'body': body,
      'link': link,
      'comment_count': commentCount,
    };
  }
}
