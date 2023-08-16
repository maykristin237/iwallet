import 'package:flutter/material.dart';
import 'package:iwallet/common/localization/default_localizations.dart';
import 'package:iwallet/common/style/def_style.dart';
import 'package:iwallet/common/utils/PlatformUtils.dart';
import 'package:iwallet/common/utils/alog.dart';
import 'package:iwallet/common/utils/common_utils.dart';
import 'package:iwallet/widget/nfc_controller.dart';
import 'package:iwallet/widget/widget_utils.dart';

/// 充满的button
///
/// Date: 2023-03-20

class NfcView extends StatelessWidget {
  final bool opWrite;
  final String? nfcAction;
  final String? bleAction;
  final String? title;
  final String? content;
  final String? address;
  final String? notice;
  final Widget? child;
  final String btnName;
  final VoidCallback? onPress;

  const NfcView(
      {Key? key,
        required this.crossFadeState,
        required this.stateCallBack,
        this.opWrite = false,
        this.nfcAction,
        this.bleAction,
        this.title,
        this.content,
        this.address,
        this.notice,
        this.child,
        this.btnName = "Cancel",
        this.onPress,
      }) : super(key: key);

  ///弹出卡片
  final CrossFadeState crossFadeState;
  final void Function(CrossFadeState cState, bool allFinish) stateCallBack;
  static bool isClose = true;
  EdgeInsetsGeometry get mainPadding => !isClose ? const EdgeInsets.all(0) : const EdgeInsets.only(left: 15, right: 15);
  EdgeInsetsGeometry get cardPadding => isClose ? const EdgeInsets.all(0) : const EdgeInsets.only(left: 15, right: 15);

  @override
  Widget build(BuildContext context) {
    return NfcController.instance.isNfcModel ? _nfcViewBuild(context) : _bleViewBuild(context);
  }

  Widget _nfcViewBuild(BuildContext context) {
    return Stack(
      children: [
        child ?? Padding(
          padding: cardPadding,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(title ?? "xxx", style: const TextStyle(fontSize: 20, color: DefColors.textMainColor, fontWeight: FontWeight.normal)),

                const Image(image: AssetImage('static/images/create_title.png'), fit: BoxFit.fitWidth,),
                const SizedBox(height: 20),
                Text(content ?? "xxx", style: const TextStyle(fontSize: 13, color: DefColors.toggleBtnColor, fontWeight: FontWeight.normal)),
                const SizedBox(height: 20),

                (address != null) ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FF).withOpacity(1.0),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Text(address ?? "", style: const TextStyle(fontSize: 13, color: Color(0xFF2880FC), fontWeight: FontWeight.normal)),
                ) : const SizedBox(),

                const SizedBox(height: 20),
                Text(notice ?? "", style: const TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.normal)),

                const SizedBox(height: 20),
                WidgetUtils.submitWidget(btnName, height: 45, onPressed: () {

                  if (isClose) stateCallBack(CrossFadeState.showSecond, false); //打开

                  NfcController.instance.nfcReadOrWrite(opWrite, callBack: (bool isEnable, NfcType type) {
                    //ALog("## isEnable = $isEnable, _isClose = $_isClose");
                    if (PlatformUtils.isIOS) NfcController.instance.nfcStop();

                    if (!isEnable) {
                      /// ####只用于单独NFC重置模块
                      if (_singleResetNfcCard(context, type)) return; //只用于单独NFC重置模块:

                      /// 普通模块:
                      if (type == NfcType.unavailable) {
                        stateCallBack(CrossFadeState.showFirst, false); //关闭
                        CommonUtils.showCommonDialog(context, Locals.i18n(context)!.nfc_error);
                        return;
                      } else if (type == NfcType.empty) {
                        CommonUtils.showCommonDialog(context, Locals.i18n(context)!.empty_card,
                          showOnce: true,
                          onPressOk: () {
                            NfcController.instance.resetAndGoNext = true;
                          }, onPressCancel: () {
                            stateCallBack(CrossFadeState.showFirst, false); //关闭
                          },
                        );
                        return;
                      } else if (type == NfcType.isExist) {
                        stateCallBack(CrossFadeState.showFirst, false); //关闭
                        CommonUtils.showCommonDialog(context, Locals.i18n(context)!.wallet_is_exist);
                        return;
                      } else if (type == NfcType.resetOk) {
                        stateCallBack(CrossFadeState.showFirst, false); //关闭
                        CommonUtils.showCommonDialog(context, Locals.i18n(context)!.reset_success);
                        return;
                      } else if (type == NfcType.resetFail) {
                        stateCallBack(CrossFadeState.showFirst, false); //关闭
                        CommonUtils.showCommonDialog(context, Locals.i18n(context)!.reset_fail);
                        return;
                      }

                      NfcController.instance.nfcStop();
                      stateCallBack(CrossFadeState.showFirst, false); //关闭
                    } else {

                      ///扫描结束, 进入成功页面
                      stateCallBack(CrossFadeState.showFirst, true); //关闭
                    }
                  });
                }),
              ],
            ),
          ),
        ),

        ///卡片
        isClose ? const SizedBox() : Container(color: Colors.grey.withOpacity(0.5)),
        Padding(
          padding: cardPadding,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: _scanCard(context),
          ),
        ),
      ],
    );
  }

  Widget _scanCard(BuildContext context) {
    scanCardView() {
      return WidgetUtils.cardView([
        const SizedBox(height: 10),
        Text(Locals.i18n(context)!.ready_scan, style: const TextStyle(fontSize: 16, color: DefColors.textMainColor, fontWeight: FontWeight.normal)),
        const SizedBox(height: 20),
        const Image(height: 100, image: AssetImage('static/images/nfc_icon.png'), fit: BoxFit.fitWidth,),
        const SizedBox(height: 20),
        Text(Locals.i18n(context)!.close_to_nfc_tag, style: const TextStyle(fontSize: 16, color: DefColors.toggleBtnColor, fontWeight: FontWeight.normal)),
        const SizedBox(height: 20),

        WidgetUtils.submitWidget(Locals.i18n(context)!.app_cancel, height: 45, onPressed: () {
          ALog("## isClose = $isClose");
          NfcController.instance.nfcStop();

          if (!isClose) stateCallBack(CrossFadeState.showFirst, false); //关闭
        }),
      ], isWrap: false);
    }

    return AnimatedCrossFade(
      sizeCurve: Curves.bounceOut,
      firstChild: const SizedBox(width: double.infinity, height: 1),
      secondChild: scanCardView(),
      duration: const Duration(milliseconds: 1000),
      crossFadeState: crossFadeState,
    );
  }

  ///只用于单独NFC重置模块:
  bool _singleResetNfcCard(BuildContext context, NfcType type) {
    if (nfcAction != null && nfcAction == "ACTION_RESET_CARD") {
      if (type == NfcType.resetOk) {
        stateCallBack(CrossFadeState.showFirst, true); //关闭
      } else if (type == NfcType.resetFail) {
        stateCallBack(CrossFadeState.showFirst, false); //关闭
        CommonUtils.showCommonDialog(context, Locals.i18n(context)!.reset_fail, showOnce: true, noCancel: true, onPressOk: () {
          NfcController.instance.nfcStop();
        });
      }
      return true;
    }
    return false;
  }


  Widget _bleViewBuild(BuildContext context) {
    return Container();
  }

}
