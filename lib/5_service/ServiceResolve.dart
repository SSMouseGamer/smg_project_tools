
import 'package:dio/dio.dart';
import 'ServiceTask.dart';
import 'package:smg_project_tools/2_utils/utils_header.dart';

class ServiceResolve {
  ///tip: 请注意这些自定义处理的初始化，建议在Service初始化之前，这是全局的操作，不支持针对某个接口特殊处理，一般作为项目统一配置处理
  ///自定义开启请求时的操作
  void Function(ServiceTask task) customResolveOnRequest;
  ///自定义开始响应时的操作
  void Function(ServiceTask task, Response response) customResolveOnResponse;
  ///自定义返回错误时的操作
  void Function(ServiceTask task, DioError e) customResolveOnError;

  ///自定义业务需要抛出的错误码处理 理论上不起作用，一般返回的数据结构重新定义，其他都需要重新定义
  Map<int, int> customErrorCode = {};

  factory ServiceResolve() => shareInstance();
  static ServiceResolve _instance = ServiceResolve._();

  ServiceResolve._();

  static ServiceResolve shareInstance() {
    return _instance;
  }
}

void resolveOnRequest(ServiceTask task) {
  if(task == null) return;
  if (task.isShowToast) {
    task.cancelToast = showLoadingToast(toastStr: task.showToastStr, timeOut: task.timeout);
  }
  if (ServiceResolve.shareInstance().customResolveOnRequest != null) {
    ServiceResolve.shareInstance().customResolveOnRequest(task);
    return;
  }
}

void resolveOnResponse(ServiceTask task, Response response) {
  if (task == null) return;
  if (task.cancelToast != null) task.cancelToast();
  if (ServiceResolve.shareInstance().customResolveOnResponse != null) {
    ServiceResolve.shareInstance().customResolveOnResponse(task, response);
    return;
  }
  

  ///以下需要具体项目定义的
  // if (response.data['code'] == 401) {
    
  // } else if (response.data['code'] == 4) {
  //   //未绑定手机号
  // } else if (task.path.contains('findUserPermission') && response.data['code'] == 1) {
  //   ///是否拥有授权状态的
  // } else if (response.data['code'] != 0) {
  //   // 抛出错误
    
  // }
}

void resolveOnError(ServiceTask task, DioError e) {
  if (task == null) return;
  if (task.cancelToast != null) task.cancelToast();
  if (ServiceResolve.shareInstance().customResolveOnError != null) {
    ServiceResolve.shareInstance().customResolveOnError(task, e);
    if (task != null && task.cancelToast != null) task.cancelToast();
    return;
  }
  if (!e.request.path.contains("open/doorcontrol") ||
      !e.request.path.contains("v2/upAppUserFaceByBase64")) {
    showTipStr();
  }
}
