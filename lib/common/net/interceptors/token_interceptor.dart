import 'package:dio/dio.dart';
import 'package:iwallet/common/config/config.dart';
import 'package:iwallet/common/local/local_storage.dart';

/// Token
///
/// on 2022/7/23.
class TokenInterceptors extends InterceptorsWrapper {
  String? _token;

  @override
  onRequest(RequestOptions options, handler) async {
    if (_token == null) {
      var authorizationCode = await getAuthorization();
      if (authorizationCode != null) {
        _token = authorizationCode;
      }
    }

    if (_token != null) {
      options.headers["X-Token"] = _token;
    }
    return super.onRequest(options, handler);
  }

  @override
  onResponse(Response response, handler) async {
    return super.onResponse(response, handler);
  }

  ///清除授权
  clearAuthorization() {
    this._token = null;
    LocalStorage.remove(Config.TOKEN_KEY);
  }

  ///获取授权token
  getAuthorization() async {
    String? token = await LocalStorage.get(Config.TOKEN_KEY);
    this._token = token;
    return token;
  }
}
