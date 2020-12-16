import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/* 
 * 基础View，封装了provider的基础应用
 * builder 这里是消费者的widget
 * model 这是viewModel，如果需要在外部调用，需要外部持有这个对象（请看NewPersonalInfo.dart）
 * child 这里一般是静态UI
 */
class BaseCosumer<T extends ChangeNotifier> extends StatefulWidget {
  final Widget Function(BuildContext context, T model, Widget child) builder;
  final T model;
  final Widget child;
  final Function(T) onModelReady;
  BaseCosumer({Key key, this.model, this.builder, this.child, this.onModelReady})
      : super(key: key);

  @override
  _BaseCosumerState<T> createState() => _BaseCosumerState<T>();
}

class _BaseCosumerState<T extends ChangeNotifier> extends State<BaseCosumer<T>> {

  T model;

  @override
  void initState() {
    model = widget.model;
    if (widget.onModelReady != null) {
      widget.onModelReady(model);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>.value(
      value: model,
      child: Consumer<T>(
        builder: widget.builder,
        child: widget.child,
      ),
    );
  }
}

///示例代码
/*
class QLTestWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BaseCosumer<TestViewModel>(
      model: TestViewModel(testService: TestService()),
      builder: (context, model, child) => Scaffold(
        appBar:DefaultView.buildDefaultAppBar(context, title:'测试BaseView的使用'),
        body: Column(
          children: <Widget>[
            model.state == ViewState.Loading ? Center(
              child:CircularProgressIndicator(),
            )
            : Text(model.testInfo),
            FlatButton(
              color: Colors.black,
              onPressed: () => model.click(),
              child: Text('按钮', style:TextStyle(color: Colors.white)),
            )
          ],
        ),
      )
    );
  }
}

class TestViewModel extends BaseModel {
  String testInfo = '请点击';
  TestService _testService;

  TestViewModel({@required TestService testService})
    : _testService = testService;
  
  Future<String> click() async {
    setState(ViewState.Loading);
    testInfo = await _testService.test();
    setState(ViewState.Success);
    return testInfo;
  }
}

class TestService {
  Future<String> test() async {
    return Future.delayed(Duration(seconds: 1), () => '已点击');
  }
}

enum ViewState {Loading, Success, Failure, None }

class BaseModel extends ChangeNotifier {
  ViewState _state = ViewState.None;

  ViewState get state => _state;

  void setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }
}
*/
