import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_video_downloader/constants/colors.dart';
import 'package:http/http.dart' as http;
import 'package:instant_video_downloader/constants/controller.dart';
import 'package:instant_video_downloader/constants/uri.dart';
import 'package:instant_video_downloader/controllers/search_controller.dart';
import 'package:instant_video_downloader/router/router_generator.dart';

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
  bool isSearching = false;

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

  Future<String?> generateDownloadLink(String? url) async {
    try {
      http.Response response = await client.post(
        Uri.parse('${LOCALHOST}post'),
        body: {"url": url},
      );
      Map<String, dynamic> jsonResponse = await jsonDecode(response.body);
      print(jsonResponse);
    } catch (e) {
      print("No user found!");
      return e.toString();
    }
  }

  Future<String?> login() async {
    try {
      http.Response response = await client.post(
        Uri.parse('${LOCALHOST}login'),
        body: {
          "username": "ehmadnavaz",
          "password": "yesecretaccounthai5",
        },
      );
      Map<String, dynamic> jsonResponse = await jsonDecode(response.body);
      print(jsonResponse);
    } catch (e) {
      print("No user found!");
      return e.toString();
    }
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
              Tab(text: 'Profile Picture'),
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
                            const SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    login();
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
                                      generateDownloadLink(
                                          postUrlController.text);
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
                    SearchWidget(),
                  ],
                ),
              ),
              Card(
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
                            onPressed: () {},
                            style:
                                ElevatedButton.styleFrom(primary: Colors.grey),
                          ),
                          ElevatedButton(
                            child: const Text('Rate us'),
                            onPressed: () {},
                            style:
                                ElevatedButton.styleFrom(primary: kAccentColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    navigationController.navigateTo(instagramAuth);
                  },
                  child: Text("Login")),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchWidget extends StatelessWidget {
  const SearchWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: TextField(
                cursorColor: Colors.white,
                style: TextStyle(color: Colors.white, fontSize: 20),
                decoration: InputDecoration(
                  fillColor: kSecondaryColor,
                  filled: true,
                  contentPadding: EdgeInsets.all(18),
                  hintText: 'Enter URL',
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Icon(Icons.search, size: 30),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(80, 60), primary: kAccentColor),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (BuildContext context, int index) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: kAccentColor,
                  child: Icon(Icons.person),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
