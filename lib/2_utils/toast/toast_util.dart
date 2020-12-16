import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'Loading.dart';

///展示loading
///[toastStr]loading的提示字符串
CancelFunc showLoadingToast({String toastStr = '', int timeOut = 5}) {
  return BotToast.showCustomLoading(
        duration: Duration(seconds:timeOut ?? 5),
        ignoreContentClick: true,
        toastBuilder: (cancelFunc) {
          return Loading(text: toastStr ?? '');
    });
}

///展示请求错误
///[errorStr]默认 网络异常，请稍后再试
void showTipStr({String tipStr = '网络异常，请稍后再试！'}) {
  BotToast.showText(
        text: tipStr,
        align: Alignment(0, 0.1),
        onlyOne: true,
        duration: Duration(milliseconds: 2000),
        contentPadding: const EdgeInsets.all(15.0));
}