import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_md_edit/models/article.dart';
import 'package:flutter_md_edit/utils/markdown_highlight.dart';
import 'package:flutter_md_edit/utils/overrid_stack.dart';

class EditUI extends StatefulWidget {
  final int articleID;

  const EditUI({Key? key, required this.articleID}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EditUIState();
  }
}

class EditUIState extends State<EditUI> {
  var _top = 0.0;
  var _width = 0.0;
  bool _editVisible = true;
  bool _viewVisible = true;
  FocusNode editFocusNode = FocusNode();
  FocusNode titleFocusNode = FocusNode();

  final TextEditingController markdownController = TextEditingController();
  final TextEditingController titleController = TextEditingController();

  var markdownText = "";
  var titleText = "";

  Future<String> _loadText() async {
    return markdownText;
  }

  _loadData(int articleID) async {
    if (articleID != 0) {
      Article article = await ArticleProvider().query(articleID);
      titleController.text = article.title ?? "";
      markdownController.text = article.content ?? "";
      setState(() {
        titleText = article.title ?? "";
        markdownText = article.content ?? "";
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData(widget.articleID);
    editFocusNode.addListener(() async {
      if (editFocusNode.hasFocus) {
        print("获取焦点");
      } else {
        // TODO: 两个逻辑，新建文件保存草稿箱，非新建文件直接保存
        if (widget.articleID != 0) {
          Article article = Article(
            title: titleText,
            content: markdownText,
            superFolderID: 0,
          );
          await ArticleProvider()
              .update(article, widget.articleID);
        } else {
          Article article = Article(
            title: titleText,
            content: markdownText,
            superFolderID: 0,
          );
          await ArticleProvider().insert(article);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _top = MediaQuery.of(context).padding.top;
    _width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(top: _top),
            height: _top + 50,
            color: const Color.fromARGB(255, 249, 249, 251),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    bool isRefresh = false;
                    Navigator.of(context).pop(isRefresh);
                  },
                  child: Text("取消"),
                ),
                TextButton(
                    onPressed: () async {
                      bool isRefresh = false;
                      if (titleText.isNotEmpty) {
                        isRefresh = true;
                        if (widget.articleID != 0) {
                          Article article = Article(
                            title: titleText,
                            content: markdownText,
                            superFolderID: 0,
                          );
                          await ArticleProvider()
                              .update(article, widget.articleID);
                        } else {
                          Article article = Article(
                            title: titleText,
                            content: markdownText,
                            superFolderID: 0,
                          );
                          await ArticleProvider().insert(article);
                        }
                        Navigator.of(context).pop(isRefresh);
                      } else {
                        await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('注意了'),
                                content: Text('谁家孩子写文章不写标题就保存？'),
                                actions: <Widget>[
                                  FlatButton(child: Text('我知道了'),onPressed: (){
                                    Navigator.pop(context);
                                  },),
                                ],
                              );
                            },
                        );
                      }
                    },
                    child: Text("保存"))
              ],
            ),
          ),
          titleUI(),
          Expanded(
            child: contentUI(),
          ),
          shortcutButtonsUI(),
        ],
      ),
    );
  }

  // 标题界面
  Widget titleUI() {
    return Container(
      height: 50,
      child: Row(
        children: [
          Visibility(visible: _editVisible, child: editTitleUI()),
          Visibility(visible: _viewVisible, child: titleViewUI()),
        ],
      ),
    );
  }

  // 标题编辑区界面
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
          controller: titleController,
          maxLines: 1,
          minLines: 1,
          maxLength: 50,
          focusNode: titleFocusNode,
          decoration: const InputDecoration(
              counterText: "",
              hintText: "请输入标题",
              hintStyle: TextStyle(color: Color.fromARGB(255, 154, 154, 156)),
              border: InputBorder.none),
          style: TextStyle(color: Color.fromARGB(255, 42, 41, 48)),
          onChanged: (text) {
            setState(() {
              titleText = text;
            });
          },
        ),
      ),
    );
  }

  // 标题预览区界面
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
              titleFocusNode.unfocus();
              editFocusNode.unfocus();
            },
            child: Text(
              titleText,
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
        ));
  }

  Widget contentUI() {
    return Row(
      children: [
        Visibility(
          visible: _editVisible,
          child: Expanded(
            flex: 1,
            child: editMarkDownUI(),
          ),
        ),
        Visibility(
          visible: _viewVisible,
          child: Expanded(
            flex: 1,
            child: viewUI(),
          ),
        ),
      ],
    );
  }

  // 编辑界面
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
            controller: markdownController,
            maxLines: 9999,
            decoration: null,
            onChanged: (text) {
              setState(() {
                markdownText = text;
              });
            },
            focusNode: editFocusNode,
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
                setState(() {
                  if (_viewVisible) {
                    _viewVisible = false;
                  } else {
                    _viewVisible = true;
                  }
                });
              },
            ),
          )
        ],
      ),
    );
  }

  // 预览界面
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
            editFocusNode.unfocus();
            titleFocusNode.unfocus();
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
              setState(() {
                if (_editVisible) {
                  _editVisible = false;
                } else {
                  _editVisible = true;
                }
              });
            },
          ),
        )
      ],
    );
  }

  // 快捷按钮界面
  Widget shortcutButtonsUI() {
    return Visibility(
      visible: _editVisible,
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

  Widget insertButtonUI(String name, String insertText) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        insertWord(insertText);
      },
      child: Container(
        // color: Colors.red,
        width: _width / 6,
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

  // 插入字符
  void insertWord(String word) {
    int textLength = markdownController.text.length;
    int startIndex = markdownController.selection.start;
    int endIndex = markdownController.selection.end;
    String startText = markdownController.text.substring(0, startIndex);
    String rangeText = markdownController.text.substring(startIndex, endIndex);
    String beforeText = markdownController.text.substring(0, endIndex);
    String endText = markdownController.text.substring(endIndex, textLength);

    int positionIndex = endIndex;
    String allText = markdownController.text;
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
        } else if (beforeText.endsWith("\n``")) {
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
    markdownController.text = allText;
    markdownController.selection =
        TextSelection.fromPosition(TextPosition(offset: positionIndex));
    // 触发渲染markdown
    setState(() {
      markdownText = allText;
    });
  }
}
