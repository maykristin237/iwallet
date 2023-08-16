import 'dart:convert';

///isolate 的 compute 需要静态方法
class CodeUtils {
  static List<dynamic> decodeListResult(String? data) {
    return json.decode(data!);
  }

  static Map<String, dynamic> decodeMapResult(String? data) {
    return json.decode(data!);
  }

  static String encodeToString(String data) {
    return json.encode(data);
  }

  static String formatStr(String str, {String? s1, String? s2, String? s3}) {
    if (str.isEmpty) return str;

    String resultStr = str;
    if (s1 != null) {
      resultStr = str.replaceAll("%T1", s1);
    }
    if (s2 != null) {
      resultStr = resultStr.replaceAll("%T2", s2);
    }
    if (s3 != null) {
      resultStr = resultStr.replaceAll("%T3", s3);
    }
    return resultStr;
  }

}
