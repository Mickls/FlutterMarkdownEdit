import 'package:flutter_md_edit/page/edit_markdown/edit_markdown_view.dart';
import 'package:flutter_md_edit/page/home/home_view.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

class RouteConfig{
  static const String main = "/";

  static const String editMarkdown = "/edit/markdown";

  static final List<GetPage> getPages = [
    GetPage(name: main, page: () => const HomePage()),
    GetPage(name: editMarkdown, page: () => const EditMarkdownPage()),
  ];
}