import 'dart:async';
import 'package:smg_project_tools/5_service/Service.dart';
import 'HomePage.dart';
import 'package:flutter/material.dart';
import 'package:smg_project_tools/smg_project_tools.dart';
import 'package:bot_toast/bot_toast.dart';

void main() async {
  ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails) {
    LogUtils.log(flutterErrorDetails.toString());
    // 重定向到 runZoned 处理
    Zone.current.handleUncaughtError(
        flutterErrorDetails.exception, flutterErrorDetails.stack);
    return Center(
      child: Text('发生错误了嗷'),
    );
  };
  runZoned(
    () => runApp(MyApp()),
    onError: (Object obj, StackTrace stack) {
      // 错误信息
      showBugStackView(obj.toString(), stack.toString());
    },
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BotToastInit(
      child: MaterialApp(
        navigatorKey: BaseRouter.navigatorKey,
        navigatorObservers: [BotToastNavigatorObserver()],
        debugShowCheckedModeBanner: false,
        home: MyHomePage(),
        theme: new ThemeData(primarySwatch: Colors.red),
        routes: {'homePage': (context) => HomePage()},
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  MyHomePage({Key key, this.title}) : super(key: key);
  @override
  _MyHomePage createState() => new _MyHomePage();
}

class _MyHomePage extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BaseStartupPage(goHomeBlock: () {
        _initCommon();
        BaseRouter.navigatorKey.currentState
            .pushNamedAndRemoveUntil('homePage', (route) => false);
      }),
    );
  }
}

void _initCommon() {
  ServiceConfig.shareInstance();
  ///自定义task处理，构建task时使用
  Service.shareInstance().customTaskBuildDelegate = (task, customType) {
    if (customType == 0) {
      ///默认处理path，或者其他，看情况嗷
      if (task.path.contains('?')) {
        task.path = task.path + '&' + 'sessionId=23333';
      } else {
        task.path = '${task.path}?sessionId=23333';
      }
    } else {
      ///请自行处理
      task.path = task.path + '?customType=$customType';
    }
  };

  ///自定义加密、签名等
  Service.shareInstance().customEncryptionDelegate = (param) {
    Future<Map> data;
    data = Future(() => {'233': '娃哈哈哈哈', ...param});
    return data;
  };

  ///自定义解析方案
  Service.shareInstance().customeResolveResultDelegate = (response, callback) {
    var res = response?.data ?? {};
    if (callback != null) {
      var resData = res['data'];
      var code = res['code'];
      var msg = res['message'];
      bool success = res.isNotEmpty && code == 0;
      callback(resData, success, code, msg);
    }
    return response?.data;
  };
}
