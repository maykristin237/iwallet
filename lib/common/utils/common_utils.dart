import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:iwallet/common/config/config.dart';
import 'package:iwallet/common/local/local_storage.dart';
import 'package:iwallet/common/localization/default_localizations.dart';
import 'package:iwallet/common/utils/alog.dart';
import 'package:iwallet/redux/def_state.dart';
import 'package:iwallet/redux/locale_redux.dart';
import 'package:iwallet/common/style/def_style.dart';
import 'package:iwallet/common/utils/navigator_utils.dart';
import 'package:iwallet/page/issue/issue_edit_dIalog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:redux/redux.dart';

/// 通用逻辑
/// Date: 2023-07-16

typedef StringList = List<String>;

class CommonUtils {
  static Locale? curLocale;

  ///时间戳转时间格式
  static DateTime timestampToDate(int timestamp) {
    DateTime dateTime = DateTime.now();

    ///如果是十三位时间戳返回这个
    if (timestamp.toString().length == 10) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    } else if (timestamp.toString().length == 13) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else if (timestamp.toString().length == 16) {
      ///如果是十六位时间戳
      dateTime = DateTime.fromMicrosecondsSinceEpoch(timestamp);
    }
    return dateTime;
  }

  ///时间戳转日期
  ///[timestamp] 时间戳
  ///[onlyNeedDate ] 是否只显示日期 舍去时间
  static String timestampToDateStr(int timestamp, {onlyNeedDate = false}) {
    DateTime dataTime = timestampToDate(timestamp);
    String dateTime = dataTime.toString();

    ///去掉时间后面的.000
    dateTime = dateTime.substring(0, dateTime.length - 4);
    if (onlyNeedDate) {
      List<String> dataList = dateTime.split(" ");
      dateTime = dataList[0];
    }
    return dateTime;
  }

  static getThemeData(Color color) {
    int lightValue = 0xFFFFFFFF;
    SystemUiOverlayStyle themeStyle = DefColors.primaryIntValue == lightValue ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light;

    return ThemeData(
      primaryColor: DefColors.primaryColor,
      primarySwatch: color as MaterialColor?,
      appBarTheme: AppBarTheme(
        elevation: 0.5,
        systemOverlayStyle: themeStyle.copyWith(
          systemNavigationBarContrastEnforced: true,
          systemStatusBarContrastEnforced: true,
          systemNavigationBarColor: color,
          statusBarColor: color,
          systemNavigationBarDividerColor: color.withAlpha(199),
        ),
      ),
    );
  }

  static showLanguageDialog(BuildContext context) {
    StringList list = [
      Locals.i18n(context)!.home_language_default,
      Locals.i18n(context)!.home_language_zh,
      Locals.i18n(context)!.home_language_en,
      //Locals.i18n(context)!.home_language_pt,
    ];
    CommonUtils.showCommitOptionDialog(context, list, (index) {
      CommonUtils.changeLocale(StoreProvider.of<DefState>(context), index);
      LocalStorage.save(Config.LOCALE, index.toString());
    }, underLine: true);
  }

  /// 切换语言
  static changeLocale(Store<DefState> store, int index) {
    Locale? locale = store.state.platformLocale;
    if (Config.DEBUG! && store.state.platformLocale != null) {
      ALog(store.state.platformLocale);
    }
    switch (index) {
      case 1:
        locale = const Locale('zh', 'CN');
        break;
      case 2:
        locale = const Locale('en', 'US');
        break;
      case 3:
        locale = const Locale('pt','PT');
        break;
    }
    curLocale = locale;
    store.dispatch(RefreshLocaleAction(locale));
  }

  static Future<void> showLoadingDialog(BuildContext context) {
    return NavigatorUtils.showDefDialog(
        context: context,
        builder: (BuildContext context) {
          return Material(
              color: Colors.transparent,
              child: WillPopScope(
                onWillPop: () => Future.value(false),
                child: Center(
                  child: Container(
                    width: 200.0,
                    height: 200.0,
                    padding: const EdgeInsets.all(4.0),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      //用一个BoxDecoration装饰器提供背景图片
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SpinKitCubeGrid(color: DefColors.white),
                        const SizedBox(height: 10.0),
                        Text(Locals.i18n(context)!.loading_text, style: DefConstant.normalTextWhite),
                        InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onLongPress: () => Navigator.pop(context),
                          child: const SizedBox(width: 50, height: 28),
                        ),
                      ],
                    ),
                  ),
                ),
              ));
        });
  }

  static Future<void> showEditDialog(
    BuildContext context,
    String dialogTitle,
    ValueChanged<String>? onTitleChanged,
    ValueChanged<String> onContentChanged,
    {onPressed,
    TextEditingController? titleController,
    TextEditingController? valueController,
    bool needTitle = true,
  }) {
    return NavigatorUtils.showDefDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: IssueEditDialog(
              dialogTitle,
              onTitleChanged,
              onContentChanged,
              onPressed,
              titleController: titleController,
              valueController: valueController,
              needTitle: needTitle,
            ),
          );
        });
  }

  ///列表item dialog
  static Future<void> showCommitOptionDialog(
    BuildContext context,
    StringList? commitMaps,
    ValueChanged<int> onTap, {
    underLine = false,
    width = 250.0,
    //height = 400.0,
    List<Color>? colorList,
  }) {

    Widget _submitWidget(String btnName, {double fontSize = 16, double tpHeight = 12, int maxLines = 1, double radius = 25, bool isWrap = false, double top = 10, double bottom = 10, bool underLine = false, required onPressed}) {
      return Container(
        margin: isWrap ? null : EdgeInsets.only(left: 0, right: 0, top: top, bottom: bottom),
        //height: isWrap ? null : null,
        width: isWrap ? null : double.infinity,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: ButtonStyleButton.allOrNull<Color>(Theme.of(context).primaryColor), //DefColors.textTitleYellow
            //textStyle: ButtonStyleButton.allOrNull<TextStyle>(TextStyle(color: textColor)),
            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(isWrap ? const EdgeInsets.all(6.0) : EdgeInsets.only(left: 10, top: tpHeight, right: 10, bottom: tpHeight)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius))),
          ),
          onPressed: onPressed,
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(btnName, textAlign: TextAlign.center, style: TextStyle(fontSize: fontSize, color: Colors.black), maxLines: maxLines, overflow: TextOverflow.ellipsis),
              if (underLine) Container(width: double.infinity, height: 1, color: Colors.grey.withOpacity(0.3), margin: EdgeInsets.only(top: 6),),
            ],
          ),
        ),
      );
    }

    return NavigatorUtils.showDefDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: Container(
              width: width,
              height: commitMaps!.length > 10 ? MediaQuery.of(context).size.height * 1 / 2 : null,
              padding: const EdgeInsets.all(4.0),
              margin: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                //用一个BoxDecoration装饰器提供背景图片
                border: Border.all(color: DefColors.textTitleYellow, width: 2),
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad}),
                child: ListView.builder(
                    //physics: BouncingScrollPhysics(), //NeverScrollableScrollPhysics()
                    shrinkWrap: true,
                    itemCount: commitMaps.length,
                    itemBuilder: (context, index) {
                      return _submitWidget(commitMaps[index], underLine: false, isWrap: true, radius: 0.0, maxLines: 1, fontSize: 14, onPressed: () {
                        Navigator.pop(context);
                        onTap(index);
                      });
                    }),
              ),
            ),
          );
        });
  }

  ///通用弹窗
  static bool dialogShowing = false;
  static showCommonDialog(BuildContext context, String contentMsg, {bool showOnce = false, Function()? onPressOk, Function()? onPressCancel, bool closeParent = false, bool noCancel = false, bool noYes = false, bool autoDisappear = false, int disTime = 1}) {
    if (showOnce) {
      if (dialogShowing) return;
      dialogShowing = true;
    } else {
      dialogShowing = false;
    }

    //自动消失
    if (autoDisappear && disTime < 10) {
      Future.delayed(Duration(seconds: disTime), () {
        // setState(() {
        // });
        Navigator.pop(context);
      });
    }

    return NavigatorUtils.showDefDialog(
        context: context,
        useSafeArea: !autoDisappear,
        barrierDismissible: !autoDisappear && !closeParent && !showOnce,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: DefColors.primaryColor,
            title: Text(Locals.i18n(context)!.message, style: const TextStyle(color: DefColors.textMainColor)),
            content: Text(contentMsg, style: const TextStyle(color: DefColors.textMainColor)),
            actions: <Widget>[
              noCancel
                  ? const SizedBox()
                  : TextButton(
                      onPressed: () {
                        dialogShowing = false;
                        if (!autoDisappear) Navigator.pop(context);
                        if (closeParent) Navigator.pop(context);
                        onPressCancel?.call();
                      },
                      child: Text(Locals.i18n(context)!.app_cancel, style: const TextStyle(color: DefColors.textMainColor))),
              noYes
                  ? const SizedBox()
                  : TextButton(
                      onPressed: () {
                        //launch(Address.updateUrl);
                        dialogShowing = false;
                        if (!autoDisappear) Navigator.pop(context);
                        if (closeParent) Navigator.pop(context);
                        onPressOk?.call();
                      },
                      child: Text(Locals.i18n(context)!.app_ok, style: const TextStyle(color: DefColors.textMainColor))),
            ],
          );
        });
  }

}
