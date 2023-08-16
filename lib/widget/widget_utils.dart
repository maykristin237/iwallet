import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iwallet/common/style/def_style.dart';
import 'package:iwallet/widget/w_input_widget.dart';

class WidgetUtils {

  /// 滑动
  static Widget scrollView({required BuildContext context, required ScrollController controller, required Widget child}) {
    return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad}),
          child: SingleChildScrollView(
            controller: controller,
            scrollDirection: Axis.vertical,
            child: child,
          ),
        );
  }

  ///卡片
  static Widget cardView(List<Widget> children, {bool isWrap = true, bool shadow = true, bool borderSide = false, CrossAxisAlignment alignment = CrossAxisAlignment.center, EdgeInsetsGeometry padding = const EdgeInsets.all(8.0)}) {
    if (!isWrap) children.add(const SizedBox(width: double.infinity, height: 1));

    return Card(
      elevation: shadow ? 3 : 0,
      color: DefColors.cardBgColor,
      shadowColor: Colors.black87,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: borderSide ? BorderSide(width: 1, color: DefColors.textTitleYellow) : BorderSide.none),
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: alignment,
          children: children,
        ),
      ),
    );
  }

  ///姓别选择器
  static Widget toggleButtons(State context, {var txt = const ["12个", "18个"], List<bool> isSelected = const [true, false], required void Function(List<bool> select) callBack}) {
    itemView() {
      List<Widget> list = [];
      for (String t in txt) {
        list.add(Text(t, textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13)));
      }
      return list;
    }

    return Container(
      padding: EdgeInsets.all(5),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(9.0), bottomRight: Radius.circular(9.0)),
      ),

      child: ToggleButtons(
        constraints: const BoxConstraints(minWidth: 80.0, minHeight: 36.0),
        color: DefColors.toggleBtnColor,
        borderColor: DefColors.toggleBtnColor,
        selectedBorderColor: DefColors.toggleBtnColor,
        selectedColor: Colors.white,
        fillColor: DefColors.textTitleYellow,
        borderWidth: 1,
        borderRadius: BorderRadius.circular(8),
        isSelected: isSelected,
        onPressed: (value) => { context.setState(() { isSelected = isSelected.map((e) => false).toList(); isSelected[value] = true; callBack(isSelected);}) },
        children: itemView(),
      ),
    );
  }

  /// 提交按钮 1
  static Widget submitWidget(String btnName, {required Function() onPressed, bool isWrap = false, Color color = DefColors.textTitleYellow, double? height, double top = 20, double bottom = 20, double left = 0, double right = 0, Function()? onLongPress}) {
    return Container(
      margin: isWrap ? null : EdgeInsets.only(left: 36, right: 36, top: top, bottom: bottom),
      height: height,
      width: isWrap ? null : double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: ButtonStyleButton.allOrNull<Color>(color),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(!isWrap || (left > 0 && right > 0) ? EdgeInsets.only(left: left, top: 6, right: right, bottom: 6) : const EdgeInsets.all(6.0)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
        ),
        onPressed: onPressed,
        onLongPress: onLongPress,
        child: Text(btnName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: DefColors.subTextColor), maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  /// InWell按钮
  static Widget inWellBtn({
    String txt="", String linkID="",
    Widget? child,
    TextStyle? textStyle = const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
    EdgeInsetsGeometry padding = const EdgeInsets.only(left: 15, right: 15, top: 6, bottom: 6),
    void Function()? onTap,
  }) {
    return Material(
      color: Colors.transparent, //transparent
      child: InkWell(
        hoverColor: const Color(0x50009966),
        splashColor: const Color(0xFF009966),
        highlightColor: const Color(0xFF009966),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        onTap: onTap,
        child: child ?? Padding(
          padding: padding,
          child: Text(txt, textAlign: TextAlign.center, style: textStyle),
        ),
      ),
    );
  }

  /// InkWell 按钮
  static Widget inWellBtn2({String txt = "", Widget? child, Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      splashColor: DefColors.textTitleYellow,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: child ?? Text(txt, textAlign: TextAlign.left, style: const TextStyle(color: DefColors.textMainColor, fontWeight: FontWeight.normal,fontSize: 13)),
      ),
    );
  }

  /// InkWell 按钮
  static Widget underLineBtn({String txt = "", Widget? child, Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      splashColor: DefColors.textTitleYellow,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: child ?? Text(txt, textAlign: TextAlign.left, style: const TextStyle(fontSize: 13, color: DefColors.textTitleYellow,fontWeight: FontWeight.normal, decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.solid, decorationThickness: 1,)),
      ),
    );
  }

  /// Text 按钮
  static textBtn(String txt, {double? fontSize, bool txtBold = false, Function()? onPressed, Function()? onLongPress}) {
    return TextButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      child: Text(txt, style: TextStyle(fontSize: fontSize, fontWeight: txtBold ? FontWeight.bold : FontWeight.normal, color: DefColors.textTitleYellow)),
    );
  }

  ///带icon的列表 按钮
  static listViewBtn({String? png, IconData? icon, String? txt, Color color = DefColors.cardBgColor, Function()? onTap, Function()? onLongPress}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 10, right: 10),
      child: ListTile(
        tileColor: color,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                png != null ? Image.asset('static/images/$png', width: 18) : const SizedBox(),
                icon != null ? Icon(icon, size: 22, color: DefColors.textMainColor) : const SizedBox(),
                const SizedBox(width: 10),
                Text(txt ?? "", style: const TextStyle(fontSize: 15, color: DefColors.toggleBtnColor, fontWeight: FontWeight.bold)),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, size: 20, color: DefColors.toggleBtnColor),
          ],
        ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }

  ///输入框
  static Widget textInput(String hintText, final TextEditingController controller, {bool isPsw = false, bool isWrap = false, TextInputType inputType = TextInputType.text, Function(String)? onChanged}) {
    return Padding(
        padding: const EdgeInsets.only(left: 0, right: 0, top: 5),
        child: WInputWidget(
          textStyle: const TextStyle(fontSize: 16, color: Colors.black),
          controller: controller,
          hintText: hintText,
          isWrap: isWrap,
          obscureText: isPsw,
          textInputType: inputType,
          onChanged: onChanged,
        ));
  }

  ///下拉框
  static Widget dropdownBtn(List<String> info, List<int> values, int value, String hintText, Function onChan) {
    List<DropdownMenuItem<int>> buildItems(List<String> info, List<int> colors) {
      return colors.map((e) => DropdownMenuItem<int>(
        value: e,
        child: Text(info[colors.indexOf(e)], style: const TextStyle(fontSize: 15, color: Colors.grey)),
      ),
      ).toList();
    }

    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      margin: const EdgeInsets.only(top: 12, bottom: 12, right: 15),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F8F8),
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      child: DropdownButton<int>(
          isExpanded: false,
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          focusColor: Colors.transparent,
          value: value,
          underline: const SizedBox(),
          elevation: 1,
          dropdownColor: DefColors.primaryColor,
          icon: const Icon(Icons.expand_more, size: 20, color: DefColors.toggleBtnColor),
          items: buildItems(info, values),
          onChanged: (v) => onChan(v)),
    );
  }

  /// 滑块选择器
  static Widget sliderView(State context, {double curValue = 0, double minValue = 0, double maxValue = 100, int divisions = 10, required void Function(double select) callBack}) {
    return Slider(
        value: curValue,
        min: minValue,
        max: maxValue,
        divisions: divisions,
        activeColor: DefColors.textTitleYellow,
        inactiveColor: DefColors.textTitleYellow.withAlpha(99),
        onChanged: (value) {
          context.setState(() {
            curValue = value;
            callBack(value);
          });
        });
  }

}