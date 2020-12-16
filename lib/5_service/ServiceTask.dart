import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:smg_project_tools/5_service/Service.dart';
import 'ServiceConfig.dart';

enum TaskContentType { json, formData }

///网络访问单个任务配置信息
class ServiceTask {
  ///主域名
  String domain;

  ///请求的api
  String path;

  ///请求参数
  Map params;

  ///请求参数 字符串
  String paramStr;

  ///数据类型 默认json
  TaskContentType contentType;

  ///数据类型
  String contentTypeStr;

  ///超时时间 单位s 5s
  int timeout;

  ///访问参数是否放在body中，默认true，默认不放在body则拼在链接后面
  bool isBodyParams;

  ///域名等级， 默认0，参考ServiceConfig读取的文件中，domain在数组中的排序，为asc，如果外部设置为空，将返回空的task，不进行访问
  int domainLevel;

  ///是否展示loading
  bool isShowToast;

  ///展示的loading文案 默认正在加载
  String showToastStr;

  ///用于取消请求的token
  CancelToken cancelToken;

  ///用于取消loading
  CancelFunc cancelToast;

  /* 
   * path 路径
   * timeout 超时时间，单位s，默认5s
   * isBodyParams 是否在body添加参数，默认true
   * contentType 参数格式
   * isSubDomain 是否使用二级域名 
   * params 通过编辑的请求参数字符串，可能是json
   * cancelToken 取消操作的方法
   * isShowToast 是否展示loading
   * customType  对应customTaskBuildDelegate的特殊操作，传入以后，如果定义了customTaskBuildDelegate，则在回调中可发现
   * 
   */
  ServiceTask(this.path,
      {this.timeout = 5,
      this.isBodyParams,
      this.contentType,
      this.domainLevel,
      this.params,
      this.paramStr,
      this.cancelToken,
      this.isShowToast,
      this.showToastStr,
      this.cancelToast,
      int customType = 0}) {
    this.domain = ServiceConfig.shareInstance().domains['$domainLevel'];
    if (this.contentType == TaskContentType.json) {
      this.contentTypeStr = 'application/json; charset=utf-8';
    } else {
      this.contentTypeStr = 'application/x-www-form-urlencoded';
    }
    ///自定义的一些操作，customType，默认0
    if (Service.shareInstance().customTaskBuildDelegate != null) {
      Service.shareInstance().customTaskBuildDelegate(this, customType);
    }
  }

  /*
   *获取基础配置 
   */
  BaseOptions getOptions() {
    return BaseOptions(
        //请求基地址,可以包含子路径
        baseUrl: this.domain,
        //连接服务器超时时间，单位是毫秒.
        connectTimeout: this.timeout * 1000,
        //响应流上前后两次接受到数据的间隔，单位为毫秒。
        receiveTimeout: 5000,
        //Http请求头.
        headers: {
          //do something
        },
        contentType: this.contentTypeStr,
        responseType: ResponseType.json);
  }
  
}

///创建请求任务
///[domainLevel]域名等级， 默认0，参考ServiceConfig读取的文件中，domain在数组中的排序，为asc，如果外部设置为空，将返回空的task，不进行访问
Future<ServiceTask> buildTask(String path,
    {Map param,
    int domainLevel = 0,
    TaskContentType contentType = TaskContentType.json,
    bool isBodyParams = true,
    CancelToken cancelToken,
    bool isShowToast = true,
    String showToastStr = '正在加载',
    int customType = 0}) async {
  
  if (param == null) param = {};
  String paramStr = await getParamStr(param, isBodyParams, contentType);
  ///不放在body中
  if (!isBodyParams) {
    if (path.contains('?')) {
      path = path + '&' + paramStr ?? '';
    } else {
      path = path + '?' + paramStr ?? '';
    }
    paramStr = '';
  }
  return ServiceTask(path,
      params: param,
      paramStr: paramStr,
      domainLevel: domainLevel,
      contentType: contentType,
      isBodyParams: isBodyParams,
      cancelToken: cancelToken,
      showToastStr: showToastStr,
      isShowToast: isShowToast,
      customType: customType);
}

Future<String> getParamStr(
    Map param, bool isBodyParams, TaskContentType contentType) async {
  param = param == null ? {} : param;
  param.removeWhere((key, value) => (value.toString().isEmpty));
  Map res = param;
  ///自定义加密
  if (Service.shareInstance().customEncryptionDelegate != null) {
    res = await Service.shareInstance().customEncryptionDelegate(param);
  }
  String paramStr = '';
  if (isBodyParams) {
    switch (contentType) {
      case TaskContentType.json:
        {
          paramStr = json.encode(res);
        }
        break;
      case TaskContentType.formData:
        {
          res.forEach((key, value) {
            paramStr += '$key=$value&';
          });
          paramStr = paramStr.substring(0, paramStr.length - 1);
        }
        break;
      default:
    }
  } else {
    param.forEach((key, value) {
      paramStr += '$key=$value&';
    });
    paramStr = paramStr.substring(0, paramStr.length - 1);
  }
  return paramStr;
}

