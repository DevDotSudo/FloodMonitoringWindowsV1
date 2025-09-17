import 'package:flutter/material.dart';

enum ScreenType {
  dashboard,
  subscribers,
  waterLevelData,
  registerUser,
  sendWarningAlert,
  settings,
}

class NavigationController with ChangeNotifier {
  ScreenType _currentScreen = ScreenType.dashboard;

  ScreenType get currentScreen => _currentScreen;

  void navigateTo(ScreenType screenType) {
    _currentScreen = screenType;
    notifyListeners();
  }
}
