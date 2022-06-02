import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:instant_video_downloader/constants/colors.dart';
import 'package:instant_video_downloader/views/bottom_navbar/instagram_auth_view.dart';
import 'package:instant_video_downloader/views/bottom_navbar/download_view.dart';
import 'package:instant_video_downloader/views/bottom_navbar/history_view.dart';
import 'package:instant_video_downloader/views/bottom_navbar/settings_view.dart';
import 'package:instant_video_downloader/views/bottom_navbar/story_saver_view.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class NavBody extends StatefulWidget {
  const NavBody({Key? key}) : super(key: key);

  @override
  _NavBodyState createState() => _NavBodyState();
}

class _NavBodyState extends State<NavBody> {
  final List<Widget> _children = [
    InstagramAuthView(),
    const DownloadView(),
    StorySaverView(),
    HistoryView(),
    SettingsView()
  ];
  final List<PersistentBottomNavBarItem> _navBarItems = [
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.login),
      title: 'Instagram',
      inactiveColorPrimary: Colors.white,
      activeColorPrimary: Colors.white,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.download),
      title: 'Download',
      inactiveColorPrimary: Colors.white,
      activeColorPrimary: Colors.white,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.downloading),
      title: 'Story Saver',
      inactiveColorPrimary: Colors.white,
      activeColorPrimary: Colors.white,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.history),
      title: 'History',
      inactiveColorPrimary: Colors.white,
      activeColorPrimary: Colors.white,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.settings),
      title: 'Settings',
      inactiveColorPrimary: Colors.white,
      activeColorPrimary: Colors.white,
    ),
  ];

  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  @override
  initState() {
    super.initState();
    initializeDownloder();
  }

  void initializeDownloder() async {
    await FlutterDownloader.initialize(debug: true);
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _children,
      items: _navBarItems,
      confineInSafeArea: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: kPrimaryColor,
      hideNavigationBarWhenKeyboardShows: true,
      decoration: const NavBarDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        colorBehindNavBar: Colors.white,
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: const ItemAnimationProperties(
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: const ScreenTransitionAnimation(
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle: NavBarStyle.style9,
    );
  }
}
