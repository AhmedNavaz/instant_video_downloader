import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:instant_video_downloader/constants/colors.dart';
import 'package:instant_video_downloader/views/authentication/instagram_auth_view.dart';
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
    DownloadView(),
    StorySaverView(),
    const HistoryView(),
    const SettingsView()
  ];
  final List<PersistentBottomNavBarItem> _navBarItems = [
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.settings),
      title: 'Instagram',
      inactiveColorPrimary: Colors.black,
      activeColorPrimary: kPrimaryColor,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.download),
      title: 'Download',
      inactiveColorPrimary: Colors.black,
      activeColorPrimary: kPrimaryColor,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.downloading),
      title: 'Story Saver',
      inactiveColorPrimary: Colors.black,
      activeColorPrimary: kPrimaryColor,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.history),
      title: 'History',
      inactiveColorPrimary: Colors.black,
      activeColorPrimary: kPrimaryColor,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.settings),
      title: 'Settings',
      inactiveColorPrimary: Colors.black,
      activeColorPrimary: kPrimaryColor,
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
      hideNavigationBarWhenKeyboardShows: true,
      decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(10),
          colorBehindNavBar: Colors.black),
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
      navBarStyle: NavBarStyle.style2,
    );
  }
}
