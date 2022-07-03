import 'package:flutter/material.dart';

class HandleUI extends StatelessWidget{
  final int articleID;

  const HandleUI({Key? key, required this.articleID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (value){
        print(value);
      },
      itemBuilder: (BuildContext context){
        return <PopupMenuEntry<String>>[
          PopupMenuItem(
            value: '重命名',
            child: Text('重命名'),
          ),
          PopupMenuDivider(),
          PopupMenuItem(
            value: '移动',
            child: Text('移动'),
          ),
          PopupMenuDivider(),
          PopupMenuItem(
            value: '删除',
            child: Text('删除'),
          ),
        ];
      },
    );
  }

}