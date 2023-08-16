import 'package:iwallet/common/dao/api_network_dao.dart';
import 'package:rxdart/rxdart.dart';

///
/// on 2022/7/16.

enum ApiName { getBalance, getTradeRecord, getOther, getOther2 }

class ComNetModel {
  bool _requested = false;
  bool _isLoading = false;

  //是否正在loading
  bool get isLoading => _isLoading;
  ///是否已经请求过
  bool get requested => _requested;
  ///rxdart 实现的 stream
  final _subject = PublishSubject<dynamic>();
  Stream<dynamic> get stream => _subject.stream;

  ///根据数据库和网络返回数据
  Future<void> requestRefresh(context, params, ApiName apiName, {Function()? netStateCallBack}) async {
    if (_isLoading) return;
    _isLoading = true;

    //1. apiName start
    dynamic res;
    switch(apiName) {
      case ApiName.getBalance:
        res = await ApiNetWorkDao.getBalance(context: context, reqParams: params, netStateCallBack: netStateCallBack);
        break;
      case ApiName.getTradeRecord:
        res = await ApiNetWorkDao.getTradeRecord(context: context, reqParams: params);
        break;
      case ApiName.getOther:
        // TODO: Handle this case.
        break;
      case ApiName.getOther2:
        // TODO: Handle this case.
        break;
    }
    //## apiName end

    if (res != null && res.result) {
      _subject.add(res.data);
    }
    await doNext(res);
    _isLoading = false;
    _requested = true;
    return;
  }

  ///请求next，是否有网络
  doNext(res) async {
    if (res.next != null) {
      var resNext = await res.next();
      if (resNext != null && resNext.result) {
        _subject.add(resNext.data);
      }
    }
  }

}
