import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:instant_video_downloader/constants/colors.dart';
import 'package:instant_video_downloader/services/shared_pref.dart';

class HistoryView extends StatefulWidget {
  HistoryView({Key? key}) : super(key: key);

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  SharedPref sharedPref = Get.put(SharedPref());

  @override
  void initState() {
    sharedPref.getPostListFromSharedPrefs().then((value) {
      setState(() {
        sharedPref.postList = value!;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: kPrimaryColor,
        centerTitle: true,
      ),
      body: sharedPref.postList.isEmpty
          ? const Center(
              child: Text(
              "You haven't downloaded anything yet!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ))
          : ListView.builder(
              itemCount: sharedPref.postList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Row(
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
                                        image: NetworkImage(sharedPref
                                                .postList[index].thumbnail ??
                                            ""),
                                        fit: BoxFit.cover),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Container(
                                        color: Colors.black.withOpacity(0.5),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Text(
                                              sharedPref.postList[index]
                                                          .duration ==
                                                      null
                                                  ? ''
                                                  : sharedPref
                                                      .postList[index].duration
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                sharedPref.postList[index]
                                                        .profilePic ??
                                                    ''),
                                            backgroundColor: Colors.transparent,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            '@${sharedPref.postList[index].username}',
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      sharedPref.postList[index].title ?? "",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                          thickness: 1,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.open_in_browser),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () => Clipboard.setData(ClipboardData(
                                      text: sharedPref.postList[index].title))
                                  .then(
                                (value) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content:
                                        Text("Caption copied to clipboard!"),
                                    padding: EdgeInsets.only(
                                        left: 10, bottom: 20, top: 10),
                                  ));
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                sharedPref.removePostFromSharedPrefs(
                                    sharedPref.postList[index].id);
                                sharedPref
                                    .getPostListFromSharedPrefs()
                                    .then((value) {
                                  setState(() {
                                    sharedPref.postList = value!;
                                  });
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
    );
  }
}
