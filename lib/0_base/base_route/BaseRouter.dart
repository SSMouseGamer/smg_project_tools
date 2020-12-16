import 'package:flutter/material.dart' hide Router;
import 'package:smg_project_tools/1_extension/extension_header.dart';
import 'package:smg_project_tools/2_utils/utils_header.dart';

class BaseRouter {
  ///全局的key
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  factory BaseRouter() => shareInstance();
  static BaseRouter _instance = BaseRouter._();
  BaseRouter._();
  static BaseRouter shareInstance() {
    return _instance;
  }

  ///进入页面
  ///[viewName]routeName
  void Function(String viewName) onPageStart;

  ///退出页面
  ///[viewName]routeName
  void Function(String viewName) onPageEnd;

  ///以下是安全调用
  void pageStart(String viewName) {
    if (onPageStart != null) return onPageStart(viewName);
  }
  void pageEnd(String viewName) {
    if (onPageEnd != null) return onPageEnd(viewName);
  }

}

///当前的context
BuildContext getCurrentContext() => BaseRouter.navigatorKey.currentContext;

Map<String, WidgetBuilder> baseRoutes = {};

///通过路由名称跳转到指定页面，需要在baseRoutes中注册才可以跳转嗷
///[routeName]路由名称
///[arguments]参数
navigatorPushName<T extends Object>(String routeName, {Object arguments}) {
  return Navigator.push(getCurrentContext(), MaterialPageRoute(
    settings:RouteSettings(name: routeName, arguments: arguments),
    builder: (context) => baseRoutes[routeName](context)
  ));
}

///通过Widget跳转到指定的页面，未注册到baseRoutes的UI可以通过此方法跳转
///[pageWidget]指定的widget
nativatorPushWidget<T extends Object>(Widget pageWidget) {
  return Navigator.push(getCurrentContext(), MaterialPageRoute(builder: (context) => pageWidget));
}

///在当前页面返回上一个页面
///[result]参数
navigatorPop<T extends Object>([T result]) {
  if (!BaseRouter.navigatorKey.currentState.canPop()) {
    LogUtils.log('不能退出，当前已经是栈顶了');
    return;
  }
  Navigator.of(getCurrentContext()).pop<T>(result);
}

///跳转到不同的页面，相同页面不再跳转
///[routeName]路由名称
bool navigatorPushNameIfNotCurrent(String routeName) {
  return Navigator.of(getCurrentContext()).pushNameIfNotCurrent(routeName);
}

///返回当前栈顶，并从栈顶跳转到指定页面
///[routeName]路由名称
///[ifNotCurrent]是否禁止跳转重复页面，默认为true
natigatorPopRootAndPushName(String routeName, {bool ifNotCurrent = true, dynamic arguments}) {
  Navigator.popUntil(getCurrentContext(), (route) => route.isFirst);
  if (ifNotCurrent) {
    return navigatorPushNameIfNotCurrent(routeName);
  }
  return navigatorPushName(routeName);
}



