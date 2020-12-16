import 'package:flutter/material.dart';
import 'package:smg_project_tools/3_view/tableView/TableView.dart';
import 'package:smg_project_tools/1_extension/layout/widget_chain.dart';
import 'package:smg_project_tools/4_page/base_page/BaseStatefulPage.dart';

class BaseTablePage extends BaseStatefulPage with BaseTableMixin {
  @override
  Widget buildBody() {
    return Container(
      color: Colors.white,
      child:
          tableView.buildTable(context).intoContainer(color: Color(0xFFF4F4F4)),
    );
  }

  @override
  void onStateCreate() {
    initDataSource();
  }

  @override
  void initDataSource() {}

  @override
  NavigationBar get navigationBar => super.navigationBar;
}

mixin BaseTableMixin {
  BaseTableView tableView = BaseTableView();
  void initDataSource();
}
