import 'package:flutter/material.dart';
import 'package:iwallet/common/style/def_style.dart';

/// Card Widget
///
/// Date: 2023-07-16
class WCardItem extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final Color? color;
  final RoundedRectangleBorder? shape;
  final double elevation;

  const WCardItem({super.key, required this.child, this.margin, this.color, this.shape, this.elevation = 5.0});

  @override
  Widget build(BuildContext context) {
    EdgeInsets? margin = this.margin;
    RoundedRectangleBorder? shape = this.shape;
    Color? color = this.color;
    margin ??= const EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0, bottom: 10.0);
    shape ??= const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0)));
    color ??= DefColors.cardBgColor;
    return Card(elevation: elevation, shape: shape, color: color, margin: margin, child: child);
  }
}
