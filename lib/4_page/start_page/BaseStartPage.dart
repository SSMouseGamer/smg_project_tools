// 启动页
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smg_project_tools/0_base/base_route/BaseRouter.dart';
import 'package:smg_project_tools/4_page/base_page/BaseNavHidePage.dart';

// ignore: must_be_immutable
class BaseStartupPage extends StatefulWidget {
  String launchBGImg;
  String launchLogoImg;
  void Function() goHomeBlock;
  BaseStartupPage({this.launchBGImg = 'image/img_qidong.jpg', this.launchLogoImg = 'image/img_logo.png', this.goHomeBlock});
  @override
  _BaseStartupPage createState() => _BaseStartupPage(
      launchBGImg: this.launchBGImg,
      launchLogoImg: this.launchLogoImg,
      goHomeBlock: this.goHomeBlock);
}

class _BaseStartupPage extends BaseNavHidePage {
  void Function() goHomeBlock;
  String launchBGImg = '';
  String launchLogoImg = '';

  _BaseStartupPage({this.launchBGImg, this.launchLogoImg, this.goHomeBlock});

  @override
  void onStateCreate() {
    updateSetting();
    // 2秒后跳转至主页
    Future.delayed(Duration(milliseconds: 1500), () {
      gotoHomePage();
    });
    super.onStateCreate();
  }

  void gotoHomePage() {
    if (this.goHomeBlock != null) this.goHomeBlock();
  }

  @override
  Widget buildBody() {
    return Container(
      color: Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: 0,
              child: Container(
                child: Image(
                  image: AssetImage(this.launchBGImg, package: 'smg_project_tools'),
                  width: window.physicalSize.width / window.devicePixelRatio,
                  height: window.physicalSize.height / window.devicePixelRatio,
                  fit: BoxFit.fill,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // 版本更新设置
  updateSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('updateVersionFlag', json.encode(true));
  }
}
