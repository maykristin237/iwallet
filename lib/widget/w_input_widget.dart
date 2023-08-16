import 'package:flutter/material.dart';
import 'package:iwallet/common/style/def_style.dart';

/// 带图标的输入框
class WInputWidget extends StatefulWidget {
  final bool obscureText;
  final bool isWrap;
  final String? hintText;
  final IconData? iconData;
  final ValueChanged<String>? onChanged;
  final double radius;
  final TextStyle? textStyle;
  final TextInputType? textInputType;
  final TextEditingController? controller;

  const WInputWidget(
      {Key? key,
      this.isWrap = false,
      this.hintText,
      this.iconData,
      this.onChanged,
      this.radius = 25,
      this.textStyle,
      this.controller,
      this.obscureText = false,
      this.textInputType})
      : super(key: key);

  @override
  State<WInputWidget> createState() => _WInputWidgetState();
}

/// State for [WInputWidget] widgets.
class _WInputWidgetState extends State<WInputWidget> {
  late TextStyle mTextStyle;

  @override
  Widget build(BuildContext context) {
    double? fSize = widget.textStyle?.fontSize ?? 16.0;

    return Container(
      decoration: BoxDecoration(
        color: DefColors.cardBgColor.withOpacity(1.0),
        borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
      ),
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        obscureText: widget.obscureText,
        style: widget.textStyle,
        keyboardType: widget.textInputType,
        decoration: InputDecoration(
          isCollapsed: true,
          contentPadding: EdgeInsets.all(widget.isWrap ? 0.0 : 12.0),
          border: InputBorder.none,
          hintText: widget.hintText,
          hintStyle: TextStyle(fontSize: fSize, color: const Color(0xFF999999)),
        ),
        cursorColor: Colors.blue,
        cursorWidth: 2,
        cursorRadius: const Radius.circular(5),
      ),
    );

  }
}
