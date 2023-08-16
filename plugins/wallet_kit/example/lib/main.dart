import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:wallet_kit/wallet_kit.dart';
import 'package:wallet_kit/wallet_kit_platform_interface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown', _respData = "";
  final _walletKitPlugin = WalletKit();

  late final StreamSubscription<dynamic> _createWalletSubs;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {

    //第三方包侦听 调用
    _createWalletSubs = WalletKitPlatform.instance.callEventResp().listen(_listenCallEvent);

    //
    String platformVersion;
    try {
      platformVersion = await _walletKitPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  void _listenCallEvent(dynamic resp) {
    setState(() {
      _respData = "resp: $resp";
    });

    print('### resp: $resp');
    //_showTips('创建钱包返回的数据', 'resp: ');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Text('Running on: $_platformVersion\n$_respData'),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {

              },
              child: const Text("点击", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  _createWallet() async {
    dynamic resp = await _walletKitPlugin.createWallet(true, true, "666666");
    setState(() {
      _respData = "resp: $resp";
    });
  }

  void _showTips(String title, String content) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
        );
      },
    );
  }
}
