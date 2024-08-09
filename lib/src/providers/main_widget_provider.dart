import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/views/screens/home/home_screen.dart';

import '../views/screens/auth/login_screen.dart';

class MainWidgetProvider extends ChangeNotifier {
  Widget _currentScreen = const HomeWorksWidget();
  Widget get currentScreen => _currentScreen;

  void setCurrentScreen(Widget current) {
    _currentScreen = current;
    notifyListeners();
  }

  Widget _lastScreen = const HomeWorksWidget();
  Widget get lastScreen => _lastScreen;

  void setLastScreen(Widget last) {
    _lastScreen = last;
    notifyListeners();
  }

  bool _visibleSearch = true;
  bool get visibleSearch => _visibleSearch;

  void setVisibleSearch(bool visible) {
    _visibleSearch = visible;
    notifyListeners();
  }

  String _titleMain = '';
  String get titleMain => _titleMain;

  void setTitleMain(String title) {
    _titleMain = title;
    notifyListeners();
  }

  bool _isShowTestDevice = false;
  bool get isShowTestDevice => _isShowTestDevice;
  void setIsShowTestDevice(bool show) {
    _isShowTestDevice = show;
    notifyListeners();
  }
}
