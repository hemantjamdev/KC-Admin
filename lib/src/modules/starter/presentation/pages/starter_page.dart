import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../shared/widgets/app_refresh_indicator.dart';
import '../../application/providers/counter_provider.dart';

class StarterPage extends ConsumerWidget {
  const StarterPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterControllerProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: AppRefreshIndicator(
        onRefresh: () async {
          ref.read(counterControllerProvider.notifier).reset();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          children: [
            const SizedBox(height: 100),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('You have pushed the button this many times:'),
                  const SizedBox(height: 16),
                  Text(
                    '$counter',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Pull down to reset counter',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            ref.read(counterControllerProvider.notifier).increment(),
        tooltip: 'Increment',
        child: Icon(PhosphorIcons.plus()),
      ),
    );
  }
}
