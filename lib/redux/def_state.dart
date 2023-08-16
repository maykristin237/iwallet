import 'package:flutter/material.dart';
import 'package:iwallet/redux/theme_redux.dart';
import 'package:iwallet/redux/locale_redux.dart';

/**
 * Redux全局State
 * Date: 2023-07-16
 */

///全局Redux store 的对象，保存State数据
class DefState {
  ///主题数据
  ThemeData? themeData;
  ///语言
  Locale? locale;
  ///当前手机平台默认语言
  Locale? platformLocale;

  ///构造方法
  DefState({this.themeData, this.locale});
}

///创建 Reducer
DefState appReducer(DefState state, action) {
  return DefState(
    themeData: themeDataReducer(state.themeData, action),
    locale: LocaleReducer(state.locale, action),
  );
}
