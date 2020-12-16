import 'package:flutter/material.dart';
import 'TableDataSource.dart';
import 'package:smg_project_tools/1_extension/layout/widget_chain.dart';
/* 
 * 基础列表，用于快速构建列表，使用示例请在项目搜索：MsgNotificationPage
 * dataSource => TableDataSource 用于管理列表的分组、头、尾，如果使用默认UI，传入数据即可使用，反之需要重写dataSource的各个UI代理
 * datas 默认数据
 */
class BaseTableView {
  ///构造函数
  ///dataSource listView的管理工具
  ///datas listView的数据
  ///这两者都用于默认的listView
  BaseTableView({this.dataSource, this.datas}) {
    if (this.datas == null) {
      this.datas = [];
    }
    if (this.dataSource == null) {
      this.dataSource = _getTableDataSource();
    }
  }
  TableDataSource dataSource;
  List<List<BaseTableModel>> datas;

  ///构建列表
  ///context 上下文
  Widget buildTable(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return dataSource.cellAtIndex(index);
      },
      itemCount: dataSource.allItemCount,
    );
  }

  void reloadData() {
    this.dataSource = _getTableDataSource();
  }

  ///默认的dataSource管理器
  TableDataSource _getTableDataSource() {
    return TableDataSource(
      numberOfSections: datas.length,
      numberOfRowsInSection: (section) => datas[section].length,
      footerForSection: (section) => Container(height: 20, color:Color(0xFFF4F4F4)),
      cellForRowAtIndexPath: (IndexPath indexPath) {
        return InkWell(
            onTap: () {
              if (datas[indexPath.section][indexPath.row].action != null) {
                datas[indexPath.section][indexPath.row].action();
              }
            },
            child: Text(
                  datas[indexPath.section][indexPath.row].title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: datas[indexPath.section][indexPath.row].selected
                          ? Colors.red
                          : Colors.black),
                  textAlign: TextAlign.left,
                ).addNeighbor(
                  Text(datas[indexPath.section][indexPath.row].desc,
                    style: TextStyle(fontSize: 10), textAlign: TextAlign.left)
                ).addNeighbor(
                  (indexPath.row == (datas[indexPath.section].length - 1) ? Container(height: 1.5) :
                  Divider(color:Color(0xFFEBEBEB), height: 1.5,))
                  .intoContainer(margin: const EdgeInsets.only(top: 15))
                ).intoColumn(crossAxisAlignment: CrossAxisAlignment.start)
                .intoContainer(margin: EdgeInsets.only(top:15, left: 15, right: 15))
                .intoContainer(color: Colors.white)
                
         );
      },
    );
  }
}

/* 
 *base列表基础数据
 */
class BaseTableModel {
  String title = '';
  String desc = '';
  bool selected = false;
  void Function() action;
  BaseTableModel({this.title, this.desc, this.action, this.selected = false});
}
