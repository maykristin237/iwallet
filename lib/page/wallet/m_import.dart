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
import 'package:wallet_kit/wallet_kit.dart';

mixin Import_M<T extends StatefulWidget> on State<T> {

  /// public var
  final TextEditingController tCtr0 = TextEditingController(), tCtr1 = TextEditingController(), tCtr2 = TextEditingController();
  final TextEditingController myController = TextEditingController();
  late int loginType = 1;

  late bool isImportKeyBl = false, isImportWordBl = false;

  /// private var
  late String _myText = "";
  late bool _onceFlag = false, _disposeFlag = false;

  String _ethAddr = "", _btcAddr = "";
  List<String> words = [];
  final WalletKit _walletKitPlugin = WalletKit();

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

  void importWalletByKey({Function()? callBack}) async {
    String psw1 = tCtr1.value.text;
    if (psw1.isEmpty) {
      CommonUtils.showCommonDialog(context, Locals.i18n(context)!.psw_empty);
      return;
    }

    //评估版本
    if (await _isEvaluation(psw1, callBack)) {}

    dynamic resp = await _walletKitPlugin.importWalletByPrivateKey(true, true, psw1, NfcController.instance.cardPayload, NfcController.instance.tagId,NfcController.instance.cplStr, NfcController.instance.tiStr);
    dynamic resp2 = await _walletKitPlugin.importWalletByPrivateKey(false, true, psw1, NfcController.instance.cardPayload, NfcController.instance.tagId,NfcController.instance.cplStr, NfcController.instance.tiStr);

    String result = resp["result"] ?? "Error result";
    if (result != "ok") {
      if (mounted) {
        if (result.contains("密码错误")) CommonUtils.showCommonDialog(context, Locals.i18n(context)!.psw_error);
        else if (result.contains("空钱包")) CommonUtils.showCommonDialog(context, Locals.i18n(context)!.empty_car_import);
        else CommonUtils.showCommonDialog(context, result);
      }
      return;
    }

    _btcAddr = resp?["address"] ?? "";
    _ethAddr = resp2?["address"] ?? "";

    callBack?.call();
  }

  void importWalletByWord({Function()? callBack}) async {
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
    if (await _isEvaluation(psw1, callBack)) return;

    dynamic resp = await _walletKitPlugin.importWalletByMnemonic(true, true, psw2, words);
    dynamic resp2 = await _walletKitPlugin.importWalletByMnemonic(false, true, psw2, words);

    String result = resp["result"] ?? "Error result";
    String result2 = resp2["result"] ?? "Error result";
    if (result != "ok" && result2 != "ok") {
      if (mounted) {
        if (result.contains("助记词")) CommonUtils.showCommonDialog(context, Locals.i18n(context)!.mnemonic_import_error);
        else CommonUtils.showCommonDialog(context, result);
      }
      return;
    }

    String privateKey = resp?["privateKey"] ?? "";
    String privateKey2 = resp2?["privateKey"] ?? "";
    if (privateKey.isEmpty) privateKey = privateKey2;
    NfcController.instance.setEncPrivateKey(privateKey, psw2, true);

    _btcAddr = resp?["address"] ?? "";
    _ethAddr = resp2?["address"] ?? "";

    callBack?.call();
  }

  void saveAddressData() async {
    //保存:
    HomePage.btcAddress = _btcAddr;
    HomePage.ethAddress = _ethAddr;
    Map data = {"btcAddress": HomePage.btcAddress, "ethAddress": HomePage.ethAddress};
    String dataStr = json.encode(data);
    await LocalStorage.save(Config.WALLET_ACCOUNT, dataStr);
  }

  //评估版本
  Future<bool> _isEvaluation(String pw, Function()? callBack) async {
    if (HomePage.isEvaluation) {

      if (isImportKeyBl) {
        String? evaluation = await LocalStorage.get(Config.EVALUATION);
        Map mapEva = json.decode(evaluation ?? "{}");
        String tigId = mapEva["tigId"] ?? "04F02901564803";
        String cardData = mapEva["cardPayload"] ?? "00019F8BB87CBEE559DE24CB02E2346B4E157548A3D8181DE43E393ACB58C33C2607DDFE9D1EAC743ED4CA11C5EB5BE9F6EA4406F97B5C3B85093ADBDA96A6D90790BFBCB6A6CF249FBF42B1BC8BD02E044B8EDAD96682902DC6";

        NfcController.instance.setTagId(tigId);
        NfcController.instance.setCardData(cardData);
        return true;
      } else if (isImportWordBl) {
        String mnemonicsStr = "spike world quit road parent loyal erode that safe shock doll good ";
        String wordStr = "";
        words.forEach((element) => wordStr += "$element ");
        if (mnemonicsStr != wordStr) {
          CommonUtils.showCommonDialog(context, Locals.i18n(context)!.mnemonic_import_error);
          return true;
        } else {
          List<String> mnemonics = ["spike", "world", "quit", "road", "parent", "loyal", "erode", "that", "safe", "shock", "doll", "panda"];
          dynamic resp = await _walletKitPlugin.importWalletByMnemonic(true, true, pw, mnemonics);
          dynamic resp2 = await _walletKitPlugin.importWalletByMnemonic(false, true, pw, mnemonics);

          String result = resp["result"] ?? "Error result";
          String result2 = resp2["result"] ?? "Error result!";
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

          _btcAddr = resp?["address"] ?? "";
          _ethAddr = resp2?["address"] ?? "";
          saveAddressData();//保存生成的地址

          //1.新privateKey
          dynamic respNewKey = await _walletKitPlugin.encPrivateKey("04F02901564803", "cardPayload", privateKey, pw, true, []);  //ios不需要cardPayload, _overwrite
          String resultStr = resp?["result"] ?? "Error result";
          if (resultStr != "ok") {
            if (mounted) CommonUtils.showCommonDialog(context, "Import error!");
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
          ALog("## save dataEvaStr = $dataEvaStr");

        }
      }
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