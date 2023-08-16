import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'wallet_kit_method_channel.dart';

abstract class WalletKitPlatform extends PlatformInterface {
  /// Constructs a WalletKitPlatform.
  WalletKitPlatform() : super(token: _token);

  static final Object _token = Object();

  static WalletKitPlatform _instance = MethodChannelWalletKit();

  /// The default instance of [WalletKitPlatform] to use.
  ///
  /// Defaults to [MethodChannelWalletKit].
  static WalletKitPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WalletKitPlatform] when
  /// they register themselves.
  static set instance(WalletKitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// 回调callback
  Stream<dynamic> callEventResp() {
    throw UnimplementedError('authResp() has not been implemented.');
  }

  /// Template Sample
  Future<void> tempFunction({required String name, bool open = true}) {
    throw UnimplementedError(
        'auth({required info, isShowLoading}) has not been implemented.');
  }



  /// 创建钱包
  Future<dynamic> createWallet({required bool isBtc, bool isMainNet = true, required String psw}) {
    throw UnimplementedError(
        'auth({required info, isShowLoading}) has not been implemented.');
  }

  /// 私钥导入钱包 var bytes = utf8.encode(password);
  Future<dynamic> importWalletByPrivateKey({required bool isBtc, bool isMainNet = true, required String psw, required List<int> privateKey, required List<int> deviceId, required String prvKeyStr, required String devIdStr}) {
    throw UnimplementedError(
        'auth({required info, isShowLoading}) has not been implemented.');
  }

  /// 助记词导入钱包
  Future<dynamic> importWalletByMnemonic({required bool isBtc, bool isMainNet = true, required String psw, required List<String> mnemonics}) {
    throw UnimplementedError(
        'auth({required info, isShowLoading}) has not been implemented.');
  }

  /// 交易签名 BTC需要address参数  utxo => required String txHash, required int vout, required num amount, required String scriptPubKey, required String derivedPath
  Future<dynamic> transactionSignBtc({required bool isBtc, bool isMainNet = true, required String psw, required String address, required List<int> privateKey, required List<int> deviceId, required String prvKeyStr, required String devIdStr,
    required int changeIdx, required String amount, required String fee, required List<Map> utxo}) {
    throw UnimplementedError(
        'auth({required info, isShowLoading}) has not been implemented.');
  }

  /// 交易签名 ETH
  Future<dynamic> transactionSignEth({required bool isBtc, bool isMainNet = true, required String psw, required String address, required List<int> privateKey, required List<int> deviceId, required String prvKeyStr, required String devIdStr,
    required String nonce, required String gasPrice, required String gasLimit, required String to, required String value, required String data}) {
    throw UnimplementedError(
        'auth({required info, isShowLoading}) has not been implemented.');
  }

  /// 创建钱包时用到 tagId, cardPayload, privateKey 需要16进制 Hex
  Future<dynamic> encPrivateKey({required String tagId, required String cardPayload, required String privateKey, required String psw, required bool overwrite, required List<int> other}) {
    throw UnimplementedError(
        'auth({required info, isShowLoading}) has not been implemented.');
  }

  /// 重置卡片时用到 tagId, deviceSn 需要16进制 Hex
  Future<dynamic> encDeviceFactoryInfo({required String tagId, required String deviceSn}) {
    throw UnimplementedError(
        'auth({required info, isShowLoading}) has not been implemented.');
  }

}
