// connectivity_service.dart
import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService instance = ConnectivityService._();
  ConnectivityService._();

  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get onStatusChange => _controller.stream;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  Timer? _timer;

  void startMonitoring() {
    _checkInternet();

    _timer = Timer.periodic(Duration(seconds: 10), (_) => _checkInternet());
    Connectivity().onConnectivityChanged.listen((_) => _checkInternet());
  }

  Future<void> _checkInternet() async {
    final result = await _hasRealInternet();
    if (result != _isConnected) {
      _isConnected = result;
      _controller.add(_isConnected);
    }
  }

  Future<bool> _hasRealInternet() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> checkNow() async {
    final result = await _hasRealInternet();
    if (result != _isConnected) {
      _isConnected = result;
      _controller.add(_isConnected);
    }
    return result;
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
