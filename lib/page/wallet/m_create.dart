import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iwallet/common/config/config.dart';
import 'package:iwallet/common/local/local_storage.dart';
import 'package:iwallet/common/localization/default_localizations.dart';
import 'package:iwallet/common/utils/HexUtils.dart';
import 'package:iwallet/common/utils/PlatformUtils.dart';
import 'package:iwallet/common/utils/alog.dart';
import 'package:iwallet/common/utils/common_utils.dart';
import 'package:iwallet/page/home/home_page.dart';
import 'package:iwallet/widget/nfc_controller.dart';
import 'package:iwallet/widget/nfc_widget.dart';
import 'package:wallet_kit/wallet_kit.dart';

mixin Create_M<T extends StatefulWidget> on State<T> {

  /// public var
  final TextEditingController tCtr1 = TextEditingController(),  tCtr2 = TextEditingController();

  final TextEditingController myController = TextEditingController();
  late int loginType = 1;

  /// private var
  late String _myText = "";
  late bool _onceFlag = false, _disposeFlag = false;

  ///弹出卡片
  NfcView? nfcView;
  var crossFadeState = CrossFadeState.showFirst;
  bool get _isClose => NfcView.isClose = (crossFadeState == CrossFadeState.showFirst);
  EdgeInsetsGeometry get mainPadding => !_isClose ? const EdgeInsets.all(0) : const EdgeInsets.only(left: 15, right: 15);
  EdgeInsetsGeometry get cardPadding => _isClose ? const EdgeInsets.all(0) : const EdgeInsets.only(left: 15, right: 15);

  final ScrollController scrollController = ScrollController();
  final WalletKit _walletKitPlugin = WalletKit();
  String address = "", mnemonics = "", privateKey = "";
  bool _isBtc = false;

  @override
  void initState() {
    super.initState();
    _initData();
    _initParams();
  }

  Future<void> _initData() async {
    myController.value;
    setState(() {
      loginType = 2;
    });
  }

  _initParams() async {
    if (PlatformUtils.isAndroid || PlatformUtils.isIOS || PlatformUtils.isWindows || PlatformUtils.isWeb) {
      //2.本地用户信息获取
      _myText = await LocalStorage.getString(Config.USER_NAME_KEY);
    }
    myController.value = TextEditingValue(text: _myText ?? "");
  }

  @override
  void dispose() {
    super.dispose();
    _disposeFlag = true;
    NfcController.instance.nfcStop();
    myController.removeListener(_privateUsernameChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //防止重复进入
    if (_onceFlag || _disposeFlag) return;
    _onceFlag = true;

  }

  _privateUsernameChange() {
    _myText = myController.text;
  }

  void createWallet(bool isBtc, {Function()? callBack}) async {
    _isBtc = isBtc;

    String psw1 = tCtr1.value.text, psw2 = tCtr2.value.text;
    if (psw1.isEmpty) {
      CommonUtils.showCommonDialog(context, Locals.i18n(context)!.new_psw_empty);
      return;
    }
    if (psw2.isEmpty) {
      CommonUtils.showCommonDialog(context, Locals.i18n(context)!.confirm_psw_empty);
      return;
    }
    if (psw1 != psw2) {
      CommonUtils.showCommonDialog(context, Locals.i18n(context)!.psw_unconfirm);
      return;
    }

    //评估版本
    if (await _isEvaluation(psw2, callBack)) return;

    dynamic resp = await _walletKitPlugin.createWallet(isBtc, true, psw2);
    ALog("## Resp: $resp");

    String result = resp["result"] ?? "Error result";
    if (result != "ok") {
      CommonUtils.showCommonDialog(context, result);
      return;
    }

    address = resp["address"] ?? "";
    mnemonics = resp["mnemonics"] ?? "";
    privateKey = resp?["privateKey"] ?? "";
    NfcController.instance.setEncPrivateKey(privateKey, psw2, false);

    callBack?.call();
  }

  void saveAddressData() async {
    String btcAddr = "", ethAddr = "";
    if (NfcController.instance.storePrivateKey.isNotEmpty) {
      String psw1 = tCtr1.value.text;
      String cplStr = HexUtils.uint8ToHex(NfcController.instance.storePrivateKey);
      String tiStr = HexUtils.uint8ToHex(NfcController.instance.tagId);

      dynamic resp = await _walletKitPlugin.importWalletByPrivateKey(true, true, psw1, NfcController.instance.storePrivateKey, NfcController.instance.tagId, cplStr, tiStr);
      dynamic resp2 = await _walletKitPlugin.importWalletByPrivateKey(false, true, psw1, NfcController.instance.storePrivateKey, NfcController.instance.tagId, cplStr, tiStr);
      btcAddr = resp?["address"] ?? "";
      ethAddr = resp2?["address"] ?? "";
    }


    //保存:
    HomePage.btcAddress = btcAddr == address ? btcAddr : address;
    HomePage.ethAddress = ethAddr;
    Map data = {"btcAddress": HomePage.btcAddress, "ethAddress": HomePage.ethAddress};
    String dataStr = json.encode(data);
    await LocalStorage.save(Config.WALLET_ACCOUNT, dataStr);

  }

  //评估版本
  Future<bool> _isEvaluation(String pw, Function()? callBack) async {
    if (HomePage.isEvaluation) {
      mnemonics = "spike world quit road parent loyal erode that safe shock doll good"; //view for ui
      List<String> mnemonic = ["spike", "world", "quit", "road", "parent", "loyal", "erode", "that", "safe", "shock", "doll", "panda"];

      dynamic resp = await _walletKitPlugin.importWalletByMnemonic(true, true, pw, mnemonic);
      dynamic resp2 = await _walletKitPlugin.importWalletByMnemonic(false, true, pw, mnemonic);

      String result = resp["result"] ?? "Error result";
      String result2 = resp2["result"] ?? "Error result";
      if (result != "ok" && result2 != "ok") {
        if (mounted) {
          if (result.contains("助记词")) CommonUtils.showCommonDialog(context, Locals.i18n(context)!.mnemonic_import_error);
          else CommonUtils.showCommonDialog(context, result);
        }
        return true;
      }

      String privateKey = resp?["privateKey"] ?? "";
      String privateKey2 = resp2?["privateKey"] ?? "";
      if (privateKey.isEmpty) privateKey = privateKey2;

      String btcAddr = resp?["address"] ?? "";
      String ethAddr = resp2?["address"] ?? "";
      HomePage.btcAddress = btcAddr;
      HomePage.ethAddress = ethAddr;
      Map data = {"btcAddress": HomePage.btcAddress, "ethAddress": HomePage.ethAddress};
      String dataStr = json.encode(data);
      await LocalStorage.save(Config.WALLET_ACCOUNT, dataStr);

      //1.新privateKey
      dynamic respNewKey = await _walletKitPlugin.encPrivateKey("04F02901564803", "cardPayload", privateKey, pw, true, []);  //ios不需要cardPayload, _overwrite
      String resultStr = resp?["result"] ?? "Error result";
      if (resultStr != "ok") {
        if (mounted) CommonUtils.showCommonDialog(context, "Create error!");
        return true;
      }
      List<int> encPrivateKey = respNewKey?["encPrivateKey"] ?? [];
      String cardPayload = HexUtils.uint8ToHex(encPrivateKey);
      NfcController.instance.setTagId("04F02901564803");
      NfcController.instance.setCardData(cardPayload);

      //2.保存新privateKey
      HomePage.evaluationPw = pw;
      Map dataEva = {"isEvaluation": HomePage.isEvaluation, "tigId": "04F02901564803", "cardPayload": cardPayload, "evaluationPw": HomePage.evaluationPw};
      String dataEvaStr = json.encode(dataEva);
      LocalStorage.save(Config.EVALUATION, dataEvaStr);

      callBack?.call();
      return true;
    } else {
      return false;
    }
  }


  clearFunction() {
    myController.text = "";
  }

}