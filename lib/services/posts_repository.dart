import 'package:dio/dio.dart';
import 'package:flutterapis/models/post.dart';

import 'package:flutterapis/util/api_routes.dart';

class PostsRepository {
  PostsRepository(this.client);

  final Dio client;

  /// Fetch posts.
  Future<ApiData<List<Post>>> getPosts(int max) async {
    List<Post> data = [];
    var errorMessage;

    try {
      var response = await client.get(APIRoutes.posts);

      if (response.statusCode == 200 && response.data is List) {
        var list = response.data as List;
        var safeMax = list.length < max ? list.length : max;
        var items = list.getRange(0, safeMax);
        data = items.map((item) => Post.fromJson(item)).toList();
      }
    } catch (e) {
      errorMessage = e.toString();
    }

    return ApiData<List<Post>>(data: data, errorMessage: errorMessage);
  }
}

/// Simple helper class for returning data from the repositories.
/// Can contain the returned data and/or an error message if something
/// went wrong.
class ApiData<T> {
  ApiData({this.data, this.errorMessage = ''});

  final T data;
  final String errorMessage;
}
