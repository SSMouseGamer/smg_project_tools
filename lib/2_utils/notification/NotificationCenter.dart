/*模仿 iOS NS族的NotificationCenter原理
 *使用 observerMap保存观察者信息
 *  这里只是简单的封装，还有更高级的应用，并没有做到一对多的功能，后期需要对observer进行调整，
  比如使用链表的数据结构。外层是一个table，以通知名称notificationName作为key，其value也是
  一个table（内层table），内层table以object为key，其value是一个链表，用来保存所有的观察者

 *注意：这里的object传入可能是空的，这里我们回根据空的情况生成一个key，相当于这个key对应的
       value（链表）保存的是当前通知传入了notificationName没有传入object的所有观察者。当
       对应的notificationName的通知发送时，链表中所有的观察者都会收到通知，这就是1对多的实现
*/
/*
 原官方的数据结构是这样的
 //内部一共有两张表，named & nameless，后者相当于去掉notificationName为key的表，只记录object的对应关系
 typedef struct NCTbl {
  Observation       *wildcard;  /* Get ALL messages. */
  GSIMapTable       nameless;   /* Get messages for any name. */
  GSIMapTable       named;      /* Getting named messages only. */
} NCTable;

typedef struct  Obs {
  id        observer;   /* Object to receive message.   */
  SEL       selector;   /* Method selector.     */
  struct Obs    *next;      /* Next item in linked list.    */
  int       retained;   /* Retain count for structure.  */
  struct NCTbl  *link;      /* Pointer back to chunk table  */
} Observation;
 */
/*
                                        Name Table
  ________________________________
 |      key        |     value    |             ______________________
 |_________________|______________|            |    key    |   value  |              __________
 |notificationName1|              |----------->|___________|__________|             | observer |
 |_________________|______________|            |   object1 |          |------------>|__________|
 |notificationName2|              |            |___________|__________|             |   next   |
 |_________________|______________|            |   object2 |          |             |_____|____|
 |      ...        |              |            |___________|__________|                   |
 |_________________|______________|            |    ...    |          |              __________  
                                               |___________|__________|             | observer |
                                                                                    |__________|
                                                                                    |   next   |
                                                                                    |_____|____|
                                                                                          |
                                                                                         end
 */

import 'package:smg_project_tools/2_utils/log/LogUtils.dart';

class NotificationCenter {
  static NotificationCenter _default = new NotificationCenter();
  ///观察者对象
  Map<String, Map<String, Observation>> _observerMap = new Map();

  /*
   * 发送通知
   * notificationName 通知名称
   * param 通知参数
   */
  static void post(String notificationName, [Object param]) {
    if (notificationName != null) {
      Map<String, Observation> nameLess = NotificationCenter._default._observerMap[notificationName];
      if (nameLess == null || nameLess.isEmpty) {
        LogUtils.log('方法：$notificationName 未注册');
        return;
      }
      nameLess.forEach((key, value) {
        if (value.selector != null) {
          value.selector(param);  
        }
      });
    } else {
      LogUtils.log('[Notification] post name not null');
    }
  }

  /*
   * 监听通知
   * observer 监听对象
   * notificationName 监听的通知名称
   * block 监听通知的回调
   */
  static void addObserver(Object observer, String notificationName,
      [void block(Object param)]) {
    if (observer != null && notificationName != null) {
      // final key = notificationName + NotificationCenter._default._segmentKey + observer.hashCode.toString();
      Map<String, Observation> nameLess = NotificationCenter._default._observerMap[notificationName];
      if (nameLess == null) {
        nameLess = {};
      }
      Observation obs = Observation.init(observer, block);
      nameLess.update(obs.hashStr, (value) => obs, ifAbsent: () => obs);
      NotificationCenter._default._observerMap[notificationName] = nameLess;
    } else {
      print('[Notification] observer not null or name not null');
    }
  }

  /*
   * 移除通知
   * observer 要移除的对象
   * notificationName 要移除的通知名称（如果为空则移除observer下所有通知）
   */
  static void removeObserver(Object observer, [String notificationName]) {
    if (observer != null) {
      if (notificationName != null) {
        // final key = notificationName +
        //     NotificationCenter._default._segmentKey +
        //     observer.hashCode.toString();
        NotificationCenter._default._observerMap.remove(notificationName);
      } else {
        String hashStr = observer.hashCode.toString();
        NotificationCenter._default._observerMap.forEach((key, value) {
          value.removeWhere((key, value) => hashStr == key);
        });
      }
    }
  }
}


///观察者对象
class Observation {
  ///用来接收消息的对象
  Object observer;
  ///observer对象的hash字符串
  String hashStr;
  ///用来响应的方法
  void Function(dynamic param) selector;

  Observation.init(this.observer, this.selector) {
    if (observer != null) {
      hashStr = observer.hashCode.toString();
    }
  }
}