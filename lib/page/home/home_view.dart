import 'package:flutter/material.dart';
import 'package:flutter_md_edit/contains/color.dart';
import 'package:flutter_md_edit/contains/icon.dart';
import 'package:flutter_md_edit/page/folder/folder_view.dart';
import 'package:flutter_md_edit/page/latest/latest_view.dart';
import 'package:getwidget/getwidget.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {

  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  Widget getBottomTab(IconData icons, String text) {
    return Tab(
      icon: Icon(
        icons,
      ),
      child: Text(
        text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GFTabBarView(
        controller: tabController,
        children: [
          LatestPage(),
          FolderPage(),
          Container(),
        ],
      ),
      bottomNavigationBar: GFTabBar(
        length: 3,
        controller: tabController,
        tabBarColor: tabBarColor,
        tabBarHeight: 65,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: unSelectedColor,
        indicatorWeight: 1.5,
        labelColor: selectedColor,
        unselectedLabelColor: unSelectedColor,
        shape: const BorderDirectional(
          top: BorderSide(
              width: 0.5,
              color: borderSideColor,
          ),
        ),
        tabs: [
          getBottomTab(AntIcons.home, '最新'),
          getBottomTab(AntIcons.folder, '文件夹'),
          getBottomTab(AntIcons.setting, '设置'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}