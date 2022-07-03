import 'package:flutter/material.dart';


class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/search');
          },
          child: Text("点击转跳")),
    );
  }
}

class SearchPage extends StatefulWidget {
  // const SearchPage({Key? key}) : super(key: key);


  @override
  State<StatefulWidget> createState() {
    return SearchPageState();
  }
}

class SearchPageState extends State<SearchPage>{
  String _result = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('搜索界面'),
        ),
        body: Column(
          children: [
            Text("获取到的内容为${_result}"),
            Center(
              child: ElevatedButton(
                  onPressed: () async {
                    var result = await Navigator.pushNamed(context, '/form');
                    setState((){
                      _result = result.toString();
                    });
                  },
                  child: const Text("点击转跳")),
            ),
          ],
        ),
      ),
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
    );
  }

}


class FormPage extends StatefulWidget {
  FormPage({Key? key}) : super(key: key);

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text("表单页面"),
      ),
      body: ElevatedButton(
          onPressed: () {
            Navigator.pop(context, "返回的数据");
          },
          child: const Text("点击转跳")),
    );
  }
}
