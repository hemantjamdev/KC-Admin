import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/network_providers.dart';
import 'app_toast.dart';

/// Wraps application layout to listen for network state changes via Riverpod.
/// Shows floating toast when offline ("You are offline") or back online ("You are online").
class NetworkListenerWrapper extends ConsumerStatefulWidget {
  const NetworkListenerWrapper({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NetworkListenerWrapper> createState() =>
      _NetworkListenerWrapperState();
}

class _NetworkListenerWrapperState
    extends ConsumerState<NetworkListenerWrapper> {
  bool? _isOnline;

  void _showConnectivityToast(bool online) {
    if (!mounted) return;
    AppToast.show(
      context,
      online ? 'You are online' : 'You are offline',
      type: online ? ToastType.success : ToastType.error,
      icon: online ? Icons.wifi_rounded : Icons.wifi_off_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<bool>>(isOnlineStreamProvider, (previous, next) {
      final online = next.valueOrNull;
      if (online != null && _isOnline != null && _isOnline != online) {
        _showConnectivityToast(online);
      }
      if (online != null) {
        _isOnline = online;
      }
    });

    return widget.child;
  }
}
