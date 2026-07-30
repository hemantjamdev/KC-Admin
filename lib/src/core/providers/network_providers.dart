import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/network_connectivity_service.dart';

/// Provider for the singleton [NetworkConnectivityService].
final networkConnectivityServiceProvider = Provider<NetworkConnectivityService>(
  (ref) {
    final service = NetworkConnectivityService.instance;
    service.initialize();
    ref.onDispose(() {
      service.dispose();
    });
    return service;
  },
);

/// Stream provider for real-time network connectivity status changes (true = online, false = offline).
final isOnlineStreamProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(networkConnectivityServiceProvider);
  return service.onConnectivityChanged;
});

/// Synchronous provider for current network online state.
final isOnlineProvider = Provider<bool>((ref) {
  final streamState = ref.watch(isOnlineStreamProvider);
  return streamState.valueOrNull ??
      ref.watch(networkConnectivityServiceProvider).isOnline;
});
