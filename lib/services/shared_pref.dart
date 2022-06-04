import 'dart:convert';
import 'package:get/get.dart';
import 'package:instant_video_downloader/models/post.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  SharedPref._();
  static final SharedPref _instance = SharedPref._();
  factory SharedPref() => _instance;
  SharedPreferences? _pref;
  SharedPreferences get pref => _pref!;
  List<Post>? _postList;
  List<Post> get postList => _postList!;
  set postList(List<Post> value) {
    _postList = value;
  }

  static Future<void> init() async {
    _instance._pref = await SharedPreferences.getInstance();
  }

  Future<void> addPostListToSharedPrefs(Post post) async {
    getPostListFromSharedPrefs().then((value) {
      if (value == null) {
        _instance.pref.setStringList('posts', [
          jsonEncode(post.toJson()),
        ]);
      } else {
        _instance._postList = value;
        _instance._postList!.add(post);
      }
      _instance.pref.setStringList('posts',
          _instance._postList!.map((e) => jsonEncode(e.toJson())).toList());
    });
  }

  Future<List<Post>?> getPostListFromSharedPrefs() async {
    final List<String>? jsonList = _instance.pref.getStringList('posts');
    if (jsonList == null) {
      return null;
    }
    return jsonList.map((json) => Post.fromJson(jsonDecode(json))).toList();
  }

  Future<void> removePostFromSharedPrefs(String? id) async {
    getPostListFromSharedPrefs().then((value) {
      _instance._postList = value;
      _instance._postList!.removeWhere((element) => element.id == id);
      _instance.pref.setStringList('posts',
          _instance._postList!.map((e) => jsonEncode(e.toJson())).toList());
    });
  }

  Future<void> setDownloadLocation(String path) async {
    _instance.pref.setString('downloadLocation', path);
  }

  Future<String?> getDownloadLocation() async {
    return _instance.pref.getString('downloadLocation');
  }

  Future<void> saveUsername(String username) async {
    _instance.pref.setString('username', username);
  }

  Future<String?> getUsername() async {
    String? result = _instance.pref.getString('username');
    if (result == null) {
      return null;
    }
    return result;
  }
}
