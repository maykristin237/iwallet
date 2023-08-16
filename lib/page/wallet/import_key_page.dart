import 'package:flutter/material.dart';
import 'package:iwallet/common/localization/default_localizations.dart';
import 'package:iwallet/common/localization/string_all_base.dart';
import 'package:iwallet/common/style/def_style.dart';
import 'package:iwallet/common/utils/HexUtils.dart';
import 'package:iwallet/common/utils/navigator_utils.dart';
import 'package:iwallet/page/home/home_page.dart';
import 'package:iwallet/widget/nfc_controller.dart';
import 'package:iwallet/widget/nfc_widget.dart';
import 'package:iwallet/widget/widget_utils.dart';

import 'm_import.dart';

/// xxx
///
/// Date: 2023-03-06


class ImportKeyPage extends StatefulWidget {
  static const String sName = "importKey";

  const ImportKeyPage({super.key});

  @override
  State<ImportKeyPage> createState() => _ImportKeyPageState();
}

class _ImportKeyPageState extends State<ImportKeyPage> with Import_M {

  StringAllBase get Lan => Locals.i18n(context)!;
  late var txtName = ["12个", "18个", "24个"];
  late var isSelected = [false, false, true];

  int panelIndex = 1;
  ///弹出卡片
  NfcView? _nfcView;
  var _crossFadeState = CrossFadeState.showFirst;
  bool get _isClose => NfcView.isClose = (_crossFadeState == CrossFadeState.showFirst);
  EdgeInsetsGeometry get mainPadding => !_isClose ? const EdgeInsets.all(0) : const EdgeInsets.only(left: 15, right: 15);
  EdgeInsetsGeometry get cardPadding => _isClose ? const EdgeInsets.all(0) : const EdgeInsets.only(left: 15, right: 15);

  String get _privateKey => NfcController.instance.cardPayload.isNotEmpty ? HexUtils.uint8ToHex(NfcController.instance.cardPayload) : "";

  @override
  void initState() {
    super.initState();
    isImportKeyBl = true;
    //评估版本
    if (HomePage.isEvaluation) panelIndex = 2;
  }

  @override
  Widget build(BuildContext context) {
    /// 触摸收起键盘
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {FocusScope.of(context).requestFocus(FocusNode());},
      child: Scaffold(
          backgroundColor: DefColors.primaryValue,
          //floatingActionButton: FloatingActionButton(child: Icon(Icons.file_download), onPressed: () { }),
          appBar: AppBar(
            title: Text(Locals.i18n(context)!.import_wallet), //WYTitleBar("标题"),
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
    if (_isEvaluation2()) return;  //评估版本

    if (panelIndex == 1) {
      Navigator.maybePop(context, PageType.BACK);
    } else if (panelIndex == 2) {
      setState(() => panelIndex = 1);
    } else if (panelIndex == 3) {
      Navigator.maybePop(context, PageType.FINISH);
    } else {
      Navigator.maybePop(context, PageType.BACK);
    }
  }

  Widget _allPanels() {
    if (panelIndex == 1) {
      return _panel1();
    } else if (panelIndex == 2) {
      return _panel2();
    } else if (panelIndex == 3) {
      return _panel3();
    }
    return const SizedBox();
  }

  //评估版本
  bool _isEvaluation2() {
    if (HomePage.isEvaluation) {
      if (panelIndex == 2) Navigator.maybePop(context, PageType.BACK);
      else if (panelIndex == 3) Navigator.maybePop(context, PageType.FINISH);
      else Navigator.maybePop(context, PageType.BACK);
      return true;
    } else {
      return false;
    }
  }

  Widget _panel1() {
    _nfcView = NfcView(
        bleAction: "ACTION_READ_PRIVATE_KEY",
        crossFadeState: _crossFadeState,
        title: Locals.i18n(context)!.private_key_import,
        content: Locals.i18n(context)!.nfc_info,
        btnName: Locals.i18n(context)!.read_btn,
        stateCallBack: (cState, allFinish) {
          setState(() {
            _crossFadeState = cState;

            if (allFinish) {
              panelIndex = 2;
            }
          });
        });

    return _nfcView ?? const SizedBox();
  }

  Widget _panel2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Align(alignment: Alignment.topLeft, child: Text(Locals.i18n(context)!.private_key_import, style: const TextStyle(fontSize: 20, color: DefColors.textMainColor, fontWeight: FontWeight.normal))),
        const SizedBox(height: 50),
        Text("${Locals.i18n(context)!.your_private_key}: \n0x${_privateKey.length>20?_privateKey.substring(0, 20):""}...", style: const TextStyle(fontSize: 16, color: DefColors.toggleBtnColor, fontWeight: FontWeight.normal)),
        const SizedBox(height: 20),
        WidgetUtils.textInput(Locals.i18n(context)!.input_wallet_psw, tCtr1, isPsw: true),

        const SizedBox(height: 50),
        WidgetUtils.submitWidget(Locals.i18n(context)!.import_wallet, height: 45, onPressed: () {
          //调用 sdk
          importWalletByKey(callBack: () {
            setState(() {
              panelIndex = 3;
            });
            ///保存地址数据
            saveAddressData();
          });

        }),
      ],
    );
  }

  Widget _panel3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Text(Locals.i18n(context)!.import_success, style: const TextStyle(fontSize: 20, color: DefColors.textMainColor, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        const Image(height: 168, image: AssetImage('static/images/success.png'), fit: BoxFit.fitWidth,),
        const SizedBox(height: 20),

        const SizedBox(height: 20),
        WidgetUtils.submitWidget(Locals.i18n(context)!.finish, height: 45, onPressed: () {
          Navigator.maybePop(context, PageType.FINISH);
        }),
      ],
    );
  }


  ///空页面
  Widget _buildEmpty() {
    var height = MediaQuery.of(context).size.height - kBottomNavigationBarHeight;
    return SingleChildScrollView(
      child: Container(
        height: height, //double.infinity
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () {},
              child:  Image(image: AssetImage(DefICons.DEFAULT_USER_ICON), width: 70.0, height: 70.0),
            ),
            Text(Locals.i18n(context)!.app_empty, style: TextStyle(color: Colors.white, fontSize: 16,)),
          ],
        ),
      ),
    );
  }

}

