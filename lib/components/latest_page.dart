import 'package:flutter/material.dart';
import 'package:flutter_md_edit/contains/icon.dart';
import 'package:flutter_md_edit/models/folder.dart';
import 'package:getwidget/getwidget.dart';

Widget titleUI(String title) {
  return Row(
    children: [
      const Icon(
        AntIcons.fileMarkdown,
        size: 20,
      ),
      const SizedBox(
        width: 5,
      ),
      Text(
        '$title.md',
        style: const TextStyle(
          fontSize: 20,
        ),
      ),
    ],
  );
}
