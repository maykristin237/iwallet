
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:iwallet/common/net/code.dart';
import 'package:iwallet/common/utils/alog.dart';
import 'package:iwallet/common/dao/dao_result.dart';
import 'package:iwallet/common/net/address.dart';
import 'package:iwallet/common/net/api.dart';

///
/// Date: 2023-07-16

class ApiNetWorkDao {

  /// 查询余额
  static getBalance({required context, required reqParams, page = 0, needDb = false, noTip = false, Function()? netStateCallBack}) async {
    try {
      var conResult = await Connectivity().checkConnectivity();
      if (conResult == ConnectivityResult.none) {
        ALog('Not connected to any network');
        netStateCallBack?.call();
        return DataResult(null, false);
      }
    } catch (e) {
      ALog('Could not check connectivity status, error=$e');
    }

    String url = Address.getBalanceApi();

    String btcAddress = reqParams["address1"], ethAddress = reqParams["address2"];
    Map reqParams1 = {"ccy": "BTC", "address": ""};
    Map reqParams2 = {"ccy": "ETH", "address": ""};
    reqParams1["address"] = btcAddress;
    reqParams2["address"] = ethAddress;

    List resData = [];
    dynamic result;
    //BTC
    if (btcAddress.length > 20) {
      result = await httpManager.netFetch(url, reqParams1, null, Options(method: "post"), noTip: noTip, context: context);
      if (result != null && result.result && result.code == 0) {
        resData.add(result.data["data"]); //return DataResult(result.data["data"], true);
      } else {
        //resData.add({"ccy": "BTC"}); //空数据
      }
    }

    //ETH
    if (ethAddress.length > 20) {
      result = await httpManager.netFetch(url, reqParams2, null, Options(method: "post"), noTip: noTip, context: context);
      if (result != null && result.result && result.code == 0) {
        resData.add(result.data["data"]); //return DataResult(result.data["data"], true);
      } else {
        //resData.add({"ccy": "ETH"}); //空数据
      }
    }

    if (resData.isNotEmpty) {
      return DataResult(resData, true);
    } else {
      return DataResult(null, false);
    }
  }

  /// 获取交易记录
  static getTradeRecord({required context, required reqParams, page = 0, needDb = false, noTip = false}) async {
    String url = Address.getTradeRecordApi();

    var result = await httpManager.netFetch(url, reqParams, null, Options(method: "post"), noTip: noTip, context: context);
    if (result != null && result.result && result.code == 0) {

      return DataResult(result.data["data"], true);
    } else if (result != null && result.result && result.code == 1) {

    }

    return DataResult(null, false);
  }

  /// 获取交易详情
  static getTradeRecordDetail({required context, required reqParams, page = 0, needDb = false, noTip = false}) async {
    String url = Address.getTradeRecordDetailApi();

    var result = await httpManager.netFetch(url, reqParams, null, Options(method: "post"), noTip: noTip, context: context);
    if (result != null && result.result && result.code == 0) {

      return DataResult(result.data["data"], true);
    } else if (result != null && result.result && result.code == 1) {

    }

    return DataResult(null, false);
  }

  /// 获取预估矿工费
  static getEstimateFee({required context, required reqParams, page = 0, needDb = false, noTip = false, Function? netStateCallBack}) async {
    String url = Address.getEstimateFeeApi();

    var result = await httpManager.netFetch(url, reqParams, null, Options(method: "post"), noTip: noTip, context: context);
    if (result != null && result.result && result.code == 0) {

      return DataResult(result.data["data"], true);
    } else if (result != null && result.result == false && result.code == Code.NETWORK_ERROR) {
      netStateCallBack?.call();
      return null;
    }

    return DataResult(null, false);
  }

  /// 获取BTC的UTXO列表
  static getUtxoList({required context, required reqParams, page = 0, needDb = false, noTip = false}) async {
    String url = Address.getUtxoListApi();

    var result = await httpManager.netFetch(url, reqParams, null, Options(method: "post"), noTip: noTip, context: context);
    if (result != null && result.result && result.code == 0) {

      return DataResult(result.data["data"], true);
    } else if (result != null && result.result && result.code == 1) {

    }

    return DataResult(null, false);
  }

  /// 发送交易
  static sendRawTransaction({required context, required reqParams, page = 0, needDb = false, noTip = false}) async {
    String url = Address.getSendRawTransactionApi();

    var result = await httpManager.netFetch(url, reqParams, null, Options(method: "post"), noTip: noTip, context: context);
    if (result != null && result.result && result.code == 0) {

      return DataResult(result.data["data"], true);
    } else if (result != null && result.result && result.code == 1) {

    }

    return DataResult(null, false);
  }

}
