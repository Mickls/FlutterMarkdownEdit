import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'edit_markdown_logic.dart';
import 'edit_markdown_state.dart';

class EditMarkdownPage extends StatefulWidget {
  const EditMarkdownPage({Key? key}) : super(key: key);

  @override
  _EditMarkdownPageState createState() => _EditMarkdownPageState();
}

class _EditMarkdownPageState extends State<EditMarkdownPage> {
  final EditMarkdownLogic logic = Get.put(EditMarkdownLogic());
  final EditMarkdownState state = Get.find<EditMarkdownLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(top: state.top),
            height: state.top + 50,
            color: const Color.fromARGB(255, 249, 249, 251),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("取消"),
                ),
                TextButton(
                    onPressed: () async {
                      Future(() => logic.saveData());
                    },
                    child: const Text("保存"))
              ],
            ),
          ),
          logic.titleUI(),
          Expanded(
            child: logic.contentUI(),
          ),
          logic.shortcutButtonsUI(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<EditMarkdownLogic>();
    super.dispose();
  }
}