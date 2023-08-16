import 'package:flutter/material.dart';
import 'package:iwallet/common/localization/default_localizations.dart';
import 'package:iwallet/common/localization/string_all_base.dart';
import 'package:iwallet/common/style/def_style.dart';
import 'package:iwallet/common/utils/navigator_utils.dart';
import 'package:iwallet/page/home/home_page.dart';
import 'package:iwallet/widget/nfc_widget.dart';
import 'package:iwallet/widget/widget_utils.dart';

import 'm_create.dart';

/// xxx
///
/// Date: 2023-03-06

class CreatePage extends StatefulWidget {
  static const String sName = "create";

  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> with Create_M {

  StringAllBase get Lan => Locals.i18n(context)!;
  late var walletType = ["BTC", "ETH"], txtName = ["12", "18", "24"];
  late var walletSelected = [true, true], isSelected = [true, false, false];
  bool get isBtc => walletSelected.elementAt(0);
  bool get isEth => walletSelected.elementAt(1);

  int panelIndex = 1;

  @override
  Widget build(BuildContext context) {

    /// 触摸收起键盘
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {FocusScope.of(context).requestFocus(FocusNode());},
      child: Scaffold(
          backgroundColor: DefColors.primaryValue,
          appBar: AppBar(
            title: Text(Locals.i18n(context)!.create_wallet),
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
    if (panelIndex == 1) {
      Navigator.maybePop(context, PageType.BACK);
    } else if (panelIndex == 2) {
      setState(() => panelIndex = 1);
    } else if (panelIndex == 3) {
      setState(() => panelIndex = 2);
    } else if (panelIndex == 4) {
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
    } else if (panelIndex == 4) {
      return _panel4();
    }
    return const SizedBox();
  }

  Widget _panel1() {
    var itemView = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(Locals.i18n(context)!.select_wallet_type, style: const TextStyle(fontSize: 18, color: DefColors.textMainColor, fontWeight: FontWeight.normal)),
        WidgetUtils.toggleButtons(this, txt: walletType, isSelected: walletSelected, callBack: (v) {/*walletSelected = v;*/}),
        const SizedBox(height: 5),

        Text(Locals.i18n(context)!.input_psw, style: const TextStyle(fontSize: 18, color: DefColors.textMainColor, fontWeight: FontWeight.normal)),
        const SizedBox(height: 5),
        WidgetUtils.textInput(Locals.i18n(context)!.input_wallet_psw, tCtr1, isPsw: true),
        const SizedBox(height: 10),
        WidgetUtils.textInput(Locals.i18n(context)!.input_wallet_psw_again, tCtr2, isPsw: true),
        const SizedBox(height: 20),

        Text(Locals.i18n(context)!.select_mnemonics_num, style: const TextStyle(fontSize: 18, color: DefColors.textMainColor, fontWeight: FontWeight.normal)),
        WidgetUtils.toggleButtons(this, txt: txtName, isSelected: isSelected, callBack: (v) {/*isSelected = v;*/}),

        const SizedBox(height: 20),
        WidgetUtils.submitWidget(Locals.i18n(context)!.confirm, height: 45, onPressed: () {
          //调用 sdk
          createWallet(isBtc, callBack: () {
            setState(() {
              panelIndex = 2;
            });

          });
        }),
      ],
    );

    return WidgetUtils.scrollView(context: context, controller: scrollController, child: itemView);
  }

  Widget _panel2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(Locals.i18n(context)!.save_mnemonics, style: const TextStyle(fontSize: 20, color: DefColors.textMainColor, fontWeight: FontWeight.normal)),
        const SizedBox(height: 20),
        Text(Locals.i18n(context)!.save_mnemonics_info, style: const TextStyle(fontSize: 16, color: DefColors.textMainColor, fontWeight: FontWeight.normal)),
        const SizedBox(height: 20),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(10),
          color: DefColors.textBgColor,
          child: Wrap(
            spacing: 20,
            children: _wordList(),
          ),
        ),

        const SizedBox(height: 20),
        WidgetUtils.submitWidget(Locals.i18n(context)!.next, height: 45, onPressed: () {
          setState(() {
            panelIndex = 3;

            //评估版本
            if (HomePage.isEvaluation) panelIndex = 4;
          });

        }),
      ],
    );
  }

  Widget _panel3() {
    nfcView = NfcView(
        opWrite: true, //有写操作
        bleAction: "ACTION_WRITE_PRIVATE_KEY",
        crossFadeState: crossFadeState,
        title: Locals.i18n(context)!.save_private_key,
        content: Locals.i18n(context)!.save_private_key_info,
        address: "${Locals.i18n(context)!.address}: \n$address",
        notice: Locals.i18n(context)!.save_private_key_note,
        btnName: Locals.i18n(context)!.save,
        stateCallBack: (cState, allFinish) {
          setState(() {
            crossFadeState = cState;

            if (allFinish) {
              panelIndex = 4;
              ///保存地址数据
              saveAddressData();
            }
          });
        });

    return nfcView ?? const SizedBox();
  }

  Widget _panel4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Text(Locals.i18n(context)!.save_private_key_success, style: const TextStyle(fontSize: 20, color: DefColors.textMainColor, fontWeight: FontWeight.bold)),
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

  List<Widget> _wordList() {
    List<Widget>  list = [];
    if(mnemonics.isEmpty) return list;

    List<String> words = mnemonics.split(" ");
    for (String word in words) {
      list.add(Text(word, style: const TextStyle(fontSize: 16, color: DefColors.textMainColor, fontWeight: FontWeight.normal)));
    }

    return list;
  }


  ///空页面
  Widget _buildEmpty() {
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
              child:  Image(image: AssetImage(DefICons.DEFAULT_USER_ICON), width: 70.0, height: 70.0),
            ),
            Text(Locals.i18n(context)!.app_empty, style: TextStyle(color: Colors.white, fontSize: 16,)),
          ],
        ),
      ),
    );
  }

}

