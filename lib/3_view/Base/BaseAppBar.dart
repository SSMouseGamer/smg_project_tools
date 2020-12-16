import 'package:flutter/material.dart';
import 'package:smg_project_tools/1_extension/extension_header.dart';

Widget baseAppBar(BuildContext context,
    {String title = "",
    double elevation = 0.5,
    Color backgroundColor = Colors.white,
    bool hideNavBackBtn = false,
    Widget backBtnIconWidget,
    List<Widget> actionBtns = const <Widget>[]}) {
  return AppBar(
    title: Text(
      title,
      style: TextStyle(color: Colors.black),
    ),
    centerTitle: true,
    elevation: elevation,
    brightness: Brightness.light,
    backgroundColor: backgroundColor,
    leading: hideNavBackBtn
        ? Container()
        : RaisedButton(
            elevation: 0,
            highlightElevation: 0,
            color: Colors.transparent,
            highlightColor: Colors.transparent,
            // 透明色
            splashColor: Colors.transparent,
            child: backBtnIconWidget ??
                Icon(Icons.arrow_back_ios, size: 16).intoContainer(),
            onPressed: () =>
                Navigator.canPop(context) ? Navigator.pop(context) : null),
    actions: actionBtns,
  );
}
