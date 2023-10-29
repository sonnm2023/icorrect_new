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

  void clearData() {
    _startGetUserAuthDetail = false;
    _userAuthenDetailModel = UserAuthenDetailModel();
    _chewieController = null;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _startGetUserAuthDetail = false;
  bool get startGetUserAuthDetail => _startGetUserAuthDetail;
  void setStartGetUserAuthDetail(bool isStart) {
    _startGetUserAuthDetail = isStart;
    if (!isDisposed) {
      notifyListeners();
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
        videoPlayerController: controller, aspectRatio: 9 / 16);
    if (!isDisposed) {
      notifyListeners();
    }
  }
}
