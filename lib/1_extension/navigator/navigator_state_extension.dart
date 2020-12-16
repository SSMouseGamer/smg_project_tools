import 'package:flutter/material.dart';

extension NavigatorStateExtension on NavigatorState {
  
  ///若不是相同页面，则跳转，前提是routeName所在的页面使用pushName进行跳转
  bool pushNameIfNotCurrent(String routeName,{Object arguments}) {
    bool res = isCurrent(routeName);
    if (!res) {
      pushNamed(routeName, arguments: arguments);
    }
    return res;
  }

  bool isCurrent(String routeName) {
    bool isCurrent = false;
    popUntil((route) {
      if (route.settings.name == routeName) {
        isCurrent = true;
      }
      return true;
    });
    return isCurrent;
  }
}