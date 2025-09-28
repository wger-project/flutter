import 'package:flutter/foundation.dart';

/// Provider for managing health sync state
class HealthSyncProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isConnected = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  bool get isConnected => _isConnected;

  String? get errorMessage => _errorMessage;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setConnected(bool value) {
    _isConnected = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _isConnected = false;
    _errorMessage = null;
    notifyListeners();
  }
}
