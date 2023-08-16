import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:iwallet/common/localization/default_localizations.dart';
import 'package:iwallet/common/style/def_style.dart';
import 'package:iwallet/common/utils/code_utils.dart';
import 'package:iwallet/common/utils/common_utils.dart';
import 'package:iwallet/common/utils/navigator_utils.dart';
import 'package:iwallet/common/utils/number_utils.dart';
import 'package:iwallet/page/home/home_page.dart';
import 'package:iwallet/page/wallet/netmodel/network_model.dart';
import 'package:iwallet/widget/pull_load_refresh.dart';
import 'package:iwallet/widget/widget_utils.dart';

/// 主页动态tab页
/// Date: 2023-03-09
class DataDetailPage extends StatefulWidget {
  static const String sName = "detail";
  const DataDetailPage({Key? key}) : super(key: key);

  @override
  State<DataDetailPage> createState() => _DataDetailPageState();
}

class _DataDetailPageState extends State<DataDetailPage> with AutomaticKeepAliveClientMixin<DataDetailPage>, WidgetsBindingObserver {
  bool _onceFlag = false, _disposeFlag = false;
  ///网络模块
  final ComNetModel netModel = ComNetModel();
  ///控制列表滚动和监听
  final PullLoadController erController = PullLoadController();
  ///多页显示
  int _page = 1, _pageSize = 10;

  final String _BTC = "BTC";
  String _wType = "";
  bool get isBtc => _wType == _BTC;

  num _balanceUsd = 0.0, _balance = 0.0, _price = 0.0;

  ///显示刷新
  scrollToTop() {
    erController.scrollToTop();
  }

  ///下拉刷新数据
  _requestRefresh() async {
    String address = isBtc ? HomePage.btcAddress : "0x${HomePage.ethAddress}";  //test: ETH  0xCC9557F04633d82Fb6A1741dcec96986cD8689AE
    Map requestParams = {"ccy": _wType, "page": 1, "number": _page*_pageSize, "address": address};
    await netModel.requestRefresh(context, requestParams, ApiName.getTradeRecord);
    erController.finishRefresh();
  }

  ///上拉更多请求数据
  _requestLoadMore() async {
    String address = isBtc ? HomePage.btcAddress : "0x${HomePage.ethAddress}";  //test: ETH  0xCC9557F04633d82Fb6A1741dcec96986cD8689AE
    Map requestParams = {"ccy": _wType, "page": 1, "number": ++_page*_pageSize, "address": address};
    await netModel.requestRefresh(context, requestParams, ApiName.getTradeRecord).then((value) {

    });
    erController.loadFinish(this);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeFlag = true;
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    //防止重复进入
    if (_onceFlag || _disposeFlag) return;
    _onceFlag = true;

    //路由页面跳转传参:
    Object? prams = ModalRoute.of(context)?.settings.arguments;
    dynamic resData = prams as dynamic;
    _wType = resData?["ccy"] ?? "";
    _balanceUsd = resData?["balance_usd"] ?? 0.0;
    _balance = resData?["balance"] ?? 0.0;
    _price = resData?["price"] ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      color: DefColors.primaryValue,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("$_wType ${Locals.i18n(context)!.assets_details}"),
          leading: BackButton(),
          centerTitle: true,
        ),
        body: StreamBuilder<dynamic?>(
          stream: netModel.stream,
          builder: (context, snapShot) {
            return PullLoadRefresh(
              erController: erController,
              onRefresh: _requestRefresh,
              onLoad: _requestLoadMore,
              child: (snapShot.data == null)
                  ? _buildEmpty()
                  : _panel(snapShot.data),
            );
          },
        ),
      ),
    );
  }

  Widget _panel(dynamic data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        //title
        Stack(
          alignment: Alignment.center,
          children: [
            const Image(image: AssetImage('static/images/home_panel.png'), fit: BoxFit.fill),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("$_balance", style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                Text("≈$_balanceUsd USD", style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.normal)),
                Text(CodeUtils.formatStr(Locals.i18n(context)!.current_fund2, s1: _wType), style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.normal)),
              ],
            ),
          ],
        ),

        //功能
        Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: WidgetUtils.cardView([
            Row(
              children: [
                Expanded(
                  child: WidgetUtils.inWellBtn2(child: _transferView(isExpanded: true, fontSize: 10, "transfer.png", Locals.i18n(context)!.transfer, Locals.i18n(context)!.transfer_info), onTap: () {
                    NavigatorUtils.goTransferPage(context, coinType: _wType);
                  }),
                ),
                Expanded(
                  child: WidgetUtils.inWellBtn2(child: _transferView(isExpanded:true, fontSize: 10, "payment.png", Locals.i18n(context)!.payment, Locals.i18n(context)!.payment_info), onTap: () {
                    NavigatorUtils.goReceivePaymentPage(context, coinType: _wType);
                  }),
                ),
              ],
            ),
          ], isWrap: false),
        ),

        //列表
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
          child: Text(Locals.i18n(context)!.trans_records, style: const TextStyle(fontSize: 15, color: DefColors.textMainColor, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: _listView(data),
          ),
        ),

      ],
    );
  }

  _transferView(String png, String name, String value, {bool isExpanded = false, double fontSize = 12}) {
    itemView() => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: const TextStyle(fontSize: 15, color: DefColors.textMainColor, fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(fontSize: fontSize, color: DefColors.toggleBtnColor, fontWeight: FontWeight.normal), maxLines: 3, overflow: TextOverflow.ellipsis),
      ],
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image(height: 35, image: AssetImage('static/images/$png'), fit: BoxFit.fill),
        const SizedBox(width: 10),
        isExpanded ? Expanded(child: itemView()) : itemView(),
      ],
    );
  }

  _productView(int transType, String png, String leftName, String leftValue, String rightName, String rightValue) {
    Color valueColor = transType == 1 ? Colors.red : Colors.blue;
    rightValue = transType == 1 ? "-$rightValue": "+$rightValue";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _transferView(png, leftName, leftValue),

        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(rightName, style: const TextStyle(fontSize: 12, color: DefColors.toggleBtnColor, fontWeight: FontWeight.normal)),
            Text(rightValue, style: TextStyle(fontSize: 15, color: valueColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  _listView(dynamic resData) {
    List<Widget> list = [];

    viewItem(final dynamic item) {
      int type = item["trans_type"] ?? -1;
      String fromAddress = item["from_address"] ?? "";
      String toAddress = item["to_address"] ?? "";
      int time = item["timestamp"] ?? 0;
      num value = item["value"] ?? 0;

      String transType = type == 1 ? Locals.i18n(context)!.trans_out : type == 2 ? Locals.i18n(context)!.trans_in : "";
      String address = type == 1 ? toAddress : fromAddress;
      String dataTime = CommonUtils.timestampToDateStr(time);

      return WidgetUtils.inWellBtn(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _productView(type, "money_icon.png", transType, NumberUtils.breakWord(address), dataTime, NumberUtils.nFormat(value, bits: 6)),
        ),
        onTap: () {
          NavigatorUtils.goTradeDetailPage(context, item: item);
        },
      );
    }

    for (dynamic item in resData) {
      list.add(viewItem(item));
      list.add(Divider(height: 2.0, indent: 0.0, color: Colors.grey.withOpacity(0.8)));  //分隔线
    }
    return list;
  }


  ///空页面
  Widget _buildEmpty() {
    var statusBar = MediaQueryData.fromWindow(WidgetsBinding.instance.window).padding.top;
    var bottomArea = MediaQueryData.fromWindow(WidgetsBinding.instance.window).padding.bottom;
    var height = MediaQuery.of(context).size.height - statusBar - bottomArea - kBottomNavigationBarHeight - kToolbarHeight;
    return SingleChildScrollView(
      child: Container(
        height: height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () {},
              child: const Image(image: AssetImage(DefICons.DEFAULT_USER_ICON), width: 70.0, height: 70.0),
            ),
            Container(
              child: Text(Locals.i18n(context)!.app_empty, style: DefConstant.normalText),
            ),
          ],
        ),
      ),
    );
  }

}
