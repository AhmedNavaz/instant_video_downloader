import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_video_downloader/constants/controller.dart';
import 'package:instant_video_downloader/controllers/navigation_controller.dart';
import 'package:instant_video_downloader/router/router_generator.dart';
import 'package:instant_video_downloader/services/shared_pref.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  Get.put(NavigationController());
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  SharedPref.init();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      initialRoute: root,
      onGenerateRoute: RouteGenerator.onGeneratedRoutes,
      defaultTransition: Transition.zoom,
      navigatorKey: navigationController.navigationKey,
    );
  }
}
