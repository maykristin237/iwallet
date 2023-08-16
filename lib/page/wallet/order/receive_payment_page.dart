import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:iwallet/common/localization/default_localizations.dart';
import 'package:iwallet/common/style/def_style.dart';
import 'package:iwallet/common/utils/alog.dart';
import 'package:iwallet/common/utils/common_utils.dart';
import 'package:iwallet/page/home/home_page.dart';
import 'package:iwallet/widget/widget_utils.dart';

/// xxx
///
/// Date: 2023-03-19

class ReceivePaymentPage extends StatefulWidget {
  static const String sName = "receive";
  const ReceivePaymentPage({super.key});

  @override
  State<ReceivePaymentPage> createState() => _ReceivePaymentPageState();
}

class _ReceivePaymentPageState extends State<ReceivePaymentPage> {
  ScrollController vController = ScrollController();

  late bool _onceFlag = false, _disposeFlag = false;
  late List<Map> orderList = [];

  ///转帐类型
  final String allType = "ALL";
  late String _coinType;
  late var walletType = ["BTC", "ETH"];
  late var walletSelected = [true, false];      //修改这里的true false, 可以设置默认值
  bool get isBtc => walletSelected.elementAt(0);
  bool get isEth => walletSelected.elementAt(1);
  bool get twoWallet => HomePage.btcAddress.isNotEmpty && HomePage.ethAddress.isNotEmpty && (_coinType == allType);
  String get address => isBtc ? HomePage.btcAddress : "0x${HomePage.ethAddress}";

  @override
  void dispose() {
    super.dispose();
    _disposeFlag = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //防止重复进入
    if (_onceFlag || _disposeFlag) return;
    _onceFlag = true;

    Object? prams = ModalRoute.of(context)?.settings.arguments;
    _coinType = prams as String ?? "";
    if(_coinType == "BTC") walletSelected = [true, false];
    else if (_coinType == "ETH") walletSelected = [false, true];
    ALog("_coinType: $_coinType");
  }

  @override
  Widget build(BuildContext context) {
    //mContext = context;

    return Scaffold(
        backgroundColor: DefColors.primaryValue,
        appBar: AppBar(
          title: Text(Locals.i18n(context)!.payment),
          leading: BackButton(),
          centerTitle: true,
        ),
        body: Container(
          padding: const EdgeInsets.all(10.0),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad}),
            child: SingleChildScrollView(
              controller: vController,
              scrollDirection: Axis.vertical,
              child: _panel(),
            ),
          ),
        ));
  }

  Widget _panel() {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        twoWallet ? Align(
            alignment: Alignment.topRight,
            child: WidgetUtils.toggleButtons(this, txt: walletType, isSelected: walletSelected, callBack: (v) {walletSelected = v;}),
        ) : const SizedBox(),

        Text(Locals.i18n(context)!.wallet_address_is, style: const TextStyle(fontSize: 15, color: DefColors.toggleBtnColor, fontWeight: FontWeight.normal)),
        Text(address, style: const TextStyle(fontSize: 15, color: DefColors.textMainColor, fontWeight: FontWeight.normal)),

        const SizedBox(height: 20),

        Divider(height: 2.0, indent: 0.0, color: Colors.grey.withOpacity(0.8)),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                //data: "${createData?["usdt_receive_token"]??"-"}",
                data: address,
                version: QrVersions.auto,
                size: 250,
                backgroundColor: Colors.white,
                gapless: false,
              ),
              const SizedBox(height: 10),
              WidgetUtils.underLineBtn(txt: Locals.i18n(context)!.copy_wallet_link, onTap: () {
                Clipboard.setData(ClipboardData(text: address));
                CommonUtils.showCommonDialog(context, Locals.i18n(context)!.link_copied, noCancel: true, noYes: true, autoDisappear: true);
              }),
            ],
          ),
        ),


      ],
    );
  }


  ///空页面
  Widget _buildEmpty() {
    var statusBar = MediaQueryData
        .fromWindow(WidgetsBinding.instance.window)
        .padding
        .top;
    var bottomArea = MediaQueryData
        .fromWindow(WidgetsBinding.instance.window)
        .padding
        .bottom;
    //var height = MediaQuery.of(context).size.height - statusBar - bottomArea - kBottomNavigationBarHeight - kToolbarHeight;
    var height = MediaQuery
        .of(context)
        .size
        .height - kBottomNavigationBarHeight;
    return SingleChildScrollView(
      child: Container(
        height: height,
        width: MediaQuery
            .of(context)
            .size
            .width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () {},
              child: Image(image: AssetImage(DefICons.DEFAULT_USER_ICON), width: 70.0, height: 70.0),
            ),
            Text(Locals.i18n(context)!.app_empty, style: TextStyle(color: Colors.white, fontSize: 16,)),
          ],
        ),
      ),
    );
  }

}
