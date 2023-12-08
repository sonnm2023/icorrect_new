import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/core/connectivity_service.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/auth_models/video_record_exam_info.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect/src/models/ui_models/alert_info.dart';
import 'package:icorrect/src/presenters/simulator_test_presenter.dart';
import 'package:icorrect/src/provider/homework_provider.dart';
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

import '../../../../provider/auth_provider.dart';

class SimulatorTestScreen extends StatefulWidget {
  const SimulatorTestScreen(
      {super.key,
      this.homeWorkModel,
      this.testOption,
      this.topicsId,
      this.isPredict});

  final ActivitiesModel? homeWorkModel;
  final int? testOption;
  final List<int>? topicsId;
  final int? isPredict;
  @override
  State<SimulatorTestScreen> createState() => _SimulatorTestScreenState();
}

class _SimulatorTestScreenState extends State<SimulatorTestScreen>
    with AutomaticKeepAliveClientMixin<SimulatorTestScreen>
    implements SimulatorTestViewContract {
  SimulatorTestPresenter? _simulatorTestPresenter;

  SimulatorTestProvider? _simulatorTestProvider;

  AuthProvider? _authProvider;

  StreamSubscription? connection;
  bool isOffline = false;
  CircleLoading? _loading;
  final connectivityService = ConnectivityService();
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
    connection = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // when every connection status is changed.
      if (result == ConnectivityResult.none) {
        isOffline = true;
      } else if (result == ConnectivityResult.mobile) {
        if (kDebugMode) {
          print("DEBUG: connect via 3G/4G");
        }
        if (_simulatorTestPresenter!.isDownloading) {
          _simulatorTestPresenter!.reDownloadFiles(
              context, widget.homeWorkModel!.activityId.toString());
        }
        isOffline = false;
      } else if (result == ConnectivityResult.wifi) {
        if (kDebugMode) {
          print("DEBUG: connect via WIFI");
        }
        isOffline = false;
      } else if (result == ConnectivityResult.ethernet) {
        isOffline = false;
      } else if (result == ConnectivityResult.bluetooth) {
        isOffline = false;
      }

      if (kDebugMode) {
        print("DEBUG: CONNECT INTERNET === ${!isOffline}");
      }
    });

    super.initState();
    _simulatorTestProvider =
        Provider.of<SimulatorTestProvider>(context, listen: false);
    _simulatorTestPresenter = SimulatorTestPresenter(this);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);

    Provider.of<HomeWorkProvider>(context, listen: false)
        .setSimulatorTestPresenter(_simulatorTestPresenter);

    _loading = CircleLoading();

    Future.delayed(Duration.zero, () {
      _authProvider!
          .setGlobalScaffoldKey(GlobalScaffoldKey.simulatorTestScaffoldKey);
    });

    _prepareBeforeSimulatorTest();
  }

  Future _prepareBeforeSimulatorTest() async {
    if (widget.homeWorkModel != null) {
      _isExam = widget.homeWorkModel!.activityType == ActivityType.exam.name ||
          widget.homeWorkModel!.activityType == ActivityType.test.name;
    } else {
      _isExam = false;
    }

    // Utils.testCrashBug();

    _getTestDetail();
  }

  @override
  void dispose() {
    _simulatorTestPresenter!.pauseDownload();
    connection!.cancel();
    _simulatorTestPresenter!.closeClientRequest();
    _simulatorTestPresenter!.resetAutoRequestDownloadTimes();
    _simulatorTestProvider!.resetAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(child: Consumer<SimulatorTestProvider>(
      builder: (context, simulatorTest, child) {
        if (simulatorTest.isShowConfirmSaveTest) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showConfirmSaveTestBeforeExit();
          });
        }
        if (simulatorTest.submitStatus == SubmitStatus.success &&
            widget.homeWorkModel != null) {
          return Stack(
            children: [
              DefaultTabController(
                length: 3,
                child: Scaffold(
                  key: GlobalScaffoldKey.simulatorTestScaffoldKey,
                  appBar: AppBar(
                    elevation: 0.0,
                    iconTheme: const IconThemeData(
                      color: AppColor.defaultPurpleColor,
                    ),
                    centerTitle: true,
                    leading: GestureDetector(
                      onTap: () {
                        _backButtonTapped();
                      },
                      child: const Icon(Icons.arrow_back_rounded,
                          color: AppColor.defaultPurpleColor),
                    ),
                    title: Text(
                      (widget.homeWorkModel != null)
                          ? widget.homeWorkModel!.activityName
                          : "",
                      style: CustomTextStyle.textWithCustomInfo(
                        context: context,
                        color: AppColor.defaultPurpleColor,
                        fontsSize: FontsSize.fontSize_18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    bottom: PreferredSize(
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
                    ),
                    backgroundColor: AppColor.defaultWhiteColor,
                  ),
                  body: TabBarView(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: SafeArea(
                          left: true,
                          top: true,
                          right: true,
                          bottom: true,
                          child: _buildBody(),
                        ),
                      ),
                      _buildHighLightTab(),
                      _buildOtherTab(),
                    ],
                  ),
                ),
              ),
              _buildFullImage(),
            ],
          );
        } else {
          return Stack(
            children: [
              Scaffold(
                key: GlobalScaffoldKey.simulatorTestScaffoldKey,
                body: Align(
                  alignment: Alignment.topLeft,
                  child: SafeArea(
                    left: true,
                    top: true,
                    right: true,
                    bottom: true,
                    child: Stack(
                      children: [
                        _buildBody(),
                        _buildDownloadAgain(),
                        BackButtonWidget(
                          backButtonTapped: _backButtonTapped,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildFullImage(),
            ],
          );
        }
      },
    ), onWillPop: () async {
      _backButtonTapped();
      return false;
    });
  }

  Widget _buildFullImage() {
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
      homeWorkModel: widget.homeWorkModel!,
    );
  }

  Widget _buildOtherTab() {
    return OtherTab(
      provider: _simulatorTestProvider!,
      homeWorkModel: widget.homeWorkModel!,
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
              okButtonTapped: () {
                //Update reanswer
                _loading!.show(context: buildContext, isViewAIResponse: false);
                _simulatorTestProvider!.setVisibleSaveTheTest(false);
                String savedVideoPath = _simulatorTestPresenter!
                    .randomVideoRecordExam(_simulatorTestProvider!.videosSaved);
                File? videoConfirmFile = _isExam ? File(savedVideoPath) : null;
                if (widget.homeWorkModel != null) {
                  _simulatorTestPresenter!.submitTest(
                    context: buildContext,
                    testId: _simulatorTestProvider!.currentTestDetail.testId
                        .toString(),
                    activityId: widget.homeWorkModel!.activityId.toString(),
                    questions: _simulatorTestProvider!.questionList,
                    isExam: _isExam,
                    videoConfirmFile: videoConfirmFile,
                    logAction: _simulatorTestProvider!.logActions,
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
        //Go back List homework screen
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
    var connectivity = await connectivityService.checkConnectivity();
    if (connectivity.name != StringConstants.connectivity_name_none) {
      //Reset question image
      _resetQuestionImage();

      String savedVideoPath = _simulatorTestPresenter!
          .randomVideoRecordExam(_simulatorTestProvider!.videosSaved);
      File? videoConfirmFile = _isExam ? File(savedVideoPath) : null;

      //Submit
      _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.submitting);

      String activityId = "";
      if (widget.homeWorkModel != null) {
        activityId = widget.homeWorkModel!.activityId.toString();
      }
      _simulatorTestPresenter!.submitTest(
        context: context,
        testId: _simulatorTestProvider!.currentTestDetail.testId.toString(),
        activityId: activityId,
        questions: _simulatorTestProvider!.questionList,
        isExam: _isExam,
        videoConfirmFile: videoConfirmFile,
        logAction: _simulatorTestProvider!.logActions,
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
            );
          }
        },
      );
    }
  }

  Widget _buildBody() {
    return Consumer<SimulatorTestProvider>(
      builder: (context, provider, child) {
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
                  homeWorkModel: widget.homeWorkModel,
                  simulatorTestPresenter: _simulatorTestPresenter!,
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
      },
    );
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

  void _getTestDetail() async {
    _simulatorTestPresenter!.initializeData().then((_) {
      if (widget.homeWorkModel != null) {
        _simulatorTestPresenter!.getTestDetailByHomeWork(
            context: context,
            homeworkId: widget.homeWorkModel!.activityId.toString());
      } else {
        _simulatorTestPresenter!.getTestDetailByPractice(
            context: context,
            testOption: widget.testOption ?? 0,
            topicsId: widget.topicsId ?? [],
            isPredict: widget.isPredict ?? 0);
      }
    });
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
  void onDownloadFailure(AlertInfo info) {
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
    if (widget.homeWorkModel != null) {
      _simulatorTestProvider!
          .setActivityType(widget.homeWorkModel!.activityType);
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
  void onGetTestDetailComplete(TestDetailModel testDetailModel, int total) {
    _simulatorTestProvider!.setCurrentTestDetail(testDetailModel);
    _simulatorTestProvider!.setDownloadProgressingStatus(true);
    _simulatorTestProvider!.setTotal(total);
  }

  @override
  void onGetTestDetailError(String message) {
    //Show error message
    showToastMsg(
      msg: Utils.multiLanguage(message),
      toastState: ToastStatesType.error,
    );
  }

  @override
  void onSaveTopicListIntoProvider(List<TopicModel> list) {
    _simulatorTestProvider!.setTopicsList(list);
    Queue<TopicModel> queue = Queue<TopicModel>();
    queue.addAll(list);
    _simulatorTestProvider!.setTopicsQueue(queue);
  }

  @override
  void onSubmitTestFail(String msg) {
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
    );

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
    if (isOffline) {
      _showCheckNetworkDialog();
    } else {
      if (null != _simulatorTestPresenter!.testDetail &&
          null != _simulatorTestPresenter!.filesTopic) {
        updateStatusForReDownload();
        if (null == _simulatorTestPresenter!.dio) {
          _simulatorTestPresenter!.initializeData();
        }
        _simulatorTestPresenter!.reDownloadFiles(
            context, widget.homeWorkModel!.activityId.toString());
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
  void onPrepareListVideoSource(List<FileTopicModel> filesTopic) async {
    for (int i = 0; i < filesTopic.length; i++) {
      FileTopicModel fileTopicModel = filesTopic[i];
      _simulatorTestProvider!.addVideoSource(fileTopicModel);
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void onUpdateHasOrderStatus(bool hasOrder) {
    _simulatorTestProvider!.setHasOrderStatus(hasOrder);
  }
}
