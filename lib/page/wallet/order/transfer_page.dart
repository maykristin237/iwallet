import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iwallet/common/config/config.dart';
import 'package:iwallet/common/dao/api_network_dao.dart';
import 'package:iwallet/common/local/local_storage.dart';
import 'package:iwallet/common/localization/default_localizations.dart';
import 'package:iwallet/common/style/def_style.dart';
import 'package:iwallet/common/utils/HexUtils.dart';
import 'package:iwallet/common/utils/alog.dart';
import 'package:iwallet/common/utils/code_utils.dart';
import 'package:iwallet/common/utils/common_utils.dart';
import 'package:iwallet/common/utils/navigator_utils.dart';
import 'package:iwallet/page/home/home_page.dart';
import 'package:iwallet/widget/nfc_controller.dart';
import 'package:iwallet/widget/nfc_widget.dart';
import 'package:iwallet/widget/widget_utils.dart';
import 'package:wallet_kit/wallet_kit.dart';

/// xxx
///
/// Date: 2023-07-16

class TransferPage extends StatefulWidget {
  static const String sName = "transfer";
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final int btcNum = 100000000,  ehtNum = 1000000000;

  final TextEditingController tCtr0 = TextEditingController(), tCtr1 = TextEditingController(), tCtr2 = TextEditingController(), tCtr3 = TextEditingController();
  late bool inputChanged = false;
  ScrollController vController = ScrollController();

  final WalletKit _walletKitPlugin = WalletKit();

  late bool _onceFlag = false, _disposeFlag = false;

  int panelIndex = 1;
  late double _sliderValue = 1.0;

  ///弹出卡片
  NfcView? _nfcView;
  var _crossFadeState = CrossFadeState.showFirst;
  bool get _isClose => NfcView.isClose = (_crossFadeState == CrossFadeState.showFirst);
  EdgeInsetsGeometry get mainPadding => !_isClose ? const EdgeInsets.all(0) : const EdgeInsets.only(left: 10, right: 10);
  EdgeInsetsGeometry get cardPadding => _isClose ? const EdgeInsets.all(0) : const EdgeInsets.only(left: 10, right: 10);

  ///转帐类型
  final String allType = "ALL";
  late String _coinType;
  late var walletType = ["BTC", "ETH"];
  late var walletSelected = [true, false];    //修改这里的true false, 可以设置默认值
  bool get isBtc => walletSelected.elementAt(0);
  bool get isEth => walletSelected.elementAt(1);
  bool get twoWallet => HomePage.btcAddress.isNotEmpty && HomePage.ethAddress.isNotEmpty && (_coinType == allType);

  ///转账需要的值
  String get transName => isBtc ? "BTC" : "ETH";
  String get transValue => isBtc ? "${HomePage.btcBalance}$transName" : "${HomePage.ethBalance}$transName";
  List<Map> _utxoList = [];
  String _toAddress = "", _signedTx = "";
  num _amount = 0, _nonce = 0, _gasLimit = 0, _high = 0, _medium = 0, _low = 0;
  num get _feeGasPrice => _sliderValue == 1 ? _high : _sliderValue == 2 ? _medium : _sliderValue == 3 ? _low : 0;

  String get _feeGasPriceStr {
    String value = "${_feeGasPrice > 0 ? isBtc ? (_feeGasPrice / btcNum) : ((_feeGasPrice * _gasLimit / ehtNum) / ehtNum) : ""}";
    return value.length > 9 ? "≈ ${value.substring(0, 9)} $transName" : "≈ $value $transName";
  }

  String get _amountStr {
    if (isBtc) {
      return BigInt.from(_amount * btcNum).toString();
    } else {
      return (BigInt.from(_amount * ehtNum) * BigInt.from(ehtNum)).toString();
    }
  }

  String get _privateKey => NfcController.instance.cardPayload.isNotEmpty ? HexUtils.uint8ToHex(NfcController.instance.cardPayload) : "";

  ///重置获取的数据
  _resetData() {
    _utxoList.clear();
    _toAddress = "";
    _signedTx = "";
    _amount = 0; _nonce = 0; _gasLimit = 0; _high = 0; _medium = 0; _low = 0;
    tCtr0.text = "";
    tCtr1.text = "";
    inputChanged = false;
  }

  @override
  void dispose() {
    super.dispose();
    _disposeFlag = true;
    NfcController.instance.nfcStop();
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

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {FocusScope.of(context).requestFocus(FocusNode());},
      child: Scaffold(
        backgroundColor: DefColors.primaryValue,
          appBar: AppBar(
            title: Text("$transName ${Locals.i18n(context)!.transfer}"),
            leading: BackButton(onPressed: _onPressBack),
            centerTitle: true,
          ),
          body: Container(
            padding: mainPadding,
            child: _allPanels(),
          )),
    );
  }

  _onPressBack() {
    if (_isEvaluation()) return;

    if (panelIndex == 1) {
      Navigator.maybePop(context);
    } else if (panelIndex == 2) {
      setState(() => panelIndex = 1);
    } else if (panelIndex == 3) {
      setState(() => panelIndex = 2);
    } else if (panelIndex == 4) {
      Navigator.maybePop(context);
    } else {
      Navigator.maybePop(context);
    }
  }

  Widget _allPanels() {
    if (panelIndex == 1) {
      return _panel1();
    } else if (panelIndex == 2) {
      return _panel2();
    } else if (panelIndex == 3) {
      return _panel3();
    } else if (panelIndex == 4) {
      return _panel4();
    }
    return const SizedBox();
  }

  //评估版本
  bool _isEvaluation() {
    if (HomePage.isEvaluation) {
      if (panelIndex == 1) Navigator.maybePop(context);
      else if (panelIndex == 3) setState(() => panelIndex = 1);
      else if (panelIndex == 4) Navigator.maybePop(context);
      else Navigator.maybePop(context);
      return true;
    } else {
      return false;
    }
  }

  Widget _panel1() {

    itemView(String name, String hintText, TextEditingController controller, {bool haveScanBtn = false, TextInputType inputType = TextInputType.text}) {
      return WidgetUtils.cardView([
        Text(name, style: const TextStyle(fontSize: 15, color: DefColors.textMainColor, fontWeight: FontWeight.normal)),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(child: WidgetUtils.textInput(hintText, controller, isWrap: false, inputType: inputType, onChanged: (String value) => inputChanged = true)),
            haveScanBtn ? _scanBtn() : const SizedBox(),
          ],
        ),
      ], isWrap: false, alignment: CrossAxisAlignment.start, padding: EdgeInsets.all(15));
    }

    return WidgetUtils.scrollView(
      context: context,
      controller: vController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //BTC ETH选项
          twoWallet ? Align(
            alignment: Alignment.topRight,
            child: WidgetUtils.toggleButtons(this, txt: walletType, isSelected: walletSelected, callBack: (v) {walletSelected = v; _resetData();}),
          ) : const SizedBox(),

          itemView(Locals.i18n(context)!.trans_out_address, Locals.i18n(context)!.input_receive_address, tCtr0, haveScanBtn: true),
          itemView(Locals.i18n(context)!.trans_out_amount, CodeUtils.formatStr(Locals.i18n(context)!.input_trans_out_amount, s1: transValue), tCtr1, inputType: const TextInputType.numberWithOptions(decimal: true)), //1.TextInputType.number 2.TextInputType.numberWithOptions(decimal: true)
          itemView(Locals.i18n(context)!.remarks, Locals.i18n(context)!.input_remarks, tCtr2),


          const SizedBox(height: 20),
          WidgetUtils.cardView([
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${Locals.i18n(context)!.fee}: $_feeGasPriceStr", style: const TextStyle(fontSize: 15, color: DefColors.toggleBtnColor, fontWeight: FontWeight.normal)),
                  WidgetUtils.textBtn(Locals.i18n(context)!.refresh_button, onPressed: () {
                    _getEstimateFee(false);
                    // setState(() {
                    //   panelIndex = 2;
                    // });
                  }),
                ],
              ),
            ),

            WidgetUtils.sliderView(this, curValue: _sliderValue, divisions: 2, minValue: 1.0, maxValue: 3.0, callBack: (value) => _sliderValue = value),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(Locals.i18n(context)!.fast, style: const TextStyle(fontSize: 15, color: DefColors.toggleBtnColor, fontWeight: FontWeight.normal)),
                  Text(Locals.i18n(context)!.slow, style: const TextStyle(fontSize: 15, color: DefColors.toggleBtnColor, fontWeight: FontWeight.normal)),
                ],
              ),
            )
          ], isWrap: false, shadow: false, alignment: CrossAxisAlignment.start, padding: const EdgeInsets.only(top: 8, bottom: 8)),


          const SizedBox(height: 30),
          WidgetUtils.submitWidget(Locals.i18n(context)!.next, height: 45 ,onPressed: () {

            if (_feeGasPrice <= 0 || inputChanged || (isBtc && _utxoList.isEmpty)) {
              _getEstimateFee(true);
            } else {
              if (_verifyInputNull()) return;
              setState(() {
                panelIndex = 2;

                //评估版本
                if (HomePage.isEvaluation) panelIndex = 3;
              });
            }
          }),

        ],
      ),
    );
  }

  Widget _panel2() {
    _nfcView = NfcView(
        bleAction: "ACTION_TRANSACTION",
        crossFadeState: _crossFadeState,
        title: "$_amount($transName) ${Locals.i18n(context)!.transfer}",
        content: Locals.i18n(context)!.nfc_info,
        btnName: Locals.i18n(context)!.read_btn,
        stateCallBack: (cState, allFinish) {
          setState(() {
            _crossFadeState = cState;

            if (allFinish) {
              panelIndex = 3;
            }
          });
        });

    return _nfcView ?? const SizedBox();
  }

  Widget _panel3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(Locals.i18n(context)!.transfer, style: const TextStyle(fontSize: 20, color: DefColors.textMainColor, fontWeight: FontWeight.normal)),
        const SizedBox(height: 40),
        Text("${Locals.i18n(context)!.your_private_key}: \n0x${_privateKey.length>20?_privateKey.substring(0, 20):""}...", style: const TextStyle(fontSize: 16, color: DefColors.textMainColor, fontWeight: FontWeight.normal)),
        const SizedBox(height: 10),
        WidgetUtils.textInput(Locals.i18n(context)!.input_wallet_psw, tCtr3, isPsw: true),
        const SizedBox(height: 10),
        const SizedBox(height: 20),

        const SizedBox(height: 20),
        WidgetUtils.submitWidget(Locals.i18n(context)!.next, height: 45, onPressed: () {

          //调用 sdk
          _transactionSign(callBack: () {
            if (_signedTx.isNotEmpty) {
              _sendRawTransaction(_signedTx, callBack: (success) {
                if (success) setState(() { panelIndex = 4; });
              });
            }
          });

        }),
      ],
    );
  }

  Widget _panel4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Text(Locals.i18n(context)!.trans_success, style: const TextStyle(fontSize: 20, color: DefColors.textMainColor, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        const Image(height: 168, image: AssetImage('static/images/success.png'), fit: BoxFit.fitWidth,),
        const SizedBox(height: 20),

        const SizedBox(height: 20),
        WidgetUtils.submitWidget(Locals.i18n(context)!.finish, height: 45, onPressed: () {
          Navigator.maybePop(context);
        }),
      ],
    );
  }

  _scanBtn() {
    return IconButton(
      padding: const EdgeInsets.all(0),
      onPressed: () {
        tCtr0.text = "";
        NavigatorUtils.goScanViewPage(context).then((val) {
          String res = val ?? "";
          if (res.isNotEmpty) {
            tCtr0.text = res;
            ALog("## _onPageFinish res = $res");
          }
        });
      },
      icon: const Icon(Icons.qr_code_scanner, size: 20, color: Colors.blue),
      tooltip: "qr code scan",
      highlightColor: Colors.orangeAccent,
      splashColor: Colors.black12,
    );
  }

  //签名
  void _transactionSign({Function()? callBack}) async {
    String psw1 = tCtr3.value.text;
    if (psw1.isEmpty) {
      CommonUtils.showCommonDialog(context, Locals.i18n(context)!.psw_empty);
      return;
    }

    if(await _isEvaluation2()) {}

    dynamic resp;
    if (isBtc) {
      ///1.btc test:
      //
      //

      int changeIdx = 0; //需要确认这个值
      resp = await _walletKitPlugin.transactionSignBtc(true, true, psw1, _toAddress, NfcController.instance.cardPayload, NfcController.instance.tagId, NfcController.instance.cplStr, NfcController.instance.tiStr,
          changeIdx, _amountStr, "$_feeGasPrice", _utxoList);
    } else {
      resp = await _walletKitPlugin.transactionSignEth(false, true, psw1, "", NfcController.instance.cardPayload, NfcController.instance.tagId,NfcController.instance.cplStr, NfcController.instance.tiStr,
        "$_nonce", "$_feeGasPrice", "$_gasLimit", _toAddress, _amountStr, "");
    }

    String result = resp["result"] ?? "Error result";
    if (result != "ok") {
      CommonUtils.showCommonDialog(context, result);
      return;
    }

    _signedTx = resp["SignedTx"] ?? "";
    String TxHash = resp["TxHash"] ?? "";
    String WtxID = resp["WtxID"] ?? "";

    ALog("## SignedTx = $_signedTx, TxHash = $TxHash, WtxID = $WtxID");

    callBack?.call();
  }

  //评估版本
  Future<bool> _isEvaluation2() async {
    if (HomePage.isEvaluation) {
      String? evaluation = await LocalStorage.get(Config.EVALUATION);
      Map mapEva = json.decode(evaluation ?? "{}");
      String tigId = mapEva["tigId"] ?? "04F02901564803";
      String cardData = mapEva["cardPayload"] ?? "00019F8BB87CBEE559DE24CB02E2346B4E157548A3D8181DE43E393ACB58C33C2607DDFE9D1EAC743ED4CA11C5EB5BE9F6EA4406F97B5C3B85093ADBDA96A6D90790BFBCB6A6CF249FBF42B1BC8BD02E044B8EDAD96682902DC6";

      NfcController.instance.setTagId(tigId);
      NfcController.instance.setCardData(cardData);
      return true;
    } else {
      return false;
    }
  }

  ///空页面
  Widget _buildEmpty() {
    var statusBar = MediaQueryData.fromWindow(WidgetsBinding.instance.window).padding.top;
    var bottomArea = MediaQueryData.fromWindow(WidgetsBinding.instance.window).padding.bottom;
    var height = MediaQuery.of(context).size.height - kBottomNavigationBarHeight;
    return SingleChildScrollView(
      child: Container(
        height: height,
        width: MediaQuery.of(context).size.width,
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

  bool _verifyInputNull() {
    _toAddress = tCtr0.value.text;
    String amount = tCtr1.value.text;
    try {
      _amount = amount.isNotEmpty ? num.parse(amount) : 0;
    } catch (e) {
      _amount = 0;
      CommonUtils.showCommonDialog(context, Locals.i18n(context)!.trans_value_error);
      return true;
    }
    if (_toAddress.isEmpty) {
      CommonUtils.showCommonDialog(context, Locals.i18n(context)!.receive_address_empty);  //Locals.i18n(context)!.confirm_psw_empty
      return true;
    }
    if (_amount <= 0) {
      CommonUtils.showCommonDialog(context, Locals.i18n(context)!.trans_value_empty);
      return true;
    }
    inputChanged = false;
    return false;
  }

  /// 获取预估矿工费
  _getEstimateFee(final bool isNext) {
    if (_verifyInputNull()) return;

    CommonUtils.showLoadingDialog(context); //show loading
    next() async {
      String fromAddress = isBtc ? HomePage.btcAddress : "0x${HomePage.ethAddress}";
      Map params = {"ccy": isBtc ? "BTC" : "ETH", "from_address": fromAddress, "to_address": _toAddress, "value": _amount};
      var res = await ApiNetWorkDao.getEstimateFee(context: context, reqParams: params, netStateCallBack: () {
        Navigator.pop(context); //close loading
      });
      return res;
    }

    next().then((value) async {
      if (value == null) return;

      if (isBtc) await _getUtxoList(_amount);
      if (mounted) Navigator.pop(context); //close loading

      if (value != null && value.result) {
        dynamic estimateFee = value.data;
        _nonce = estimateFee?["nonce"] ?? 0;
        _gasLimit = estimateFee?["gas"] ?? 0;

        //1.eth: gasPrice or  2.btc: fee
        _high = estimateFee?["high"] ?? 0;
        _medium = estimateFee?["medium"] ?? 0;
        _low = estimateFee?["low"] ?? 0;

        if (isNext && (isEth || isBtc && _utxoList.isNotEmpty)) {
          panelIndex = 2;  //跳转下一页

          //评估版本
          if (HomePage.isEvaluation) panelIndex = 3;
        }
      }

      setState(() { });
      ALog("## 2._getEstimateFee");
    });
  }

  /// 获取BTC的UTXO列表
  _getUtxoList(num value) async {

    next() async {
      String address = HomePage.btcAddress;
      Map params = {"ccy": "BTC", "address": address, "value": value};
      var res = await ApiNetWorkDao.getUtxoList(context: context, reqParams: params);
      return res;
    }

    await next().then((value) {

      if (value != null && value.result) {
        dynamic utxo = value.data;
        _utxoList = ((utxo?["utxo_list"] ?? []) as List<dynamic>).map((d) => d as Map).toList();

        if (_utxoList.isNotEmpty) {
          ALog("## 1._getUtxoList, txHash = ${_utxoList[0]["txHash"]}");
        }
      }
    });
  }

  /// 发送交易
  _sendRawTransaction(String rawData, {required Function(bool success) callBack}) {

    CommonUtils.showLoadingDialog(context); //show loading
    next() async {
      Map params = {"ccy": isBtc ? "BTC" : "ETH", "rawData": rawData};
      var res = await ApiNetWorkDao.sendRawTransaction(context: context, reqParams: params);
      return res;
    }

    next().then((value) {
      Navigator.pop(context); //close loading

      if (value != null && value.result) {
        dynamic resData = value.data;
        String tx_id = resData?["tx_id"] ?? "";
        ALog("tx_id = $tx_id");
        callBack(true);
      } else {
        callBack(false);
      }

    });
  }

}
