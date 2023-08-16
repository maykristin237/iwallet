import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:iwallet/common/localization/default_localizations.dart';
import 'package:iwallet/common/style/def_style.dart';
import 'package:iwallet/common/utils/alog.dart';

/// 刷新
///
/// Date: 2023-03-09

class PullLoadRefresh extends StatelessWidget {
  final PullLoadController? erController;
  final Function? onRefresh, onLoad;
  final Widget? child;
  final bool alwaysLoad;       //上划时可以一直load
  final bool floatVis;         //下拉时浮窗显示

  late bool visUpload = true;  //是否显示上拉加载
  late final ScrollController? scrollController;

  PullLoadRefresh({super.key, required this.erController, required this.child, this.alwaysLoad = false, this.floatVis = false, this.onRefresh, this.onLoad}) {
    erController?.alwaysLoad = alwaysLoad;
    visUpload = onLoad != null;
    scrollController = erController?.scrollController;
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      controller: erController,
      firstRefresh: true,
      enableControlFinishRefresh: true,
      enableControlFinishLoad: true,
      bottomBouncing: visUpload,  //是否显示上拉加载
      behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad}),
      header: ClassicalHeader(
        float: floatVis,
        refreshText: Locals.i18n(context)!.refresh,
        refreshReadyText: Locals.i18n(context)!.release_refresh,
        refreshingText: Locals.i18n(context)!.refreshing,
        refreshedText: Locals.i18n(context)!.refreshed,
        infoText: Locals.i18n(context)!.update_time,
        bgColor: DefColors.primaryValue,
        textColor: DefColors.toggleBtnColor,
        infoColor: DefColors.toggleBtnColor,
      ),
      footer: visUpload ? ClassicalFooter(
        loadText: Locals.i18n(context)!.load,
        loadReadyText: Locals.i18n(context)!.release_load,
        loadingText: Locals.i18n(context)!.loading,
        loadedText: Locals.i18n(context)!.loaded,
        infoText: Locals.i18n(context)!.update_time,
        bgColor: Colors.transparent,
        textColor: DefColors.toggleBtnColor,
        infoColor: DefColors.toggleBtnColor,
        enableInfiniteLoad: alwaysLoad,
        showInfo: false,
      ) : null,
      onRefresh: _requestRefresh,
      onLoad: ((erController?.isFooter ?? true) && visUpload) ? _requestLoadMore : null,
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.vertical,
        child: child,
      ),
    );
  }

  ///下拉刷新数据
  Future<void> _requestRefresh() async {
    onRefresh?.call();
  }

  ///上拉更多请求数据
  Future<void> _requestLoadMore() async {
    onLoad?.call();
  }

}

/// EasyRefresh控制器
class PullLoadController extends EasyRefreshController {
  late bool isFooter = true;
  late bool alwaysLoad = false;

  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  ///网络返回数据后, 需要关闭.
  void loadFinish(State state) async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 500));
    this.finishLoad(success: true);
    if (!alwaysLoad) return;

    Future.delayed(const Duration(seconds: 1), () {
      state.setState(() {
        isFooter = false;
      });

      Future.delayed(const Duration(seconds: 2), () {
        state.setState(() {
          isFooter = true;
        });
      });
    });
  }

  void scrollToTop() {
    if (scrollController.offset <= 0) {
      scrollController.animateTo(0, duration: const Duration(milliseconds: 600), curve: Curves.linear).then((_) {
        this.callRefresh();
      });
    } else {
      this.callRefresh();
    }
  }

  void setScrollController(State state) {
    scrollController.addListener(() {
      ALog("scrollController.offset=${scrollController.offset}");
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          state.setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (scrollController.offset <= 24 && scrollController.offset >= 0) {
        if (topBarOpacity != scrollController.offset / 24) {
          state.setState(() {
            topBarOpacity = scrollController.offset / 24;
          });
        }
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          state.setState(() {
            topBarOpacity = 0.0;
          });
        }
      }
    });
  }

}