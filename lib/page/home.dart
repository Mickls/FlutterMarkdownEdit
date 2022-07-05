import 'package:flutter/material.dart';
import 'package:flutter_md_edit/contains/color.dart';
import 'package:flutter_md_edit/contains/icon.dart';
import 'package:flutter_md_edit/page/latest_page.dart';
import 'package:flutter_md_edit/components/test_ui.dart';
import 'package:getwidget/getwidget.dart';
import 'edit.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GFTabBarView(
        controller: tabController,
        children: [
          LatestPage(),
          HomeContent(),
          Container(),
        ],
      ),
      bottomNavigationBar: GFTabBar(
        length: 3,
        controller: tabController,
        tabBarColor: const Color.fromARGB(255, 240, 240, 242),
        tabBarHeight: 65,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: const Color.fromARGB(255, 86, 91, 99),
        indicatorWeight: 1.5,
        labelColor: selectedColor,
        unselectedLabelColor: const Color.fromARGB(255, 86, 91, 99),
        shape: const BorderDirectional(
          top: BorderSide(
            width: 0.5,
            color: Color.fromARGB(255, 210, 210, 210)
          ),
        ),
        tabs: const [
          Tab(
            icon: Icon(
              AntIcons.home,
              // color: Colors.black,
            ),
            child: Text(
              "最新",
              style: TextStyle(
                // color: Colors.black,
              ),
            ),
          ),
          Tab(
            icon: Icon(
              AntIcons.folder,
              // color: Colors.black,
            ),
            child: Text(
              "文件夹",
              style: TextStyle(
                // color: Colors.black,
              ),
            ),
          ),
          Tab(
            icon: Icon(
              AntIcons.setting,
              // color: Colors.black,
            ),
            child: Text(
              "设置",
              style: TextStyle(
                // color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
