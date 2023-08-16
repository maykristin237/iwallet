import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:iwallet/common/localization/default_localizations.dart';
import 'package:iwallet/common/style/def_style.dart';
import 'package:iwallet/common/utils/PlatformUtils.dart';
import 'package:iwallet/page/me/my_profile_page.dart';
import 'package:iwallet/redux/def_state.dart';
import 'package:iwallet/widget/w_tabbar_widget.dart';
import 'package:iwallet/widget/w_title_bar.dart';
import 'package:redux/redux.dart';

import 'data/data_page.dart';

/// 主页
/// 
/// Date: 2023-07-16

class HomePage extends StatefulWidget {
  static const String sName = "home";
  static String subUid = "";
  static String btcAddress = "", ethAddress = "";
  static num btcBalance = 0, ethBalance = 0;

  //评估版本
  static bool isEvaluation = false;
  static String evaluationPw = "";

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {

  final GlobalKey<DataPageState> dataKey = GlobalKey();
  final GlobalKey<MyProfilePageState> myKey = GlobalKey();

  bool onceFlag = false, disposeCountDownTips = false;

  int _tabsSize = 0;
  late List<Widget> tabs;
  late TabController _tabController;

  /// 不退出
  Future<bool> _dialogExitApp(BuildContext context) async {
    ///如果是 android 回到桌面
    if (PlatformUtils.isAndroid) {
      AndroidIntent intent = const AndroidIntent(
        action: 'android.intent.action.MAIN',
        category: "android.intent.category.HOME",
      );
      await intent.launch();
    }

    return Future.value(false);
  }

  /// 1. icons 类型
  _initTabViewData() {
    itemView(icon, text) {
      return Tab(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Icon(icon, size: 16.0), const SizedBox(height: 3),Text(text, style: TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)],
        ),
      );
    };

    tabs = [
      itemView(DefICons.DATA, Locals.i18n(context)!.asset),
      itemView(DefICons.ME, Locals.i18n(context)!.home_my),
    ];
    if (_tabsSize != tabs.length) {
      _tabController = TabController(vsync: this, length: tabs.length);
      _tabsSize = tabs.length;
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ///增加返回按键监听
    return WillPopScope(
      onWillPop: () {
        return _dialogExitApp(context);
      },
      child: WTabBarWidget(
        tabController: _tabController,
        type: TabType.bottom,
        tabItems: tabs,
        tabViews: [
          DataPage(key: dataKey),
          MyProfilePage(key: myKey),
        ],
        onDoublePress: (index) {
          switch (index) {
            case 0:
              dataKey.currentState?.scrollToTop();
              break;
            case 1:
              myKey.currentState?.scrollToTop();
              break;
          }
        },
        onLongPress: (index) {
          if (index == 0) {
            //getSubUserID();
          }
        },
        backgroundColor: DefColors.primarySwatch,
        indicatorColor: DefColors.transparent,
        title: WTitleBar(
          Locals.of(context)!.currentLocalized!.app_name,
          iconData: DefICons.MAIN_SEARCH,
          needRightLocalIcon: true,
          onRightIconPressed: (centerPosition) {

          },
        ),
      ),
    );
  }

  Store<DefState> _getStore() {
    return StoreProvider.of(context);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (onceFlag) return;
    onceFlag = true;

    //初始代Tab数据
    _initTabViewData();
  }

  @override
  void dispose() {
    disposeCountDownTips = true;
    super.dispose();
  }
}
