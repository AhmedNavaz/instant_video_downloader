import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:instant_video_downloader/constants/colors.dart';
import 'package:instant_video_downloader/constants/uri.dart';
import 'package:instant_video_downloader/controllers/search_controller.dart';
import 'package:instant_video_downloader/views/story_saver/stories_view.dart';

class StorySaverView extends StatefulWidget {
  StorySaverView({Key? key}) : super(key: key);

  @override
  State<StorySaverView> createState() => _StorySaverViewState();
}

class _StorySaverViewState extends State<StorySaverView> {
  http.Client get client => http.Client();
  SearchController searchController = Get.find<SearchController>();
  bool isLoading = false;
  bool noThanks = false;

  Future<List<Map<String, dynamic>>> getProfiles() async {
    try {
      http.Response response =
          await client.get(Uri.parse('${LOCALHOST}storiesProfiles'));
      final jsonResponse = json.decode(response.body);
      final profiles = jsonResponse['response'] as List<dynamic>;
      return profiles.cast<Map<String, dynamic>>();
    } catch (e) {
      print("No user found!");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> generateStoriesLink(String? userId) async {
    try {
      http.Response response = await client.post(
        Uri.parse('${LOCALHOST}stories'),
        body: {"userId": userId},
      );
      final jsonResponse = json.decode(response.body);
      final stories = jsonResponse['response'] as List<dynamic>;

      return stories.cast<Map<String, dynamic>>();
    } catch (e) {
      print("No user found!");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Saver'),
        backgroundColor: kPrimaryColor,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : Column(
              children: [
                Obx(
                  () => searchController.storiesProfiles.isEmpty &&
                          !searchController.storyLoading.value
                      ? Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: const Text("Login to see your stories",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold)))
                      : searchController.storyLoading.value
                          ? Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: const CircularProgressIndicator(
                                  color: kPrimaryColor),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(children: [
                                for (int index = 0;
                                    index <
                                        searchController.storiesProfiles.length;
                                    index++)
                                  InkWell(
                                    onTap: () async {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      await generateStoriesLink(searchController
                                              .storiesProfiles[index]
                                                  ["profileId"]
                                              .toString())
                                          .then((value) {
                                        searchController.storiesLinks = value;
                                      });
                                      Get.to(() => StoriesView(
                                            title: searchController
                                                    .storiesProfiles[index]
                                                ["username"],
                                          ));
                                      setState(() {
                                        isLoading = false;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 20),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 15),
                                            child: CircleAvatar(
                                              radius: 43,
                                              backgroundColor: Colors.red,
                                              child: CircleAvatar(
                                                radius: 40,
                                                backgroundImage: NetworkImage(
                                                    searchController
                                                            .storiesProfiles[
                                                        index]["profilePic"]),
                                                backgroundColor:
                                                    Colors.transparent,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            searchController
                                                    .storiesProfiles[index]
                                                ["username"]!,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ]),
                            ),
                ),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                // ElevatedButton(
                //   onPressed: () async {
                //     setState(() {
                //       isLoading = true;
                //     });

                //     await getProfiles().then((value) {
                //       setState(() {
                //         searchController.storiesProfiles = value;
                //         isLoading = false;
                //       });
                //     });
                //   },
                //   child: const Text("Get Stories"),
                //   style: ElevatedButton.styleFrom(
                //     primary: kPrimaryColor,
                //     fixedSize: const Size(200, 50),
                //   ),
                // ),
              ],
            ),
    );
  }
}
