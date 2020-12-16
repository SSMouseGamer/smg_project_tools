import 'package:flutter/material.dart';
import 'package:smg_project_tools/2_utils/utils_header.dart';
import 'package:smg_project_tools/1_extension/extension_header.dart';
import 'BaseRouter.dart';

/// 用于页面路由跳转的监听
class PageRouteObserver extends NavigatorObserver {
  String _lastRouteName = "";

  /// 进入路由
  @override
  void didPush(Route route, Route previousRoute) {
    super.didPush(route, previousRoute);
    LogUtils.log("--- Route didPush 进入路由 --- currentRoute:${route?.settings?.name} --- previousRoute:${previousRoute?.settings?.name}");

    /// TODO 目前项目的首页路由是 router_util.ROUTE_INDEX
    /// 系统还有一个根路由[/]，有时候会销毁全部页面直到根路由后再跳转指定页面，没配置的话，根路由不是一个实际页面
    /// onPageStart、onPageEnd 必须成对存在，所以要过滤掉根路由的 push(onPageStart) 和 pop(onPageEnd)
    /// --- Route didPush 进入路由 --- currentRoute:/ --- previousRoute:null
    /// --- Route didPush 进入路由 --- currentRoute:/index --- previousRoute:/
    /// --- Route didPush 进入路由 --- currentRoute:/my_community --- previousRoute:/index
    /// --- Route didPop 弹出路由 --- currentRoute:/my_community --- previousRoute:/index
    /// TODO 非页面的导航跳转 routeName 为 null，也要过滤掉
    /// TODO 先 end 再 start

    String currentRouteName = route?.settings?.name;
    String previousRouteName = previousRoute?.settings?.name;
    
    // 1、APP启动或者销毁全部页面
    if (currentRouteName == "/") {
      return;
    }
    // 2、APP启动或者销毁全部页面后第一次进入的页面
    if (!StringTools.stringIsEmpty(currentRouteName) && previousRouteName == "/") {
      _lastRouteName = currentRouteName;
      BaseRouter.shareInstance()?.pageStart(currentRouteName);
      return;
    }
    
    // 3、路由页面之间跳转 - 跳入
    if (!StringTools.stringIsEmpty(currentRouteName) && !StringTools.stringIsEmpty(previousRouteName)) {
      _lastRouteName = currentRouteName;
      BaseRouter.shareInstance()?.pageEnd(previousRouteName);
      BaseRouter.shareInstance()?.pageStart(currentRouteName);
      return;
    }
    // 4、路由页面跳转无路由（弹窗）- 打开
    if (StringTools.stringIsEmpty(currentRouteName) && !StringTools.stringIsEmpty(previousRouteName)) {
      _lastRouteName = previousRouteName;
      return;
    }
    // 5、无路由（弹窗）跳转路由页面 - 进入路由页面
    if (!StringTools.stringIsEmpty(currentRouteName) && StringTools.stringIsEmpty(previousRouteName)) {
      if (_lastRouteName != currentRouteName) {
        BaseRouter.shareInstance()?.pageEnd(_lastRouteName);
        BaseRouter.shareInstance()?.pageStart(currentRouteName);
        _lastRouteName = currentRouteName;
      }
      return;
    }
    // 6、无路由（弹窗）跳转无路由（弹窗）
    if (StringTools.stringIsEmpty(currentRouteName) && StringTools.stringIsEmpty(previousRouteName)) {
      return;
    }
  }

  /// 弹出路由
  @override
  void didPop(Route route, Route previousRoute) {
    super.didPop(route, previousRoute);
    // LogUtils.log("--- Route didPop 弹出路由 --- currentRoute:${route?.settings?.name} --- previousRoute:${previousRoute?.settings?.name}");

    String currentRouteName = route?.settings?.name;
    String previousRouteName = previousRoute?.settings?.name;
    // 1、APP启动或者销毁全部页面
    if (currentRouteName == "/") {
      return;
    }
    // 3、路由页面之间跳转 - 回跳
    if (!StringTools.stringIsEmpty(currentRouteName) && !StringTools.stringIsEmpty(previousRouteName)) {
      _lastRouteName = previousRouteName;
      BaseRouter.shareInstance()?.pageEnd(currentRouteName);
      BaseRouter.shareInstance()?.pageStart(previousRouteName);
      return;
    }
    // 4、路由页面跳转无路由（弹窗）- 关闭
    if (StringTools.stringIsEmpty(currentRouteName) && !StringTools.stringIsEmpty(previousRouteName)) {
      _lastRouteName = previousRouteName;
      return;
    }
    // 5、无路由（弹窗）跳转路由页面 - 回到无路由（弹窗）
    if (!StringTools.stringIsEmpty(currentRouteName) && StringTools.stringIsEmpty(previousRouteName)) {
      if (_lastRouteName != currentRouteName) {
        BaseRouter.shareInstance()?.pageEnd(currentRouteName);
        BaseRouter.shareInstance()?.pageStart(_lastRouteName);
      }
      return;
    }
  }

  /// 删除路由
  @override
  void didRemove(Route route, Route previousRoute) {
    super.didRemove(route, previousRoute);
    LogUtils.log("--- Route didRemove 删除路由 --- currentRoute:${route?.settings?.name} --- previousRoute:${previousRoute?.settings?.name}");
  }

  /// 用新路由替换旧路由
  @override
  void didReplace({Route newRoute, Route oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    LogUtils.log("--- Route didReplace 用新路由替换旧路由 --- newRoute:${newRoute?.settings?.name} --- oldRoute:${oldRoute?.settings?.name}");
  }

  /// 用户手势控制路由
  /// For example, this is called when an iOS back gesture starts,
  /// and is used to disabled hero animations during such interactions.
  @override
  void didStartUserGesture(Route route, Route previousRoute) {
    super.didStartUserGesture(route, previousRoute);
    LogUtils.log("--- Route didStartUserGesture 用户手势控制路由 --- currentRoute:${route?.settings?.name} --- previousRoute:${previousRoute?.settings?.name}");
  }

  /// 用户手势不再控制路由，与上一个相配
  @override
  void didStopUserGesture() {
    super.didStopUserGesture();
    LogUtils.log("--- Route didStopUserGesture 用户手势不再控制路由 ---");
  }

}
