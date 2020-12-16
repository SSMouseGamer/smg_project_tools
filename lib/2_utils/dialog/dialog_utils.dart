import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smg_project_tools/0_base/base_route/BaseRouter.dart';

///iOS风格的确认弹窗
showTipDialog(
    {String title = '',
    String listTitle = '',
    String detail = '',
    String sureStr = '确定',
    String cancelStr = '关闭',
    void Function() sureBlock,
    void Function() cancelBlock,
    bool autoDismiss = true}) {
  showDialog(
      context: getCurrentContext(),
      barrierDismissible: false,
      builder: (context) {
        return CupertinoAlertDialog(
          content: ListBody(
            children: <Widget>[
              Text(
                title,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              Text(listTitle),
              Text(detail)
            ],
          ),
          actions: <Widget>[
            CupertinoDialogAction(
                child: Text(cancelStr),
                onPressed: () {
                  if (cancelBlock != null) cancelBlock();
                  Navigator.of(context).pop();
                }),
            CupertinoDialogAction(
                child: Text(sureStr),
                onPressed: () {
                  if (sureBlock != null) sureBlock();
                  if (autoDismiss) Navigator.of(context).pop();
                })
          ],
        );
      });
}