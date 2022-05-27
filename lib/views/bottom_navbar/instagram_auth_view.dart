import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_video_downloader/controllers/authController.dart';

class InstagramAuthView extends StatefulWidget {
  InstagramAuthView({Key? key}) : super(key: key);

  @override
  State<InstagramAuthView> createState() => _InstagramAuthViewState();
}

class _InstagramAuthViewState extends State<InstagramAuthView> {
  bool _isObscure = true;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(" "),
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
                              authController.isLoggedIn.value = true;
                            });
                          },
                          child: const Text("Log In"),
                          style: ElevatedButton.styleFrom(
                              fixedSize: const Size(400, 60)),
                        )
                      ],
                    ),
                  ),
          ),
        ));
  }
}
