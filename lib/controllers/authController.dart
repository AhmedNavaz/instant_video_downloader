import 'package:get/get.dart';
import 'package:instant_video_downloader/models/user.dart';

class AuthController extends GetxController {
  RxBool isLoggedIn = false.obs;
  final user = User().obs;
  var downloadLocation = '/storage/emulated/0/Download'.obs;
}
