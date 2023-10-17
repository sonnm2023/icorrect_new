import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/circle_loading.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/confirm_dialog.dart';
import 'package:icorrect/src/views/screen/video_authentication/submit_video_auth.dart';
import 'package:icorrect/src/views/widget/focus_user_face_widget.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_color.dart';
import '../../../../core/camera_service.dart';
import '../../../data_sources/constant_methods.dart';
import '../../../data_sources/constants.dart';
import '../../../presenters/video_authentication_persenter.dart';
import '../../../provider/user_auth_detail_provider.dart';
import '../../../provider/video_authentication_provider.dart';
import 'package:record/record.dart';

import '../other_views/dialog/message_dialog.dart';

class VideoAuthenticationRecord extends StatefulWidget {
  UserAuthDetailProvider userAuthDetailProvider;
  VideoAuthenticationRecord({required this.userAuthDetailProvider,super.key});

  @override
  State<VideoAuthenticationRecord> createState() =>
      _VideoAuthenticationRecordState();
}

class _VideoAuthenticationRecordState extends State<VideoAuthenticationRecord>
    with WidgetsBindingObserver
    implements VideoAuthenticationContract {
  CameraService? _cameraService;

  double w = 0, h = 0;
  VideoAuthProvider? _videoAuthProvider;
  VideoAuthenticationPresenter? _presenter;
  Timer? _count;
  Duration _duration = Duration(seconds: 0);
  CircleLoading? _loading;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    _cameraService = CameraService();
    _loading = CircleLoading();
    _presenter = VideoAuthenticationPresenter(this);
    _videoAuthProvider = Provider.of<VideoAuthProvider>(context, listen: false);
    _cameraService!.initialize(() {
      setState(() {});
    });

    Future.delayed(Duration.zero, () {
      _videoAuthProvider!.clearData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (null != _count) {
      _count!.cancel();
    }
    super.dispose();
    _cameraService!.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _onAppActive();
        break;
      case AppLifecycleState.paused:
        if (kDebugMode) {
          print('DEBUG: App paused');
        }
        break;
      case AppLifecycleState.inactive:
        _onAppInBackground();
        break;
      case AppLifecycleState.detached:
        if (kDebugMode) {
          print('DEBUG: App detached');
        }
        break;
      // case AppLifecycleState.hidden:
      //   if (kDebugMode) {
      //     print('DEBUG: App hidden');
      //   }
      //   break;
    }
  }

  Future _onAppActive() async {
    _continueRecodingVideo();
  }

  Future _onAppInBackground() async {
    CameraController cameraController = _cameraService!.cameraController!;

    if (null != _count) {
      _count!.cancel();
    }

    if (cameraController != null && cameraController.value.isInitialized) {
      cameraController.pausePreview();
      if (cameraController.value.isRecordingVideo) {
        cameraController.pauseVideoRecording();
      }
    }
  }

  void _continueRecodingVideo() {
    CameraController cameraController = _cameraService!.cameraController!;

    if (cameraController != null && cameraController.value.isInitialized) {
      if (cameraController.value.isPreviewPaused) {
        cameraController.resumePreview();
      }

      if (cameraController.value.isRecordingPaused) {
        if (null != _count) {
          _count!.cancel();
        }

        _videoAuthProvider!.setRecordingVideo(true);
        Duration currentDuration = _videoAuthProvider!.currentDuration;
        _count = _presenter!.startCountRecording(durationFrom: currentDuration);
        cameraController.resumeVideoRecording();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Consumer<VideoAuthProvider>(builder: (context, provider, child) {
      return WillPopScope(
          child: Scaffold(
              backgroundColor: Colors.black,
              body: SafeArea(
                  left: true,
                  top: true,
                  right: true,
                  child: Column(
                    children: [
                      Expanded(
                          flex: 6,
                          child: Stack(
                            children: [
                              SizedBox(
                                width: w,
                                height: h,
                                child:
                                    (_cameraService!.cameraController != null)
                                        ? CameraPreview(
                                            _cameraService!.cameraController!)
                                        : Container(),
                              ),
                              Container(
                                margin: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                        onTap: () {
                                          _onBackPress();
                                        },
                                        child: const Icon(
                                          Icons.arrow_back_rounded,
                                          color: Colors.white,
                                          size: 25,
                                        )),
                                    Visibility(
                                        visible: provider.isRecordingVideo,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 126, 126, 126),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.circle,
                                                color: Colors.red,
                                                size: 10,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(provider.strCount,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15))
                                            ],
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: <Color>[
                                        Colors.transparent,
                                        Color.fromARGB(181, 0, 0, 0),
                                        Color.fromARGB(181, 0, 0, 0),
                                        Colors.black
                                      ])),
                                  height: h / 7,
                                  padding: const EdgeInsets.only(
                                      right: 10, left: 10, top: 5),
                                  child: const SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Sample Text :",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 17)),
                                        Text(
                                            "It appears as though that may be from the Android Emulator. If that is the case, it uses a low-quality renderer so that it runs fast enough especially on less powerful hardware. Test it out on a real device and you'll likely see better results.",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              FocusUserFaceWidget()
                            ],
                          )),
                      Expanded(
                          child: Container(
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.all(20),
                        child: GestureDetector(
                          onTap: () {
                            _videoAuthProvider!
                                .setRecordingVideo(!provider.isRecordingVideo);
                            if (provider.isRecordingVideo) {
                              _onStartRecording();
                            } else {
                              _onStopRecording();
                            }
                          },
                          child: Container(
                            width: 70,
                            height: 70,
                            padding: const EdgeInsets.all(8),
                            alignment: Alignment.bottomCenter,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(100)),
                            child: provider.isRecordingVideo
                                ? _recordingSymbol()
                                : _unRecordingSymbol(),
                          ),
                        ),
                      ))
                    ],
                  ))),
          onWillPop: () async {
            _onBackPress();
            return false;
          });
    });
  }

  Future _onBackPress() async {
    if (_cameraService!.cameraController != null &&
        _cameraService!.cameraController!.value.isInitialized &&
        _cameraService!.cameraController!.value.isRecordingVideo) {
      _backWhenRecordingVideo();
    } else if (_videoAuthProvider!.savedFile.existsSync()) {
      _backWhenNotSubmitVideo(context);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future _backWhenRecordingVideo() async {
    _cancelRecordingVideo(isStop: false);
    showDialog(
        context: context,
        builder: (builder) {
          return ConfirmDialogWidget(
              title: "Are you sure to exit ?",
              message:
                  "Your video authentication is recording , are you sure to exit ?",
              cancelButtonTitle: "Exit",
              okButtonTitle: "Continue",
              cancelButtonTapped: () {
                _cameraService!.cameraController!
                    .stopVideoRecording()
                    .then((value) {
                  _deleteFile(File(value.path));
                  Navigator.of(context).pop();
                });
              },
              okButtonTapped: () {
                _continueRecodingVideo();
              });
        });
  }

  Future _backWhenNotSubmitVideo(BuildContext contextBuild) async {
    _cancelRecordingVideo(isStop: false);
    showDialog(
        context: contextBuild,
        builder: (builder) {
          return ConfirmDialogWidget(
              title: "Are you sure to exit ?",
              message:
                  "Your video authentication is not submitted , do you want to submit and exit ?",
              cancelButtonTitle: "Exit",
              okButtonTitle: "Submit",
              cancelButtonTapped: () async {
                await _videoAuthProvider!.savedFile.delete().then((value) {
                  Navigator.of(contextBuild).pop();
                  Navigator.of(context).pop();
                });
              },
              okButtonTapped: () {
                _onSubmitVideoAuth(_videoAuthProvider!.savedFile);
              });
        });
  }

  Future _onStartRecording() async {
    if (_cameraService!.cameraController!.value.isInitialized &&
        !_cameraService!.cameraController!.value.isRecordingVideo) {
      _cameraService!.startCameraRecording();
      _count = _presenter!.startCountRecording(durationFrom: _duration);
    }
  }

  Future _onStopRecording() async {
    if (_cameraService!.cameraController!.value.isRecordingVideo) {
      int minSeconds = _videoAuthProvider!.currentDuration.inSeconds;
      if (minSeconds < 15) {
        print("DEBUG : Min recording less than 15 second");
        _cancelRecordingVideo(isStop: false);
        _showAlertWhenLessSecondsRecording();
      } else {
        _loading!.show(context: context, isViewAIResponse: false);
        _cameraService!.saveVideoDoingTest((savedFile) {
          _cameraService!.cameraController!.pausePreview();
          _videoAuthProvider!.setSavedFile(savedFile);
          _showSubmitVideoAuthen(savedFile);
          _loading!.hide();
        });

        if (null != _count) {
          _count!.cancel();
        }
        _videoAuthProvider!.setRecordingVideo(false);
        _videoAuthProvider!.setCurrentDuration(Duration.zero, "00:00");
      }
    }
  }

  void _showSubmitVideoAuthen(File savedFile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: false,
      isDismissible: false,
      barrierColor: AppColor.defaultGrayColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(CustomSize.size_20),
          topRight: Radius.circular(CustomSize.size_20),
        ),
      ),
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height - CustomSize.size_20),
      builder: (BuildContext buildContext) {
        return WillPopScope(
            child: SubmitVideoAuthentication(
              videoFile: savedFile,
              onClickSubmit: () {
                _onSubmitVideoAuth(savedFile);
              },
              onClickRecordNewVideo: () {
                _cameraService!.cameraController!.resumePreview();
              },
            ),
            onWillPop: () async {
              if (_videoAuthProvider!.savedFile.existsSync()) {
                _backWhenNotSubmitVideo(buildContext);
              }
              return false;
            });
      },
    );
  }

  void _onSubmitVideoAuth(File savedFile) {
    _videoAuthProvider!.setIsSubmitLoading(true);
    _presenter!.submitAuth(authFile: savedFile, isUploadVideo: true);
  }

  void _showAlertWhenLessSecondsRecording() {
    showDialog(
        context: context,
        builder: (builder) {
          return ConfirmDialogWidget(
              title: "Warning",
              message: "This video record must be greater than 15s",
              cancelButtonTitle: "Stop Now",
              okButtonTitle: "Continue",
              cancelButtonTapped: () {
                _cancelRecordingVideo(isStop: true);
              },
              okButtonTapped: () {
                _continueRecodingVideo();
              });
        });
  }

  void _cancelRecordingVideo({required bool isStop}) {
    CameraController cameraController = _cameraService!.cameraController!;
    if (null != _count) {
      _count!.cancel();
    }
    if (cameraController != null &&
        cameraController.value.isInitialized &&
        cameraController.value.isRecordingVideo) {
      if (isStop) {
        cameraController.stopVideoRecording().then((value) {
          _deleteFile(File(value.path));
        });
      } else {
        cameraController.pauseVideoRecording();
      }
    }
  }

  Future _deleteFile(File savedFile) async {
    if (savedFile.existsSync()) {
      if (kDebugMode) {
        print("DEBUG : Deleted saved file when Stop Now");
      }
      await savedFile.delete();
    }
  }

  Widget _recordingSymbol() {
    return Container(
      width: 70,
      height: 70,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.red, borderRadius: BorderRadius.circular(3)),
    );
  }

  Widget _unRecordingSymbol() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
          color: Colors.red, borderRadius: BorderRadius.circular(100)),
    );
  }

  @override
  void onCountRecording(Duration currentCount, String strCount) {
    _videoAuthProvider!.setCurrentDuration(currentCount, strCount);
  }

  @override
  void onFinishRecording() {
    _onStopRecording();
  }

  @override
  void submitAuthFail(String message) {
    _videoAuthProvider!.setIsSubmitLoading(false);
    _loading!.hide();

    showDialog(
        context: context,
        builder: (builder) {
          return MessageDialog.alertDialog(context, message);
        });
  }

  @override
  void submitAuthSuccess(File savedFile, String message) {
    _loading!.hide();

    _deleteFile(File(savedFile.path)).then((value) {
      widget.userAuthDetailProvider.setStartGetUserAuthDetail(true);
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    });

    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: AppColor.defaultGreenLightColor,
        textColor: AppColor.defaultAppColor,
        fontSize: 15.0);
  }
}
