import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/auth_models/video_record_exam_info.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect/src/models/ui_models/alert_info.dart';
import 'package:icorrect/src/presenters/simulator_test_presenter.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/provider/homework_provider.dart';
import 'package:icorrect/src/provider/my_practice_list_provider.dart';
import 'package:icorrect/src/provider/simulator_test_provider.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/circle_loading.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/custom_alert_dialog.dart';
import 'package:icorrect/src/views/screen/test/simulator_test/highlight_tab.dart';
import 'package:icorrect/src/views/screen/test/simulator_test/other_tab.dart';
import 'package:icorrect/src/views/screen/test/simulator_test/test_room_widget.dart';
import 'package:icorrect/src/views/widget/download_again_widget.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/back_button_widget.dart';
import 'package:icorrect/src/views/widget/default_loading_indicator.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/download_progressing_widget.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/full_image_widget.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/start_now_button_widget.dart';
import 'package:provider/provider.dart';
import 'package:video_compress/video_compress.dart';

class SimulatorTestScreen extends StatefulWidget {
  const SimulatorTestScreen({
    super.key,
    required this.activitiesModel,
    required this.testOption,
    required this.topicsId,
    required this.isPredict,
    required this.data,
    required this.onRefresh,
  });

  final ActivitiesModel? activitiesModel; //From Main screen
  final int? testOption; //From Practice screen
  final List<int>? topicsId; //From Practice screen
  final int? isPredict; //From Practice screen
  final Map<String, dynamic>? data; //From MyPractice
  final Function? onRefresh; //For refresh My practice list if needed

  @override
  State<SimulatorTestScreen> createState() => _SimulatorTestScreenState();
}

class _SimulatorTestScreenState extends State<SimulatorTestScreen>
    with AutomaticKeepAliveClientMixin<SimulatorTestScreen>
    implements SimulatorTestViewContract {
  SimulatorTestPresenter? _simulatorTestPresenter;
  SimulatorTestProvider? _simulatorTestProvider;
  HomeWorkProvider? _homeWorkProvider;
  AuthProvider? _authProvider;

  StreamSubscription? _connection;
  bool _isOffline = false;
  CircleLoading? _loading;
  bool _isExam = false;

  TabBar get _tabBar {
    return TabBar(
      physics: const BouncingScrollPhysics(),
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 3.0,
          color: AppColor.defaultPurpleColor,
        ),
      ),
      tabs: _tabsLabel(),
    );
  }

  List<Widget> _tabsLabel() {
    return [
      Tab(
        child: Text(
          Utils.multiLanguage(StringConstants.my_exam_tab_title),
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColor.defaultPurpleColor,
            fontsSize: FontsSize.fontSize_14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      Tab(
        child: Text(
          Utils.multiLanguage(StringConstants.highlight_tab_title),
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColor.defaultPurpleColor,
            fontsSize: FontsSize.fontSize_14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      Tab(
        child: Text(
          Utils.multiLanguage(StringConstants.others_tab_title),
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColor.defaultPurpleColor,
            fontsSize: FontsSize.fontSize_14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();

    _connection = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        _isOffline = true;
      } else if (result == ConnectivityResult.mobile) {
        if (kDebugMode) {
          print("DEBUG: connect via 3G/4G");
        }
        if (_simulatorTestPresenter!.isDownloading) {
          String? activityId;
          if (widget.activitiesModel != null) {
            activityId = widget.activitiesModel!.activityId.toString();
          }

          _simulatorTestPresenter!.reDownloadFiles(
            context,
            activityId,
          );
        }
        _isOffline = false;
      } else if (result == ConnectivityResult.wifi) {
        if (kDebugMode) {
          print("DEBUG: connect via WIFI");
        }
        _isOffline = false;
      } else if (result == ConnectivityResult.ethernet) {
        _isOffline = false;
      } else if (result == ConnectivityResult.bluetooth) {
        _isOffline = false;
      }

      if (kDebugMode) {
        print("DEBUG: CONNECT INTERNET === ${!_isOffline}");
      }
    });
    _simulatorTestProvider =
        Provider.of<SimulatorTestProvider>(context, listen: false);
    _simulatorTestPresenter = SimulatorTestPresenter(this);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _homeWorkProvider = Provider.of<HomeWorkProvider>(context, listen: false);
    _homeWorkProvider!.setSimulatorTestPresenter(_simulatorTestPresenter);

    _loading = CircleLoading();

    _getActivityType();
    _getTestDetail();

    // Future.delayed(Duration.zero, () {
    //   _authProvider!
    //       .setGlobalScaffoldKey(GlobalScaffoldKey.simulatorTestScaffoldKey);
    // });
  }

  @override
  void dispose() {
    _simulatorTestPresenter!.pauseDownload();
    _connection!.cancel();
    _simulatorTestPresenter!.closeClientRequest();
    _simulatorTestPresenter!.resetAutoRequestDownloadTimes();
    _simulatorTestProvider!.resetAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return WillPopScope(
      child: Consumer<SimulatorTestProvider>(
        builder: (context, simulatorTestProvider, child) {
          if (simulatorTestProvider.isShowConfirmSaveTest) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showConfirmSaveTestBeforeExit();
            });
          }
          if (simulatorTestProvider.submitStatus == SubmitStatus.success &&
              widget.activitiesModel != null) {
            return Stack(
              children: [
                DefaultTabController(
                  length: 3,
                  child: Scaffold(
                    // key: GlobalScaffoldKey.simulatorTestScaffoldKey,
                    appBar: AppBar(
                      elevation: 0.0,
                      iconTheme: const IconThemeData(
                        color: AppColor.defaultPurpleColor,
                      ),
                      centerTitle: true,
                      leading: _buildBackButton(),
                      title: _buildTitle(),
                      bottom: _buildBottomNavigatorTabBar(),
                      backgroundColor: AppColor.defaultWhiteColor,
                    ),
                    body: TabBarView(
                      children: [
                        _buildSimulatorTestTab(simulatorTestProvider),
                        _buildHighLightTab(),
                        _buildOtherTab(),
                      ],
                    ),
                  ),
                ),
                _buildFullImageView(),
              ],
            );
          } else {
            return Stack(
              children: [
                Scaffold(
                  // key: GlobalScaffoldKey.simulatorTestScaffoldKey,
                  body: Align(
                    alignment: Alignment.topLeft,
                    child: SafeArea(
                      left: true,
                      top: true,
                      right: true,
                      bottom: true,
                      child: Stack(
                        children: [
                          _buildBody(simulatorTestProvider),
                          _buildDownloadAgain(),
                          BackButtonWidget(
                            backButtonTapped: _backButtonTapped,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildFullImageView(),
              ],
            );
          }
        },
      ),
      onWillPop: () async {
        _backButtonTapped();
        return false;
      },
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        _backButtonTapped();
      },
      child: const Icon(
        Icons.arrow_back_rounded,
        color: AppColor.defaultPurpleColor,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      (widget.activitiesModel != null)
          ? widget.activitiesModel!.activityName
          : "",
      style: CustomTextStyle.textWithCustomInfo(
        context: context,
        color: AppColor.defaultPurpleColor,
        fontsSize: FontsSize.fontSize_18,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  PreferredSize _buildBottomNavigatorTabBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(CustomSize.size_40),
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColor.defaultPurpleColor,
            ),
          ),
        ),
        child: _tabBar,
      ),
    );
  }

  Widget _buildSimulatorTestTab(SimulatorTestProvider simulatorTestProvider) {
    return Align(
      alignment: Alignment.topLeft,
      child: SafeArea(
        left: true,
        top: true,
        right: true,
        bottom: true,
        child: _buildBody(simulatorTestProvider),
      ),
    );
  }

  Widget _buildFullImageView() {
    return Consumer<SimulatorTestProvider>(
      builder: (context, simulatorTestProvider, child) {
        if (simulatorTestProvider.showFullImage) {
          return FullImageWidget(
            imageUrl: simulatorTestProvider.selectedQuestionImageUrl,
            provider: simulatorTestProvider,
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildHighLightTab() {
    return HighLightTab(
      provider: _simulatorTestProvider!,
      homeWorkModel: widget.activitiesModel!,
    );
  }

  Widget _buildOtherTab() {
    return OtherTab(
      provider: _simulatorTestProvider!,
      homeWorkModel: widget.activitiesModel!,
    );
  }

  void _backButtonTapped() async {
    if (_simulatorTestProvider!.submitStatus == SubmitStatus.success) {
      if (_simulatorTestProvider!.isVisibleSaveTheTest) {
        //Update answer after submitted
        if (kDebugMode) {
          print("DEBUG: Update answer after submitted");
        }
        bool cancelButtonTapped = false;

        await showDialog(
          context: context,
          builder: (BuildContext buildContext) {
            return CustomAlertDialog(
              title: Utils.multiLanguage(StringConstants.dialog_title),
              description: Utils.multiLanguage(
                  StringConstants.confirm_save_change_answers_message_1),
              okButtonTitle:
                  Utils.multiLanguage(StringConstants.save_button_title),
              cancelButtonTitle:
                  Utils.multiLanguage(StringConstants.dont_save_button_title),
              borderRadius: 8,
              hasCloseButton: true,
              okButtonTapped: () async {
                //Update reanswer
                _loading!.show(context: buildContext, isViewAIResponse: false);
                _simulatorTestProvider!.setVisibleSaveTheTest(false);
                String savedVideoPath = _simulatorTestPresenter!
                    .randomVideoRecordExam(_simulatorTestProvider!.videosSaved);
                File? videoConfirmFile = _isExam ? File(savedVideoPath) : null;

                if (widget.activitiesModel != null) {
                  _simulatorTestPresenter!.submitTest(
                    context: buildContext,
                    testId: _simulatorTestProvider!.currentTestDetail.testId
                        .toString(),
                    activityId: widget.activitiesModel!.activityId.toString(),
                    questions: _simulatorTestProvider!.questionList,
                    isExam: _isExam,
                    videoConfirmFile: videoConfirmFile,
                    logAction: _simulatorTestProvider!.logActions,
                    duration: _simulatorTestProvider!.totalDuration,
                  );
                } else {
                  /////Handle practice submit
                }
              },
              cancelButtonTapped: () {
                cancelButtonTapped = true;
                Navigator.of(buildContext).pop();
              },
            );
          },
        );

        if (cancelButtonTapped) {
          if (_simulatorTestProvider!.needRefreshActivityList) {
            Navigator.pop(context, StringConstants.k_refresh);
          } else {
            Navigator.of(context).pop();
          }
        }
      } else {
        //Reset total duration
        _simulatorTestProvider!.resetTotalDuration();

        //Call back refresh list of my practice if need
        //For from My Practice Test
        _callToRefesh();

        Navigator.pop(context, StringConstants.k_refresh);
      }
    } else {
      //Disable back button when submitting test
      if (_simulatorTestProvider!.submitStatus == SubmitStatus.submitting) {
        if (kDebugMode) {
          print("DEBUG: Status is submitting!");
        }
        return;
      }

      switch (_simulatorTestProvider!.doingStatus.get) {
        case -1:
          {
            //None
            if (kDebugMode) {
              print("DEBUG: Status is not start to do the exam!");
            }

            //Reset total duration
            _simulatorTestProvider!.resetTotalDuration();

            if (_isExam) {
              Navigator.pop(context, StringConstants.k_refresh);
            } else {
              Navigator.of(context).pop();
            }

            break;
          }
        case 0:
          {
            //Doing
            if (kDebugMode) {
              print("DEBUG: Status is doing the exam!");
            }

            _showConfirmQuitTheTest();

            break;
          }
        case 1:
          {
            //Finish
            if (kDebugMode) {
              print("DEBUG: Status is finish doing the exam!");
            }

            _showConfirmSaveTestBeforeExit();

            break;
          }
      }
    }
  }

  void _callToRefesh() {
    if (widget.data != null) {
      if (widget.onRefresh != null) {
        widget.onRefresh!();
      }
    }
  }

  void _showConfirmQuitTheTest() {
    bool okButtonTapped = false;

    showDialog(
      context: context,
      builder: (BuildContext buildContext) {
        return CustomAlertDialog(
          title: Utils.multiLanguage(StringConstants.dialog_title),
          description:
              Utils.multiLanguage(StringConstants.quit_the_test_message),
          okButtonTitle: Utils.multiLanguage(StringConstants.ok_button_title),
          cancelButtonTitle:
              Utils.multiLanguage(StringConstants.cancel_button_title),
          borderRadius: 8,
          hasCloseButton: false,
          okButtonTapped: () {
            //Reset question image
            _resetQuestionImage();
            _deleteAllAnswer();
            //Reset total duration
            _simulatorTestProvider!.resetTotalDuration();
            okButtonTapped = true;
          },
          cancelButtonTapped: () {
            Navigator.of(buildContext).pop();
          },
        );
      },
    ).then((_) {
      if (okButtonTapped) {
        if (_isExam) {
          Navigator.pop(context, StringConstants.k_refresh);
        } else {
          Navigator.of(context).pop();
        }
      }
    });
  }

  void _showConfirmSaveTestBeforeExit() {
    bool cancelButtonTapped = false;

    showDialog(
      context: context,
      builder: (BuildContext buildContext) {
        return CustomAlertDialog(
          title: Utils.multiLanguage(StringConstants.dialog_title),
          description: Utils.multiLanguage(
              StringConstants.confirm_before_quit_the_test_message),
          okButtonTitle: Utils.multiLanguage(StringConstants.save_button_title),
          cancelButtonTitle:
              Utils.multiLanguage(StringConstants.exit_button_title),
          borderRadius: 8,
          hasCloseButton: true,
          okButtonTapped: () {
            _startSubmitTest();
          },
          cancelButtonTapped: () {
            cancelButtonTapped = true;
            _simulatorTestProvider!.setShowConfirmSaveTest(false);
            _deleteAllAnswer();
            Navigator.of(buildContext).pop();
          },
        );
      },
    ).then((_) {
      if (cancelButtonTapped) {
        if (_isExam) {
          Navigator.pop(context, StringConstants.k_refresh);
        } else {
          Navigator.pop(context);
        }
      }
    });
  }

  void _startSubmitTest() async {
    //Check connection
    Utils.checkInternetConnection().then(
      (isConnected) async {
        if (isConnected) {
          //Reset question image
          _resetQuestionImage();

          String savedVideoPath = _simulatorTestPresenter!
              .randomVideoRecordExam(_simulatorTestProvider!.videosSaved);
          File? videoConfirmFile = _isExam ? File(savedVideoPath) : null;

          //Submit
          _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.submitting);

          String activityId = "";
          if (widget.activitiesModel != null) {
            activityId = widget.activitiesModel!.activityId.toString();
          }

          _simulatorTestPresenter!.submitTest(
            context: context,
            testId: _simulatorTestProvider!.currentTestDetail.testId.toString(),
            activityId: activityId,
            questions: _simulatorTestProvider!.questionList,
            isExam: _isExam,
            videoConfirmFile: videoConfirmFile,
            logAction: _simulatorTestProvider!.logActions,
            duration: _simulatorTestProvider!.totalDuration,
          );
          _simulatorTestProvider!.setShowConfirmSaveTest(false);
        } else {
          //Show connect error here
          if (kDebugMode) {
            print("DEBUG: Connect error here!");
          }
          Utils.showConnectionErrorDialog(context);

          Utils.addConnectionErrorLog(context);
        }
      },
    );
  }

  void _resetQuestionImage() {
    if (_simulatorTestProvider!.questionHasImage) {
      _simulatorTestProvider!.setQuestionHasImageStatus(false);
      _simulatorTestProvider!.resetQuestionImageUrl();
    }
  }

  Future<void> _deleteAllAnswer() async {
    await VideoCompress.deleteAllCache();
    File videoResizePath = _simulatorTestProvider!.savedVideoFile;
    if (videoResizePath.existsSync()) {
      if (kDebugMode) {
        print("RECORDING_VIDEO : Delete Saved Resize File Recording");
      }
      await videoResizePath.delete();
    }

    List<VideoExamRecordInfo> videosSaved = _simulatorTestProvider!.videosSaved;
    for (int i = 0; i < videosSaved.length; i++) {
      File videoRecordFile = File(videosSaved[i].filePath ?? "");
      if (videoRecordFile.existsSync()) {
        if (kDebugMode) {
          print("RECORDING_VIDEO : Delete Saved File Recording index : $i");
        }
        await videoRecordFile.delete();
      }
    }

    List<String> answers = _simulatorTestProvider!.answerList;

    if (answers.isEmpty) return;

    for (String answer in answers) {
      FileStorageHelper.deleteFile(answer, MediaType.audio,
              _simulatorTestProvider!.currentTestDetail.testId.toString())
          .then(
        (value) {
          if (false == value) {
            showToastMsg(
              msg: Utils.multiLanguage(
                  StringConstants.can_not_delete_files_message),
              toastState: ToastStatesType.warning,
              isCenter: true,
            );
          }
        },
      );
    }
  }

  Widget _buildBody(SimulatorTestProvider provider) {
    if (kDebugMode) {
      print("DEBUG: SimulatorTest --- build -- buildBody");
    }

    if (provider.isDownloadProgressing) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const DownloadProgressingWidget(),
          Visibility(
            visible: provider.startNowAvailable,
            child: StartNowButtonWidget(
              startNowButtonTapped: () {
                _startToDoTest();
              },
            ),
          ),
        ],
      );
    }

    if (provider.isGettingTestDetail) {
      return const DefaultLoadingIndicator(
        color: AppColor.defaultPurpleColor,
      );
    } else {
      return SizedBox(
        child: Stack(
          children: [
            TestRoomWidget(
              activitiesModel: widget.activitiesModel,
              simulatorTestPresenter: _simulatorTestPresenter!,
              isExam: _isExam,
            ),
            Visibility(
              visible: provider.submitStatus == SubmitStatus.submitting,
              child: const DefaultLoadingIndicator(
                color: AppColor.defaultPurpleColor,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDownloadAgain() {
    return Consumer<SimulatorTestProvider>(
      builder: (context, provider, child) {
        if (provider.needDownloadAgain) {
          return DownloadAgainWidget(
            simulatorTestPresenter: _simulatorTestPresenter!,
            myTestPresenter: null,
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  void _getActivityType() {
    //Create a crash bug for testing
    // Utils.testCrashBug();

    if (widget.activitiesModel != null) {
      _isExam =
          widget.activitiesModel!.activityType == ActivityType.exam.name ||
              widget.activitiesModel!.activityType == ActivityType.test.name;
    } else {
      _isExam = false;
    }
  }

  void _getTestDetail() async {
    _simulatorTestPresenter!.initializeData().then(
      (_) {
        if (widget.activitiesModel != null) {
          //From main screen
          _simulatorTestPresenter!.getTestDetailFromHomeWork(
            context: context,
            activityId: widget.activitiesModel!.activityId.toString(),
          );
        } else if (widget.data != null) {
          //From my practice screen
          _simulatorTestPresenter!.getTestDetailFromMyPractice(
            context: context,
            data: widget.data!,
          );
        } else {
          //From practice screen
          _simulatorTestPresenter!.getTestDetailFromPractice(
            context: context,
            testOption: widget.testOption ?? 0,
            topicsId: widget.topicsId ?? [],
            isPredict: widget.isPredict ?? 0,
          );
        }
      },
    );
  }

  void _startToDoTest() {
    _simulatorTestProvider!.setStartNowStatus(false);
    _simulatorTestProvider!.setGettingTestDetailStatus(false);

    //Hide Loading view
    _simulatorTestProvider!.setDownloadProgressingStatus(false);

    _simulatorTestProvider!.updateDoingStatus(DoingStatus.doing);

    if (_simulatorTestProvider!.isReDownload) {
      //Reset isReDownload
      _simulatorTestProvider!.setIsReDownload(false);
      _simulatorTestProvider!.updateReviewingStatus(ReviewingStatus.none);
    }
  }

  void _showCheckNetworkDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: Utils.multiLanguage(StringConstants.dialog_title),
          description:
              Utils.multiLanguage(StringConstants.network_error_message),
          okButtonTitle: Utils.multiLanguage(StringConstants.ok_button_title),
          cancelButtonTitle: null,
          borderRadius: 8,
          hasCloseButton: false,
          okButtonTapped: () {
            Navigator.of(context).pop();
          },
          cancelButtonTapped: null,
        );
      },
    );
  }

  @override
  void onDownloadError(AlertInfo info) {
    if (kDebugMode) {
      print("DEBUG: onDownloadFailure");
    }
    // if (mounted) {
    //   if (!_simulatorTestProvider!.dialogShowing) {
    //     showDialog(
    //       context: context,
    //       barrierDismissible: false,
    //       builder: (context) {
    //         return AlertsDialog.init().showDialog(
    //           context,
    //           info,
    //           this,
    //           keyInfo: StringClass.failDownloadVideo,
    //         );
    //       },
    //     );
    //     _simulatorTestProvider!.setDialogShowing(true);
    //   }
    // }
  }

  @override
  void onDownloadSuccess(TestDetailModel testDetail, String nameFile,
      double percent, int index, int total) {
    _simulatorTestProvider!.setTotal(total);
    _simulatorTestProvider!.updateDownloadingIndex(index);
    _simulatorTestProvider!.updateDownloadingPercent(percent);
    if (widget.activitiesModel != null) {
      _simulatorTestProvider!
          .setActivityType(widget.activitiesModel!.activityType);
    } else {
      _simulatorTestProvider!.setActivityType(ActivityType.practice.name);
    }

    // Utils.testCrashBug();

    //Enable Start Testing Button
    if (index >= 5 && _simulatorTestProvider!.isReDownload == false) {
      _simulatorTestProvider!.setStartNowStatus(true);
    }

    if (index == total) {
      //Auto start to do test
      _startToDoTest();
    }
  }

  @override
  void onGetTestDetailSuccess(TestDetailModel testDetai) {
    if (kDebugMode) {
      print("DEBUG: onGetTestDetailSuccess");
    }
    _simulatorTestProvider!.setCurrentTestDetail(testDetai);
    _simulatorTestProvider!.setDownloadProgressingStatus(true);

    _simulatorTestPresenter!.prepareDataForDownload(
      context: context,
      activityId: widget.activitiesModel != null
          ? widget.activitiesModel!.activityId.toString()
          : null,
      testDetail: testDetai,
    );
  }

  @override
  void onGetTestDetailError(String message) {
    if (kDebugMode) {
      print("DEBUG: onGetTestDetailError");
    }
    //Show error message
    showToastMsg(
      msg: Utils.multiLanguage(message),
      toastState: ToastStatesType.error,
      isCenter: true,
    );
  }

  @override
  void onSubmitTestError(String msg) {
    if (null != _loading) {
      _loading!.hide();
    }
    _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.fail);
    _simulatorTestProvider!.setVisibleSaveTheTest(true);

    //Send log
    Utils.sendLog();

    showToastMsg(
      msg: msg,
      toastState: ToastStatesType.error,
      isCenter: true,
    );
  }

  @override
  void onSubmitTestSuccess(String msg) {
    if (_simulatorTestProvider!.doingStatus == DoingStatus.finish) {
      _loading!.hide();
    } else {
      _loading!.hide();
      _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.success);
    }

    //Send log
    Utils.sendLog();

    showToastMsg(
      msg: msg,
      toastState: ToastStatesType.success,
      isCenter: true,
    );

    _callToRefesh();

    Navigator.pop(context, 'refresh');
  }

  @override
  void onReDownload() {
    if (_simulatorTestProvider!.doingStatus == DoingStatus.doing) {
      _simulatorTestProvider!.setNeedDownloadAgain(false);
    } else {
      _simulatorTestProvider!.setNeedDownloadAgain(true);
    }
    _simulatorTestProvider!.setDownloadProgressingStatus(false);
    _simulatorTestProvider!.setGettingTestDetailStatus(false);
  }

  void updateStatusForReDownload() {
    // if (_simulatorTestProvider!.isReDownload) {
    //   _simulatorTestProvider!.setNeedDownloadAgain(false);
    // } else {
    //   _simulatorTestProvider!.setNeedDownloadAgain(true);
    // }
    _simulatorTestProvider!.setNeedDownloadAgain(false);
    _simulatorTestProvider!.setStartNowStatus(false);
    _simulatorTestProvider!.setDownloadProgressingStatus(true);
  }

  @override
  void onTryAgainToDownload() {
    //Check internet connection status
    if (_isOffline) {
      _showCheckNetworkDialog();
    } else {
      if (null != _simulatorTestPresenter!.testDetail) {
        updateStatusForReDownload();
        if (null == _simulatorTestPresenter!.dio) {
          _simulatorTestPresenter!.initializeData();
        }
        _simulatorTestProvider!.setIsReDownload(true);
        _simulatorTestProvider!.setStartNowStatus(false);
        _simulatorTestPresenter!.reDownloadFiles(
            context,
            widget.activitiesModel != null
                ? widget.activitiesModel!.activityId.toString()
                : null);
      }
    }
  }

  @override
  void onHandleEventBackButtonSystem({required bool isQuitTheTest}) {
    if (kDebugMode) {
      print(
          "DEBUG: _handleEventBackButtonSystem - quit this test = $isQuitTheTest");
    }

    if (isQuitTheTest) {
      _deleteAllAnswer();
      _simulatorTestProvider!.resetTotalDuration();
      Navigator.of(context).pop();
    } else {
      //Continue play video
    }
  }

  @override
  void onHandleBackButtonSystemTapped() {
    if (kDebugMode) {
      print("DEBUG: onHandleBackButtonSystemTapped");
    }
    //Pause video player
  }

  @override
  void onPrepareListVideoSource(List<QuestionTopicModel> list) async {
    for (int i = 0; i < list.length; i++) {
      QuestionTopicModel q = list[i];
      _simulatorTestProvider!.addVideoSource(q);
    }
  }

  @override
  void onUpdateHasOrderStatus(bool hasOrder) {
    _simulatorTestProvider!.setHasOrderStatus(hasOrder);
  }

  @override
  bool get wantKeepAlive => true;
}
