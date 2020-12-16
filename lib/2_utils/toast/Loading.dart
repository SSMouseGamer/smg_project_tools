import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';



class Loading extends StatefulWidget {
  final String text;
  final CancelFunc cancelFunc;

  const Loading({Key key, this.text, this.cancelFunc}) : super(key: key);

  @override
  __LoadingWidget createState() => __LoadingWidget();
}

class __LoadingWidget extends State<Loading>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return new Material(
      type: MaterialType.transparency,
      child: new Center(
        child: new Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            color: Colors.black54,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SpinKitCircle(
                color: Colors.white,
                size: 60,
              ),
              Text('${widget.text}... ', style: TextStyle(color: Colors.white, fontSize: 15.0))
            ],
          ),
        )
      ),
    );
  }
}