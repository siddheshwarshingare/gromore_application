import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  ConnectivityService() {
    // ✅ Start listening to changes in connectivity
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      bool newConnectionStatus = results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi);

      if (newConnectionStatus != _isConnected) {
        _isConnected = newConnectionStatus;
        notifyListeners(); // ✅ Notify UI to rebuild when connection changes
      }
    });
  }
  Future<void> _checkInitialConnectivity() async {
    var result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result.first);
  }

    void _updateConnectionStatus(ConnectivityResult result) {
    bool newStatus = (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi);
    if (_isConnected != newStatus) {
      _isConnected = newStatus;
      notifyListeners(); // ✅ Notify UI when connection changes
    }
  }
  // ✅ Initial check at startup
  Future<void> checkConnectivity() async {
    try {
      List<ConnectivityResult> connectivityResults =
          await _connectivity.checkConnectivity();

      _isConnected = connectivityResults.contains(ConnectivityResult.mobile) ||
          connectivityResults.contains(ConnectivityResult.wifi);

      notifyListeners();
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
    }
  }
}
