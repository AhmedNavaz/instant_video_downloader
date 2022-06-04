import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_video_downloader/constants/colors.dart';
import 'package:instant_video_downloader/constants/uri.dart';
import 'package:instant_video_downloader/controllers/authController.dart';
import 'package:http/http.dart' as http;
import 'package:instant_video_downloader/controllers/search_controller.dart';
import 'package:instant_video_downloader/services/shared_pref.dart';

class InstagramAuthView extends StatefulWidget {
  InstagramAuthView({Key? key}) : super(key: key);

  @override
  State<InstagramAuthView> createState() => _InstagramAuthViewState();
}

class _InstagramAuthViewState extends State<InstagramAuthView> {
  http.Client get client => http.Client();
  bool _isObscure = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;

  AuthController authController = Get.find<AuthController>();
  SearchController searchController = Get.put(SearchController());
  SharedPref sharedPref = SharedPref();

  Future<String?> login(String username, String password) async {
    try {
      http.Response response = await client.post(
        Uri.parse('${LOCALHOST}login'),
        body: {
          "username": username,
          "password": password,
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

  Future<int?> checkLogin(String username) async {
    try {
      http.Response response = await client.post(
        Uri.parse('${LOCALHOST}session'),
        body: {
          "username": username,
        },
      );
      Map<String, dynamic> jsonResponse = await jsonDecode(response.body);
      print(jsonResponse);
      return jsonResponse['response'];
    } catch (e) {
      print("No user found!");
    }
    return null;
  }

  Future<void> getProfileDetails(String? username) async {
    try {
      http.Response response = await client.post(
        Uri.parse('${LOCALHOST}user'),
        body: {"username": username},
      );
      Map<String, dynamic> jsonResponse = await jsonDecode(response.body);
      jsonResponse = jsonResponse['response'];
      setState(() {
        authController.user.value.profilePic = jsonResponse['profilePic'];
        authController.user.value.fullName = jsonResponse['name'];
        authController.user.value.followers = jsonResponse['followers'];
        authController.user.value.following = jsonResponse['following'];
      });
    } catch (e) {
      print("No user found!");
    }
  }

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

  void initializeStories() async {
    setState(() {
      searchController.storyLoading.value = true;
    });

    await getProfiles().then((value) {
      setState(() {
        searchController.storiesProfiles = value;
        searchController.storyLoading.value = false;
      });
    });
  }

  void initializeLogin() async {
    String? username = await sharedPref.getUsername();
    if (username == null || username == "") {
      setState(() {
        authController.isLoggedIn.value = false;
      });
    } else {
      checkLogin(username).then((value) {
        if (value == 1) {
          setState(() {
            authController.isLoggedIn.value = true;
            initializeStories();
          });
        } else {
          authController.isLoggedIn.value = false;
        }
      });
    }
  }

  @override
  void initState() {
    initializeLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(" "),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Obx(
            () => authController.isLoggedIn.value
                ? Center(
                    child: Column(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.25),
                        Image.asset(
                          "assets/logged_in.png",
                          height: 100,
                          width: 100,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        const Text("You are Logged In!",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                authController.isLoggedIn.value = false;
                                sharedPref.saveUsername('');
                              });
                            },
                            child: const Text(
                              "Login from different account",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: kAccentColor),
                            )),
                      ],
                    ),
                  )
                : Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.15),
                        Image.asset(
                          "assets/Instagram_logo.png",
                          height: 100,
                          width: 200,
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        TextFormField(
                          decoration: InputDecoration(
                              hintText: 'Username',
                              hintStyle: const TextStyle(color: Colors.black38),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black12),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200]),
                          controller: _usernameController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        TextFormField(
                          obscureText: _isObscure,
                          decoration: InputDecoration(
                              hintText: 'Password',
                              suffixIcon: IconButton(
                                  icon: Icon(_isObscure
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      _isObscure = !_isObscure;
                                    });
                                  }),
                              hintStyle: const TextStyle(color: Colors.black38),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black12),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200]),
                          controller: _passwordController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        isLoading
                            ? const CircularProgressIndicator(
                                color: kAccentColor,
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isLoading = true;
                                    login(_usernameController.text,
                                            _passwordController.text)
                                        .then((value) {
                                      setState(() {
                                        isLoading = false;
                                        authController.isLoggedIn.value = true;
                                        initializeStories();
                                        sharedPref.saveUsername(
                                            _usernameController.text);
                                      });
                                      getProfileDetails(
                                          _usernameController.text);
                                    });
                                  });
                                },
                                child: Ink(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    gradient: const LinearGradient(
                                      colors: [
                                        kPrimaryColor,
                                        kSecondaryColor,
                                        kAccentColor,
                                        kGradientColor,
                                      ],
                                    ),
                                  ),
                                  child: Container(
                                    constraints: const BoxConstraints(
                                        minWidth: 400, minHeight: 60),
                                    child: const Center(
                                        child: Text("Log In",
                                            style: TextStyle(fontSize: 20))),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  primary: Colors.white,
                                ),
                              )
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
