import 'dart:io';

import 'package:alice/alice.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutterapis/models/post.dart';
import 'package:flutterapis/services/alice_provider.dart';
import 'package:flutterapis/services/dio_client_provider.dart';
import 'package:flutterapis/services/posts_repository.dart';
import 'package:flutterapis/util/api_routes.dart';

void main() {
  var alice = Alice(darkTheme: true, showNotification: false);
  var client = Dio(
    BaseOptions(
      baseUrl: APIRoutes.baseUrl,
      responseType: ResponseType.json,
      contentType: 'application/json',
      connectTimeout: 10000,
      receiveTimeout: 30000,
    ),
  );
  client.interceptors.add(alice.getDioInterceptor());
  runApp(MyApp(
    alice: alice,
    client: client,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({this.alice, this.client});

  final Alice alice;
  final Dio client;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AliceProvider(
      alice: alice,
      child: DioClientProvider(
        client: client,
        child: MaterialApp(
          title: 'Flutter Demo',
          navigatorKey: alice.getNavigatorKey(),
          theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            primarySwatch: Colors.blue,
            // This makes the visual density adapt to the platform that you run
            // the app on. For desktop platforms, the controls will be smaller and
            // closer together (more dense) than on mobile platforms.
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: MyHomePage(title: 'Flutter Demo Home Page'),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PostsRepository repository;
  List<Post> _posts = [];
  String _error = '';
  bool _loading = false;

  static const largeText = TextStyle(fontSize: 24);
  static const normalText = TextStyle(fontSize: 16);
  static const smallText = TextStyle(fontSize: 13);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    repository ??= PostsRepository(DioClientProvider.of(context).client);
  }

  void loadPosts() async {
    setState(() {
      _loading = true;
    });

    ApiData<List> posts = await repository.getPosts(20);
    setState(() {
      _loading = false;

      if (posts.data.isNotEmpty) {
        _posts = posts.data;
        _error = '';
      } else {
        _error = posts.errorMessage;
        _posts = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: _posts.isEmpty ? MainAxisAlignment.center : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (_error.isNotEmpty) Text(_error, style: largeText),
            if (_posts.isEmpty) ...[
              Text('Click the button to load some posts!'),
              SizedBox(height: 30),
              RaisedButton(
                onPressed: () async => loadPosts(),
                child: Text(_error.isNotEmpty ? 'Retry' : 'Load Posts'),
              ),
              if (_loading) ...[
                SizedBox(height: 10),
                CircularProgressIndicator(),
              ],
            ],
            if (_posts.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Text(_posts[index].id.toString(), style: normalText),
                      title: Text(_posts[index].title, style: normalText),
                      subtitle: Text(_posts[index].body, style: smallText),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: AliceProvider.of(context).alice.showInspector,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
