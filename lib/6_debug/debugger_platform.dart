import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smg_project_tools/1_extension/string/string_tools_extension.dart';
import './debug_info_listvew.dart';

final bool isShowDebuggerPlatform = kDebugMode;
List<String> _httpInfoList = [];
List<String> _debuggerInfoList = [];

void updateHttpInfoList(String info) {
  if (!StringTools.stringIsEmpty(info)) {
    DateTime dateTime = DateTime.now();
    info =
        "Time: 【 ${dateTime.hour}:${dateTime.minute}:${dateTime.second} 】\n${info.replaceAll(">>>>>>>>>>>>>>>>>>>>", "")}";
    _httpInfoList.insert(0, info);
  }
}

void updateDebuggerInfoList(String info, {String title = "tag"}) {
  if (!StringTools.stringIsEmpty(info)) {
    info = "Tag: 【 $title 】\n$info";
    _debuggerInfoList.insert(0, info);
  }
}

Widget buildDebuggerPlatform() {
  return DebuggerPlatform();
}

/// 测试时输出信息
class DebuggerPlatform extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DebuggerPlatformState();
}

class _DebuggerPlatformState extends State<DebuggerPlatform> {
  bool _isHttpInfoList = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 30),
        Row(
          children: [
            Container(
              color: Colors.white,
              child: RaisedButton(
                  child: Text("http"),
                  onPressed: () {
                    setState(() {
                      _isHttpInfoList = true;
                    });
                  }),
            ),
            Container(
              color: Colors.white,
              child: RaisedButton(
                  child: Text("other"),
                  onPressed: () {
                    setState(() {
                      _isHttpInfoList = false;
                    });
                  }),
            ),
            Container(
              color: Colors.white,
              child: RaisedButton(
                  child: Text("clear"),
                  onPressed: () {
                    setState(() {
                      _httpInfoList.clear();
                      _debuggerInfoList.clear();
                      _isHttpInfoList = true;
                    });
                  }),
            ),
          ],
        ),
        Expanded(
          child: Container(
            color: Colors.grey,
            child: _isHttpInfoList
                ? DebugInfoListView(infoList: _httpInfoList)
                : Container(
                    child: DebugInfoListView(infoList: _debuggerInfoList)),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
