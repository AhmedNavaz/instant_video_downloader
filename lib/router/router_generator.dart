// STATIC ROUTES NAME
import 'package:flutter/material.dart';
import 'package:instant_video_downloader/views/bottom_navbar/instagram_auth_view.dart';
import 'package:instant_video_downloader/views/bottom_navbar/body.dart';
import 'package:instant_video_downloader/views/download/download_page.dart';
import 'package:instant_video_downloader/views/profile/profile_view.dart';

const String root = '/';
const String downloadPage = '/download-page';
const String instagramAuth = '/instagram-auth';
const String profileView = '/profile-view';

// ignore: todo
// TODO : ROUTES GENERATOR CLASS THAT CONTROLS THE FLOW OF NAVIGATION/ROUTING

class RouteGenerator {
  // FUNCTION THAT HANDLES ROUTING
  static Route<dynamic> onGeneratedRoutes(RouteSettings settings) {
    late dynamic args;
    if (settings.arguments != null) {
      args = settings.arguments as Map;
    }
    switch (settings.name) {
      case root:
        return _getPageRoute(const NavBody());

      case downloadPage:
        return _getPageRoute(DownloadPage());

      case instagramAuth:
        return _getPageRoute(InstagramAuthView());

      case profileView:
        return _getPageRoute(ProfileView());

      default:
        return _errorRoute();
    }
  }

  // FUNCTION THAT HANDLES NAVIGATION
  static PageRoute _getPageRoute(Widget child) {
    return MaterialPageRoute(builder: (ctx) => child);
  }

  // 404 PAGE
  static PageRoute _errorRoute() {
    return MaterialPageRoute(builder: (ctx) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('404'),
        ),
        body: const Center(
          child: Text('ERROR 404: Not Found'),
        ),
      );
    });
  }
}

class IdScreen {}
