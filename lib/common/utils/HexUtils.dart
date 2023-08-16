import 'dart:typed_data';

class HexUtils {
  //static String uint8ToHex(Uint8List bArr) {
  static String uint8ToHex(List<int> bArr) {
    //Uint8List bArr
    if (bArr.isEmpty) {
      return "";
    }
    int length = bArr.length;
    Uint8List cArr = Uint8List(length << 1);
    int i = 0;
    for (int i2 = 0; i2 < length; i2++) {
      int i3 = i + 1;
      var cArr2 = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'];

      var index = (bArr[i2] >> 4) & 15;
      cArr[i] = cArr2[index].codeUnitAt(0);
      i = i3 + 1;
      cArr[i3] = cArr2[bArr[i2] & 15].codeUnitAt(0);
    }
    return String.fromCharCodes(cArr);
  }

  static Uint8List toUnitList(String str) {
    hex(int c) {
      if (c >= '0'.codeUnitAt(0) && c <= '9'.codeUnitAt(0)) {
        return c - '0'.codeUnitAt(0);
      }
      if (c >= 'A'.codeUnitAt(0) && c <= 'F'.codeUnitAt(0)) {
        return (c - 'A'.codeUnitAt(0)) + 10;
      }
      return 0;
    }

    int length = str.length;
    if (length % 2 != 0) {
      str = "0" + str;
      length++;
    }
    List<int> s = str.toUpperCase().codeUnits;
    Uint8List bArr = Uint8List(length >> 1);
    for (int i = 0; i < length; i += 2) {
      bArr[i >> 1] = ((hex(s[i]) << 4) | hex(s[i + 1]));
    }
    return bArr;
  }

  static String uint8ToHex2(Uint8List byteArr) {
    if (byteArr.isEmpty) {
      return "";
    }
    Uint8List result = Uint8List(byteArr.length << 1);
    var hexTable = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F']; //16进制字符表
    for (var i = 0; i < byteArr.length; i++) {
      var bit = byteArr[i];
      var index = bit >> 4 & 15;
      var i2 = i << 1;
      result[i2] = hexTable[index].codeUnitAt(0);
      index = bit & 15;
      result[i2 + 1] = hexTable[index].codeUnitAt(0);
    }
    return String.fromCharCodes(result);
  }
}
