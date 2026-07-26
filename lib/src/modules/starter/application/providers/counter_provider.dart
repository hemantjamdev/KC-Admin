import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/counter_controller.dart';

final counterControllerProvider = NotifierProvider<CounterController, int>(
  CounterController.new,
);
