import 'package:flutter/material.dart';
import 'package:flutter_md_edit/ui/latest_page_ui.dart';
import 'package:flutter_md_edit/ui/test_ui.dart';
import 'edit_ui.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  double _top = 0.0;
  int _currentIndex = 0;

  Widget getPage(index){
    var page;
    switch (index) {
      case 0:
        page = LatestPageUI();
        break;
      case 1:
        page = HomeContent();
        break;
      case 2:
        page = Container();
        break;
      default:
        page = Container();
        break;
    }
    return page;
  }

  @override
  Widget build(BuildContext context) {
    _top = MediaQuery.of(context).padding.top;
    return Scaffold(
      // body: MarkdownUI(),
      body: getPage(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        currentIndex: _currentIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(label: '最新', icon: Icon(Icons.home_outlined)),
          BottomNavigationBarItem(label: '文件夹', icon: Icon(Icons.folder_outlined)),
          BottomNavigationBarItem(
              label: '我的', icon: Icon(Icons.perm_identity)),
        ],
      ),
    );
  }
}
