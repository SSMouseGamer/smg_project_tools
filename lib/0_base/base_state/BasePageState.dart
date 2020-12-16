import 'package:flutter/cupertino.dart';
import 'package:smg_project_tools/2_utils/notification/NotificationCenter.dart';

/*
* BasePageState：State 基类，用于状态、数据采集等
* StatefulWidget 和 StatelessWidget只有一个状态，不用基类，可以考虑采用 mixin
* */
abstract class BasePageState<T extends StatefulWidget> extends State<T> {
  @override
  void initState() {
    super.initState();
    onStateCreate();
  }
  
  @protected
  @mustCallSuper
  void onStateCreate();

  @override
  Widget build(BuildContext context);

  @override
  void dispose() {
    NotificationCenter.removeObserver(this);
    super.dispose();
  }

/*@override
  Type get runtimeType => super.runtimeType;

  this.runtimeType.toString()*/

}
