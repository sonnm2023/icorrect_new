import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/ui_models/user_authen_status.dart';
import 'package:icorrect/src/models/user_authentication/user_authentication_detail.dart';
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';
import 'package:icorrect/src/presenters/user_authentication_detail_presenter.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/circle_loading.dart';
import 'package:icorrect/src/views/screen/video_authentication/video_authentication_record.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../provider/user_auth_detail_provider.dart';
import '../../../provider/video_authentication_provider.dart';
import '../other_views/dialog/message_dialog.dart';

class UserAuthDetailStatus extends StatefulWidget {
  const UserAuthDetailStatus({super.key});

  @override
  State<UserAuthDetailStatus> createState() => _UserAuthDetailStatusState();
}

class _UserAuthDetailStatusState extends State<UserAuthDetailStatus>
    implements UserAuthDetailContract {
  double w = 0, h = 0;
  VideoPlayerController? _playerController;
  ChewieController? _chewieController;
  UserAuthDetailPresenter? _authDetailPresenter;
  CircleLoading? _circleLoading;
  UserAuthDetailProvider? _provider;

  @override
  void initState() {
    super.initState();
    _circleLoading = CircleLoading();
    _authDetailPresenter = UserAuthDetailPresenter(this);
    _provider = Provider.of<UserAuthDetailProvider>(context, listen: false);

    _playerController = VideoPlayerController.file(File(""));

    _getUserAuthDetail();
  }

  void _getUserAuthDetail() {
    _circleLoading!.show(context);
    _authDetailPresenter!.getUserAuthDetail();
  }

  @override
  void dispose() {
    super.dispose();
    if (_provider!.chewiePlayController != null &&
        _provider!.chewiePlayController!.isPlaying) {
      _provider!.chewiePlayController!.pause();
    }
    if (_playerController != null) {
      _playerController!.dispose();
    }
    if (_chewieController != null) {
      _chewieController!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
          left: true,
          top: true,
          right: true,
          bottom: true,
          child: Container(
            width: w,
            height: h,
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.defaultPurpleColor,
                  AppColor.defaultPurpleColor,
                  AppColor.defaultBlueColor
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: _buildMainScreen(),
          )),
    );
  }

  Widget _buildMainScreen() {
    return RefreshIndicator(
        color: AppColor.defaultPurpleColor,
        onRefresh: () {
          return Future.delayed(
            const Duration(seconds: 1),
            () {
              _getUserAuthDetail();
            },
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.arrow_back_outlined,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _headerRequireVideo()
              ],
            ),
            _videoAndStatus()
          ],
        ));
  }

  Widget _headerRequireVideo() {
    return Column(
      children: [
        Container(
          width: w,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(109, 255, 255, 255)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Image(
                image: AssetImage(AppAsset.imgSecurity),
                width: 50,
              ),
              Container(
                width: (w - 20) / 1.6,
                child: const Text(
                  'Please send video sample for authentication',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                ),
              )
            ],
          ),
        ),
        Container()
      ],
    );
  }

  Widget _videoAndStatus() {
    return Container(
      width: w,
      height: h / 1.3,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Column(
        children: [
          _videoPlayer(),
          const SizedBox(height: 20),
          _statusVideo(),
          const SizedBox(height: 30),
          _submitVideoAgainButton()
        ],
      ),
    );
  }

  Widget _videoPlayer() {
    return Consumer<UserAuthDetailProvider>(
        builder: (context, provider, child) {
      return Container(
          height: h / 3.5,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColor.defaultPurpleColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3), // Shadow color
                spreadRadius: 5,
                blurRadius: 10,
                offset: const Offset(0, 7), // Shadow offset
              ),
            ],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: _userAuthenticated()
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                      width: w / 1.5,
                      height: h / 2,
                      child: _readyVideoPlay()
                          ? Chewie(controller: provider.chewiePlayController!)
                          : const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 4,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColor.defaultPurpleColor,
                                ),
                              ),
                            )),
                )
              : GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => VideoAuthenticationRecord(
                            userCode: provider.userAuthenDetailModel.userCode),
                      ),
                    );
                  },
                  child: const AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.video_camera_front_outlined,
                            size: 100, color: AppColor.defaultPurpleSightColor),
                        Text("Start Recording Video",
                            style: TextStyle(
                                color: AppColor.defaultGrayColor,
                                fontSize: 17,
                                fontWeight: FontWeight.w500))
                      ],
                    ),
                  ),
                ));
    });
  }

  bool _readyVideoPlay() {
    return _provider!.chewiePlayController != null;
  }

  bool _userAuthenticated() {
    UserAuthenDetailModel userDataModel = _provider!.userAuthenDetailModel;
    return userDataModel.id != 0 &&
        userDataModel.status == UserAuthStatus.active.get;
  }

  Widget _statusVideo() {
    return Consumer<UserAuthDetailProvider>(
        builder: (context, provider, child) {
      UserAuthenStatusUI statusUI =
          Utils.getUserAuthenStatus(provider.userAuthenDetailModel.status);
      return Visibility(
          visible: provider.userAuthenDetailModel.id != 0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: statusUI.backgroundColor,
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(statusUI.icon, color: statusUI.iconColor, size: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusUI.title,
                      style: TextStyle(
                          color: statusUI.titleColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      width: w / 1.4,
                      child: Text(
                        statusUI.description,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w400),
                      ),
                    )
                  ],
                )
              ],
            ),
          ));
    });
  }

  Widget _submitVideoAgainButton() {
    double w = MediaQuery.of(context).size.width;
    return Consumer<UserAuthDetailProvider>(
        builder: (context, provider, child) {
      return Visibility(
          visible: provider.userAuthenDetailModel.id != 0 &&
              provider.userAuthenDetailModel.status == UserAuthStatus.draft.get,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => VideoAuthenticationRecord(
                      userCode: provider.userAuthenDetailModel.userCode),
                ),
              );
            },
            child: Container(
              width: w,
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                  color: AppColor.defaultPurpleColor,
                  borderRadius: BorderRadius.circular(100)),
              child: const Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.refresh,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text("Record Video Again",
                        style: TextStyle(
                            color: AppColor.defaultWhiteColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w400)),
                  )
                ],
              ),
            ),
          ));
    });
  }

  @override
  void getUserAuthDetailFail(String message) {
    _circleLoading!.hide();

    showDialog(
        context: context,
        builder: (builder) {
          return MessageDialog.alertDialog(context, message);
        });
  }

  @override
  void getUserAuthDetailSuccess(UserAuthenDetailModel userAuthenDetailModel) {
    _circleLoading!.hide();
    _provider!.setUserAuthenModel(userAuthenDetailModel);
    if (userAuthenDetailModel.videosAuthDetail.isNotEmpty) {
      String urlVideo =
          fileEP(userAuthenDetailModel.videosAuthDetail.first.url);
      _playerController = VideoPlayerController.networkUrl(Uri.parse(urlVideo))
        ..initialize();
      _provider!.setChewiePlay(_playerController!);
    }
  }
}
