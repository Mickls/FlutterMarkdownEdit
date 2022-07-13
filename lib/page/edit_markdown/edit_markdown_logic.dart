import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_md_edit/logic/file_data.dart';
import 'package:flutter_md_edit/models/article.dart';
import 'package:flutter_md_edit/utils/markdown_highlight.dart';
import 'package:flutter_md_edit/utils/override_stack.dart';
import 'package:get/get.dart';

import 'edit_markdown_state.dart';

class EditMarkdownLogic extends GetxController {
  final EditMarkdownState state = EditMarkdownState();

  saveData() async {
    if (state.titleText.isNotEmpty) {
      var id = state.articleID;
      print("${DateTime.now().millisecond}: save, $state.articleID");
      if (state.articleID != 0) {
        id = state.articleID;
      }
      state.articleID =
          await saveFile(id, state.titleText.value, state.markdownText.value);
      Get.back();
      // if (mounted) {
      //   Navigator.of(context).pop();
      // }
    } else {
      await Get.dialog(
        AlertDialog(
          title: const Text('注意了'),
          content: const Text('谁家孩子写文章不写标题就保存？'),
          actions: <Widget>[
            TextButton(
              child: const Text('我知道了'),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        ),
      );
    }
  }

  Future<String> _loadText() async {
    return state.markdownText.value;
  }

  Widget editTitleUI() {
    return Expanded(
      flex: 1,
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.only(left: 15),
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    width: 0.5, color: Color.fromARGB(255, 215, 215, 215))),
            color: Color.fromARGB(255, 249, 249, 251)),
        child: TextField(
          controller: state.titleController,
          maxLines: 1,
          minLines: 1,
          maxLength: 50,
          focusNode: state.titleFocusNode,
          decoration: const InputDecoration(
              counterText: "",
              hintText: "请输入标题",
              hintStyle: TextStyle(color: Color.fromARGB(255, 154, 154, 156)),
              border: InputBorder.none),
          style: TextStyle(color: Color.fromARGB(255, 42, 41, 48)),
          onChanged: (text) {
            state.titleText.value = text;
          },
        ),
      ),
    );
  }

  Widget titleViewUI() {
    return Expanded(
      flex: 1,
      child: Container(
        padding: const EdgeInsets.only(top: 10, left: 15, right: 10),
        height: double.infinity,
        // color: const Color.fromARGB(255, 240, 240, 240),
        decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  width: 0.5, color: Color.fromARGB(255, 215, 215, 215))),
          color: Color.fromARGB(255, 247, 248, 250),
        ),
        child: GestureDetector(
          onTap: () {
            state.titleFocusNode.unfocus();
            state.editFocusNode.unfocus();
          },
          child: Text(
            state.titleText.value,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 41, 40, 45),
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
          ),
        ),
      ),
    );
  }

  Widget editMarkDownUI() {
    return Container(
      padding: const EdgeInsets.only(left: 15, top: 15, right: 25),
      // width: MediaQuery.of(context).size.width / 2,
      height: double.infinity,
      child: OverRidStack(
        // alignment: Alignment.topRight,
        clipBehavior: Clip.none,
        children: [
          TextField(
            controller: state.markdownController,
            maxLines: 9999,
            decoration: null,
            onChanged: (text) {
              // setState(() {
              //   markdownText = text;
              // });
              state.markdownText.value = text;
            },
            focusNode: state.editFocusNode,
          ),
          Positioned(
            right: -35,
            top: -25,
            child: IconButton(
              icon: const Icon(
                Icons.zoom_out_map,
                size: 20,
                color: Color.fromARGB(255, 220, 220, 220),
              ),
              onPressed: () {
                if (state.viewVisible.value) {
                  state.viewVisible.value = false;
                } else {
                  state.viewVisible.value = true;
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget viewUI() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          child: Container(
            // padding: EdgeInsets.only(top: _top),
            color: const Color.fromARGB(255, 247, 248, 250),
            // width: MediaQuery.of(context).size.width / 2,
            height: double.infinity,
            child: Scrollbar(
              child: FutureBuilder(
                future: _loadText(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return Markdown(
                      data: snapshot.data,
                      softLineBreak: true,
                      selectable: true,
                      styleSheetTheme: MarkdownStyleSheetBaseTheme.material,
                      styleSheet: MarkdownStyleSheet(
                        // 支持修改样式
                        code: const TextStyle(
                          backgroundColor: Colors.white,
                          // fontSize: 20
                        ),
                      ),
                      syntaxHighlighter: HighLight(),
                    );
                  } else {
                    return const Center(
                      child: Text("加载中..."),
                    );
                  }
                },
              ),
            ),
          ),
          onTap: () {
            state.editFocusNode.unfocus();
            state.titleFocusNode.unfocus();
          },
        ),
        Positioned(
          right: -10,
          top: -10,
          child: IconButton(
            icon: const Icon(
              Icons.zoom_out_map,
              size: 20,
              color: Color.fromARGB(255, 200, 200, 200),
            ),
            onPressed: () {
              if (state.editVisible.value) {
                state.editVisible.value = false;
              } else {
                state.editVisible.value = true;
              }
            },
          ),
        )
      ],
    );
  }

  Widget titleUI() {
    return Obx(() {
      return SizedBox(
        height: 50,
        child: Row(
          children: [
            Visibility(visible: state.editVisible.value, child: editTitleUI()),
            Visibility(visible: state.viewVisible.value, child: titleViewUI()),
          ],
        ),
      );
    });
  }

  Widget contentUI() {
    return Obx(() {
      return Row(
        children: [
          Visibility(
            visible: state.editVisible.value,
            child: Expanded(
              flex: 1,
              child: editMarkDownUI(),
            ),
          ),
          Visibility(
            visible: state.viewVisible.value,
            child: Expanded(
              flex: 1,
              child: viewUI(),
            ),
          ),
        ],
      );
    });
  }

  void insertWord(String word) {
    int textLength = state.markdownController.text.length;
    int startIndex = state.markdownController.selection.start;
    int endIndex = state.markdownController.selection.end;
    String startText = state.markdownController.text.substring(0, startIndex);
    String rangeText =
        state.markdownController.text.substring(startIndex, endIndex);
    String beforeText = state.markdownController.text.substring(0, endIndex);
    String endText =
        state.markdownController.text.substring(endIndex, textLength);

    int positionIndex = endIndex;
    String allText = state.markdownController.text;
    if (startIndex == endIndex) {
      // #号标记插入
      if (word.contains("#")) {
        word = "$word ";
        if (beforeText.endsWith("# ")) {
          beforeText = beforeText.trimRight();
          positionIndex = beforeText.length;
        }
      }
      // `号标记插入
      else if (word.contains("`")) {
        if (!beforeText.endsWith("`") &&
            (endText.startsWith(" ") ||
                endText.startsWith("\n") ||
                endText == "")) {
          endText = "`$endText";
        } else if (beforeText.endsWith("`") && endText.startsWith("`")) {
          word = "";
          positionIndex += 1;
        } else if (beforeText.endsWith("\n``") || startIndex==2) {
          word = "$word\n";
          endText = "\n```$endText";
        }
      }
      // "号标记插入
      else if (word.contains("\"")) {
        if (!beforeText.endsWith("\"") &&
            (endText.startsWith(" ") ||
                endText.startsWith("\n") ||
                endText == "")) {
          endText = "\"$endText";
        } else if (beforeText.endsWith("\"") && endText.startsWith("\"")) {
          word = "";
          positionIndex += 1;
        }
      }
      // *号标记插入
      else if (word.contains("*")) {
        if (!beforeText.endsWith("*") &&
            (endText.startsWith(" ") ||
                endText.startsWith("\n") ||
                endText == "")) {
          endText = "*$endText";
        } else if (beforeText.endsWith("*") && endText.startsWith("*")) {
          word = "";
          positionIndex += 1;
        } else if (beforeText.endsWith("**") &&
            (endText.startsWith(" ") ||
                endText.startsWith("\n") ||
                endText == "")) {
          word = "";
          endText = "**$endText";
        }
      } else {
        word = "$word ";
      }
      // 设置插入文字和光标位置
      allText = "$beforeText$word$endText";
      positionIndex += word.length;
    } else {
      // #号标记插入
      if (word.contains("#") && beforeText.endsWith("# ")) {
        beforeText = beforeText.trimRight();
        endIndex = beforeText.length;
        allText = "$startText$word$rangeText$endText";
        positionIndex = startIndex + 1;
      }
      // `号，"号，*号标记插入
      else if (word.contains("`") ||
          word.contains("\"") ||
          word.contains("*")) {
        rangeText = "$word$rangeText$word";
        allText = "$startText$rangeText$endText";
        positionIndex += word.length;
      }
      // 其余符号插入处理
      else {
        word = "$word ";
        allText = "$startText$word$rangeText$endText";
        positionIndex = startIndex + word.length;
      }
    }
    // 设置插入文字和光标位置
    state.markdownController.text = allText;
    state.markdownController.selection =
        TextSelection.fromPosition(TextPosition(offset: positionIndex));
    // 触发渲染markdown
    // setState(() {
    //   markdownText = allText;
    // });
    state.markdownText.value = allText;
  }

  Widget insertButtonUI(String name, String insertText) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        insertWord(insertText);
      },
      child: Container(
        // color: Colors.red,
        width: state.width / 6,
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              color: Colors.green,
              fontFamily: 'simplified',
            ),
          ),
        ),
      ),
    );
  }

  Widget shortcutButtonsUI() {
    return Visibility(
      visible: state.editVisible.value,
      child: SizedBox(
        height: 40,
        // color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            insertButtonUI('#', '#'),
            insertButtonUI('`', '`'),
            insertButtonUI('"', '"'),
            insertButtonUI('>', '>'),
            insertButtonUI('-', '-'),
            insertButtonUI('*', '*'),
          ],
        ),
      ),
    );
  }

  _loadData() async {
    if (state.articleID != 0) {
      Article article = await ArticleProvider().query(state.articleID);
      state.titleController.text = article.title ?? "";
      state.markdownController.text = article.content ?? "";
      state.titleText.value = article.title ?? "";
      state.markdownText.value = article.content ?? "";
    }
  }

  _autoSave() async {
    if (state.editFocusNode.hasFocus || state.titleFocusNode.hasFocus) {
      print("获取焦点");
    } else {
      print("${DateTime.now().millisecond}: autosave, ${state.articleID}");
      // var id = state.articleID;
      // if (state.articleID != 0){
      //   id = state.articleID;
      // }
      state.articleID = await autoSaveFile(
        state.articleID,
        state.titleText.value,
        state.markdownText.value,
      );
    }
  }

  @override
  void onReady() {
    _loadData();
    state.titleFocusNode.addListener(() async {
      Future(() => _autoSave());
    });
    state.editFocusNode.addListener(() async {
      Future(() => _autoSave());
    });
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
}
