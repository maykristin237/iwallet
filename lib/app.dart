import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:iwallet/common/event/http_error_event.dart';
import 'package:iwallet/common/event/index.dart';
import 'package:iwallet/common/localization/default_localizations.dart';
import 'package:iwallet/common/localization/my_localizations_delegate.dart';
import 'package:iwallet/common/utils/alog.dart';
import 'package:iwallet/page/home/data/data_page_detail.dart';
import 'package:iwallet/page/wallet/create_page.dart';
import 'package:iwallet/page/wallet/import_key_page.dart';
import 'package:iwallet/page/wallet/import_word_page.dart';
import 'package:iwallet/page/wallet/order/receive_payment_page.dart';
import 'package:iwallet/page/wallet/order/trade_record_detail_page.dart';
import 'package:iwallet/page/wallet/order/trade_record_page.dart';
import 'package:iwallet/page/wallet/order/transfer_page.dart';
import 'package:iwallet/redux/def_state.dart';
import 'package:iwallet/common/style/def_style.dart';
import 'package:iwallet/common/utils/common_utils.dart';
import 'package:iwallet/page/home/home_page.dart';
import 'package:iwallet/page/welcome_page.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:iwallet/common/net/code.dart';

import 'common/utils/navigator_utils.dart';

class FlutterReduxApp extends StatefulWidget {
  const FlutterReduxApp({super.key});

  @override
  State<FlutterReduxApp> createState() => _FlutterReduxAppState();
}

class _FlutterReduxAppState extends State<FlutterReduxApp> with HttpErrorListener {
  /// initialState 初始化 State
  final store = Store<DefState>(
    appReducer,

    ///初始化数据
    initialState: DefState(
        themeData: CommonUtils.getThemeData(DefColors.primarySwatch),
    ),
  );


  @override
  Widget build(BuildContext context) {

    /// 使用 flutter_redux 做全局状态共享
    return StoreProvider(
      store: store,
      child: StoreBuilder<DefState>(builder: (context, store) {
        ///使用 StoreBuilder 获取 store 中的 theme 、locale
        store.state.platformLocale = WidgetsBinding.instance.window.locale;
        _store = store;

        return MaterialApp(
            debugShowCheckedModeBanner: false,

            ///多语言实现代理
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              MyLocalizationsDelegate.delegate,
            ],
            supportedLocales: [
              store.state.locale ?? store.state.platformLocale!
            ],
            locale: store.state.locale,
            theme: store.state.themeData,

            ///命名式路由
            routes: {
              WelcomePage.sName: (context) {
                return WelcomePage();
              },
              HomePage.sName: (context) {
                return NavigatorUtils.pageContainer(HomePage(), context);
              },
              CreatePage.sName: (context) {
                return NavigatorUtils.pageContainer(CreatePage(), context);
              },
              ImportKeyPage.sName: (context) {
                return NavigatorUtils.pageContainer(ImportKeyPage(), context);
              },
              ImportWordPage.sName: (context) {
                return NavigatorUtils.pageContainer(ImportWordPage(), context);
              },
              DataDetailPage.sName: (context) {
                return NavigatorUtils.pageContainer(DataDetailPage(), context);
              },
              TransferPage.sName: (context) {
                return NavigatorUtils.pageContainer(TransferPage(), context);
              },
              ReceivePaymentPage.sName: (context) {
                return NavigatorUtils.pageContainer(ReceivePaymentPage(), context);
              },
              TradeRecordPage.sName: (context) {
                return NavigatorUtils.pageContainer(TradeRecordPage(), context);
              },
              TradeRecordDetailPage.sName: (context) {
                return NavigatorUtils.pageContainer(TradeRecordDetailPage(), context);
              },
            });
      }),
    );
  }
}

mixin HttpErrorListener on State<FlutterReduxApp> {
  StreamSubscription? stream;
  late BuildContext _context;

  late Store<DefState> _store;

  @override
  void initState() {
    super.initState();

    ///Stream演示event bus
    stream = eventBus.on<HttpErrorEvent>().listen((event) {
      _context = event.context;
      errorHandleFunction(event.code, event.message, event.context);
    });
  }

  @override
  void dispose() {
    super.dispose();
    ALog(" ### eventBus dispose()!!");
    if (stream != null) {
      stream!.cancel();
      stream = null;
    }
  }

  ///网络错误提醒
  errorHandleFunction(int? code, message, _context) {
    switch (code) {
      case Code.NETWORK_ERROR:
        showToast(Locals.i18n(_context)!.network_error);
        break;
      case 401:
        showToast(Locals.i18n(_context)!.network_error_401);
        break;
      case 403:
        showToast(Locals.i18n(_context)!.network_error_403);
        break;
      case 404:
        showToast(Locals.i18n(_context)!.network_error_404);
        break;
      case 422:
        showToast(Locals.i18n(_context)!.network_error_422);
        break;
      case Code.NETWORK_TIMEOUT:
        //超时
        showToast(Locals.i18n(_context)!.network_error_timeout);
        break;
      case Code.GITHUB_API_REFUSED:
        showToast("HttpException: Connection refused or reset.");
        break;
      default:
        showToast(Locals.i18n(_context)!.network_error_unknown + " " + message);
        break;
    }
  }

  showToast(String message) {
    CommonUtils.showCommonDialog(_context, message);
  }

}
