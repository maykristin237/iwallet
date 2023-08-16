import 'package:flutter/material.dart';
import 'package:iwallet/common/style/def_style.dart';
import 'package:iwallet/widget/w_tabs.dart' as WTab;

class WTabBarWidget extends StatefulWidget {
  final TabType type;
  final bool resizeToAvoidBottomPadding;
  final TabController? tabController;
  final List<Widget>? tabItems;
  final List<Widget>? tabViews;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final Widget? title;
  final Widget? drawer;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomBar;
  final List<Widget>? footerButtons;

  final ValueChanged<int>? onPageChanged;
  final ValueChanged<int>? onSinglePress;
  final ValueChanged<int>? onDoublePress;
  final ValueChanged<int>? onLongPress;

  const WTabBarWidget({
    Key? key,
    this.type = TabType.top,
    this.tabController,
    this.tabItems,
    this.tabViews,
    this.backgroundColor,
    this.indicatorColor,
    this.title,
    this.drawer,
    this.bottomBar,
    this.onDoublePress,
    this.onSinglePress,
    this.floatingActionButtonLocation,
    this.floatingActionButton,
    this.resizeToAvoidBottomPadding = true,
    this.footerButtons,
    this.onPageChanged,
    this.onLongPress,
  }) : super(key: key);

  @override
  State<WTabBarWidget> createState() => _WTabBarState();
}

class _WTabBarState extends State<WTabBarWidget> with SingleTickerProviderStateMixin { //with SingleTickerProviderStateMixin  TickerProviderStateMixin
  final PageController _pageController = PageController();

  TabController? _tabController;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _tabController = widget.tabController;
    _tabController ??= TabController(vsync: this, length: widget.tabItems!.length);
  }

  ///整个页面dispose时，记得把控制器也dispose掉，释放内存
  @override
  void dispose() {
    (widget.tabController ?? _tabController)?.dispose();
    //_tabController?.dispose();
    //widget.tabController?.dispose();
    super.dispose();
  }

  _navigationPageChanged(index) {
    if (_index == index) {
      return;
    }
    _index = index;
    (widget.tabController ?? _tabController)?.animateTo(index);
    widget.onPageChanged?.call(index);
  }

  _navigationTapClick(index) {
    if (_index == index) {
      return;
    }
    bool isRight = index > _index;  //判断向右划, 还是向左划
    _index = index;
    widget.onPageChanged?.call(index);

    double w = MediaQuery.of(context).size.width;
    double pos = isRight ? (index - 1) * w + (w * 2 / 3) : index * w + (w / 3);
    _pageController.jumpTo(pos);

    widget.onSinglePress?.call(index);
  }

  _navigationDoubleTapClick(index) {
    _navigationTapClick(index);
    widget.onDoublePress?.call(index);
  }

  _navigationLongTapClick(index) {
    _navigationTapClick(index);
    widget.onLongPress?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == TabType.top) {

      ///顶部tab bar 1
      return Scaffold(
          appBar: AppBar(
            toolbarHeight: 33,
            flexibleSpace: SafeArea(
              child: TabBar(
                  controller: widget.tabController ?? _tabController,
                  tabs: widget.tabItems!,
                  indicatorColor: widget.indicatorColor,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorWeight: 3,
                  labelColor: DefColors.textTitleYellow,
                  unselectedLabelColor: const Color(0xff909090),
                  onTap: _navigationTapClick),
            ),
          ),
          body: PageView(
            controller: _pageController,
            onPageChanged: _navigationPageChanged,
            children: widget.tabViews!,
          ));

    }

    ///底部tab bar
    return Scaffold(
        drawer: widget.drawer,
        body: PageView(
          controller: _pageController,
          onPageChanged: _navigationPageChanged,
          children: widget.tabViews!,
        ),
        bottomNavigationBar: Material(
          //为了适配主题风格，包一层Material实现风格套用
          color: Theme.of(context).primaryColor, //底部导航栏主题颜色
          child: SafeArea(
            child: WTab.TabBar(
              //TabBar导航标签，底部导航放到Scaffold的bottomNavigationBar中
              controller: widget.tabController ?? _tabController,
              //配置控制器
              tabs: widget.tabItems!,
              labelColor: DefColors.textTitleYellow,
              unselectedLabelColor: const Color(0xff909090),
              indicatorColor: widget.indicatorColor,  //tab标签的下划线颜色
              onDoubleTap: _navigationDoubleTapClick,
              onTap: _navigationTapClick,
              onLongTap: _navigationLongTapClick,
            ),
          ),
        ));
  }
}

enum TabType { top, bottom }
