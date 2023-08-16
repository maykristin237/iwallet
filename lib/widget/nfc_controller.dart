import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:iwallet/common/utils/HexUtils.dart';
import 'package:iwallet/common/utils/alog.dart';
import 'package:iwallet/widget/nfc_widget.dart';
import 'package:wallet_kit/wallet_kit.dart';

enum NfcType { ok, empty, unavailable, resetOk, resetFail, isExist, other }

class NfcController {
  final bool isNfcModel = true; //NFC

  final String NDEF_DOMAIN = "sevenblock";
  final String NDEF_DATA_TYPE = "wallet";
  final WalletKit _walletKit = WalletKit();

  static NfcController? _instance;
  static NfcController get instance => _instance ??= NfcController._();

  NfcController._() {
    //channel.setMethodCallHandler(_handleMethodCall);
  }

  ///需要重置
  late bool needReset = false;
  ///重置并接着操作
  late bool resetAndGoNext = false;

  ///创建钱包时所需要的值
  String _privateKey = "", _psw = "";
  bool _overwrite = false;
  void setEncPrivateKey(String privateKey, String psw, bool overwrite) {
    _privateKey = privateKey;
    _psw = psw;
    _overwrite = overwrite;
  }

  List<int> storePrivateKey = [];
  List<int> _cardPayload = [], _tagId = [];
  List<int> get cardPayload =>_cardPayload;
  List<int> get tagId => _tagId;
  String get cplStr => HexUtils.uint8ToHex(_cardPayload);
  String get tiStr => HexUtils.uint8ToHex(_tagId);

  //评估版本使用:
  void setCardData(String value) => _cardPayload = HexUtils.toUnitList(value);
  void setTagId(String value) => _tagId = HexUtils.toUnitList(value);

  //NFC模块
  Future<bool> _nfcIsAvailable() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    return isAvailable;
  }

  Future<void> nfcStop() async {
    if (isNfcModel) {
      ALog("NFC Stop");
      bool isAvailable = false;
      try {isAvailable = await NfcManager.instance.isAvailable(); } catch (e) {ALog("NFC Error: $e");}
      if (isAvailable) {
        NfcManager.instance.stopSession();
      }
    }
  }

  Future<void> nfcReadOrWrite(bool isWrite, {Function(bool result, NfcType type)? callBack}) async {
    ALog("NFC Read");
    bool isAvailable = false;
    try {isAvailable = await NfcManager.instance.isAvailable();} catch (e) {ALog("NFC Error: $e");}

    if (!isAvailable) {
      callBack?.call(false, NfcType.unavailable);
      return;
    }

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {

      ALog("NfcManager _isClose = ${NfcView.isClose}");
      if (NfcView.isClose) {
        ALog("NFC dd Stop");
        NfcManager.instance.stopSession();
        return;
      }

      ValueNotifier<dynamic> result = ValueNotifier(null);

      dynamic tagData = tag.data["ndef"] ?? tag.data["nfca"];
      _tagId = tagData?["identifier"] ?? [];
      if (_tagId.isEmpty) {
        _tagId = tag.data["mifare"]?["identifier"] ?? [];   //ios系统
      }

      String tagId = HexUtils.uint8ToHex(_tagId);

      Ndef? ndef = Ndef.from(tag);
      if (ndef == null) {
        ALog("NFC ndef = null");
        callBack?.call(false, NfcType.unavailable);
        return;
      }

      //需要重置
      if (needReset) {
        needReset = false;
        if (await _newReset(ndef, tagId)) callBack?.call(false, NfcType.resetOk);
        else callBack?.call(false, NfcType.resetFail);
        return;
      } else if (resetAndGoNext) {
        if (await _newReset(ndef, tagId)) {
          resetAndGoNext = true;
        } else {
          resetAndGoNext = false;
          callBack?.call(false, NfcType.resetFail);
          return;
        }
      }

      //没有数据
      dynamic cachedMessage = tagData?["cachedMessage"];
      if (cachedMessage == null && !resetAndGoNext) {
        ALog("NFC cachedMessage = null");
        callBack?.call(false, NfcType.empty);
        return;
      }
      resetAndGoNext = false;

      try {
        //1.读
        NdefMessage msg = await ndef.read();
        ALog("## records.len = ${msg.records.length}");
        NdefRecord? record;
        for (NdefRecord re in msg.records) {
          record = re;
        }
        _cardPayload = record?.payload ?? [];

        String cardPayload = HexUtils.uint8ToHex(_cardPayload);
        if (_cardPayload.isEmpty) {
          callBack?.call(false, NfcType.empty);
          return;
        }

        //2.写
        if (isWrite && ndef.isWritable) {

          dynamic resp = await _walletKit.encPrivateKey(tagId, cardPayload, _privateKey, _psw, _overwrite, []);  //ios不需要cardPayload, _overwrite
          String resultStr = resp?["result"] ?? "Error result";
          if (resultStr != "ok") {
            if (resultStr.contains("卡片已存在钱包")) callBack?.call(false, NfcType.isExist);
            else callBack?.call(false, NfcType.other);
            return;
          }
          Uint8List encPrivateKey = resp?["encPrivateKey"] ?? [];
          if (encPrivateKey.isEmpty) {
            callBack?.call(false, NfcType.other);
            return;
          }
          storePrivateKey = encPrivateKey;

          ALog("## 5.Flutter encPrivateKey = $encPrivateKey");
          ALog("## 6.Flutter encPrivateKey Hex = ${HexUtils.uint8ToHex(encPrivateKey)}");

          NdefMessage message = NdefMessage([
            NdefRecord.createExternal(NDEF_DOMAIN, NDEF_DATA_TYPE, encPrivateKey),
          ]);

          await ndef.write(message);
          result.value = 'Success to "Ndef Write"';
          ALog("## 7.Flutter Success to Ndef Write !!");
        }

      } catch (e) {
        ALog("my error = $e");
        result.value = e;
        callBack?.call(false, NfcType.other);
        return;
      }

      callBack?.call(true, NfcType.ok);
    });
  }

  Future<bool> _newReset(Ndef ndef, String tagId) async {
    if (!ndef.isWritable || tagId.isEmpty) return false;

    try {
      ///1. 通过sdk生成: privateKey, 设置为默认值卡片:
      const String deviceSn = "701001000000";
      Uint8List encPrivateKey = await _walletKit.encDeviceFactoryInfo(tagId, deviceSn);

      ///2. 设置为空卡片:
      NdefMessage message = NdefMessage([
        NdefRecord.createExternal(NDEF_DOMAIN, NDEF_DATA_TYPE, encPrivateKey),
      ]);

      await ndef.write(message);
      ALog("## 7.Flutter _newReset !!");
    } catch (e) {
      ALog("## _newReset error: $e");
      return false;
    }
    return true;
  }

  Future<void> nfcRead({Function(bool result)? callBack}) async {
    ALog("NFC Read");
    bool isAvailable = false;
    try {isAvailable = await NfcManager.instance.isAvailable();} catch (e) {ALog("NFC Error: $e");}

    if (!isAvailable) {
      callBack?.call(false);
      return;
    }

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      ALog("NfcManager _isClose = ${NfcView.isClose}");
      if (NfcView.isClose) {
        ALog("NFC Stop");
        NfcManager.instance.stopSession();
        return;
      }

      ValueNotifier<dynamic> result = ValueNotifier(null);
      var ndef = Ndef.from(tag);
      if (ndef == null) {
        result.value = 'NFC Error';
        NfcManager.instance.stopSession(errorMessage: result.value);
        callBack?.call(false);
        return;
      }

      try {
        NdefMessage msg = await ndef.read();
        ALog("## records.len = ${msg.records.length}");
        for (NdefRecord record in msg.records) {
          ALog("record.payload = ${record.payload}");
        }
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        callBack?.call(false);
        return;
      }
      callBack?.call(true);
    });
  }

  Future<void> nfcDefWrite({Function(bool result)? callBack}) async {
    bool isAvailable = false;
    try {isAvailable = await NfcManager.instance.isAvailable();} catch (e) {ALog("NFC Error: $e");}

    if (!isAvailable) {
      callBack?.call(false);
      return;
    }

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      ValueNotifier<dynamic> result = ValueNotifier(null);
      var ndef = Ndef.from(tag);
      if (ndef == null || !ndef.isWritable) {
        result.value = 'Tag is not ndef writable';
        NfcManager.instance.stopSession(errorMessage: result.value);
        return;
      }

      NdefMessage message = NdefMessage([
        NdefRecord.createExternal('com.example', 'mytype', Uint8List.fromList('mydata'.codeUnits)),
      ]);

      try {
        await ndef.write(message);
        result.value = 'Success to "Ndef Write"';
        NfcManager.instance.stopSession();
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
    });
  }

  void nfcDefWriteLock() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      ValueNotifier<dynamic> result = ValueNotifier(null);
      var ndef = Ndef.from(tag);
      if (ndef == null) {
        result.value = 'Tag is not ndef';
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }

      try {
        await ndef.writeLock();
        result.value = 'Success to "Ndef Write Lock"';
        NfcManager.instance.stopSession();
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
    });
  }

}