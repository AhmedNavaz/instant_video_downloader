import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_video_downloader/controllers/search_controller.dart';

class StoriesView extends StatefulWidget {
  const StoriesView({Key? key}) : super(key: key);

  @override
  State<StoriesView> createState() => _StoriesViewState();
}

class _StoriesViewState extends State<StoriesView> {
  SearchController searchController = Get.find<SearchController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story'),
      ),
      body: ListView.builder(
        itemCount: searchController.storiesLinks.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Image.network(
                  searchController.storiesLinks[index]['thumbnail'],
                  width: 400,
                  height: 500,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                ElevatedButton(onPressed: () {}, child: Text("Download"))
              ],
            ),
          );
        },
      ),
    );
  }
}
