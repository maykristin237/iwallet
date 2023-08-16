import 'package:flutter/material.dart';

/// 充满的button
///
/// Date: 2023-07-16

class WFlexButton extends StatelessWidget {
  final String? text;
  final Color? color;
  final Color textColor;
  final VoidCallback? onPress;

  final bool underLine;
  final double radius;
  final double height;
  final double fontSize;
  final int maxLines;
  final MainAxisAlignment mainAxisAlignment;

  const WFlexButton(
      {Key? key,
      this.text,
      this.color,
      this.textColor = Colors.black,
      this.onPress,
      this.fontSize = 20.0,
      this.mainAxisAlignment = MainAxisAlignment.center,
      this.maxLines = 1,
      this.height = 12.0,
      this.radius = 25.0,
      this.underLine = false,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
          backgroundColor: ButtonStyleButton.allOrNull<Color>(
            color,
          ),
          textStyle: ButtonStyleButton.allOrNull<TextStyle>(TextStyle(color: textColor)),
          padding: ButtonStyleButton.allOrNull<EdgeInsetsGeometry>(
            EdgeInsets.only(left: 6.0, top: height, right: 6.0, bottom: height),
          ),
          //shadowColor: MaterialStateProperty.all(Colors.red),
          //side: MaterialStateProperty.all(const BorderSide(width: 1,color: Color(0xffCAD0DB))),//边框
          //shape: MaterialStateProperty.all(BeveledRectangleBorder(borderRadius: BorderRadius.circular(20))),
          //shape: MaterialStateProperty.all(CircleBorder(BorderSide(width: 1.0))),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            //side: BorderSide(color: color!),
          )),
        ),
        child: Flex(
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: MainAxisSize.min,
          direction: Axis.vertical,
          children: <Widget>[
            // Expanded(
            //   child: Text(text!,
            //       style: TextStyle(fontSize: fontSize, color: textColor, fontWeight: FontWeight.w500),
            //       textAlign: TextAlign.center,
            //       maxLines: maxLines,
            //       overflow: TextOverflow.ellipsis),
            // )
            Text(text!,
                style: TextStyle(fontSize: fontSize, color: textColor),  //, fontWeight: FontWeight.w500
                textAlign: TextAlign.center,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis),

            if (underLine) Container(width: double.infinity, height: 1, color: Colors.grey.withOpacity(0.3), margin: EdgeInsets.only(top: 6),),

          ],
        ),
        onPressed: () {
          onPress?.call();
        });
  }
}
