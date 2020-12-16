/* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= service_config.json数据结构 -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
[
    {   "name"     :"正式环境", 
        "domains"  :{
            "0":"https://mobileapi.qinlinkeji.com/api/", 
            "1":"https://qapp.qinlinkeji.com/app/api/"
        }
    },

    {   "name"     :"测试环境",
        "domains"  :{
            "0":"https://uat-mobileapi.qinlinkeji.com/api/", 
            "1":"https://uat-qapp.qinlinkeji.com/app/api/"
        }
    }
]

 */
///service_config.json的目录请按照CONFIG_SERVICE_PATH_KEY定义的方式存放，resource与yaml文件在同一个目录下

import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:flutter/services.dart';
import 'package:smg_project_tools/2_utils/utils_header.dart';
import 'Service.dart';

///json路径
const String CONFIG_SERVICE_PATH_KEY = 'resource/service_config.json';

///缓存在本地的key，默认0，也就是正式环境
const String CONFIG_SERVICE_ENVIRONMENT_KEY = 'ql_environment';

///配置的代理
const String CONFIG_SERVICE_PROXY_KEY = 'ql_proxy';

class ServiceConfig {
  ///代理
  String proxy;

  ///选择的环境 0:正式环境， 1:测试环境
  int environment;

  ///当前选中的域名配置信息
  Map domains;

  ///从文件读取的配置信息表
  List<dynamic> qlDomainConfigs;

  factory ServiceConfig() => shareInstance();
  static ServiceConfig _instance = ServiceConfig._();

  ServiceConfig._() {
    //初始化代码
    initConfigs();
  }

  Future<void> initConfigs() async {
    //1、选择的环境，默认正式环境
    environment = await getSpInt(CONFIG_SERVICE_ENVIRONMENT_KEY);
    environment = environment == null ? 0 : environment;
    //2、获取本地domain配置文件
    await rootBundle.loadString(CONFIG_SERVICE_PATH_KEY).then((value) {
      final configs = jsonDecode(value);
      this.qlDomainConfigs = configs;
      if (environment < this.qlDomainConfigs.length) {
        this.domains = this.qlDomainConfigs[environment]["domains"];
      } else {
        this.domains = this.qlDomainConfigs.first["domains"];
      }
    });
    //3、 获取本地代理配置
    proxy = await getSpString(CONFIG_SERVICE_PROXY_KEY);
    resetServiceProxy(proxy);
  }

  /* 
   *重置代理
   */
  void resetServiceProxy(String currentProxy) {
    proxy = currentProxy;
    // if (kReleaseMode) return;
    //解决Android抓包的问题
    if (currentProxy != null && currentProxy.isNotEmpty) {
      //解决Android抓包的问题
      (Service.shareInstance().dio.httpClientAdapter
              as DefaultHttpClientAdapter)
          .onHttpClientCreate = (client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return Platform.isAndroid;
        };
        client.findProxy = (uri) {
          return "PROXY $currentProxy";
        };
      };
    }
  }

  static ServiceConfig shareInstance() {
    return _instance;
  }
}
