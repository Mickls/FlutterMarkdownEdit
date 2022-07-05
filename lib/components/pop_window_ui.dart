import 'package:flutter/material.dart';

Widget titleEmptyDialog(BuildContext context) {
  return AlertDialog(
    title: const Text('注意了'),
    content: const Text('谁家孩子写文章不写标题就保存？'),
    actions: <Widget>[
      TextButton(child: const Text('我知道了'),onPressed: (){
        Navigator.pop(context);
      },),
    ],
  );
}