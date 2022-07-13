import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class EditMarkdownState {
  final width = Get.width;
  final top = MediaQueryData.fromWindow(Get.window).padding.top;

  final FocusNode titleFocusNode = FocusNode();
  final FocusNode editFocusNode = FocusNode();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController markdownController = TextEditingController();

  late int articleID;

  late RxString markdownText;
  late RxString titleText;
  late RxBool editVisible;
  late RxBool viewVisible;

  EditMarkdownState() {
    var id = Get.parameters['articleID'];
    articleID = id != null ? int.parse(id) : 0;
    markdownText = "".obs;
    titleText = "".obs;
    editVisible = true.obs;
    viewVisible = true.obs;
  }
}
