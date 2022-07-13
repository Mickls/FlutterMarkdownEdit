import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'folder_logic.dart';
import 'folder_state.dart';

class FolderPage extends StatelessWidget {
  const FolderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FolderLogic logic = Get.put(FolderLogic());
    final FolderState state = Get.find<FolderLogic>().state;

    return Scaffold(
      appBar: logic.appBarUI(),
      body: Container(
        color: const Color.fromARGB(255, 245, 245, 245),
        child: logic.getContentUI(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          await Navigator.of(context).pushNamed("/edit", arguments: 0);
          // _refreshData();
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
