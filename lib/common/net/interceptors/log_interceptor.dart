import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:iwallet/common/config/config.dart';
import 'package:iwallet/common/utils/alog.dart';

/// Log 拦截器
///
/// on 2022/7/16.
class LogsInterceptors extends InterceptorsWrapper {
  static List<Map?> sHttpResponses = [];
  static List<String?> sResponsesHttpUrl = [];

  static List<Map<String, dynamic>?> sHttpRequest = [];
  static List<String?> sRequestHttpUrl = [];

  static List<Map<String, dynamic>?> sHttpError = [];
  static List<String?> sHttpErrorUrl = [];

  @override
  onRequest(RequestOptions options, handler) async {
    if (Config.DEBUG!) {
      ALog("请求url：${options.path} ${options.method}");
      options.headers.forEach((k, v) => options.headers[k] = v ?? "");
      ALog('请求头: ' + options.headers.toString());
      if (options.data != null) {
        ALog('请求参数: ' + options.data.toString());
      }
    }
    try {
      addLogic(sRequestHttpUrl, options.path);
      var data;
      if (options.data is Map) {
        data = options.data;
      } else {
        data = Map<String, dynamic>();
      }
      var map = {
        "header:": {...options.headers},
      };
      if (options.method == "POST") {
        map["data"] = data;
      }
      addLogic(sHttpRequest, map);
    } catch (e) {
      ALog(e);
    }
    return super.onRequest(options, handler);
  }

  @override
  onResponse(Response response, handler) async {
    if (Config.DEBUG!) {
      ALog('返回参数: ' + response.toString());
    }
    if (response.data is Map || response.data is List) {
      try {
        var data = Map<String, dynamic>();
        data["data"] = response.data;
        addLogic(sResponsesHttpUrl, response.requestOptions.uri.toString());
        addLogic(sHttpResponses, data);
      } catch (e) {
        ALog(e);
      }
    } else if (response.data is String) {
      try {
        var data = Map<String, dynamic>();
        data["data"] = response.data;
        addLogic(sResponsesHttpUrl, response.requestOptions.uri.toString());
        addLogic(sHttpResponses, data);
      } catch (e) {
        ALog(e);
      }
    } else if (response.data != null) {
      try {
        String data = response.data.toJson();
        addLogic(sResponsesHttpUrl, response.requestOptions.uri.toString());
        addLogic(sHttpResponses, json.decode(data));
      } catch (e) {
        ALog(e);
      }
    }
    return super.onResponse(response, handler);
  }

  @override
  onError(DioError err, handler) async {
    if (Config.DEBUG!) {
      ALog('请求异常: ' + err.toString());
    }
    try {
      addLogic(sHttpErrorUrl, err.requestOptions.path);
      var errors = Map<String, dynamic>();
      errors["error"] = err.message;
      addLogic(sHttpError, errors);
    } catch (e) {
      ALog(e);
    }
    return super.onError(err, handler);
  }

  static addLogic(List list, data) {
    if (list.length > 20) {
      list.removeAt(0);
    }
    list.add(data);
  }
}
