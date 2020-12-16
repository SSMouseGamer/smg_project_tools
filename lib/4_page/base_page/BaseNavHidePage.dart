import 'package:flutter/material.dart';
import 'package:smg_project_tools/4_page/base_page/BaseStatefulPage.dart';

class BaseNavHidePage extends BaseStatefulPage {

  @override 
  Color get bodyColor => super.bodyColor;

  @override
  NavigationBar get navigationBar {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: buildBody(),
      ),
    );
  }

  @override
  void onStateCreate() {
    super.onStateCreate();
  }

  @override
  Widget buildBody() {
    return super.buildBody();
  }
}
