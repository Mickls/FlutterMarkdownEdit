import 'package:flutter/material.dart';
import 'package:flutter_md_edit/page/home.dart';
import 'package:flutter_md_edit/page/edit.dart';
import 'package:flutter_md_edit/components/test_ui.dart';
import 'package:flutter_md_edit/models/db_utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final routes = {
      "/edit": (context, {arguments}) => EditUI(articleID:arguments),
      // '/search': (context,{arguments}) => SearchPage(arguments:arguments),
      '/search': (context) => new SearchPage(),
      '/form': (context) => FormPage(),
    };
    // DBProvider().init();

    return MaterialApp(
      title: 'Welcome to Flutter',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
            primary: Colors.green,
            onPrimary: Colors.white,
            onBackground: Colors.yellow,
            secondary: Colors.amber),
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: (RouteSettings settings) {
        // 统一处理
        final String? name = settings.name;
        final Function? pageContentBuilder = routes[name];
        if (pageContentBuilder != null) {
          if (settings.arguments != null) {
            final Route route = MaterialPageRoute(
                builder: (context) =>
                    pageContentBuilder(context, arguments: settings.arguments));
            return route;
          } else {
            final Route route = MaterialPageRoute(
                builder: (context) => pageContentBuilder(context));
            return route;
          }
        }
      },
      initialRoute: '/',
      home: const Home(),
    );
  }
}
