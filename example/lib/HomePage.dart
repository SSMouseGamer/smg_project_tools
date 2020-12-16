import 'package:flutter/material.dart';
import 'package:smg_project_tools/smg_project_tools.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageSate createState() => _HomePageSate();
}

class _HomePageSate extends BaseTablePage {

  void _requestTest() async {
    ///测试域名1
    ServiceTask task1 = await buildTask('wahhhh', domainLevel: 1);
    ///测试默认域名
    ServiceTask task2 = await buildTask('23333');
    ///测试自定义task处理
    ServiceTask task3 = await buildTask('44444', customType: 233);

    Service.shareInstance().post(task1, customCallback: (data, success, code, msg) {
      LogUtils.log('返回的数据task1：$data');
    });

    Service.shareInstance().post(task2).then((value) {
      LogUtils.log('返回的数据task2：$value');
    });

    LogUtils.log('task1: path => ${task1.path}, paramStr => ${task1.paramStr}');
    LogUtils.log('task2: path => ${task2.path}, paramStr => ${task2.paramStr}');
    LogUtils.log('task3: path => ${task3.path}, paramStr => ${task3.paramStr}');
  }

  @override
  NavigationBar get navigationBar {
    NavigationBar bar = super.navigationBar;
    bar.hideNavBackBtn = true;
    return bar;
  }

  @override
  void onStateCreate() {
    setPageNavigatorTitle('测试UI');
    super.onStateCreate();
  }

  @override
  void initDataSource() {
    BaseTableModel m0 = BaseTableModel(title: '标题', desc: '描述', action: () {

    });
    BaseTableModel m1 = BaseTableModel(
        title: '测试接口构建',
        desc: '描述',
        action: () {
          _requestTest();
        });

    BaseTableModel m2 = BaseTableModel(
        title: '切换环境等',
        desc: '描述',
        action: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => ServiceSetting()));
        });

    setState(() {
      tableView.datas = [
        [m0],
        [m2, m1]
      ];
      tableView.reloadData();
    });
  }
}