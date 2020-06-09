import 'package:alice/alice.dart';
import 'package:flutter/cupertino.dart';

class AliceProvider extends InheritedWidget {
  const AliceProvider({
    Key key,
    @required this.alice,
    @required Widget child,
  })  : assert(alice != null),
        assert(child != null),
        super(key: key, child: child);

  final Alice alice;

  static AliceProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AliceProvider>();
  }

  @override
  bool updateShouldNotify(AliceProvider oldWidget) {
    return oldWidget.alice != alice;
  }
}
