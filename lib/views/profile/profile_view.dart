import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:instant_video_downloader/constants/colors.dart';
import 'package:instant_video_downloader/constants/uri.dart';
import 'package:instant_video_downloader/controllers/search_controller.dart';
import 'package:instant_video_downloader/models/profile.dart';
import 'package:http/http.dart' as http;
import 'package:numeral/numeral.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  http.Client get client => http.Client();
  Profile userProfile = Profile();
  SearchController searchController = Get.find<SearchController>();
  bool isLoading = false;
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    isLoading = true;
    getProfileDetails(searchController.userName2.value).then((value) {
      setState(() {
        isLoading = false;
      });
    });

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
    super.initState();
  }

  Future<void> getProfileDetails(String? username) async {
    try {
      http.Response response = await client.post(
        Uri.parse('${LOCALHOST}profile'),
        body: {"username": username},
      );
      Map<String, dynamic> jsonResponse = await jsonDecode(response.body);
      jsonResponse = jsonResponse['response'];
      setState(() {
        userProfile.fullName = jsonResponse['name'];
        userProfile.profilePic = searchController.profileImage2.value;
        userProfile.followers = jsonResponse['followers'];
        userProfile.following = jsonResponse['following'];
        userProfile.posts = jsonResponse['posts'];
        print(userProfile.posts);
      });
    } catch (e) {
      print("No user found!");
    }
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  void download(String? url) async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      await FlutterDownloader.enqueue(
              url: url!,
              savedDir: '/storage/emulated/0/Download',
              showNotification: true,
              openFileFromNotification: true,
              fileName: setFileName(url))
          .then((value) {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Downloading..."),
            padding: EdgeInsets.only(left: 10, bottom: 20, top: 10),
          ));
        });
      });
    }
  }

  String setFileName(String? url) {
    String fileName = url!;
    fileName =
        fileName.substring(fileName.lastIndexOf('/') + 1).split('?').first;
    return fileName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(searchController.userName2.value),
        backgroundColor: kPrimaryColor,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: kGradientColor,
            ))
          : Padding(
              padding: const EdgeInsets.only(top: 20, right: 10, left: 10),
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
                            backgroundImage:
                                NetworkImage(userProfile.profilePic!, scale: 1),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(userProfile.fullName ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                )),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(Numeral(userProfile.followers!).format(),
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const Text('Followers',
                              style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      Column(
                        children: [
                          Text(Numeral(userProfile.following!).format(),
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const Text('Following',
                              style: TextStyle(fontSize: 20)),
                        ],
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text("Posts",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: userProfile.posts!.length,
                      itemBuilder: (context, index) {
                        return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage(
                                    userProfile.posts![index]['thumbnail'],
                                    scale: 1),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (userProfile.posts![index]['type'] ==
                                        'video') {
                                      download(userProfile.posts![index]
                                          ['video_url']);
                                    } else {
                                      download(userProfile.posts![index]
                                          ['thumbnail']);
                                    }
                                  },
                                  child: const Align(
                                    alignment: Alignment.topRight,
                                    child: Icon(Icons.download_rounded,
                                        color: Colors.white, size: 30),
                                  ),
                                ),
                                userProfile.posts![index]['type'] == "video"
                                    ? const Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Icon(Icons.play_arrow_rounded,
                                            color: Colors.white, size: 40),
                                      )
                                    : Container(),
                              ],
                            ));
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
    );
  }
}
