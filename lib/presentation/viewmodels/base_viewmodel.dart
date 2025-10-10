import 'package:flutter/material.dart';

class BaseViewmodel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(v) {
    _isLoading = v;
    notifyListeners();
  }
}
