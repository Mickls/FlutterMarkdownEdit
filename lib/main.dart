import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_md_edit/config/route.dart';
import 'package:flutter_md_edit/page/home/home_view.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(
      title: 'Welcome to Flutter',
      initialRoute: '/',
      getPages: RouteConfig.getPages,
      builder: (context, child) => Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
            }
          },
          child: child,
        ),
      ),
      home: const HomePage(),
    );
  }
}
