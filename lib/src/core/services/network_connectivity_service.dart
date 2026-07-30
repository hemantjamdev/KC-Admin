import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Network connectivity & reachability service powered by package:connectivity_plus.
/// Monitors internet connection changes and emits state on a broadcast stream.
class NetworkConnectivityService {
  NetworkConnectivityService._();
  static final NetworkConnectivityService instance =
      NetworkConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool? _lastIsOnline;

  Stream<bool> get onConnectivityChanged => _controller.stream;
  bool get isOnline => _lastIsOnline ?? true;

  void initialize() {
    _checkStatus();
    _subscription?.cancel();
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.contains(ConnectivityResult.none)) {
        _updateState(false);
        return;
      }
      final lookupResult = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 2));
      final online =
          lookupResult.isNotEmpty && lookupResult[0].rawAddress.isNotEmpty;
      _updateState(online);
    } catch (_) {
      _updateState(false);
    }
  }

  void _updateState(bool online) {
    if (_lastIsOnline != online) {
      _lastIsOnline = online;
      _controller.add(online);
    }
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
