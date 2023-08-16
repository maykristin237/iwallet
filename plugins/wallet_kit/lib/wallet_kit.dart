
import 'wallet_kit_platform_interface.dart';

class WalletKit {
  Future<String?> getPlatformVersion() {
    return WalletKitPlatform.instance.getPlatformVersion();
  }

  /// 创建钱包
  Future<dynamic> createWallet(bool isBtc, bool isMainNet, String psw) {
    return WalletKitPlatform.instance.createWallet(isBtc: isBtc, isMainNet: isMainNet, psw: psw);
  }

  /// 私钥导入钱包 var bytes = utf8.encode(password);
  Future<dynamic> importWalletByPrivateKey(bool isBtc, bool isMainNet, String psw, List<int> privateKey, List<int> deviceId, String prvKeyStr, String devIdStr) {
    return WalletKitPlatform.instance.importWalletByPrivateKey(isBtc: isBtc, isMainNet: isMainNet, psw: psw, privateKey: privateKey, deviceId: deviceId, prvKeyStr: prvKeyStr, devIdStr: devIdStr);
  }

  /// 助记词导入钱包
  Future<dynamic> importWalletByMnemonic(bool isBtc, bool isMainNet, String psw, List<String> mnemonics) {
    return WalletKitPlatform.instance.importWalletByMnemonic(isBtc: isBtc, isMainNet: isMainNet, psw: psw, mnemonics: mnemonics);
  }

  /// 交易签名 BTC需要address参数  utxo => String txHash, int vout, num amount, String address, String scriptPubKey, String derivedPath
  Future<dynamic> transactionSignBtc(bool isBtc, bool isMainNet, String psw, String address, List<int> privateKey, List<int> deviceId, String prvKeyStr, String devIdStr,
      int changeIdx, String amount, String fee, List<Map> utxo) {
    return WalletKitPlatform.instance.transactionSignBtc(
        isBtc: isBtc,
        isMainNet: isMainNet,
        psw: psw,
        address: address,
        privateKey: privateKey,
        deviceId: deviceId,
        prvKeyStr: prvKeyStr,
        devIdStr: devIdStr,
        changeIdx: changeIdx,
        amount: amount,
        fee: fee,
        utxo: utxo);
  }

  /// 交易签名 ETH
  Future<dynamic> transactionSignEth(bool isBtc, bool isMainNet, String psw, String address, List<int> privateKey, List<int> deviceId, String prvKeyStr, String devIdStr,
      String nonce, String gasPrice, String gasLimit, String to, String value, String data) {
    return WalletKitPlatform.instance.transactionSignEth(
        isBtc: isBtc,
        isMainNet: isMainNet,
        psw: psw,
        address: address,
        privateKey: privateKey,
        deviceId: deviceId,
        prvKeyStr: prvKeyStr,
        devIdStr: devIdStr,
        nonce: nonce,
        gasPrice: gasPrice,
        gasLimit: gasLimit,
        to: to,
        value: value,
        data: data);
  }

  /// 创建钱包时用到 tagId, cardPayload, privateKey 需要16进制 Hex
  Future<dynamic> encPrivateKey(String tagId, String cardPayload, String privateKey, String psw, bool overwrite, List<int> other) {
    return WalletKitPlatform.instance.encPrivateKey(tagId: tagId, cardPayload: cardPayload, privateKey: privateKey, psw: psw, overwrite: overwrite, other: other);
  }

  /// 重置卡片时用到 tagId, deviceSn 需要16进制 Hex
  Future<dynamic> encDeviceFactoryInfo(String tagId, String deviceSn) {
    return WalletKitPlatform.instance.encDeviceFactoryInfo(tagId: tagId, deviceSn: deviceSn);
  }

}
