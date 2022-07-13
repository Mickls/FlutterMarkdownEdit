import 'package:flutter/material.dart';
import 'package:flutter_md_edit/models/folder.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FolderState {
  final ScrollController scrollController = ScrollController();
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  int superID = 0;

  late RxList<dynamic> levelRoots;

  late RxList<dynamic> tempLevelRoots;

  FolderState() {
    levelRoots = [].obs;
    tempLevelRoots = [].obs;
  }
}
