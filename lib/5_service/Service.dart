import 'package:dio/dio.dart';
import 'package:smg_project_tools/2_utils/log/LogUtils.dart';
import 'ServiceResolve.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import 'ServiceTask.dart';

typedef ServiceCompleteCallback = void Function(dynamic data, dynamic success, dynamic code, dynamic msg);

///网络访问控制器
class Service {
  ///自定义task处理 
  ///[task]当前构建的任务 
  ///[customType]自定义的类型，比如要在path后面拼接固定字符串什么的 
  void Function(ServiceTask task, int customType) customTaskBuildDelegate;

  ///自定义加密、签名处理
  ///[param]需要加密的参数
  ///[return]返回原来的参数+签名参数
  Future<Map> Function(Map param) customEncryptionDelegate;


  Future Function(Response response, ServiceCompleteCallback callback) customeResolveResultDelegate;
  
  ///dio网络请求管理
  Dio dio;

  ///请求配置
  BaseOptions options;

  ///用来缓存当前进行的任务
  Map<String, ServiceTask> _taskCacheMap;

  factory Service() => shareInstance();
  static Service _instance = Service._();

  Service._() {
    //初始化代码
    _taskCacheMap = {};
    _initDio();
  }

  static Service shareInstance() {
    return _instance;
  }

  /*
   * 初始化dio服务
   */
  _initDio() {
    dio = new Dio();
    ///添加拦截器
    _addInterceptors();
  }

  void _addInterceptors() {
    ///Cookie管理
    dio.interceptors.add(CookieManager(CookieJar()));
    ///拦截器状态处理
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (RequestOptions options) {
        String requestInfo = '''
\n>>>>>>>>>>>>>>>>>>>>>>>>> Http-Request >>>>>>>>>>>>>>>>>>>>>>>>>>> 
>>> 
>>> ${options.path}
>>> method = ${options.method.toString()}
>>> url = ${options.uri.toString()}
>>> headers = ${options.headers}
>>> params = ${options.data}
>>> 
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> \n
''';
        LogUtils.httpLog(requestInfo);
        // Do something before request is sent
        resolveOnRequest(_taskCacheMap[options.path]);
        return options;
      },
      onResponse: (Response response) {
        String responseInfo = '''
\n>>>>>>>>>>>>>>>>>>>>>>>>> Http-Response >>>>>>>>>>>>>>>>>>>>>>>>>>> 
>>> 
>>> ${response.request?.path}
>>> url = ${response.request?.uri}
>>> code = ${response.statusCode}
>>> data = ${response.data}
>>> 
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> \n
''';
        LogUtils.httpLog(responseInfo);
        // 请求成功
        Future.delayed(Duration(milliseconds: 150), () {
          resolveOnResponse(_taskCacheMap[response.request.path], response);
          _taskCacheMap.remove(response.request.path);
          return response;
        });
      },
      onError: (DioError e) {
        String errorInfo = '''
\n>>>>>>>>>>>>>>>>>>>>>>>>>> Http-Error >>>>>>>>>>>>>>>>>>>>>>>>>>>> 
>>> 
>>> ${e.request?.path}
>>> url = ${e.request?.uri}
>>> type = ${e.type}
>>> message = ${e.message}
>>> 
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> \n
''';
        LogUtils.httpLog(errorInfo);
        // Do something with response error
        Future.delayed(Duration(milliseconds: 100), () {
          resolveOnError(_taskCacheMap[e.request.path], e);
          _taskCacheMap.remove(e.request.path);
          return e;
        });
      },
    ));
    // 开启请求日志
    // dio.interceptors.add(LogInterceptor(responseBody: false));
  }

  // ------------------------------------------------------------
  // ------------------------------------------------------------

  /*
   * get请求 暂时还没有get请求的接口，暂且搁置
   * task 请求的任务
   * @cancelToken 该请求的标识，可用于取消该请求
   */
  get(ServiceTask task, {cancelToken}) async {
    Response response;
    try {
      response = await dio.get(task.path,
          queryParameters: task.params, cancelToken: cancelToken);
      //  response.data; 响应体
      //  response.headers; 响应头
      //  response.request; 请求体
      //  response.statusCode; 状态码
    } on DioError catch (e) {
      formatError(e);
    }
    return response.data;
  }

  /* 
  *post 请求
  *task 任务信息
  *cancelToken 取消任务的方法
  *customCallback 以函数体的方式返回标准数据，如果customeResolveResultDelegate未定义，设置了也不生效，只能从future.then返回的整个response数据自行处理
  */
  Future<T> post<T>(ServiceTask task, {cancelToken, ServiceCompleteCallback customCallback}) async {
    Response response;
    ///task为空，直接忽略callback，不需要处理
    if (task == null) return response?.data;
    ///已经有执行的任务，直接忽略callback，不需要处理
    if (_taskCacheMap[task.path] != null) {
      LogUtils.log('request：${task.path} 已经有请求在执行');
      return response?.data ?? {};
    }

    ///1 获取配置
    dio.options = task.getOptions();

    ///2 开启请求
    try {
      ///更新任务池
      _taskCacheMap.update(task.path, (value) => (task), ifAbsent: () => task);
      response = await dio.post(
          task.path,
          data: task.paramStr,
          options: RequestOptions(
              baseUrl: task.domain, contentType: task.contentTypeStr),
          cancelToken: cancelToken);
    } on DioError catch (e) {
      formatError(e);
    }
    ///有自定义的返回自定义
    if (customeResolveResultDelegate != null) {
      return customeResolveResultDelegate(response, customCallback);
    }
    return response?.data ?? {};
  }

  /*
   * 下载文件
   */
  downloadFile(urlPath, savePath) async {
    Response response;
    try {
      response = await dio.download(urlPath, savePath,
          onReceiveProgress: (int count, int total) {
        //进度
        LogUtils.log("$count $total");
      });
    } on DioError catch (e) {
      formatError(e);
    }
    return response.data;
  }

  /* 
   * 上传文件
   * task任务配置，其中的params必须包含imageFilePath字段
   */
  Future<T> uploadFile <T>(ServiceTask task) async {
    if (task.params['imageFilePath'] == null) return null;
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(task.params['imageFilePath']),
      ...task.params
    });
    dio.options = task.getOptions();
    Response response;
    try {
      response = await dio.post(
        task.path,
        options: RequestOptions(
              baseUrl: task.domain, contentType: task.contentTypeStr),
        data: formData);
    } on DioError catch (e) {
      formatError(e);
    }
    return response?.data;
  }

  /*
   * error统一处理
   */
  void formatError(DioError e) {
    if (e.type == DioErrorType.CONNECT_TIMEOUT) {
      // It occurs when url is opened timeout.
      LogUtils.log("连接超时");
    } else if (e.type == DioErrorType.SEND_TIMEOUT) {
      // It occurs when url is sent timeout.
      LogUtils.log("请求超时");
    } else if (e.type == DioErrorType.RECEIVE_TIMEOUT) {
      //It occurs when receiving timeout
      LogUtils.log("响应超时");
    } else if (e.type == DioErrorType.RESPONSE) {
      // When the server response, but with a incorrect status, such as 404, 503...
      LogUtils.log("出现异常");
    } else if (e.type == DioErrorType.CANCEL) {
      // When the request is cancelled, dio will throw a error with this type.
      LogUtils.log("请求取消");
    } else {
      //DEFAULT Default error type, Some other Error. In this case, you can read the DioError.error if it is not null.
      LogUtils.log("未知错误");
    }
  }

  /*
   * 取消请求 
   * 同一个cancel token 可以用于多个请求，当一个cancel token取消时，所有使用该cancel token的请求都会被取消。
   * 所以参数可选
   */
  void cancelRequests(CancelToken token) {
    token.cancel("cancelled");
  }
}

typedef SuccessCallback<T> = void Function(T data);
typedef OtherCodeCallback = void Function(int code, String message);

/// 处理 http 返回数据格式
void handleResponseData<T>(Map res, SuccessCallback<T> successCallback,
    {OtherCodeCallback otherCodeCallback}) {
  if (res == null || res.isEmpty || res['code'] == null) return;
  final code = res['code'];
  if (code == 0) {
    final data = res['data'];
    if (data != null) {
      successCallback(data as T);
    }
  } else {
    if (otherCodeCallback != null) {
      otherCodeCallback(code, res['message']);
    }
  }
}
