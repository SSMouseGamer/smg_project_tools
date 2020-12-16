import 'package:flutter/foundation.dart';
import 'package:smg_project_tools/6_debug/debugger_platform.dart';

class LogUtils {
  static void log(Object obj) {
    if (kReleaseMode) return;
    print(obj);
  }

    static void httpLog(String httpInfo) {
    log(httpInfo);
    if (isShowDebuggerPlatform) {
      updateHttpInfoList(httpInfo);
    }
  }

  static void debuggerPlatformLog(String debuggerInfo, {String title = "tag"}) {
    log(debuggerInfo);
    if (isShowDebuggerPlatform) {
      updateDebuggerInfoList(debuggerInfo, title: title);
    }
  }
}

