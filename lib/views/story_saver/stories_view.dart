import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:instant_video_downloader/constants/colors.dart';
import 'package:instant_video_downloader/controllers/search_controller.dart';
import 'package:permission_handler/permission_handler.dart';

class StoriesView extends StatefulWidget {
  StoriesView({Key? key, this.title}) : super(key: key);
  String? title;

  @override
  State<StoriesView> createState() => _StoriesViewState();
}

class _StoriesViewState extends State<StoriesView> {
  SearchController searchController = Get.find<SearchController>();
  final ReceivePort _port = ReceivePort();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('@${widget.title!}'),
        backgroundColor: kPrimaryColor,
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
                ElevatedButton(
                    onPressed: () {
                      download(searchController.storiesLinks[index]['url']);
                    },
                    child: const Text("Download"))
              ],
            ),
          );
        },
      ),
    );
  }
}
