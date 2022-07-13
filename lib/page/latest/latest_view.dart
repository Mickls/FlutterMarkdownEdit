import 'package:flutter/material.dart';
import 'package:flutter_md_edit/config/route.dart';
import 'package:flutter_md_edit/logic/route_jump.dart';
import 'package:get/get.dart';

import 'latest_logic.dart';
import 'latest_state.dart';

class LatestPage extends StatelessWidget {
  const LatestPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final LatestLogic logic = Get.put(LatestLogic());
    final LatestState state = Get.find<LatestLogic>().state;
    return Scaffold(
      appBar: logic.latestAppBarUI(),
      body: Container(
        color: const Color.fromARGB(255, 245, 245, 245),
        child: logic.getContentUI(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          jump(RouteConfig.editMarkdown);
          logic.refreshData();
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