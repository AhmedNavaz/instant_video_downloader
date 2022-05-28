import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_video_downloader/constants/colors.dart';
import 'package:instant_video_downloader/constants/uri.dart';
import 'package:instant_video_downloader/controllers/search_controller.dart';
import 'package:instant_video_downloader/models/profile.dart';
import 'package:http/http.dart' as http;
import 'package:numeral/numeral.dart';

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

  @override
  void initState() {
    isLoading = true;
    getProfileDetails(searchController.userName2.value).then((value) {
      setState(() {
        isLoading = false;
      });
    });
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(searchController.userName2.value),
        backgroundColor: kPrimaryColor,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
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
                                style: TextStyle(
                                  fontSize: 16,
                                )),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(Numeral(userProfile.followers!).format(),
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('Followers', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      Column(
                        children: [
                          Text(Numeral(userProfile.following!).format(),
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('Following', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
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
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Image.network(
                              userProfile.posts![index]['thumbnail'] ?? '',
                              scale: 1),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
    );
  }
}
