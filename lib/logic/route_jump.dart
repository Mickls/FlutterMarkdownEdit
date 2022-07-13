import 'package:get/route_manager.dart';

jump(String routePath, {Map<String, dynamic>? argument}) async {
  Uri uri;
  argument = argument ?? {};
  if (argument.isNotEmpty) {
    uri = Uri(path: routePath, queryParameters: argument);
  } else {
    uri = Uri(path: routePath);
  }
  await Get.toNamed(uri.toString());
}
