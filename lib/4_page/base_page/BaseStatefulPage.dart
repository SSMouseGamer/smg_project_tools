import 'package:flutter/material.dart';
import 'package:smg_project_tools/0_base/base_header.dart';
import 'package:smg_project_tools/3_view/Base/BaseAppBar.dart';

class BaseStatefulPage extends BasePageState with BaseStatefulPageMixin {
  Color bodyColor = Color(0xffeeeeee);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Container(
        color: bodyColor,
        child: buildBody(),
      ),
    );
  }

  @override
  void onStateCreate() {}

  @override
  Widget buildBody() {
    return super.buildBody();
  }
}

mixin BaseStatefulPageMixin {
  NavigationBar navigationBar = NavigationBar();

  void setPageNavigatorTitle(String title) {
    navigationBar.title = title;
  }

  Widget buildBody() {
    return Container();
  }

  Widget buildAppBar(BuildContext context) {
    List actionBtns = navigationBar.rightBarItems
        .map((e) => FlatButton(
            child: Text(e.title),
            onPressed: () => e.actionBlock != null ? e.actionBlock() : null))
        .toList();
    return baseAppBar(context,
        hideNavBackBtn: navigationBar.hideNavBackBtn,
        title: navigationBar.title,
        actionBtns: actionBtns);
  }
}

class NavigationBar {
  String title = '';
  String backTitle = '';
  String backIcon = '';
  bool hideNavBackBtn = false;
  List<BarButtonItem> rightBarItems = [];
}

class BarButtonItem {
  String title;
  void Function() actionBlock;
}
