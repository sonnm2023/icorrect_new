import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:icorrect/src/models/user_authentication/user_authentication_detail.dart';
import 'package:video_player/video_player.dart';

class UserAuthDetailProvider extends ChangeNotifier {
  bool isDisposed = false;

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!isDisposed) {
      super.notifyListeners();
    }
  }

  UserAuthenDetailModel _userAuthenDetailModel = UserAuthenDetailModel();
  UserAuthenDetailModel get userAuthenDetailModel => _userAuthenDetailModel;
  void setUserAuthenModel(UserAuthenDetailModel model) {
    _userAuthenDetailModel = model;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  ChewieController? _chewieController;
  ChewieController? get chewiePlayController => _chewieController;
  void setChewiePlay(VideoPlayerController controller) {
    _chewieController = ChewieController(
        videoPlayerController: controller, aspectRatio: 16 / 9);
    if (!isDisposed) {
      notifyListeners();
    }
  }
}
