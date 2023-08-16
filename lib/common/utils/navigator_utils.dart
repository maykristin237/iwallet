import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iwallet/page/home/data/data_page_detail.dart';
import 'package:iwallet/page/home/home_page.dart';
import 'package:iwallet/page/wallet/create_page.dart';
import 'package:iwallet/page/wallet/import_key_page.dart';
import 'package:iwallet/page/wallet/import_word_page.dart';
import 'package:iwallet/page/wallet/order/receive_payment_page.dart';
import 'package:iwallet/page/wallet/order/trade_record_detail_page.dart';
import 'package:iwallet/page/wallet/order/trade_record_page.dart';
import 'package:iwallet/page/wallet/order/transfer_page.dart';
import 'package:iwallet/page/welcome_page.dart';
import 'package:iwallet/widget/never_overscroll_indicator.dart';
import 'package:iwallet/widget/scanner/qr_scan_widget.dart';

import 'alog.dart';

/// 导航栏
/// 
/// Date: 2023-07-16

enum PageType { OK, BACK, FINISH }

class NavigatorUtils {
  ///替换
  static pushReplacementNamed(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  ///切换无参数页面
  static pushNamed(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  //欢迎页
  static goWelcomePage(BuildContext context) {
    Navigator.pushReplacementNamed(context, WelcomePage.sName);
  }

  ///主页
  static goHome(BuildContext context, {required bool fromLogin}) {
    Navigator.pushReplacementNamed(context, HomePage.sName, arguments: fromLogin);
  }

  ///创建钱包
  static Future goCreatePage(BuildContext context) {
    return Navigator.pushNamed(context, CreatePage.sName);
  }

  ///私钥导入钱包
  static Future goImportKeyPage(BuildContext context) {
    return Navigator.pushNamed(context, ImportKeyPage.sName);
  }

  ///助记词导入钱包
  static Future goImportWordPage(BuildContext context) {
    return Navigator.pushNamed(context, ImportWordPage.sName);
  }

  ///资产明细页
  static goDataDetailPage(BuildContext context, dynamic data) {
    Navigator.pushNamed(context, DataDetailPage.sName, arguments: data);
  }

  ///转账页面
  static goTransferPage(BuildContext context, {String coinType = "ALL"}) {  //coinType: BTC, ETH
    Navigator.pushNamed(context, TransferPage.sName, arguments: coinType);
  }
  ///收款页面
  static goReceivePaymentPage(BuildContext context, {String coinType = "ALL"}) {
    Navigator.pushNamed(context, ReceivePaymentPage.sName, arguments: coinType);
  }

  ///我的交易列表
  static goTradeRecordPagePage(BuildContext context) {
    Navigator.pushNamed(context, TradeRecordPage.sName);
  }

  ///交易详单
  static goTradeDetailPage(BuildContext context, {dynamic item}) {
    Navigator.pushNamed(context, TradeRecordDetailPage.sName, arguments: item);
  }

  /// 扫描二维码
  static Future goScanViewPage(BuildContext context) {
    return comNavigatorRouter(context, const QrScanView());  //不需要定义 sName的跳转方式
  }

  ///公共打开方式:  (不需要定义 sName的跳转方式)
  static Future comNavigatorRouter(BuildContext context, Widget widget) {
    return Navigator.push(context, CupertinoPageRoute(builder: (context) => pageContainer(widget, context)));
  }

  static Future comNavigatorRouter2(BuildContext context, Widget widget) {
    return Navigator.push(context, MaterialPageRoute(builder: (context) => pageContainer(widget, context)));
  }

  ///Page页面的容器，做一次通用自定义
  static Widget pageContainer(widget, BuildContext context) {
    return MediaQuery(

        ///不受系统字体缩放影响
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
        child: NeverOverScrollIndicator(
          needOverload: false,
          child: widget,
        ));
  }

  ///弹出 dialog
  static Future<T?> showDefDialog<T>({required BuildContext context, bool barrierDismissible = true, bool useSafeArea = true, WidgetBuilder? builder}) {
    return showDialog<T>(
        context: context,
        useSafeArea: useSafeArea,
        barrierDismissible: barrierDismissible,
        builder: (context) {
          return MediaQuery(

              ///不受系统字体缩放影响
              data: MediaQueryData.fromWindow(WidgetsBinding.instance.window).copyWith(textScaleFactor: 1),
              child: NeverOverScrollIndicator(
                needOverload: false,
                child: SafeArea(child: builder!(context)),
              ));
        });
  }
}
