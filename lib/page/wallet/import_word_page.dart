import 'package:flutter/material.dart';
import 'package:iwallet/common/localization/default_localizations.dart';
import 'package:iwallet/common/localization/string_all_base.dart';
import 'package:iwallet/common/style/def_style.dart';
import 'package:iwallet/common/utils/alog.dart';
import 'package:iwallet/common/utils/common_utils.dart';
import 'package:iwallet/common/utils/navigator_utils.dart';
import 'package:iwallet/page/home/home_page.dart';
import 'package:iwallet/widget/nfc_widget.dart';
import 'package:iwallet/widget/widget_utils.dart';

import 'm_import.dart';


/// xxx
///
/// Date: 2023-03-06

class ImportWordPage extends StatefulWidget {
  static const String sName = "importWord";

  const ImportWordPage({super.key});

  @override
  State<ImportWordPage> createState() => _ImportWordPageState();
}

class _ImportWordPageState extends State<ImportWordPage> with Import_M {

  final ScrollController scrollController = ScrollController();
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

  @override
  void initState() {
    super.initState();
    isImportWordBl = true;
  }

  @override
  Widget build(BuildContext context) {
    /// 触摸收起键盘
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {FocusScope.of(context).requestFocus(FocusNode());},
      child: Scaffold(
          backgroundColor: DefColors.primaryValue,
          appBar: AppBar(
            title: Text(Locals.i18n(context)!.import_wallet), //WTitleBar("标题"),
            leading: BackButton(onPressed: _onPressBack),
            centerTitle: true,
          ),
          body: Container(
            padding: mainPadding,
            //color: Colors.black,
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
        Text(Locals.i18n(context)!.mnemonics_import, style: const TextStyle(fontSize: 20, color: DefColors.textMainColor, fontWeight: FontWeight.normal)),
        const SizedBox(height: 40),

        Text(Locals.i18n(context)!.input_mnemonics, style: const TextStyle(fontSize: 16, color: DefColors.textMainColor, fontWeight: FontWeight.normal)),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(child: WidgetUtils.textInput(Locals.i18n(context)!.input_mnemonics_btn, tCtr0)),
            const SizedBox(width: 10,),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: WidgetUtils.submitWidget(Locals.i18n(context)!.confirm, onPressed: () {
                ALog("## _index = $_index");
                if (tCtr0.value.text.isEmpty || (words.length >= 12 && _index == -1)) return;

                String word = tCtr0.value.text.trim();
                if (_index >= 0) words[_index] = word;   //修改
                else words.add(word);                    //添加

                setState(() {
                  _index = -1;
                  tCtr0.text = "";
                });
              }, isWrap: true, left: 20, right: 20),
            ),
          ],
        ),
        const SizedBox(height: 20),

        ///显示助记词
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(words.isEmpty ? 0 : 10),
          color: Colors.white,
          child: Wrap(
            spacing: 5,
            children: _wordList(),
          ),
        ),

        const SizedBox(height: 5),
        words.isNotEmpty ? Align(
          alignment: Alignment.centerRight,
          child: WidgetUtils.submitWidget(Locals.i18n(context)!.delete_btn, onPressed: () {
            if (words.isEmpty) return;

            if (_index >= 0) words.removeAt(_index);  //删除选择的View
            else words.removeLast();                  //删除最后一个

            setState(() {
              _index = -1;
              tCtr0.text = "";
            });
          }, color: Colors.red, isWrap: true, left: 20, right: 20),
        ) : const SizedBox(),

        const SizedBox(height: 20),
        WidgetUtils.submitWidget(Locals.i18n(context)!.next, height: 45, onPressed: () {
          if (words.isEmpty) {
            CommonUtils.showCommonDialog(context, Locals.i18n(context)!.input_mnemonics);
            return;
          }

          setState(() {
            panelIndex = 2;
          });
        }),
      ],
    );

    return WidgetUtils.scrollView(context: context, controller: scrollController, child: itemView);
  }

  Widget _panel2() {
    var itemView = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(Locals.i18n(context)!.mnemonics_import, style: const TextStyle(fontSize: 20, color: DefColors.textMainColor, fontWeight: FontWeight.normal)),
        const SizedBox(height: 40),
        Text(Locals.i18n(context)!.set_psw, style: const TextStyle(fontSize: 16, color: DefColors.textMainColor, fontWeight: FontWeight.normal)),
        const SizedBox(height: 5),
        WidgetUtils.textInput(Locals.i18n(context)!.input_wallet_psw, tCtr1, isPsw: true),
        const SizedBox(height: 10),
        WidgetUtils.textInput(Locals.i18n(context)!.input_wallet_psw_again, tCtr2, isPsw: true),
        const SizedBox(height: 20),

        const SizedBox(height: 20),
        WidgetUtils.submitWidget(Locals.i18n(context)!.import_wallet, height: 45, onPressed: () {
          //调用 sdk
          importWalletByWord(callBack: () {
            setState(() {
              panelIndex = 3;

              //评估版本
              if (HomePage.isEvaluation) panelIndex = 4;
            });

          });

        }),
      ],
    );

    return WidgetUtils.scrollView(context: context, controller: scrollController, child: itemView);
  }

  Widget _panel3() {
    _nfcView = NfcView(
        opWrite: true, //有写操作
        crossFadeState: _crossFadeState,
        title: Locals.i18n(context)!.save_private_key2,
        content: Locals.i18n(context)!.save_private_key_info,
        btnName: Locals.i18n(context)!.save,
        stateCallBack: (cState, allFinish) {
          setState(() {
            _crossFadeState = cState;

            if (allFinish) {
              ///扫描结束, 进入成功页面(#### 未完成)
              panelIndex = 4;
              ///保存地址数据
              saveAddressData();
            }
          });
        });

    return _nfcView ?? const SizedBox();
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

  int _index = -1;
  List<Widget> _wordList() {

    Map<int, String> wordsMap = {};
    int size = words.length;
    for (int i = 0; i < size; i++) {
      wordsMap[i] = words[i];
    }


    return wordsMap.keys.map((index) => TextButton(
              child: Text("${index + 1}. ${wordsMap[index]!}",
              style: TextStyle(fontSize: 16, color: (_index != index) ? Colors.grey : Colors.blue, fontWeight: FontWeight.normal)),
              onPressed: () {
                tCtr0.text = wordsMap[index]!;
                setState(() => _index = index);
              },
            ))
        .toList();
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

