import 'package:flutter/material.dart';
import '../../core/errors/app_failure.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({super.key, this.failure, this.message, this.onRetry});

  final AppFailure? failure;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final errorMessage =
        message ??
        failure?.when(
          network: (msg, code, err) => msg ?? 'Network connection error.',
          timeout: (msg, code, err) => msg ?? 'Request timed out.',
          authentication: (msg, code, err) => msg ?? 'Authentication required.',
          permission: (msg, code, err) => msg ?? 'Permission denied.',
          validation: (msg, code, err) => msg ?? 'Validation error.',
          notFound: (msg, code, err) => msg ?? 'Resource not found.',
          server: (msg, code, err) => msg ?? 'Server error.',
          storage: (msg, code, err) => msg ?? 'Storage error.',
          unknown: (msg, code, err) => msg ?? 'An unexpected error occurred.',
        ) ??
        'An unexpected error occurred.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
