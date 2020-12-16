import 'package:flutter/material.dart';
import 'package:smg_project_tools/2_utils/dialog/dialog_utils.dart';
import 'package:smg_project_tools/2_utils/utils_header.dart';
import 'package:smg_project_tools/4_page/base_page/BaseStatefulPage.dart';
import 'package:smg_project_tools/5_service/ServiceConfig.dart';
import 'package:smg_project_tools/smg_project_tools.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:smg_project_tools/4_page/table_page/BaseTablePage.dart';

class ServiceSetting extends StatefulWidget {
  @override
  _ServiceSettingState createState() => _ServiceSettingState();
}

class _ServiceSettingState extends BaseTablePage {
  void _copyDeviceToken() async {
    // String token = await PlatformMethodChannel.getInstance().getDeviceToken();
    // if (token != null && token.length > 0) {
    //     Clipboard.setData(ClipboardData(text: token));
    //     showTipStr(tipStr:'已复制到剪切板');
    //   } else {
    //     showTipStr(tipStr:'获取token失败，请重试');
    //   }
  }

  @override
  NavigationBar get navigationBar {
    NavigationBar bar = NavigationBar();
    bar.title = '选择环境';
    BarButtonItem item = BarButtonItem();
    item.title = '获取推送Token';
    item.actionBlock = () {
      _copyDeviceToken();
    };
    bar.rightBarItems = [item];
    return bar;
  }

  @override
  void initDataSource() {
    // 1、获取本地存储的环境下标（以json文件的数组顺序为准），默认正式环境
    SharedPreferences prefs;
    SharedPreferences.getInstance().then((value) => prefs = value);
    int environment = ServiceConfig.shareInstance().environment;
    List configs = ServiceConfig.shareInstance().qlDomainConfigs;
    List<BaseTableModel> results = [];
    for (int i = 0; i < configs.length; i++) {
      Map domains = configs[i]['domains'];
      results.add(BaseTableModel(
          title: configs[i]["name"],
          desc: domains.isEmpty
              ? '未配置，请修改service_configs.json'
              : domains[domains.keys.first],
          selected: i == environment,
          action: () {
            if (i == environment) return;
            showTipDialog(
                title: '是否切换至${configs[i]["name"]}',
                sureBlock: () {
                  prefs.setInt(CONFIG_SERVICE_ENVIRONMENT_KEY, i);
                  showTipStr(tipStr: "切换至${configs[i]["name"]}成功，请重新登录");
                  ServiceConfig.shareInstance().domains = configs[i]['domains'];
                  ServiceConfig.shareInstance().environment = i;
                });
          }));
    }
    getSpString(CONFIG_SERVICE_PROXY_KEY).then((proxy) {
      setState(() {
        BaseTableModel proxyModel = BaseTableModel(
            title: '配置代理',
            selected: false,
            desc: proxy == null || proxy.length == 0 ? '未配置' : proxy,
            action: () {
              showInputDialog(context,
                  hintText: '请输入代理，eg:x.x.x.x:233',
                  currentText: proxy, block: (newProxy) {
                setSpString(
                    CONFIG_SERVICE_PROXY_KEY, newProxy == null ? '' : newProxy);
                showTipStr(tipStr: '代理配置成功，杀掉应用重新进入即可');
                ServiceConfig.shareInstance().resetServiceProxy(newProxy);
                Navigator.of(context).pop();
              });
            });
        tableView.datas = [results, [proxyModel]];
        tableView.reloadData();
      });
    });
  }
}

void showInputDialog(BuildContext context,
    {String currentText = '', String hintText, void block(String inputText)}) {
  showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String _inputText = currentText ?? '';
        return new Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AlertDialog(
              content: Container(
                child: TextField(
                  textInputAction: TextInputAction.done,
                  showCursor: true,
                  controller: TextEditingController(text: currentText),
                  enableInteractiveSelection: true,
                  // focusNode: _autofocus,
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      hintText: hintText,
                      labelText: currentText,
                      counterText: "",
                      border: OutlineInputBorder(borderSide: BorderSide.none)),
                  onChanged: (v) {
                    _inputText = v;
                  },
                  onSubmitted: (v) {
                    if (block != null) block(v);
                    Navigator.pop(context);
                  },
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                    onPressed: () {
                      if (block != null) block(_inputText);
                      Navigator.pop(context);
                    },
                    child: Text('确认')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('取消')),
              ],
            )
          ],
        ));
      });
}
