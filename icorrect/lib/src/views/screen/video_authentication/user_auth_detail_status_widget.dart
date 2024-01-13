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
import 'package:icorrect/src/presenters/user_authentication_detail_presenter.dart';
import 'package:icorrect/src/provider/user_auth_detail_provider.dart';
import 'package:icorrect/src/views/other/circle_loading.dart';
import 'package:icorrect/src/views/other/confirm_dialog.dart';
import 'package:icorrect/src/views/other/message_dialog.dart';
import 'package:icorrect/src/views/screen/video_authentication/video_authentication_record.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class UserAuthDetailStatus extends StatefulWidget {
  const UserAuthDetailStatus({super.key});

  @override
  State<UserAuthDetailStatus> createState() => _UserAuthDetailStatusState();
}

class _UserAuthDetailStatusState extends State<UserAuthDetailStatus>
    implements UserAuthDetailContract {
  double w = 0, h = 0;
  VideoPlayerController? _playerController;
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
    _circleLoading!.show(context: context, isViewAIResponse: false);
    _authDetailPresenter!.getUserAuthDetail(context);
    Future.delayed(Duration.zero, () {
      _provider!.clearData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_provider!.chewiePlayController != null &&
        _provider!.chewiePlayController!.isPlaying) {
      _provider!.chewiePlayController!.pause();
    }
    // if (_playerController != null) {
    //   _playerController!.dispose();
    // }
    // if (_chewieController != null) {
    //   _chewieController!.dispose();
    // }
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
        child: Consumer<UserAuthDetailProvider>(
          builder: (context, provider, child) {
            if (provider.startGetUserAuthDetail) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) {
                  _provider!.clearData();
                  _getUserAuthDetail();
                },
              );
            }
            return RefreshIndicator(
              onRefresh: () {
                return Future.delayed(
                  const Duration(seconds: 1),
                  () {
                    _provider!.clearData();
                    _getUserAuthDetail();
                  },
                );
              },
              child: SingleChildScrollView(
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainScreen() {
    return Column(
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
            _headerRequireVideo()
          ],
        ),
        _videoAndStatus()
      ],
    );
  }

  Widget _headerRequireVideo() {
    return Container(
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
          SizedBox(
            width: (w - 20) / 1.6,
            child: Text(
              Utils.multiLanguage(
                StringConstants.require_user_authentication_title,
              )!,
              textAlign: TextAlign.start,
              style: CustomTextStyle.textWithCustomInfo(
                context: context,
                color: AppColor.defaultAppColor,
                fontsSize: FontsSize.fontSize_16,
                fontWeight: FontWeight.w400,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _videoAndStatus() {
    return Container(
      width: w,
      height: h / 1.2,
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
          height: h / 2.5,
          width: w,
          margin: const EdgeInsets.all(20),
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
          child: _userHadVideoAuth()
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: provider.chewiePlayController != null
                      ? Chewie(controller: provider.chewiePlayController!)
                      : const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColor.defaultPurpleColor,
                            ),
                          ),
                        ),
                )
              : GestureDetector(
                  onTap: () {
                    _stopVideo();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => VideoAuthenticationRecord(
                            userAuthDetailProvider: provider),
                      ),
                    );
                  },
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.video_camera_front_outlined,
                            size: 100, color: AppColor.defaultPurpleSightColor),
                        Text(
                          Utils.multiLanguage(
                            StringConstants.start_record_video_title,
                          )!,
                          style: CustomTextStyle.textWithCustomInfo(
                            context: context,
                            color: AppColor.defaultGrayColor,
                            fontsSize: FontsSize.fontSize_17,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  bool _userHadVideoAuth() {
    UserAuthenDetailModel userDataModel = _provider!.userAuthenDetailModel;
    return userDataModel.id != 0 &&
            userDataModel.status == UserAuthStatus.active.get ||
        userDataModel.videosAuthDetail.isNotEmpty;
  }

  Widget _statusVideo() {
    return Consumer<UserAuthDetailProvider>(
      builder: (context, provider, child) {
        UserAuthenStatusUI statusUI = Utils.getUserAuthenStatus(
            context, provider.userAuthenDetailModel.status);
        if (_inProgressForAuthentication()) {
          statusUI = Utils.getUserAuthenStatus(
              context, UserAuthStatus.waitingModelFile.get);
        }

        String note = provider.userAuthenDetailModel.note;
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
                      style: CustomTextStyle.textWithCustomInfo(
                        context: context,
                        color: statusUI.titleColor,
                        fontsSize: FontsSize.fontSize_17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(
                      width: w / 1.4,
                      child: Text(
                        note.isNotEmpty ? note : statusUI.description,
                        style: CustomTextStyle.textWithCustomInfo(
                          context: context,
                          color: AppColor.defaultBlackColor,
                          fontsSize: FontsSize.fontSize_15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  bool _inProgressForAuthentication() {
    return _provider!.userAuthenDetailModel.videosAuthDetail.isNotEmpty &&
        _provider!.userAuthenDetailModel.status == UserAuthStatus.draft.get;
  }

  Widget _submitVideoAgainButton() {
    double w = MediaQuery.of(context).size.width;
    return Consumer<UserAuthDetailProvider>(
      builder: (context, provider, child) {
        int statusUser = provider.userAuthenDetailModel.status;
        return Visibility(
            visible: _canStartRecord(statusUser),
            child: GestureDetector(
              onTap: () {
                if (provider
                    .userAuthenDetailModel.videosAuthDetail.isNotEmpty) {
                  _showConfirmBeforeRecord();
                } else {
                  _stopVideo();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => VideoAuthenticationRecord(
                          userAuthDetailProvider: provider),
                    ),
                  );
                }
              },
              child: Container(
                width: w,
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                    color: provider
                            .userAuthenDetailModel.videosAuthDetail.isNotEmpty
                        ? AppColor.defaultYellowColor
                        : AppColor.defaultPurpleColor,
                    borderRadius: BorderRadius.circular(100)),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        provider.userAuthenDetailModel.videosAuthDetail
                                .isNotEmpty
                            ? Icons.refresh
                            : Icons.video_camera_front_outlined,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        provider.userAuthenDetailModel.videosAuthDetail
                                .isNotEmpty
                            ? Utils.multiLanguage(
                                StringConstants.record_video_again_title,
                              )!
                            : Utils.multiLanguage(
                                StringConstants
                                    .record_video_authentication_title,
                              )!,
                        style: CustomTextStyle.textWithCustomInfo(
                          context: context,
                          color: AppColor.defaultWhiteColor,
                          fontsSize: FontsSize.fontSize_18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ));
      },
    );
  }

  void _showConfirmBeforeRecord() {
    _stopVideo();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (builderContext) {
        return ConfirmDialogWidget(
          title: Utils.multiLanguage(
            StringConstants.waiting_review_video,
          )!,
          message: Utils.multiLanguage(
            StringConstants.confirm_record_new_video,
          )!,
          cancelButtonTitle: Utils.multiLanguage(
            StringConstants.cancel_button_title,
          )!,
          okButtonTitle: Utils.multiLanguage(
            StringConstants.ok_button_title,
          )!,
          cancelButtonTapped: () {},
          okButtonTapped: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => VideoAuthenticationRecord(
                    userAuthDetailProvider: _provider!),
              ),
            );
          },
        );
      },
    );
  }

  bool _canStartRecord(int status) {
    return status == UserAuthStatus.reject.get ||
        status == UserAuthStatus.lock.get ||
        status == UserAuthStatus.errorAuth.get ||
        status == UserAuthStatus.draft.get;
  }

  void _stopVideo() {
    if (_provider!.chewiePlayController != null &&
        _provider!.chewiePlayController!.isPlaying) {
      _provider!.chewiePlayController!.pause();
    }
  }

  @override
  void onGetUserAuthDetailError(String message) {
    _circleLoading!.hide();
    _provider!.setStartGetUserAuthDetail(false);
    showDialog(
      context: context,
      builder: (builder) {
        return MessageDialog.alertDialog(context, message);
      },
    );
  }

  @override
  void onGetUserAuthDetailSuccess(UserAuthenDetailModel userAuthenDetailModel) {
    _provider!.setStartGetUserAuthDetail(false);
    _circleLoading!.hide();
    _provider!.setUserAuthenModel(userAuthenDetailModel);
    if (userAuthenDetailModel.videosAuthDetail.isNotEmpty) {
      String urlVideo = fileEP(userAuthenDetailModel.videosAuthDetail.last.url);
      if (kDebugMode) {
        print('DEBUG : Authentication urlVideo: $urlVideo');
      }
      _playerController = VideoPlayerController.networkUrl(Uri.parse(urlVideo))
        ..initialize();
      _provider!.setChewiePlay(_playerController!);
    }
  }

  @override
  void userNotFoundWhenLoadAuth(String message) {
    _circleLoading!.hide();
    _provider!.setStartGetUserAuthDetail(false);
  }
}
