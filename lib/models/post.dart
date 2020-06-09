import 'dart:math';

class Post {
  Post({this.id, this.title, this.body});

  final int id;
  final String title;
  final String body;

  static Post fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] ?? Random().nextInt(100000),
        title: json['title'] ?? 'N/A',
        body: json['body'] ?? 'N/A',
      );
}
