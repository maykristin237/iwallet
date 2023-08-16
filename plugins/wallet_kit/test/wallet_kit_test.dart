import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_kit/wallet_kit.dart';
import 'package:wallet_kit/wallet_kit_platform_interface.dart';
import 'package:wallet_kit/wallet_kit_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWalletKitPlatform with MockPlatformInterfaceMixin implements WalletKitPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Stream callEventResp() {
    // TODO: implement callEventResp
    throw UnimplementedError();
  }

  @override
  Future createWallet({required isBtc, bool isMainNet = true, required String psw}) {
    // TODO: implement createWallet
    throw UnimplementedError();
  }

  @override
  Future<void> tempFunction({required String name, bool open = true}) {
    // TODO: implement tempFunction
    throw UnimplementedError();
  }

  @override
  Future importWalletByPrivateKey({required isBtc, bool isMainNet = true, required String psw, required List<int> privateKey, required List<int> deviceId, required String prvKeyStr, required String devIdStr}) {
    // TODO: implement importWalletByPrivateKey
    throw UnimplementedError();
  }

  @override
  Future importWalletByMnemonic({required isBtc, bool isMainNet = true, required String psw, required List<String> mnemonics}) {
    // TODO: implement importWalletByMnemonic
    throw UnimplementedError();
  }

  @override
  Future encDeviceFactoryInfo({required String tagId, required String deviceSn}) {
    // TODO: implement encDeviceFactoryInfo
    throw UnimplementedError();
  }

  @override
  Future encPrivateKey({required String tagId, required String cardPayload, required String privateKey, required String psw, required bool overwrite, required List<int> other}) {
    // TODO: implement encPrivateKey
    throw UnimplementedError();
  }

  @override
  Future transactionSignBtc({required bool isBtc, bool isMainNet = true, required String psw, required String address, required List<int> privateKey, required List<int> deviceId, required String prvKeyStr, required String devIdStr, required int changeIdx, required String amount, required String fee, required List<Map> utxo}) {
    // TODO: implement transactionSignBtc
    throw UnimplementedError();
  }

  @override
  Future transactionSignEth({required bool isBtc, bool isMainNet = true, required String psw, required String address, required List<int> privateKey, required List<int> deviceId, required String prvKeyStr, required String devIdStr, required String nonce, required String gasPrice, required String gasLimit, required String to, required String value, required String data}) {
    // TODO: implement transactionSignEth
    throw UnimplementedError();
  }

}

void main() {
  final WalletKitPlatform initialPlatform = WalletKitPlatform.instance;

  test('$MethodChannelWalletKit is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWalletKit>());
  });

  test('getPlatformVersion', () async {
    WalletKit walletKitPlugin = WalletKit();
    MockWalletKitPlatform fakePlatform = MockWalletKitPlatform();
    WalletKitPlatform.instance = fakePlatform;

    expect(await walletKitPlugin.getPlatformVersion(), '42');
  });
}
