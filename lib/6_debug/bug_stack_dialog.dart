import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smg_project_tools/1_extension/extension_header.dart';
import 'package:smg_project_tools/0_base/base_route/BaseRouter.dart';

import 'debug_info_listvew.dart';

final bool isShowBugStackView = kDebugMode;
List<String> _stackInfoList = [];

/// debug 时用于展示 bug 信息
showBugStackView(String exception, String stack) async {
  if (!isShowBugStackView || StringTools.stringIsEmpty(stack)) {
    return;
  }
  DateTime dateTime = DateTime.now();
  _stackInfoList.add("$exception\nTime: 【 ${dateTime.hour}:${dateTime.minute}:${dateTime.second} 】\n$stack");
  showDialog<bool>(
    context: getCurrentContext(),
    barrierDismissible: false,
    builder: (context) {
      return DebugInfoListView(
        infoList: _stackInfoList,
      );
    },
  );
}
