import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kc_admin/src/modules/starter/application/providers/counter_provider.dart';

void main() {
  group('CounterController Test', () {
    test('initial state is 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(counterControllerProvider), 0);
    });

    test('increment increases counter state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(counterControllerProvider), 0);

      container.read(counterControllerProvider.notifier).increment();

      expect(container.read(counterControllerProvider), 1);
    });

    test('reset clears counter state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(counterControllerProvider.notifier).increment();
      expect(container.read(counterControllerProvider), 1);

      container.read(counterControllerProvider.notifier).reset();
      expect(container.read(counterControllerProvider), 0);
    });
  });
}
