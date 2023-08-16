import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:iwallet/common/config/config.dart';
import 'package:iwallet/common/local/local_storage.dart';
import 'package:iwallet/common/localization/default_localizations.dart';
import 'package:iwallet/common/utils/common_utils.dart';
import 'package:iwallet/page/home/home_page.dart';
import 'package:iwallet/redux/def_state.dart';
import 'package:iwallet/common/style/def_style.dart';
import 'package:iwallet/common/utils/navigator_utils.dart';
import 'package:iwallet/widget/widget_utils.dart';

/// 欢迎页
/// Date: 2023-07-16
///

class WelcomePage extends StatefulWidget {
  static const String sName = "/";
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {
  bool hadInit = false;

  String text1 = "", text2 = "";
  bool start = false;
  double fontSize = 39;
  AnimationController? anController;

  bool get newAccount => (HomePage.btcAddress.isEmpty || HomePage.btcAddress.isEmpty);

  @override
  void initState() {
    super.initState();
    anController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    anController?.forward();
  }

  @override
  void dispose() {
    anController?.dispose();
    super.dispose();
  }

  _onPageBack(PageType type) async {
    if (type == PageType.BACK) {
      if (!anController!.isAnimating) {
        anController?.forward(from: 0);
      }
    } else if (type == PageType.FINISH) {
      NavigatorUtils.goHome(context, fromLogin: false);
    }
  }

  initAccount() async {
    //读取
    String? account = await LocalStorage.get(Config.WALLET_ACCOUNT);
    Map map = json.decode(account ?? "{}");
    HomePage.btcAddress = map["btcAddress"] ?? "";
    HomePage.ethAddress = map["ethAddress"] ?? "";
    //是否评估版本
    String? evaluation = await LocalStorage.get(Config.EVALUATION);
    Map mapEva = json.decode(evaluation ?? "{}");
    HomePage.isEvaluation = mapEva["isEvaluation"] ?? false;
    HomePage.evaluationPw = mapEva["evaluationPw"] ?? "";

    if (newAccount) {
      setState(() {
        text1 = Locals.i18n(context)!.welcome_title;
        text2 = Locals.i18n(context)!.welcome_title;
        start = true;
      });
    } else {
      NavigatorUtils.goHome(context, fromLogin: false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (hadInit) {
      return;
    }
    hadInit = true;

    initAccount();
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<DefState>(
      builder: (context, store) {
        double size = 200;
        return Material(
          child: Stack(
            children: <Widget>[
              Container(color: DefColors.primaryValue),

              Align(
                alignment: const Alignment(0.0, -0.3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    start ? _rainbowText([text1, text2]) : const SizedBox(),
                    const Image(height: 268, image: AssetImage('static/images/welcome.png'), fit: BoxFit.fitWidth,),

                    _allPanels(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget animationView(int count, int index, {Widget? mChild}) {
    return AnimatedBuilder(
      animation: anController!,
      builder: (BuildContext context, Widget? child) {

        final Animation<double> animation = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Interval((1 / count) * index, 1.0, curve: Curves.fastOutSlowIn))).animate(anController!);
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(0.0, 30 * (1.0 - animation.value), 0.0),
            child: mChild,
          ),
        );
      },
    );
  }

  bool _isMainPanel = true;
  Widget _allPanels() {
    return _isMainPanel ? _mainPanel() : _importKeyPanel();
  }

  Widget _mainPanel() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: start ? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          animationView(2, 0,
            mChild: WidgetUtils.submitWidget(Locals.i18n(context)!.create_wallet, height: 48, onPressed: () {
              NavigatorUtils.goCreatePage(context).then((val) => (val != null) ? _onPageBack(val) : null);
            }),
          ),
          animationView(2, 1,
            mChild: WidgetUtils.submitWidget(Locals.i18n(context)!.import_wallet, height: 48, onPressed: () {
              setState(() {
                _isMainPanel = false;
                anController?.forward(from: 0);
              });
            }),
          ),

          animationView(2, 2,
            mChild: InkWell(
              onTap: () {
                CommonUtils.showLanguageDialog(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(Locals.i18n(context)!.switch_language, style: const TextStyle(fontSize: 12, color: Colors.black)),
              ),
            ),
          ),

        ],
      ): const SizedBox(),
    );
  }

  Widget _importKeyPanel() {
    return Padding(
      //alignment: const Alignment(0.0, 0.5),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: start ? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          animationView(3, 0, mChild: WidgetUtils.submitWidget(Locals.i18n(context)!.use_private_key_import, height: 45, top: 0, onPressed: () {
            NavigatorUtils.goImportKeyPage(context).then((val) => (val != null) ? _onPageBack(val) : null);
          })),
          animationView(3, 1, mChild: WidgetUtils.submitWidget(Locals.i18n(context)!.use_mnemonics_import, height: 45, top: 0, onPressed: () {
            NavigatorUtils.goImportWordPage(context).then((val) => (val != null) ? _onPageBack(val) : null);
          })),
          animationView(3, 2,
              mChild: WidgetUtils.inWellBtn2(txt: Locals.i18n(context)!.back, onTap: () {
                setState(() {
                  _isMainPanel = true;
                  anController?.forward(from: 0);
                });
              }),
          ),

        ],
      ): const SizedBox(),
    );
  }

  Widget _rainbowText(List<String> texts) {
    const colorizeColors = [
      Color(0xffE0BD86),
      // Colors.yellow,
      Colors.blue,
      Colors.purple,
      Colors.red,
    ];

    const colorizeTextStyle = TextStyle(
      fontSize: 29.0,
      fontWeight: FontWeight.normal,
    );
    return SizedBox(
      //width: 320.0,
      child: AnimatedTextKit(
        animatedTexts: texts.map((txt) => ColorizeAnimatedText(
          txt,
          textAlign: TextAlign.center,
          textStyle: colorizeTextStyle,
          colors: colorizeColors,
        )).toList(),
        pause: const Duration(milliseconds: 500),
        isRepeatingAnimation: false,
        repeatForever: false,
        onFinished: () {

        },
      ),
    );
  }
}
