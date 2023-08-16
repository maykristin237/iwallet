import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:iwallet/common/config/config.dart';
import 'package:iwallet/common/local/local_storage.dart';
import 'package:iwallet/common/localization/default_localizations.dart';
import 'package:iwallet/common/utils/PlatformUtils.dart';
import 'package:iwallet/common/utils/alog.dart';
import 'package:iwallet/page/home/home_page.dart';
import 'package:iwallet/page/me/about_dialog.dart' as Me;
import 'package:iwallet/redux/def_state.dart';
import 'package:iwallet/common/style/def_style.dart';
import 'package:iwallet/common/utils/common_utils.dart';
import 'package:iwallet/common/utils/navigator_utils.dart';
import 'package:iwallet/widget/w_flex_button.dart';
import 'package:iwallet/widget/nfc_controller.dart';
import 'package:iwallet/widget/nfc_widget.dart';
import 'package:iwallet/widget/widget_utils.dart';

/// 主页me
/// Date: 2023-07-18
class MyProfilePage extends StatefulWidget {

  const MyProfilePage({Key? key}) : super(key: key);

  @override
  State<MyProfilePage> createState() => MyProfilePageState();
}

class MyProfilePageState extends State<MyProfilePage> with AutomaticKeepAliveClientMixin<MyProfilePage> {

  PackageInfo _packageInfo = PackageInfo(appName: 'Unknown', packageName: 'Unknown', version: 'Unknown', buildNumber: 'Unknown', buildSignature: 'Unknown',);
  late String userName = "---";
  late List<Map> goodsList = [];

  String get coinType => (HomePage.btcAddress.isNotEmpty && HomePage.ethAddress.isNotEmpty) ? "ALL" : (HomePage.btcAddress.isNotEmpty ? "BTC" : "ETH");

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    initData();
    _initPackageInfo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> initData() async {
    userName = await LocalStorage.getString(Config.USER_NAME_KEY, def: "---");
    ALog("initData() userName= ${userName}");
    setState(() {
      userName;
    });
  }
  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  scrollToTop() {

  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double top = math.max(MediaQuery.of(context).padding.top , EdgeInsets.zero.top);
    mainPadding; //用于修改NFC view的isClose的状态.

    return isProfile ? Material(
      child: StoreBuilder<DefState>(
        builder: (context, store) {
          //User user = store.state.userInfo!;
          return Drawer(
            ///侧边栏按钮Drawer
            child: Container(
              padding: EdgeInsets.only(top: PlatformUtils.isAndroid || PlatformUtils.isIOS ? top : 0),
              ///默认背景
              //color: store.state.themeData!.primaryColor,
              color: DefColors.primaryValue,
              child: SingleChildScrollView(
                ///item 背景
                child: Material(
                  color: DefColors.primaryValue,
                  child: Column(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      //标题
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const SizedBox(width: 20),
                          const Image(width: 25,image: AssetImage('static/images/home_logo.png'), fit: BoxFit.fill),
                          const SizedBox(width: 10),
                          Text(Locals.i18n(context)!.wallet, style: const TextStyle(fontSize: 15, color: DefColors.textMainColor, fontWeight: FontWeight.bold)),
                        ],
                      ),

                      //用户头像
                      const SizedBox(height: 5),
                      SizedBox(
                        width: 62,
                        height: 62,
                        child: GestureDetector(
                          onTap: () {},
                          child: const CircleAvatar(
                            backgroundImage: AssetImage(DefICons.DEFAULT_PROFILE_PIC),
                            backgroundColor: DefColors.primaryValue,
                          ),
                        ),
                      ),
                      Text(userName, style: const TextStyle(fontSize: 20, color: DefColors.textMainColor, fontWeight: FontWeight.bold)),

                      const SizedBox(height: 18),
                      //转账模块
                      _transferView(),
                      const SizedBox(height: 10),

                      //2.我的订单入口
                      WidgetUtils.listViewBtn(png: "record.png", txt: Locals.i18n(context)!.trans_records, onTap: () {
                        NavigatorUtils.goTradeRecordPagePage(context);
                      }),
                      //3.意见反馈
                      PlatformUtils.isIOS ? const SizedBox() :
                      WidgetUtils.listViewBtn(png: "feedback.png", txt: Locals.i18n(context)!.home_reply, onTap: () {
                        String content = "";
                        CommonUtils.showEditDialog(context, Locals.i18n(context)!.home_reply, (title) {}, (res) {
                          content = res;
                        }, onPressed: (list) {
                          if (content.isEmpty) {
                            return;
                          }
                        }, titleController: TextEditingController(), valueController: TextEditingController(), needTitle: false);
                      }),
                      //4.重置
                      (!HomePage.isEvaluation) ? WidgetUtils.listViewBtn(icon: Icons.lock_reset, txt: Locals.i18n(context)!.btn_reset, onTap: () {
                        setState(() {isProfile = false;});
                        NfcController.instance.needReset = true;
                      }) : const SizedBox(),
                      //5.我的语言
                      WidgetUtils.listViewBtn(icon: Icons.language, txt: Locals.i18n(context)!.home_change_language, onTap: () {
                        CommonUtils.showLanguageDialog(context);
                      }),
                      //6.关于我们
                      WidgetUtils.listViewBtn(png: "about_us.png", txt: Locals.i18n(context)!.about_us, onTap: () {
                            //Navigator.pop(context);
                            PackageInfo.fromPlatform().then((value) {
                              //ALog(value);
                              showAboutDialog(context, value.version);
                            });
                          },
                          onLongPress: () {
                            Navigator.pop(context);
                          }),

                      //登出:
                      const SizedBox(height: 39),
                      ListTile(
                          title: WFlexButton(
                            text: Locals.i18n(context)!.exit_import,
                            color: DefColors.textTitleYellow,
                            textColor: DefColors.subTextColor,
                            fontSize: 15,
                            height: 10,
                            onPress: () {
                              _goExit();
                            },
                          ),
                          onTap: () {}),

                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ) : _panelNfc();
  }

  /// 退出:
  _goExit() async {
    //store.dispatch(LogoutAction(context));
    await LocalStorage.remove(Config.WALLET_ACCOUNT);
    HomePage.btcAddress = "";
    HomePage.ethAddress = "";
    NavigatorUtils.goWelcomePage(context);
  }

  ///弹出卡片
  bool isProfile = true;
  NfcView? nfcView;
  var crossFadeState = CrossFadeState.showFirst;
  bool get _isClose => NfcView.isClose = (crossFadeState == CrossFadeState.showFirst);
  EdgeInsetsGeometry get mainPadding => !_isClose ? const EdgeInsets.all(0) : const EdgeInsets.only(left: 15, right: 15);
  EdgeInsetsGeometry get cardPadding => _isClose ? const EdgeInsets.all(0) : const EdgeInsets.only(left: 15, right: 15);
  Widget _panelNfc() {
    nfcView = NfcView(
        opWrite: true, //有写操作
        nfcAction: "ACTION_RESET_CARD",
        crossFadeState: crossFadeState,
        title: Locals.i18n(context)!.reset_wallet,
        content: Locals.i18n(context)!.save_private_key_info,
        address: "${Locals.i18n(context)!.address}: ",
        notice: Locals.i18n(context)!.save_private_key_note,
        btnName: Locals.i18n(context)!.btn_reset,
        stateCallBack: (cState, allFinish) {

          setState(() {
            crossFadeState = cState;
            if (allFinish) {
              isProfile = true;
            }
          });

          if (allFinish) {
            CommonUtils.dialogShowing = false;
            CommonUtils.showCommonDialog(context, Locals.i18n(context)!.reset_success, showOnce: true, noCancel: true, onPressOk: () {
              NfcController.instance.nfcStop();
              _goExit();
            });
          }

        });

    return Scaffold(
        backgroundColor: DefColors.primaryValue,
        //floatingActionButton: FloatingActionButton(child: Icon(Icons.file_download), onPressed: () { }),
        appBar: AppBar(
          title: Text(Locals.i18n(context)!.btn_reset), //WTitleBar("标题"),
          leading: BackButton(onPressed: () {
            NfcController.instance.nfcStop(); //关闭蓝牙
            NfcController.instance.needReset = false;
            setState(() {
              isProfile = true;
            });
          }),
          centerTitle: true,
        ),
        body: Padding(
          padding: mainPadding,
          child: nfcView,
        ),
    );

    //return nfcView ?? const SizedBox();
  }

  Widget _transferView() {

    itemView(String png, String name, String value, {bool isExpanded = false, double fontSize = 12}) {
      itemView() => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontSize: 15, color: DefColors.textMainColor, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontSize: fontSize, color: DefColors.toggleBtnColor, fontWeight: FontWeight.normal), maxLines: 3, overflow: TextOverflow.ellipsis),
        ],
      );

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image(height: 35, image: AssetImage('static/images/$png'), fit: BoxFit.fill),
          const SizedBox(width: 10),
          isExpanded ? Expanded(child: itemView()) : itemView(),
        ],
      );
    }

    ///转账view
    return Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: WidgetUtils.cardView([
          Row(
            //mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: WidgetUtils.inWellBtn2(child: itemView(isExpanded:true, fontSize: 10, "transfer.png", Locals.i18n(context)!.transfer, Locals.i18n(context)!.transfer_info), onTap: () {
                  NavigatorUtils.goTransferPage(context, coinType: coinType);
                }),
              ),
              Expanded(
                child: WidgetUtils.inWellBtn2(child: itemView(isExpanded:true, fontSize: 10, "payment.png", Locals.i18n(context)!.payment, Locals.i18n(context)!.payment_info), onTap: () {
                  NavigatorUtils.goReceivePaymentPage(context, coinType: "ALL");
                }),
              ),
            ],
          ),
        ], isWrap: false),
      );
  }

  showAboutDialog(BuildContext context, String? versionName) {
    versionName ??= "Null";
    NavigatorUtils.showDefDialog(
        context: context,
        builder: (BuildContext context) => Me.AboutDialog(
          applicationName: Locals.i18n(context)!.app_name,
          applicationVersion: "${Locals.i18n(context)!.app_version}: ${versionName ?? ""}",
          applicationIcon: const Image(image: AssetImage(DefICons.DEFAULT_USER_ICON), width: 50.0, height: 50.0),
          applicationLegalese: "https://www.iwallet-wallet.com/",
        ));
  }

}
