import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'wallet_kit_platform_interface.dart';

/// An implementation of [WalletKitPlatform] that uses method channels.
class MethodChannelWalletKit extends WalletKitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  late final methodChannel = const MethodChannel('wallet_kit')
    ..setMethodCallHandler(_handleMethod);

  final StreamController<dynamic> _eventController = StreamController<dynamic>.broadcast();

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onBleSearch':
        _eventController.add({"action": "onBleSearch", "resData": call.arguments});
        break;
      case 'onBleSearchTimeOut':
        _eventController.add({"action": "onBleSearchTimeOut", "resData": call.arguments});
        break;
      case 'onReadPrivateKey':
        _eventController.add({"action": "onReadPrivateKey", "resData": call.arguments});
        break;
      case 'onWritePrivateKey':
        _eventController.add({"action": "onWritePrivateKey", "resData": call.arguments});
        break;
      case 'onHandShake':
        _eventController.add({"action": "onHandShake", "resData": call.arguments});
        break;
      case 'onTranslate':
        _eventController.add({"action": "onTranslate", "resData": call.arguments});
        break;
      case 'onFail':
        _eventController.add({"action": "onFail", "resData": call.arguments});
        break;
      case 'onEventCallResp':
        _eventController.add(call.arguments);
        break;
      case "onOther":
        //_eventController.add(AlipayResp.fromJson((call.arguments as Map<dynamic, dynamic>).cast<String, dynamic>()));
        break;
    }
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Stream<dynamic> callEventResp() {
    return _eventController.stream;
  }

  /// Template Sample
  @override
  Future<void> tempFunction({required String name, bool open = true}) {
    return methodChannel.invokeMethod<void>(
      'other_channel_name',
      <String, dynamic>{
        'name': name,
        'open': open,
      },
    );
  }

  /// 创建钱包
  @override
  Future<dynamic> createWallet({required bool isBtc, bool isMainNet = true, required String psw}) {
    return methodChannel.invokeMethod<dynamic>(
      'create_wallet',
      <String, dynamic>{
        'isBtc': isBtc,
        'isMainNet': isMainNet,
        'psw': psw,
      },
    );
  }

  /// 私钥导入钱包 var bytes = utf8.encode(password);
  @override
  Future<dynamic> importWalletByPrivateKey({required bool isBtc, bool isMainNet = true, required String psw, required List<int> privateKey, required List<int> deviceId, required String prvKeyStr, required String devIdStr}) {
    return methodChannel.invokeMethod<dynamic>(
      'import_wallet_key',
      <String, dynamic>{
        'isBtc': isBtc,
        'isMainNet': isMainNet,
        'psw': psw,
        "privateKey" : privateKey,
        "deviceId" : deviceId,
        "prvKeyStr":prvKeyStr,
        "devIdStr":devIdStr,
      },
    );
  }

  /// 助记词导入钱包
  @override
  Future<dynamic> importWalletByMnemonic({required bool isBtc, bool isMainNet = true, required String psw, required List<String> mnemonics}) {
    return methodChannel.invokeMethod<dynamic>(
      'import_wallet_mnemonics',
      <String, dynamic>{
        'isBtc': isBtc,
        'isMainNet': isMainNet,
        'psw': psw,
        "mnemonics" : mnemonics,
      },
    );
  }

  /// 交易签名 BTC需要address参数  utxo => required String txHash, required int vout, required num amount, required String scriptPubKey, required String derivedPath
  @override
  Future<dynamic> transactionSignBtc({required bool isBtc, bool isMainNet = true, required String psw, required String address, required List<int> privateKey, required List<int> deviceId, required String prvKeyStr, required String devIdStr,
    required int changeIdx, required String amount, required String fee, required List<Map> utxo}) {
    return methodChannel.invokeMethod<dynamic>(
      'transaction_sign_btc',
      <String, dynamic>{
        'isBtc': isBtc,
        'isMainNet': isMainNet,
        'psw': psw,
        "address" : address,
        "privateKey" : privateKey,
        "deviceId" : deviceId,
        "prvKeyStr":prvKeyStr,
        "devIdStr":devIdStr,
        "changeIdx" : changeIdx,
        "amount" : amount,
        "fee" : fee,
        "utxo" : utxo,
      },
    );
  }

  /// 交易签名 ETH
  @override
  Future<dynamic> transactionSignEth({required bool isBtc, bool isMainNet = true, required String psw, required String address, required List<int> privateKey, required List<int> deviceId, required String prvKeyStr, required String devIdStr,
    required String nonce, required String gasPrice, required String gasLimit, required String to, required String value, required String data}) {
    return methodChannel.invokeMethod<dynamic>(
      'transaction_sign_eth',
      <String, dynamic>{
        'isBtc': isBtc,
        'isMainNet': isMainNet,
        'psw': psw,
        "address" : address,
        "privateKey" : privateKey,
        "deviceId" : deviceId,
        "prvKeyStr":prvKeyStr,
        "devIdStr":devIdStr,
        "nonce" : nonce,
        "gasPrice" : gasPrice,
        "gasLimit" : gasLimit,
        "to" : to,
        "value" : value,
        "data" : data,
      },
    );
  }

  /// 创建钱包时用到 tagId, cardPayload, privateKey 需要16进制 Hex
  @override
  Future<dynamic> encPrivateKey({required String tagId, required String cardPayload, required String privateKey, required String psw, required bool overwrite, required List<int> other}) {
    return methodChannel.invokeMethod<dynamic>(
      'enc_private_key',
      <String, dynamic>{
        'tagId': tagId,
        'cardPayload': cardPayload,
        'privateKey': privateKey,
        "psw" : psw,
        "overwrite": overwrite,
        "other" : other,
      },
    );
  }

  /// 重置卡片时用到 tagId, cardPayload, privateKey 需要16进制 Hex
  @override
  Future<dynamic> encDeviceFactoryInfo({required String tagId, required String deviceSn}) {
    return methodChannel.invokeMethod<dynamic>(
      'enc_dev_info',
      <String, dynamic>{
        'tagId': tagId,
        'deviceSn': deviceSn,
      },
    );
  }

}
