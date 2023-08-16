import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:iwallet/app.dart';
import 'package:iwallet/page/error_page.dart';

void main() {

  runZonedGuarded(() {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      Zone.current.handleUncaughtError(details.exception, details.stack!);
      return ErrorPage("${details.exception.toString()}\n ${details.stack.toString()}", details);
    };

    runApp(const FlutterReduxApp());
  }, (Object obj, StackTrace stack) { });
}


/// MyApp:
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
