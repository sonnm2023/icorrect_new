// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/core/camera_service.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/presenters/video_authentication_persenter.dart';
import 'package:icorrect/src/provider/user_auth_detail_provider.dart';
import 'package:icorrect/src/provider/video_authentication_provider.dart';
import 'package:icorrect/src/views/other/circle_loading.dart';
import 'package:icorrect/src/views/other/confirm_dialog.dart';
import 'package:icorrect/src/views/other/message_dialog.dart';
import 'package:icorrect/src/views/other/resize_video_dialog.dart';
import 'package:icorrect/src/views/screen/video_authentication/submit_video_auth.dart';
import 'package:icorrect/src/views/widget/focus_user_face_widget.dart';
import 'package:provider/provider.dart';

class VideoAuthenticationRecord extends StatefulWidget {
  UserAuthDetailProvider userAuthDetailProvider;
  VideoAuthenticationRecord({required this.userAuthDetailProvider, super.key});

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
  final Duration _duration = const Duration(seconds: 0);
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
    if (null != _loading) {
      _loading = null;
    }
    _cameraService!.dispose();
    super.dispose();
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
      case AppLifecycleState.hidden:
        if (kDebugMode) {
          print('DEBUG: App hidden');
        }
        break;
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

    if (cameraController.value.isInitialized) {
      cameraController.pausePreview();
      if (cameraController.value.isRecordingVideo) {
        cameraController.pauseVideoRecording();
      }
    }
  }

  void _continueRecodingVideo() {
    CameraController cameraController = _cameraService!.cameraController!;

    if (cameraController.value.isInitialized) {
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
    return Consumer<VideoAuthProvider>(
      builder: (context, provider, child) {
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
                          child: (_cameraService!.cameraController != null)
                              ? CameraPreview(_cameraService!.cameraController!)
                              : Container(),
                        ),
                        Container(
                          margin: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _onBackButtonTapped();
                                },
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                              Visibility(
                                visible: provider.isRecordingVideo,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 126, 126, 126),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.circle,
                                        color: Colors.red,
                                        size: 10,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        provider.strCount,
                                        style:
                                            CustomTextStyle.textWithCustomInfo(
                                          context: context,
                                          color: AppColor.defaultWhiteColor,
                                          fontsSize: FontsSize.fontSize_15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
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
                                ],
                              ),
                            ),
                            height: h / 5,
                            padding: const EdgeInsets.only(
                                right: 10, left: 10, top: 5),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Utils.multiLanguage(
                                      StringConstants.sampleTextTitle,
                                    )!,
                                    style: CustomTextStyle.textWithCustomInfo(
                                      context: context,
                                      color: AppColor.defaultAppColor,
                                      fontsSize: FontsSize.fontSize_17,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    Utils.multiLanguage(
                                      StringConstants.sampleTextContent,
                                    )!,
                                    style: CustomTextStyle.textWithCustomInfo(
                                      context: context,
                                      color: AppColor.defaultAppColor,
                                      fontsSize: FontsSize.fontSize_16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        const FocusUserFaceWidget()
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.all(20),
                      child: GestureDetector(
                        onTap: () {
                          if (!provider.isRecordingVideo) {
                            _onStartRecording();
                            _videoAuthProvider!.setRecordingVideo(true);
                          } else {
                            int minSeconds =
                                _videoAuthProvider!.currentDuration.inSeconds;
                            if (minSeconds >= 15) {
                              _onStopRecording();
                              _videoAuthProvider!.setRecordingVideo(false);
                            } else {
                              Fluttertoast.showToast(
                                msg: Utils.multiLanguage(
                                  StringConstants
                                      .video_record_duration_less_than_15s,
                                )!,
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 5,
                                backgroundColor: AppColor.defaultGrayColor,
                                textColor: AppColor.defaultAppColor,
                                fontSize: 15.0,
                              );
                            }
                          }
                        },
                        child: Container(
                          width: w / 6,
                          height: 70,
                          padding: const EdgeInsets.all(8),
                          alignment: Alignment.bottomCenter,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(200)),
                          child: provider.isRecordingVideo
                              ? _recordingSymbol()
                              : _unRecordingSymbol(),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          onWillPop: () async {
            _onBackButtonTapped();
            return false;
          },
        );
      },
    );
  }

  Future _onBackButtonTapped() async {
    if (_videoRecording()) {
      _backWhenRecordingVideo();
    } else if (_videoAuthProvider!.savedFile.existsSync()) {
      _backWhenNotSubmitVideo(context);
    } else {
      Navigator.of(context).pop();
    }
  }

  bool _videoRecording() {
    return _cameraService!.cameraController != null &&
        _cameraService!.cameraController!.value.isInitialized &&
        _cameraService!.cameraController!.value.isRecordingVideo;
  }

  Future _backWhenRecordingVideo() async {
    _cancelRecordingVideo(isStop: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (builderContext) {
        return WillPopScope(
          child: ConfirmDialogWidget(
            title:
                Utils.multiLanguage(StringConstants.confirm_exit_screen_title)!,
            message: Utils.multiLanguage(StringConstants.confirm_exit_content)!,
            cancelButtonTitle:
                Utils.multiLanguage(StringConstants.exit_button_title)!,
            okButtonTitle:
                Utils.multiLanguage(StringConstants.later_button_title)!,
            dimissButtonTapped: () {
              _continueRecodingVideo();
            },
            cancelButtonTapped: () {
              _cameraService!.cameraController!.stopVideoRecording().then(
                (value) {
                  _deleteFile(File(value.path));
                  Navigator.of(context).pop();
                },
              );
            },
            okButtonTapped: () {
              _continueRecodingVideo();
            },
          ),
          onWillPop: () async {
            _continueRecodingVideo();
            return true;
          },
        );
      },
    );
  }

  Future _backWhenNotSubmitVideo(BuildContext contextBuild) async {
    _cancelRecordingVideo(isStop: false);
    showDialog(
      context: contextBuild,
      builder: (builder) {
        return ConfirmDialogWidget(
          title: Utils.multiLanguage(
            StringConstants.confirm_exit_screen_title,
          )!,
          message: Utils.multiLanguage(
            StringConstants.confirm_submit_before_out_screen,
          )!,
          cancelButtonTitle: Utils.multiLanguage(
            StringConstants.exit_button_title,
          )!,
          okButtonTitle: Utils.multiLanguage(
            StringConstants.submit_button_title,
          )!,
          cancelButtonTapped: () async {
            await _videoAuthProvider!.savedFile.delete().then(
              (value) {
                Navigator.of(contextBuild).pop();
                Navigator.of(context).pop();
              },
            );
          },
          okButtonTapped: () {
            _onSubmitVideoAuth(_videoAuthProvider!.savedFile);
          },
        );
      },
    );
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
      _loading!.show(context: context, isViewAIResponse: false);
      _cameraService!.saveVideoDoingTest(
        (savedFile) {
          _cameraService!.cameraController!.pausePreview();
          _loading!.hide();
          if (savedFile.existsSync() &&
              (savedFile.lengthSync() / (1024 * 1024)) > 40) {
            _showResizeFileDialog(savedFile);
          } else {
            _prepareForSubmitVideo(savedFile);
          }
        },
      );

      if (null != _count) {
        _count!.cancel();
      }
      _videoAuthProvider!.setRecordingVideo(false);
      _videoAuthProvider!.setCurrentDuration(Duration.zero, "00:00");
    }
  }

  void _showResizeFileDialog(File savedFile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (builderContext) {
        return WillPopScope(
          child: ResizeVideoDialog(
              videoFile: savedFile,
              isVideoExam: false,
              onResizeCompleted: (resizedFile) async {
                // String newPath =
                //     'VIDEO_EXAM_${DateTime.now().microsecond.toString()}.mp4';
                // File newFile = Utils.changeFileNameSync(resizedFile, newPath);
                _prepareForSubmitVideo(resizedFile);
              },
              onErrorResizeFile: () {
                _prepareForSubmitVideo(savedFile);
              },
              skipAndLater: () {
                _continuePreviewVideo();
              }),
          onWillPop: () async {
            return false;
          },
        );
      },
    );
  }

  void _prepareForSubmitVideo(File savedFile) {
    _videoAuthProvider!.setSavedFile(savedFile);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSubmitVideoAuthen(savedFile);
    });
    setState(() {});
  }

  void _continuePreviewVideo() {
    CameraController cameraController = _cameraService!.cameraController!;

    if (cameraController.value.isInitialized) {
      if (null != _count) {
        _count!.cancel();
      }
      if (cameraController.value.isPreviewPaused) {
        cameraController.resumePreview();
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
          },
        );
      },
    );
  }

  void _onSubmitVideoAuth(File savedFile) async {
    Utils.checkInternetConnection().then((isConnected) {
      if (isConnected) {
        _videoAuthProvider!.setIsSubmitLoading(true);

        _presenter!.submitAuth(
          authFile: savedFile,
          isUploadVideo: true,
          context: context,
        );
      } else {
        _handleConnectionError();
      }
    });
  }

  void _handleConnectionError() {
    //Show connect error here
    if (kDebugMode) {
      print("DEBUG: Connect error here!");
    }
    Utils.showConnectionErrorDialog(context);

    Utils.addConnectionErrorLog(context);
  }

  void _cancelRecordingVideo({required bool isStop}) {
    CameraController cameraController = _cameraService!.cameraController!;
    if (null != _count) {
      _count!.cancel();
    }
    if (cameraController.value.isInitialized &&
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
        print("DEBUG: Deleted saved file when Stop Now");
      }
      await savedFile.delete();
    }
  }

  Widget _recordingSymbol() {
    return Container(
      width: w / 6,
      height: 70,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _unRecordingSymbol() {
    return Container(
      width: w / 6,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(100),
      ),
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
  void onSubmitAuthError(String message) {
    _videoAuthProvider!.setIsSubmitLoading(false);
    _loading!.hide();

    showDialog(
      context: context,
      builder: (builder) {
        return MessageDialog.alertDialog(context, message);
      },
    );
  }

  @override
  void onSubmitAuthSuccess(File savedFile, String message) {
    _loading!.hide();

    _deleteFile(File(savedFile.path)).then(
      (value) {
        widget.userAuthDetailProvider.setStartGetUserAuthDetail(true);
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 5,
      backgroundColor: AppColor.defaultGreenLightColor,
      textColor: AppColor.defaultAppColor,
      fontSize: 15.0,
    );
  }
}
