import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_md_edit/components/common.dart';
import 'package:flutter_md_edit/config/route.dart';
import 'package:flutter_md_edit/contains/color.dart';
import 'package:flutter_md_edit/contains/font_style.dart';
import 'package:flutter_md_edit/contains/icon.dart';
import 'package:flutter_md_edit/logic/route_jump.dart';
import 'package:flutter_md_edit/models/article.dart';
import 'package:flutter_md_edit/models/folder.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'latest_state.dart';

class LatestLogic extends GetxController {
  final LatestState state = LatestState();

  loadData({int limit = 10, offset = 0}) async {
    if (state.levelRoots.length > offset) {
      offset = state.levelRoots.length;
    }
    var levelRoots =
    await FolderProvider().queryLevelRoot(limit: limit, offset: offset);
    if (levelRoots.isNotEmpty) {
      var i = 1;
      for (var element in levelRoots) {
        if ((offset + i) > state.levelRoots.length) {
          state.levelRoots.add(element);
        } else {
          state.levelRoots[offset + i] = element;
        }
        i++;
      }
      state.refreshController.loadComplete();
    } else {
      state.refreshController.loadNoData();
    }
  }

  refreshData({int offset = 0, limit = 10}) async {
    var levelRoots =
    await FolderProvider().queryLevelRoot(offset: offset, limit: limit);
    state.levelRoots.value = levelRoots;
    state.refreshController.refreshCompleted();
    state.refreshController.loadComplete();
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

  Widget _renameUI(String text) {
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
                  Get.offNamed(RouteConfig.main);
                },
                child: Text(
                  "取消",
                  style: getNormalTextStyle(),
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.back(result: renameController.text);
                  // Navigator.pop(context, renameController.text);
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

  Widget _showCardDialog(int index) {
    return Column(
      children: <Widget>[
        GestureDetector(
            onTap: () async {
              Get.back();
              final levelRoot = state.levelRoots[index];
              String renameTitle = await Get.dialog(
                Padding(
                    padding: const EdgeInsets.all(30),
                    child: _renameUI(levelRoot.name ?? "")),
              );
              Article? article = Article(
                title: renameTitle,
                content: levelRoot.content,
              );
              await ArticleProvider().update(article, levelRoot.id ?? 0);
              refreshData();
            },
            child: generateDialogButton("重命名", Icons.edit_note_outlined)),
        const Divider(),
        GestureDetector(
            onTap: () {
              Get.back();
            },
            child: generateDialogButton("移动", Icons.drive_file_move_outline)),
        const Divider(),
        GestureDetector(
            onTap: () async {
              Get.back();
              await ArticleProvider()
                  .delete(state.levelRoots[index].id ?? 0);
              refreshData();
            },
            child: generateDialogButton("删除", Icons.delete_outline)),
      ],
    );
  }

  Widget articleTitleUI(int index) {
    var levelRoot = state.levelRoots[index];
    var updateTime = levelRoot.updatedAt;
    return GFListTile(
      title: generalTitleComponents(levelRoot.name, levelRoot.type),
      description: Text("${updateTime?.year.toString()}-"
          "${updateTime?.month.toString()}-"
          "${updateTime?.day.toString()} "),
      color: Colors.white,
      onTap: () async {
        await jump(
          RouteConfig.editMarkdown,
          argument: {'articleID': state.levelRoots[index].id.toString()},
        );
        refreshData();
      },
      onLongPress: () async {
        Get.dialog(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                color: Colors.white,
                child: _showCardDialog(index),
              ),
            ],
          ),
        );
      },
    );
  }

  AppBar latestAppBarUI() {
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
          offset: const Offset(0, 56),
          icon: const Icon(
            AntIcons.menu,
            color: appBarIconColor,
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
          },
        ),
      ],
      elevation: 0,
      backgroundColor: Color.fromARGB(255, 245, 245, 245),
    );
  }

  Widget getContentUI() {
    return Column(
      children: [
        getSearchUI(state.levelRoots, state.tempLevelRoots),
        Expanded(
          child: Obx(() {
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
              controller: state.refreshController,
              onRefresh: refreshData,
              onLoading: loadData,
              child: ListView.builder(
                itemCount: state.levelRoots.length,
                controller: state.scrollController,
                // shrinkWrap: true,
                itemBuilder: (context, index) {
                  // return articleCartUI(index);
                  return articleTitleUI(index);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  void onReady() {
    loadData();
    super.onReady();
  }
}
