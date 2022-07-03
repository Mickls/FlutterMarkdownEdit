import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_md_edit/models/article.dart';
import 'package:flutter_md_edit/models/folder.dart';
import 'package:flutter_md_edit/contains/font_style.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class LatestPageUI extends StatefulWidget {
  const LatestPageUI({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LatestPageState();
  }
}

class LatestPageState extends State<LatestPageUI> {
  final ScrollController _scrollController = ScrollController();

  List<LevelRoot> _levelRoots = [];

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  _loadData({int superID = 0, limit = 10, offset = 0}) async {
    if (_levelRoots.length > offset) {
      offset = _levelRoots.length;
    }
    var levelRoots =
        await FolderProvider().queryRoot(superID, limit: limit, offset: offset);
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
    var levelRoots =
        await FolderProvider().queryRoot(superID, offset: offset, limit: limit);
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

  Widget articleCartUI(int index) {
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context)
            .pushNamed("/edit", arguments: _levelRoots[index].id ?? 0);
        _refreshData();
      },
      onLongPress: () {
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
      child: articleUI(index),
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
                // title: levelRoots.name,
                title: renameTitle,
                content: levelRoot.content,
              );
              await ArticleProvider().update(article, levelRoot.id ?? 0);
              // _refreshArticleDataWithIndex(levelRoot.id ?? 0, index);
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

  Widget getContentUI() {
    return SmartRefresher(
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
        itemBuilder: (context, index) {
          return articleCartUI(index);
        },
      ),
    );
  }

  Widget articleUI(int index) {
    if (index >= _levelRoots.length) {
      return const Spacer();
    }
    LevelRoot levelRoot = _levelRoots[index];
    return Flex(
      direction: Axis.horizontal,
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.all(15),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.file_copy,
                      color: Colors.green,
                    ),
                    Text(
                      levelRoot.name ?? "",
                      style: getNormalTextStyle(),
                    ),
                  ],
                ),
                Visibility(
                  visible:
                      (levelRoot.content == null || levelRoot.content == "")
                          ? false
                          : true,
                  child: Text(
                    levelRoot.content?.split('\n').first ?? "",
                    style: getNormalTextStyle(),
                  ),
                ),
                Text(
                  "${levelRoot.updatedAt?.year.toString()}-"
                  "${levelRoot.updatedAt?.month.toString()}-"
                  "${levelRoot.updatedAt?.day.toString()} "
                  "${levelRoot.updatedAt?.hour.toString()}:"
                  "${levelRoot.updatedAt?.minute.toString()}:"
                  "${levelRoot.updatedAt?.second.toString()}",
                  style: getNormalTextStyle(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  AppBar titleUI() {
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
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.menu,
            color: Color.fromARGB(255, 180, 180, 180),
          ),
        ),
      ],
      elevation: 0,
      backgroundColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: titleUI(),
      body: Container(
        color: const Color.fromARGB(255, 245, 245, 245),
        child: getContentUI(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          dynamic isRefresh =
              await Navigator.of(context).pushNamed("/edit", arguments: 0);
          if (isRefresh ?? false) {
            _refreshData();
          }
        },
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
