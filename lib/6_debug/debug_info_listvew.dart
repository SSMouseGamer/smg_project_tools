import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smg_project_tools/2_utils/utils_header.dart';

class DebugInfoListView extends StatefulWidget {
  final List<String> infoList;

  DebugInfoListView({
    Key key,
    this.infoList = const [],
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DebugInfoListViewState(infoList);
}

class _DebugInfoListViewState extends State<DebugInfoListView> {
  final List<String> _infoList;
  int _clickIndex = -1;

  _DebugInfoListViewState(this._infoList);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return Container(
          child: Column(
            children: <Widget>[
              _buildInfoItem(index),
              if (index == _clickIndex) _buildDetailItem(index),
              Divider(),
            ],
          ),
        );
      },
      itemCount: _infoList.length,
    );
  }

  Widget _buildInfoItem(int index) {
    return GestureDetector(
      child: Text(
        _infoList[index],
        maxLines: 5,
        style: TextStyle(
          fontSize: 15,
          decoration: TextDecoration.none,
        ),
      ),
      onTap: () {
        setState(() {
          _clickIndex = index;
        });
      },
    );
  }

  Widget _buildDetailItem(int index) {
    String info = _infoList[index];
    return GestureDetector(
      child: Container(
        color: Colors.white,
        child: Text(
          info,
          style: TextStyle(
            fontSize: 15,
            decoration: TextDecoration.none,
          ),
        ),
      ),
      onTap: () {
        setState(() {
          _clickIndex = -1;
        });
      },
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: info));
        showTipStr(tipStr:"已复制到剪贴板");
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
