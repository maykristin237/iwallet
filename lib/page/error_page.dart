import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iwallet/common/net/interceptors/log_interceptor.dart';
import 'package:iwallet/common/style/def_style.dart';
import 'package:iwallet/common/utils/alog.dart';

class ErrorPage extends StatefulWidget {
  final String errorMessage;
  final FlutterErrorDetails details;

  const ErrorPage(this.errorMessage, this.details, {super.key});

  @override
  ErrorPageState createState() => ErrorPageState();
}

class ErrorPageState extends State<ErrorPage> {
  static List<Map<String, dynamic>?> sErrorStack = [];
  static List<String?> sErrorName = [];

  final TextEditingController textEditingController =
      TextEditingController();

  addError(FlutterErrorDetails details) {
    try {
      var map = Map<String, dynamic>();
      map["error"] = details.toString();
      LogsInterceptors.addLogic(
          sErrorName, details.exception.runtimeType.toString());
      LogsInterceptors.addLogic(sErrorStack, map);
    } catch (e) {
      ALog(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width;
    return Container(
      color: DefColors.primaryValue,
      child: Center(
        child: Container(
          alignment: Alignment.center,
          width: width,
          height: width,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(30),
            gradient:
                RadialGradient(tileMode: TileMode.mirror, radius: 0.1, colors: [
              Colors.white.withAlpha(10),
              DefColors.primaryValue.withAlpha(100),
            ]),
            borderRadius: BorderRadius.all(Radius.circular(width / 2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Image(
                  image: AssetImage(DefICons.DEFAULT_USER_ICON),
                  width: 90.0,
                  height: 90.0),
              const SizedBox(
                height: 11,
              ),
              const Material(
                color: DefColors.primaryValue,
                child: Text(
                  "Error Occur",
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: ButtonStyleButton.allOrNull<Color>(
                          DefColors.white.withAlpha(100)),
                    ),
                    onPressed: () {

                      if (true) {
                        Navigator.of(context).pop();
                        return;
                      }
                    },
                    child: Text("Report"),
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  TextButton(
                      style: ButtonStyle(
                        backgroundColor: ButtonStyleButton.allOrNull<Color>(
                            Colors.white.withAlpha(100)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Back")),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
