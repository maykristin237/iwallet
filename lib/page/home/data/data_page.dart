import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:iwallet/common/localization/default_localizations.dart';
import 'package:iwallet/common/style/def_style.dart';
import 'package:iwallet/common/utils/PlatformUtils.dart';
import 'package:iwallet/common/utils/alog.dart';
import 'package:iwallet/common/utils/common_utils.dart';
import 'package:iwallet/common/utils/navigator_utils.dart';
import 'package:iwallet/common/utils/number_utils.dart';
import 'package:iwallet/page/home/home_page.dart';
import 'package:iwallet/page/wallet/netmodel/network_model.dart';
import 'package:iwallet/redux/def_state.dart';
import 'package:iwallet/widget/pull_load_refresh.dart';
import 'package:iwallet/widget/widget_utils.dart';
import 'package:redux/redux.dart';

/// 主页动态tab页
/// Date: 2023-03-08
class DataPage extends StatefulWidget {
  const DataPage({Key? key}) : super(key: key);

  @override
  State<DataPage> createState() => DataPageState();
}

class DataPageState extends State<DataPage> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<DataPage>, WidgetsBindingObserver {
  bool _onceFlag = false, _disposeFlag = false;
  ///网络模块
  final ComNetModel netModel = ComNetModel();
  ///控制列表滚动和监听
  final PullLoadController erController = PullLoadController();

  final String _BTC = "BTC";
  double topBarOpacity = 0.0;

  String get coinType => (HomePage.btcAddress.isNotEmpty && HomePage.ethAddress.isNotEmpty) ? "ALL" : (HomePage.btcAddress.isNotEmpty ? "BTC" : "ETH");

  ///显示刷新
  scrollToTop() {
    erController.scrollToTop();
  }

  ///下拉刷新数据
  _requestRefresh() async {
    Map requestParams = {"address1": HomePage.btcAddress, "address2": "0x${HomePage.ethAddress}"};  //1. BTC  2. ETH
    await netModel.requestRefresh(context, requestParams, ApiName.getBalance, netStateCallBack: (){
      CommonUtils.showCommonDialog(context, Locals.i18n(context)!.network_disable, showOnce: true, noCancel: true, onPressOk: () {
        scrollToTop();
      });
    });
    erController.finishRefresh();
  }

  ///上拉更多请求数据
  _requestLoadMore() async {
    Map requestParams = {"investor_uid": HomePage.subUid};
    await netModel.requestRefresh(context, requestParams, ApiName.getBalance).then((value) {

    });
    erController.loadFinish(this);
  }

  Store<DefState> _getStore() {
    return StoreProvider.of(context);
  }

  @override
  void initState() {
    super.initState();
    ///监听生命周期，主要判断页面 resumed 的时候触发刷新
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

  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double top = math.max(MediaQuery.of(context).padding.top, EdgeInsets.zero.top);

    return Container(
      padding: EdgeInsets.only(top: PlatformUtils.isAndroid || PlatformUtils.isIOS ? top : 0),
      color: DefColors.primaryValue,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        //floatingActionButton: visConfigBtn ? _configBtn() : null, ///#### 配置按钮: Config Button:  大客户不显示
        body: StreamBuilder<dynamic?>(
          stream: netModel.stream,
          builder: (context, snapShot) {
            return PullLoadRefresh(
              //alwaysLoad: true,
              erController: erController,
              onRefresh: _requestRefresh,
              //onLoad: _requestLoadMore,
              child: (snapShot.data == null)
                  ? _buildEmpty()
                  : _panel(snapShot.data as List),
            );
          },
        ),
      ),
    );
  }

  Widget _panel(List resDataList) {
    num balanceUsd = 0;
    for (dynamic resData in resDataList) {
      balanceUsd += resData?["balance_usd"] ?? 0.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            const SizedBox(width: 20),
            const Image(width: 25,image: AssetImage('static/images/home_logo.png'), fit: BoxFit.fill),
            const SizedBox(width: 10),
            Text(Locals.i18n(context)!.wallet, style: const TextStyle(fontSize: 15, color: DefColors.textMainColor, fontWeight: FontWeight.bold)),
          ],
        ),

        //title
        Stack(
          alignment: Alignment.center,
          children: [
            const Image(image: AssetImage('static/images/home_panel.png'), fit: BoxFit.fill),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${NumberUtils.nFormat(balanceUsd, bits: 2)} USD", style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                Text(Locals.i18n(context)!.current_fund, style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.normal)),
              ],
            ),
          ],
        ),

        //功能
        Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: WidgetUtils.cardView([
            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: WidgetUtils.inWellBtn2(child: _transferView(isExpanded: true, fontSize: 10, "transfer.png", Locals.i18n(context)!.transfer, Locals.i18n(context)!.transfer_info), onTap: () {
                    NavigatorUtils.goTransferPage(context, coinType: coinType);
                  }),
                ),
                Expanded(
                  child: WidgetUtils.inWellBtn2(child: _transferView(isExpanded: true, fontSize: 10, "payment.png", Locals.i18n(context)!.payment, Locals.i18n(context)!.payment_info), onTap: () {
                    NavigatorUtils.goReceivePaymentPage(context, coinType: coinType);
                  }),
                ),
              ],
            ),
          ], isWrap: false),
        ),

        //列表
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
          child: Text(Locals.i18n(context)!.my_assets, style: const TextStyle(fontSize: 15, color: DefColors.textMainColor, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: _listView(resDataList),
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

  _productView(String png, String leftName, String leftValue, String rightName, String rightValue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _transferView(png, leftName, leftValue),

        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(rightName, style: const TextStyle(fontSize: 15, color: Colors.blue, fontWeight: FontWeight.bold)),
            Text(rightValue, style: const TextStyle(fontSize: 12, color: DefColors.toggleBtnColor, fontWeight: FontWeight.normal)),
          ],
        ),
      ],
    );
  }

  _listView(List resDataList) {
    List<Map> data = [];

    for (dynamic resData in resDataList) {
      Map item = {"png": "btc_icon.png", "name1": "Bitcoin", "name2": "btc", "value1": "0.53", "value2": "≈6000CNY", "resData": null};
      bool isBtc = ((resData?["ccy"] ?? "") == _BTC);
      num balance = resData?["balance"] ?? 0.0;
      num balanceUsd = resData?["balance_usd"] ?? 0.0;

      if (isBtc) HomePage.btcBalance = balance;
      else HomePage.ethBalance = balance;

      item["png"] = isBtc ? "btc_icon.png" : "eth_icon.png";
      item["name1"] = isBtc ? "Bitcoin" : "Ethereum";
      item["name2"] = isBtc ? "btc" : "eth";
      item["value1"] = "$balance";
      item["value2"] = "$balanceUsd USD";
      item["resData"] = resData;
      data.add(item);
    }

    List<Widget> list = [];

    viewItem(var item) {
      return WidgetUtils.inWellBtn(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _productView(item["png"], item["name1"], item["name2"], item["value1"], item["value2"]),
        ),
        onTap: () {
          NavigatorUtils.goDataDetailPage(context, item["resData"]);
        },
      );
    }

    for (var item in data) {
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
    ALog("MediaQuery.of(context).padding.bottom=${MediaQuery.of(context).padding.bottom}, bottomArea=$bottomArea");

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