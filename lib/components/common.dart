import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_md_edit/components/search_ui.dart';
import 'package:flutter_md_edit/contains/icon.dart';
import 'package:flutter_md_edit/models/folder.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

Widget generalTitleComponents(String? title, int? type) {
  final IconData antIcon;
  String text = title ?? "";
  switch (type) {
    case articleType:
      {
        text = '$title.md';
        antIcon = AntIcons.fileMarkdown;
        break;
      }
    case folderType:
      {
        antIcon = AntIcons.folder;
        break;
      }
    default:
      {
        antIcon = AntIcons.file;
      }
  }
  return Row(
    children: [
      Icon(
        antIcon,
        size: 20,
      ),
      const SizedBox(
        width: 5,
      ),
      Text(
        text,
        style: const TextStyle(
          fontSize: 20,
        ),
      ),
    ],
  );
}

Widget getSearchUI(RxList<dynamic> root, temp) {
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
        if (temp.isNotEmpty) {
          root.clear();
          for (var element in temp) {
            root.add(element);
          }
          temp.clear();
        }
      } else {
        final levelRoots = await FolderProvider().queryLevelRootWithKey(query);
        if (temp.isEmpty) {
          temp.addAll(root);
        }
        root.value = levelRoots;
      }
      return [];
    },
    noItemsFoundWidget: Container(),
  );
}
