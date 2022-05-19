import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_video_downloader/controllers/search_controller.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadPage extends StatefulWidget {
  DownloadPage({Key? key}) : super(key: key);

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  SearchController searchController = Get.find<SearchController>();
  bool isDownloading = false;
  ReceivePort _port = ReceivePort();

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

  void download() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      await FlutterDownloader.enqueue(
              url: searchController.profileImage.toString(),
              savedDir: '/storage/emulated/0/Download',
              showNotification: true,
              openFileFromNotification: true,
              fileName: setFileName())
          .then((value) {
        setState(() {
          isDownloading = false;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Image Downloaded Successfully."),
          ));
        });
      });
    }
  }

  String setFileName() {
    String fileName = searchController.profileImage.toString();
    fileName =
        fileName.substring(fileName.lastIndexOf('/') + 1).split('?').first;
    return fileName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('@${searchController.userName.toString()}'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Image.network(searchController.profileImage.toString(),
                  width: 400, height: 600),
              isDownloading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isDownloading = true;
                        });
                        download();
                      },
                      child: const Text('Download'))
            ],
          ),
        ));
  }
}
