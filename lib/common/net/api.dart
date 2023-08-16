import 'package:connectivity/connectivity.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:iwallet/common/net/code.dart';
import 'dart:collection';
import 'package:iwallet/common/net/interceptors/token_interceptor.dart';
import 'package:iwallet/common/net/result_data.dart';
import 'package:iwallet/common/utils/alog.dart';

///http请求
class HttpManager {

  // 使用默认配置
  final Dio _dio = Dio();
  final TokenInterceptors _tokenInterceptors = TokenInterceptors();

  HttpManager() {
    _dio.interceptors.add(_tokenInterceptors);
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (cert, host, port) => true;
    };
  }

  ///发起网络请求
  Future<ResultData?> netFetch(url, params, Map<String, dynamic>? header, Options? option, {context, noTip = false}) async {

    Map<String, dynamic> headers = HashMap();
    if (header != null) {
      headers.addAll(header);
    }

    if (option != null) {
      option.headers = headers;
    } else {
      option = Options(method: "get");
      option.headers = headers;
      option.receiveTimeout = 20000;
    }

    resultError(DioError e) async {
      Response? errorResponse;
      if (e.response != null) {
        errorResponse = e.response;
      } else {
        errorResponse = Response(statusCode: 666, requestOptions: RequestOptions(path: url));
      }
      //1.network error
      var conResult = await Connectivity().checkConnectivity();
      if (conResult == ConnectivityResult.none) {
        errorResponse?.statusCode = Code.NETWORK_ERROR;
      }
      //2.network timeout
      if (e.type == DioErrorType.connectTimeout || e.type == DioErrorType.receiveTimeout) {
        errorResponse?.statusCode = Code.NETWORK_TIMEOUT;
      }

      Future.delayed(const Duration(milliseconds: 300), () => Code.errorHandleFunction(errorResponse?.statusCode, e.message, noTip, context));
      return ResultData(e.message, false, errorResponse?.statusCode);
    }

    Response response;
    try {
      response = await _dio.request(url, data: params, options: option);
    } on DioError catch (e) {
      return resultError(e);
    }
    if (response.data is DioError) {
      return resultError(response.data);
    }

    int sCode = -1;
    if(response.statusCode == 200) {
      sCode = response.data["c"] as int;
      String sMessage = response.data["m"] as String;
      if(sCode != 0) {
        ALog("错误码: $sCode");
        return ResultData(Code.errorHandleFunction(sCode, sMessage, noTip, context), false, sCode);
      }
    }
    return ResultData(response.data, true, sCode);
  }

  ///清除授权
  clearAuthorization() {
    _tokenInterceptors.clearAuthorization();
  }

  ///获取授权token
  getAuthorization() async {
    return _tokenInterceptors.getAuthorization();
  }
}

final HttpManager httpManager = HttpManager();
