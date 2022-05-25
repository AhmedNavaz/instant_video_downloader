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
  List<String?> profilesList = [];
  http.Client get client => http.Client();
  SearchController searchController = Get.put(SearchController());

  Future<List<String?>> getProfiles() async {
    try {
      http.Response response =
          await client.get(Uri.parse('${LOCALHOST}storiesProfiles'));
      final jsonResponse = json.decode(response.body);
      final profiles = jsonResponse['response'] as List<dynamic>;
      return profiles.cast<String?>();
    } catch (e) {
      print("No user found!");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> generateStoriesLink(
      String? userName) async {
    try {
      http.Response response = await client.post(
        Uri.parse('${LOCALHOST}stories'),
        body: {"username": userName},
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
      ),
      body: profilesList.isEmpty
          ? Center(
              child: ElevatedButton(
                onPressed: () async {
                  await getProfiles().then((value) {
                    setState(() {
                      profilesList = value;
                    });
                  });
                },
                child: Text("Get Stories"),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20),
                  itemCount: profilesList.length,
                  itemBuilder: (BuildContext ctx, index) {
                    return InkWell(
                      onTap: () async {
                        await generateStoriesLink(profilesList[index])
                            .then((value) {
                          searchController.storiesLinks = value;
                        });
                        Get.to(StoriesView());
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(profilesList[index]!,
                            style: TextStyle(fontSize: 20)),
                        decoration: BoxDecoration(
                            color: kAccentColor,
                            borderRadius: BorderRadius.circular(15)),
                      ),
                    );
                  }),
            ),
    );
  }
}
