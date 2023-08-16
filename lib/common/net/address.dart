
///地址数据
class Address {
  static const String host = "http://218.255.3.60:7979/";
  static const String article_host = "http://218.255.3.60:7979/";

  ///1. 查询余额
  static getBalanceApi() {
    return "${host}wallet/getBalance";
  }

  //2. 获取交易记录
  static getTradeRecordApi() {
    return "${host}wallet/getTransactions";
  }

  //3. 获取交易记录
  static getTradeRecordDetailApi() {
    return "${host}wallet/getTransactionDetail";
  }

  //4. 获取预估矿工费
  static getEstimateFeeApi() {
    return "${host}wallet/estimateFee";
  }

  //5. 获取预估矿工费
  static getUtxoListApi() {
    return "${host}wallet/getUTXOs";
  }

  //6. 发送交易
  static getSendRawTransactionApi() {
    return "${host}wallet/sendRawTransaction";
  }

}
