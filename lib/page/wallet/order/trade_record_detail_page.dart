import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:iwallet/common/dao/api_network_dao.dart';
import 'package:iwallet/common/localization/default_localizations.dart';
import 'package:iwallet/common/style/def_style.dart';
import 'package:iwallet/common/utils/common_utils.dart';
import 'package:iwallet/common/utils/number_utils.dart';
import 'package:iwallet/widget/widget_utils.dart';

///
/// Date: 2023-03-19

class TradeRecordDetailPage extends StatefulWidget {
  static const String sName = "record_detail";
  const TradeRecordDetailPage({super.key});

  @override
  State<TradeRecordDetailPage> createState() => _TradeRecordDetailPageState();
}

class _TradeRecordDetailPageState extends State<TradeRecordDetailPage> {
  ScrollController vController = ScrollController();

  late bool _onceFlag = false, _disposeFlag = false;
  dynamic orderItem;

  @override
  void dispose() {
    super.dispose();
    _disposeFlag = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //防止重复进入
    if (_onceFlag || _disposeFlag) return;
    _onceFlag = true;

    Object? prams = ModalRoute.of(context)?.settings.arguments;
    dynamic item = prams as dynamic;
    //ALog("## item=$item");

    Future.delayed(const Duration(milliseconds: 200), () {
      _getOrderListData(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    //mContext = context;

    return Scaffold(
        backgroundColor: DefColors.primaryValue,
        appBar: AppBar(
          title: Text(Locals.i18n(context)!.trans_records),
          leading: BackButton(),
          centerTitle: true,
        ),
        body: Container(
          //color: Colors.black,
          //width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(10.0),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad}),
            child: SingleChildScrollView(
              controller: vController,
              scrollDirection: Axis.vertical,
              child: orderItem == null ? _buildEmpty() : _panel(),
            ),
          ),
        ));
  }

  Widget _panel() {
    int type = orderItem["trans_type"] ?? -1;
    String txID = orderItem["tx_id"] ?? "";
    String fromAddress = orderItem["from_address"] ?? "";
    String toAddress = orderItem["to_address"] ?? "";
    int time = orderItem["timestamp"] ?? 0;
    String ccy = orderItem["ccy"] ?? 0;
    int blockNum = orderItem["block_number"] ?? 0;
    num fee = orderItem["fee"] ?? 0;
    String feeStr = NumberUtils.nFormat(fee, bits: 6) + ccy;
    num value = orderItem["value"] ?? 0;
    String valueStr = NumberUtils.nFormat(value, bits: 6) + ccy;

    String transType = type == 1 ? Locals.i18n(context)!.trans_out : type == 2 ? Locals.i18n(context)!.trans_in : "";
    String dataTime = CommonUtils.timestampToDateStr(time);
    Color valueColor = type == 1 ? Colors.red : Colors.blue;
    valueStr = type == 1 ? "-$valueStr" : "+$valueStr";
    String txIDBreakStr = NumberUtils.breakWord(txID);
    String copyLink = orderItem["detail_url"] ?? "";


    itemView(String name, String value) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name, style: const TextStyle(fontSize: 15, color: DefColors.toggleBtnColor, fontWeight: FontWeight.normal)),
            Text(value, style: const TextStyle(fontSize: 15, color: DefColors.textMainColor, fontWeight: FontWeight.normal)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(alignment: Alignment.center,
            child: Image(height: 38, image: AssetImage('static/images/money_icon.png'), fit: BoxFit.fill)),
        Align(alignment: Alignment.center,
            child: Text(transType, style: TextStyle(fontSize: 13, color: valueColor, fontWeight: FontWeight.normal))),
        Align(alignment: Alignment.center,
            child: Text(valueStr, style: TextStyle(fontSize: 18, color: valueColor, fontWeight: FontWeight.bold))),

        itemView(Locals.i18n(context)!.payee, toAddress),
        itemView(Locals.i18n(context)!.sender, fromAddress),
        itemView(Locals.i18n(context)!.fee, feeStr),
        itemView("${Locals.i18n(context)!.remarks}：", ""),

        const SizedBox(height: 20),
        Divider(height: 2.0, indent: 0.0, color: Colors.grey.withOpacity(0.8)),

        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  itemView(Locals.i18n(context)!.trans_num, txIDBreakStr),
                  itemView(Locals.i18n(context)!.block_num, blockNum.toString()),
                  itemView(Locals.i18n(context)!.trans_time, dataTime),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    QrImageView(
                      data: txID,
                      version: QrVersions.auto,
                      size: 110,
                      backgroundColor: Colors.white,
                      gapless: false,
                    ),
                    const SizedBox(height: 10),
                    WidgetUtils.underLineBtn(txt: Locals.i18n(context)!.copy_link, onTap: () {
                      Clipboard.setData(ClipboardData(text: copyLink));
                      CommonUtils.showCommonDialog(context, Locals.i18n(context)!.link_copied, noCancel: true, noYes: true, autoDisappear: true);
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }


  ///空页面
  Widget _buildEmpty() {
    var statusBar = MediaQueryData.fromWindow(WidgetsBinding.instance.window).padding.top;
    var bottomArea = MediaQueryData.fromWindow(WidgetsBinding.instance.window).padding.bottom;
    var height = MediaQuery.of(context).size.height - statusBar - bottomArea - kBottomNavigationBarHeight - kToolbarHeight;
    return SingleChildScrollView(
      child: Container(
        height: height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () {},
              child: const Image(image: AssetImage(DefICons.DEFAULT_USER_ICON), width: 70.0, height: 70.0),
            ),
            Container(
              child: Text(Locals.i18n(context)!.app_empty, style: DefConstant.normalText),
            ),
          ],
        ),
      ),
    );
  }


  _getOrderListData(dynamic item) {
    if (item == null) return;

    CommonUtils.showLoadingDialog(context); //show loading
    next() async {
      int type = item["trans_type"] ?? -1;
      String ccy = item["ccy"] ?? "";
      String txId = item["tx_id"] ?? "";
      String fromAddress = item["from_address"] ?? "";
      String toAddress = item["to_address"] ?? "";
      String address = type == 1 ? fromAddress : toAddress; //自己的地址

      Map params = {"ccy": ccy, "txId": txId, "address": address};
      var res = await ApiNetWorkDao.getTradeRecordDetail(context: context, reqParams: params);
      return res;
    }

    next().then((value) {
      Navigator.pop(context);

      if (value != null && value.result) {
        setState(() {
          orderItem = value.data;
        });
      }
    });
  }

}
