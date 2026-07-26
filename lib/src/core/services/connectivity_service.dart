import '../network/network_info.dart';

class ConnectivityService implements NetworkInfo {
  const ConnectivityService();

  @override
  Future<bool> get isConnected async => true;
}
