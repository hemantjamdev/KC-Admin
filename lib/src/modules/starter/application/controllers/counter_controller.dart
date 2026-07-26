import 'package:flutter_riverpod/flutter_riverpod.dart';

class CounterController extends Notifier<int> {
  @override
  int build() => 0;

  void increment() {
    state++;
  }

  void reset() {
    state = 0;
  }
}
