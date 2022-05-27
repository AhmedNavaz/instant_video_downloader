import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:instant_video_downloader/constants/colors.dart';
import 'package:http/http.dart' as http;
import 'package:instant_video_downloader/constants/controller.dart';
import 'package:instant_video_downloader/constants/uri.dart';
import 'package:instant_video_downloader/controllers/search_controller.dart';
import 'package:instant_video_downloader/models/post.dart';
import 'package:instant_video_downloader/router/router_generator.dart';
import 'package:instant_video_downloader/services/shared_pref.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadView extends StatefulWidget {
  const DownloadView({Key? key}) : super(key: key);

  @override
  State<DownloadView> createState() => _DownloadViewState();
}

class _DownloadViewState extends State<DownloadView> {
  http.Client get client => http.Client();
  TextEditingController userNameController = TextEditingController();
  TextEditingController postUrlController = TextEditingController();
  SearchController searchController = Get.put(SearchController());

  final _formKey = GlobalKey<FormState>();
  SharedPref sharedPref = Get.put(SharedPref());

  bool isSearching = false;
  bool isPasted = false;
  bool isGettingPost = false;
  bool noThanks = false;
  final ReceivePort _port = ReceivePort();

  final Post _post = Post();

  Future<String?> getDP(String userName) async {
    try {
      http.Response response = await client.post(
        Uri.parse('${LOCALHOST}dp'),
        body: {"query": userName},
      );
      Map<String, dynamic> jsonResponse = await jsonDecode(response.body);
      var result = jsonResponse["response"];
      if (result.isEmpty) {
        return "Sorry an error occured";
      }
      return result.toString();
    } catch (e) {
      print("No user found!");
      return e.toString();
    }
  }

  Future<void> generateDownloadLink(String? url) async {
    try {
      http.Response response = await client.post(
        Uri.parse('${LOCALHOST}post'),
        body: {"url": url},
      );
      Map<String, dynamic> jsonResponse = await jsonDecode(response.body);
      setState(() {
        _post.thumbnail = jsonResponse["node"]["display_url"];
        String? postTitle = jsonResponse["node"]["edge_media_to_caption"]
            ["edges"][0]["node"]["text"];
        _post.title = postTitle!.substring(0, min(postTitle!.length, 50));
        _post.duration = jsonResponse["node"]["video_duration"];
        _post.username = jsonResponse["node"]["owner"]["username"];
        _post.profilePic = jsonResponse["node"]["owner"]["profile_pic_url"];
        _post.url = jsonResponse["node"]["video_url"];
      });
    } catch (e) {
      print("No user found!");
    }
  }

  Future<String?> login() async {
    try {
      http.Response response = await client.post(
        Uri.parse('${LOCALHOST}login'),
        body: {
          "username": "itchaboey",
          "password": "g6g)6/F8T&C&@N\$",
        },
      );
      Map<String, dynamic> jsonResponse = await jsonDecode(response.body);
      print(jsonResponse);
    } catch (e) {
      print("No user found!");
      return e.toString();
    }
    return null;
  }

  @override
  void initState() {
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

  Future<String?> _getClipboardText() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    return clipboardData?.text;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Instant Video Downloader'),
          backgroundColor: kPrimaryColor,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: kPrimaryColor,
            tabs: [
              Tab(text: 'Post/Video'),
              Tab(text: 'DP'),
              Tab(text: 'Profile'),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                height: MediaQuery.of(context).size.height * 0.3,
                color: kPrimaryColor,
                child: TabBarView(
                  children: [
                    Column(children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: postUrlController,
                              cursorColor: Colors.white,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 20),
                              decoration: const InputDecoration(
                                fillColor: kSecondaryColor,
                                filled: true,
                                contentPadding: EdgeInsets.all(18),
                                hintText: 'Enter URL',
                                hintStyle: TextStyle(color: Colors.white),
                                border: InputBorder.none,
                              ),
                            ),
                            const SizedBox(height: 55),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isPasted = true;
                                      isGettingPost = true;
                                    });

                                    _getClipboardText().then((value) {
                                      postUrlController.text = value!;
                                      generateDownloadLink(value).then((value) {
                                        setState(() {
                                          isGettingPost = false;
                                        });
                                      });
                                    });
                                  },
                                  child: const Text("Paste Link",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                      )),
                                  style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(70, 50),
                                      primary: kBackgroundColor),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      download(_post.url);
                                      sharedPref
                                          .addPostListToSharedPrefs(_post);
                                    }
                                  },
                                  child: const Text("Download",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      )),
                                  style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(70, 50),
                                      primary: kAccentColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ]),
                    Column(children: [
                      Form(
                        key: _formKey,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: userNameController,
                                onChanged: (value) {
                                  setState(() {
                                    isSearching = true;
                                  });
                                },
                                cursorColor: Colors.white,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                                decoration: const InputDecoration(
                                  fillColor: kSecondaryColor,
                                  filled: true,
                                  contentPadding: EdgeInsets.all(18),
                                  hintText: 'Enter Username',
                                  hintStyle: TextStyle(color: Colors.white),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  await getDP(userNameController.text).then(
                                    (value) {
                                      setState(() {
                                        searchController.profileImage.value =
                                            value!;
                                        searchController.userName.value =
                                            userNameController.text;
                                      });
                                      isSearching = false;
                                      return null;
                                    },
                                  );
                                }
                              },
                              child: const Icon(Icons.search, size: 30),
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(80, 60),
                                  primary: kAccentColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      isSearching
                          ? const Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: Center(
                                  child: CircularProgressIndicator(
                                color: Colors.white,
                              )),
                            )
                          : Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    navigationController
                                        .navigateTo(downloadPage);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundColor: kAccentColor,
                                      backgroundImage: NetworkImage(
                                          searchController.profileImage
                                              .toString(),
                                          scale: 1),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '@${userNameController.text}',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 16),
                                ),
                              ],
                            ),
                    ]),
                    Column(children: [
                      Form(
                        key: _formKey,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: userNameController,
                                onChanged: (value) {
                                  setState(() {
                                    isSearching = true;
                                  });
                                },
                                cursorColor: Colors.white,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                                decoration: const InputDecoration(
                                  fillColor: kSecondaryColor,
                                  filled: true,
                                  contentPadding: EdgeInsets.all(18),
                                  hintText: 'Enter Username',
                                  hintStyle: TextStyle(color: Colors.white),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  await getDP(userNameController.text).then(
                                    (value) {
                                      setState(() {
                                        searchController.profileImage.value =
                                            value!;
                                        searchController.userName.value =
                                            userNameController.text;
                                      });
                                      isSearching = false;
                                      return null;
                                    },
                                  );
                                }
                              },
                              child: const Icon(Icons.search, size: 30),
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(80, 60),
                                  primary: kAccentColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      isSearching
                          ? const Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: Center(
                                  child: CircularProgressIndicator(
                                color: Colors.white,
                              )),
                            )
                          : Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    navigationController
                                        .navigateTo(downloadPage);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundColor: kAccentColor,
                                      backgroundImage: NetworkImage(
                                          searchController.profileImage
                                              .toString(),
                                          scale: 1),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '@${userNameController.text}',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 16),
                                ),
                              ],
                            ),
                    ]),
                  ],
                ),
              ),
              isPasted
                  ? Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 10),
                      child: isGettingPost
                          ? const Center(child: CircularProgressIndicator())
                          : Row(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 150,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                        ),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                _post.thumbnail ?? ""),
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Container(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: Text(
                                                  _post.duration == null
                                                      ? ''
                                                      : _post.duration
                                                          .toString()
                                                          .split('.')[0],
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16)),
                                            )),
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10, right: 5),
                                              child: CircleAvatar(
                                                radius: 15,
                                                backgroundImage: NetworkImage(
                                                    _post.profilePic ?? ''),
                                                backgroundColor:
                                                    Colors.transparent,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10),
                                              child: Text(
                                                '@${_post.username}',
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          _post.title ?? "",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    )
                  : Container(),
              noThanks
                  ? Container()
                  : Card(
                      margin: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            const Text(
                              'Loving this app?',
                              style: TextStyle(fontSize: 20),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Rate us on the play store to support us.',
                              style: TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: const [
                                Icon(Icons.star),
                                Icon(Icons.star),
                                Icon(Icons.star),
                                Icon(Icons.star),
                                Icon(Icons.star),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  child: const Text('No Thanks'),
                                  onPressed: () {
                                    setState(() {
                                      noThanks = true;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.grey),
                                ),
                                ElevatedButton(
                                  child: const Text('Rate us'),
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      primary: kAccentColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
              ElevatedButton(
                  onPressed: () {
                    login();
                  },
                  child: const Text("Login")),
            ],
          ),
        ),
      ),
    );
  }
}
