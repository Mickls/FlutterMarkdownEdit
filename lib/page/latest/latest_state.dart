import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class LatestState {
  final ScrollController scrollController = ScrollController();
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  late RxList<dynamic> levelRoots;
  late RxList<dynamic> tempLevelRoots;

  LatestState() {
    levelRoots = [].obs;
    tempLevelRoots = [].obs;
  }
}
