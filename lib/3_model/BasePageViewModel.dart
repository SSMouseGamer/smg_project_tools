import 'package:flutter/material.dart';

class BasePageViewModel extends ChangeNotifier {
  BasePageViewModel();
  ///页面状态
  int _pageState = 0;

  void changeState(int pageState) {
    _pageState = pageState;
    notifyListeners();
  }

  get pageState => _pageState;
}