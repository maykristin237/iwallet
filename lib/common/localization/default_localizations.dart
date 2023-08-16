import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iwallet/common/localization/string_all_base.dart';
import 'package:iwallet/common/localization/string_en.dart';
import 'package:iwallet/common/localization/string_pt.dart';
import 'package:iwallet/common/localization/string_zh.dart';

///自定义多语言实现
class Locals {
  final Locale locale;

  Locals(this.locale);

  ///根据不同 locale.languageCode 加载不同语言对应
  static final Map<String, StringAllBase> _localizedValues = {
    'en': StringEn(),
    'zh': StringZh(),
    'pt': StringPt(),
  };

  StringAllBase? get currentLocalized {
    if (_localizedValues.containsKey(locale.languageCode)) {
      return _localizedValues[locale.languageCode];
    }
    return _localizedValues["en"];
  }

  ///通过 Localizations 加载当前的
  static Locals? of(BuildContext context) {
    return Localizations.of(context, Locals);
  }

  ///通过 Localizations 加载当前的
  static StringAllBase? i18n(BuildContext context) {
    return (Localizations.of(context, Locals) as Locals).currentLocalized;
  }
}
