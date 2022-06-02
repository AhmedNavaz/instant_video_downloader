import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_video_downloader/constants/colors.dart';
import 'package:instant_video_downloader/constants/uri.dart';
import 'package:instant_video_downloader/controllers/authController.dart';
import 'package:http/http.dart' as http;

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

  AuthController authController = Get.put(AuthController());

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
            child: authController.isLoggedIn.value
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
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              login(_usernameController.text,
                                      _passwordController.text)
                                  .then((value) {
                                setState(() {
                                  authController.isLoggedIn.value = true;
                                });
                                getProfileDetails(_usernameController.text);
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
        ));
  }
}
