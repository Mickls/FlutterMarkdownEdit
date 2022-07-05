import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_md_edit/components/latest_page.dart';
import 'package:flutter_md_edit/contains/icon.dart';
import 'package:flutter_md_edit/models/article.dart';
import 'package:flutter_md_edit/models/folder.dart';
import 'package:flutter_md_edit/contains/font_style.dart';
import 'package:flutter_md_edit/page/search_ui.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:getwidget/getwidget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class LatestPage extends StatefulWidget {
  const LatestPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LatestPageState();
  }
}

class LatestPageState extends State<LatestPage> {
  final ScrollController _scrollController = ScrollController();

  List<LevelRoot> _levelRoots = [];
  List<LevelRoot> _tempLevelRoots = [];
  // List<String> _titles = [];

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  _loadData({int superID = 0, limit = 10, offset = 0}) async {
    if (_levelRoots.length > offset) {
      offset = _levelRoots.length;
    }
    var levelRoots = await FolderProvider()
        .queryLevelRootWithID(superID, limit: limit, offset: offset);
    if (levelRoots.isNotEmpty) {
      if (mounted) {
        setState(() {
          for (var element in levelRoots) {
            if (!_levelRoots.contains(element)) {
              _levelRoots.add(element);
            }
          }
          _refreshController.loadComplete();
        });
      }
    } else {
      _refreshController.loadNoData();
    }
  }

  _refreshData({int superID = 0, offset = 0, limit = 10}) async {
    var levelRoots = await FolderProvider()
        .queryLevelRootWithID(superID, offset: offset, limit: limit);
    setState(() {
      _levelRoots = levelRoots;
    });
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Widget articleTitleUI(int index) {
    var levelRoot = _levelRoots[index];
    var updateTime = levelRoot.updatedAt;
    return GFListTile(
      title: titleUI(levelRoot.name ?? ""),
      description: Text("${updateTime?.year.toString()}-"
          "${updateTime?.month.toString()}-"
          "${updateTime?.day.toString()} "
          // "${updateTime?.hour.toString()}:"
          // "${updateTime?.minute.toString()}:"
          // "${updateTime?.second.toString()}",
          ),
      color: Colors.white,
      onTap: () async {
        await Navigator.of(context)
            .pushNamed("/edit", arguments: _levelRoots[index].id ?? 0);
        _refreshData();
      },
      onLongPress: () async {
        showDialog(
          // 传入 context
          context: context,
          // 构建 Dialog 的视图
          builder: (context) => Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  color: Colors.white,
                  child: _showCardDialog(context, index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget generateDialogButton(String text, IconData icon) {
    return Flex(
      direction: Axis.horizontal,
      children: [
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.only(left: 15),
            decoration: const BoxDecoration(),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.green,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    text,
                    style: getNormalTextStyle(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _renameUI(BuildContext context, String text) {
    TextEditingController renameController = TextEditingController();
    renameController.text = text;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(top: 10),
          color: Colors.white,
          alignment: Alignment.center,
          child: const Icon(
            Icons.edit_note_outlined,
            color: Colors.green,
          ),
        ),
        Container(
          alignment: Alignment.center,
          color: Colors.white,
          height: 30,
          child: Text(
            "重命名",
            style: getNormalTextStyle(),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(15),
          alignment: Alignment.center,
          color: Colors.white,
          child: CupertinoTextField(
            controller: renameController,
          ),
        ),
        Container(
          alignment: Alignment.center,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, "/");
                },
                child: Text(
                  "取消",
                  style: getNormalTextStyle(),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, renameController.text);
                },
                child: Text(
                  "保存",
                  style: getNormalTextStyle(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 弹出窗
  Widget _showCardDialog(BuildContext context, int index) {
    return Column(
      children: <Widget>[
        GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              final levelRoot = _levelRoots[index];
              String renameTitle = await showDialog(
                context: context,
                builder: (context) => Padding(
                    padding: const EdgeInsets.all(30),
                    child: _renameUI(context, levelRoot.name ?? "")),
              );
              Article? article = Article(
                title: renameTitle,
                content: levelRoot.content,
              );
              await ArticleProvider().update(article, levelRoot.id ?? 0);
              _refreshData();
            },
            child: generateDialogButton("重命名", Icons.edit_note_outlined)),
        const Divider(),
        GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: generateDialogButton("移动", Icons.drive_file_move_outline)),
        const Divider(),
        GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              await ArticleProvider().delete(_levelRoots[index].id ?? 0);
              _refreshData();
            },
            child: generateDialogButton("删除", Icons.delete_outline)),
      ],
    );
  }

  Widget getSearchUI() {
    return SearchBar(
      // overlaySearchListHeight: 100.0,
      searchList: [],
      overlaySearchListItemBuilder: (dynamic item) {
        return Container(
          padding: const EdgeInsets.all(8),
          child: Text(
            item,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        );
      },
      searchQueryBuilder: (String query, List<dynamic> searchList) async {
        if (query.isEmpty) {
          if (_tempLevelRoots.isNotEmpty) {
            setState(() {
              _levelRoots.clear();
              _levelRoots.addAll(_tempLevelRoots);
              _tempLevelRoots.clear();
            });
          }
        } else {
          final levelRoots =
              await FolderProvider().queryLevelRootWithKey(query);
          if (_tempLevelRoots.isEmpty) {
            _tempLevelRoots.addAll(_levelRoots);
          }
          // searchList.clear();
          // for (var element in levelRoots) {
          //   searchList.add(element.name ?? "");
          // }
          setState(() {
            _levelRoots = levelRoots;
          });
        }
        return [];
        // return searchList;
      },
      noItemsFoundWidget: Container(),
    );
  }

  Widget getContentUI() {
    var searchList = [];
    for (var element in _levelRoots) {
      searchList.add(element.name);
    }
    return Column(
      children: [
        getSearchUI(),
        Expanded(
          child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            header: const WaterDropHeader(),
            footer: CustomFooter(
              builder: (BuildContext context, LoadStatus? mode) {
                Widget body;
                if (mode == LoadStatus.idle) {
                  body = const Text("上拉加载");
                } else if (mode == LoadStatus.loading) {
                  body = const CupertinoActivityIndicator();
                } else if (mode == LoadStatus.failed) {
                  body = const Text("加载失败！点击重试！");
                } else if (mode == LoadStatus.canLoading) {
                  body = const Text("松手,加载更多!");
                } else {
                  body = const Text("没有更多数据了!");
                }
                return SizedBox(
                  height: 55.0,
                  child: Center(child: body),
                );
              },
            ),
            controller: _refreshController,
            onRefresh: _refreshData,
            onLoading: _loadData,
            child: ListView.builder(
              itemCount: _levelRoots.length,
              controller: _scrollController,
              // shrinkWrap: true,
              itemBuilder: (context, index) {
                // return articleCartUI(index);
                return articleTitleUI(index);
              },
            ),
          ),
        ),
      ],
    );
  }

  AppBar appBarUI() {
    return AppBar(
      title: const Text(
        "最新",
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
            fontFamily: 'simplified',
            fontSize: 15),
      ),
      centerTitle: true,
      actions: [
        PopupMenuButton(
            elevation: 1,
            offset: Offset(0, 56),
            icon: const Icon(
              AntIcons.menu,
              color: Color.fromARGB(255, 180, 180, 180),
            ),
            shape: RoundedRectangleBorder(
              // side: BorderSide(
              //     color: Colors.red
              // ),
              borderRadius: BorderRadius.circular(10),
            ),
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem(child: Text("同步")),
                PopupMenuDivider(),
                CheckedPopupMenuItem(
                  checked: true,
                  child: Text("显示草稿"),
                ),
              ];
            }),
      ],
      elevation: 0,
      backgroundColor: Color.fromARGB(255, 245, 245, 245),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarUI(),
      body: Container(
        color: const Color.fromARGB(255, 245, 245, 245),
        child: getContentUI(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          await Navigator.of(context).pushNamed("/edit", arguments: 0);
          _refreshData();
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
