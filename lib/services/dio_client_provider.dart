import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class DioClientProvider extends InheritedWidget {
  const DioClientProvider({
    Key key,
    @required this.client,
    @required Widget child,
  })  : assert(client != null),
        assert(child != null),
        super(key: key, child: child);

  final Dio client;

  static DioClientProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DioClientProvider>();
  }

  @override
  bool updateShouldNotify(DioClientProvider oldWidget) {
    return oldWidget.client != client;
  }
}
