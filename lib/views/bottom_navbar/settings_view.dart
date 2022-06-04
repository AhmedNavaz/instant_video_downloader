import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_video_downloader/constants/colors.dart';
import 'package:instant_video_downloader/constants/uri.dart';
import 'package:instant_video_downloader/controllers/authController.dart';
import 'package:instant_video_downloader/models/user.dart';
import 'package:instant_video_downloader/services/shared_pref.dart';
import 'package:numeral/numeral.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class SettingsView extends StatefulWidget {
  SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  http.Client get client => http.Client();

  AuthController authController = Get.find<AuthController>();
  SharedPref sharedPref = SharedPref();

  Future<String?> setDownloadLocation() async {
    // get permission
    final status = await Permission.storage.request();
    if (status.isGranted) {
      String? path = await FilePicker.platform.getDirectoryPath();
      if (path != null) {
        await sharedPref.setDownloadLocation(path);
        return path;
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: kPrimaryColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: kAccentColor,
                      backgroundImage: NetworkImage(
                          authController.user.value.profilePic ?? '',
                          scale: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(authController.user.value.fullName ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                          )),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                        Numeral(authController.user.value.followers ?? 0)
                            .format(),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('Followers', style: TextStyle(fontSize: 20)),
                  ],
                ),
                Column(
                  children: [
                    Text(
                        Numeral(authController.user.value.following ?? 0)
                            .format(),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('Following', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: InkWell(
                onTap: () {
                  setDownloadLocation().then(
                    (value) {
                      setState(() {
                        authController.downloadLocation.value = value!;
                      });
                    },
                  );
                },
                child: Card(
                    child: ListTile(
                  leading: const Icon(
                    Icons.folder,
                    color: kAccentColor,
                  ),
                  title: const Text('Download Location',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text(authController.downloadLocation.toString()),
                )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: InkWell(
                onTap: () {},
                child: const Card(
                    child: ListTile(
                  leading: Icon(
                    Icons.privacy_tip,
                    color: kAccentColor,
                  ),
                  title: Text('Privacy Policy',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: InkWell(
                onTap: () {},
                child: const Card(
                    child: ListTile(
                  leading: Icon(
                    Icons.star,
                    color: kAccentColor,
                  ),
                  title: Text('Rate Us',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: InkWell(
                onTap: () {},
                child: const Card(
                    child: ListTile(
                  leading: Icon(
                    Icons.share,
                    color: kAccentColor,
                  ),
                  title: Text('Share App',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
