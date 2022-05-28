import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_video_downloader/constants/controller.dart';
import 'package:instant_video_downloader/controllers/navigation_controller.dart';
import 'package:instant_video_downloader/router/router_generator.dart';
import 'package:instant_video_downloader/services/shared_pref.dart';

void main() {
  Get.put(NavigationController());
  WidgetsFlutterBinding.ensureInitialized();
  SharedPref.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Instant Video Downloader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: root,
      onGenerateRoute: RouteGenerator.onGeneratedRoutes,
      defaultTransition: Transition.zoom,
      navigatorKey: navigationController.navigationKey,
    );
  }
}
