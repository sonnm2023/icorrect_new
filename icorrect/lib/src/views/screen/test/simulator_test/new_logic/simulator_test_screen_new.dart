import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activity_answer_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect/src/models/ui_models/alert_info.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/alert_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/circle_loading.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/custom_alert_dialog.dart';
import 'package:icorrect/src/views/screen/test/my_test/student_detail_test/download_again_widget.dart';
import 'package:icorrect/src/views/screen/test/simulator_test/new_logic/download_info.dart';
import 'package:icorrect/src/views/screen/test/simulator_test/new_logic/download_processing_widget_new.dart';
import 'package:icorrect/src/views/screen/test/simulator_test/new_logic/message_dialog_widget.dart';
import 'package:icorrect/src/views/screen/test/simulator_test/new_logic/simulator_presenter_new.dart';
import 'package:icorrect/src/views/screen/test/simulator_test/new_logic/simulator_test_provider_new.dart';
import 'package:icorrect/src/views/screen/test/simulator_test/new_logic/start_now_button_widget.dart';
import 'package:icorrect/src/views/screen/test/simulator_test/new_logic/test_room_simulator.dart';
import 'package:icorrect/src/views/widget/default_loading_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class SimulatorTestScreenNew extends StatefulWidget {
  const SimulatorTestScreenNew(
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
  State<SimulatorTestScreenNew> createState() => _SimulatorTestScreenState();
}

class _SimulatorTestScreenState extends State<SimulatorTestScreenNew>
    with TickerProviderStateMixin
    implements SimulatorTestViewContractNew, ActionAlertListener {
  double w = 0;
  double h = 0;
  SimulatorTestPresenterNew? _simulatorTestPresenter;

  SimulatorTestProviderNew? _simulatorTestProvider;
  AuthProvider? _authWidgetProvider;
  // CameraPreviewProvider? _cameraPreviewProvider;

  Permission? _microPermission;
  CircleLoading? _loading;
  PermissionStatus _microPermissionStatus = PermissionStatus.denied;
  TabController? _tabController;

  StreamSubscription? connection;
  bool isOffline = false;
  bool _isExam = false;

  @override
  void initState() {
    connection = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // when every connection status is changed.
      if (result == ConnectivityResult.none) {
        isOffline = true;
      } else if (result == ConnectivityResult.mobile) {
        isOffline = false;
      } else if (result == ConnectivityResult.wifi) {
        isOffline = false;
      } else if (result == ConnectivityResult.ethernet) {
        isOffline = false;
      } else if (result == ConnectivityResult.bluetooth) {
        isOffline = false;
      }

      if (kDebugMode) {
        print("DEBUG: NO INTERNET === $isOffline");
      }
      if (isOffline) {
        Future.delayed(Duration.zero, () {
          _showCheckNetworkDialog();
        });
      }
    });

    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    _loading = CircleLoading();

    _simulatorTestProvider =
        Provider.of<SimulatorTestProviderNew>(context, listen: false);
    // _cameraPreviewProvider =
    //     Provider.of<CameraPreviewProvider>(context, listen: false);
    Future.delayed(Duration.zero, () {
      _simulatorTestProvider!.resetAll();
    });
    _authWidgetProvider = Provider.of<AuthProvider>(context, listen: false);
    _simulatorTestPresenter = SimulatorTestPresenterNew(this);

    if (widget.homeWorkModel != null) {
      _isExam = widget.homeWorkModel!.activityType == ActivityType.exam.name ||
          widget.homeWorkModel!.activityType == ActivityType.test.name;
    } else {
      _isExam = false;
    }
    _getTestDetail();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              InkWell(
                onTap: _backButtonTapped,
                child: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: const Icon(
                    Icons.arrow_back_outlined,
                    color: AppColor.defaultPurpleColor,
                    size: 30,
                  ),
                ),
              ),
              Text(
                  (widget.homeWorkModel != null)
                      ? widget.homeWorkModel!.activityName
                      : "",
                  style: const TextStyle(
                      color: AppColor.defaultPurpleColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBody(),
              _buildDownloadAgain(),
            ],
          ),
        ),
      ],
    ));
  }

  @override
  void dispose() {
    super.dispose();
    // CameraService.instance()
    //     .disposeCurrentCamera(provider: _cameraPreviewProvider!);
    connection!.cancel();
    _simulatorTestPresenter!.closeClientRequest();
    _simulatorTestPresenter!.resetAutoRequestDownloadTimes();
    _simulatorTestProvider!.resetAll();
  }

  void _backButtonTapped() async {
    //Disable back button when submitting test
    if (_simulatorTestProvider!.submitStatus == SubmitStatus.submitting) {
      if (kDebugMode) {
        print("DEBUG: Status is submitting!");
      }
      return;
    }

    if (_simulatorTestProvider!.submitStatus == SubmitStatus.success) {
      if (_simulatorTestProvider!.reanswersList.isNotEmpty) {
        if (kDebugMode) {
          print("DEBUG: Status is doing the test!");
        }

        bool okButtonTapped = false;
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlertDialog(
              title: Utils.multiLanguage(StringConstants.dialog_title),
              description:
                  Utils.multiLanguage("save_change_before_exit_message"),
              okButtonTitle: StringConstants.ok_button_title,
              cancelButtonTitle:
                  Utils.multiLanguage(StringConstants.cancel_button_title),
              borderRadius: 8,
              hasCloseButton: false,
              okButtonTapped: () {
                okButtonTapped = true;
                _onSubmitTest();
              },
              cancelButtonTapped: () {
                Navigator.of(context).pop();
              },
            );
          },
        );

        if (okButtonTapped) {
          Navigator.of(context).pop();
        }
      } else {
        // _authWidgetProvider!.setRefresh(true); //TODO
        Navigator.of(context).pop();
      }
      return;
    }

    switch (_simulatorTestProvider!.doingStatus.get) {
      case -1:
        {
          //None
          if (kDebugMode) {
            print("DEBUG: Status is not start to do the test!");
          }
          Navigator.of(context).pop();
          break;
        }
      case 0:
        {
          //Doing
          if (kDebugMode) {
            print("DEBUG: Status is doing the test!");
          }

          bool okButtonTapped = false;

          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomAlertDialog(
                title: Utils.multiLanguage(StringConstants.dialog_title),
                description: Utils.multiLanguage("exit_while_testing_confirm"),
                okButtonTitle: StringConstants.ok_button_title,
                cancelButtonTitle:
                    Utils.multiLanguage(StringConstants.cancel_button_title),
                borderRadius: 8,
                hasCloseButton: false,
                okButtonTapped: () {
                  okButtonTapped = true;
                  _deleteAllAnswer();
                },
                cancelButtonTapped: () {
                  Navigator.of(context).pop();
                },
              );
            },
          );

          if (okButtonTapped) {
            // _authWidgetProvider!.setRefresh(_isExam); //TODO
            Navigator.of(context).pop();
          }

          break;
        }
      case 1:
        {
          //Finish
          if (kDebugMode) {
            print("DEBUG: Status is finish doing the test!");
          }

          bool cancelButtonTapped = false;

          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomAlertDialog(
                title: Utils.multiLanguage(StringConstants.dialog_title),
                description: Utils.multiLanguage("save_before_exit_message"),
                okButtonTitle:
                    Utils.multiLanguage(StringConstants.save_button_title),
                cancelButtonTitle:
                    Utils.multiLanguage(StringConstants.dont_save_button_title),
                borderRadius: 8,
                hasCloseButton: false,
                okButtonTapped: () {
                  //Submit
                  _onSubmitTest();
                },
                cancelButtonTapped: () {
                  cancelButtonTapped = true;
                  _deleteAllAnswer();
                  Navigator.of(context).pop();
                },
              );
            },
          );

          if (cancelButtonTapped) {
            // _authWidgetProvider!.setRefresh(_isExam);//TODO
            Navigator.of(context).pop();
          }

          break;
        }
    }
  }

  Future _onSubmitTest() async {
    _loading!.show(context: context, isViewAIResponse: false);

    String activityId = "";
    if (widget.homeWorkModel != null) {
      activityId = widget.homeWorkModel!.activityId.toString();
    }
    if (_simulatorTestProvider!.reanswersList.isNotEmpty) {
      _simulatorTestPresenter!.submitTest(
          context: context,
          testId: _simulatorTestProvider!.currentTestDetail.testId.toString(),
          activityId: activityId,
          questions: _simulatorTestProvider!.reanswersList,
          isExam: _isExam,
          isUpdate: true,
          logAction: _simulatorTestProvider!.logActions);
    } else {
      String pathVideo = _simulatorTestPresenter!
          .randomVideoRecordExam(_simulatorTestProvider!.videosRecorded);
      if (kDebugMode) {
        print("RECORDING_VIDEO : Video Recording saved at: $pathVideo");
      }
      _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.submitting);
      _simulatorTestPresenter!.submitTest(
          context: context,
          testId: _simulatorTestProvider!.currentTestDetail.testId.toString(),
          activityId: activityId,
          questions: _simulatorTestProvider!.questionList,
          isExam: _isExam,
          isUpdate: false,
          videoConfirmFile:
              File(pathVideo).existsSync() ? File(pathVideo) : null,
          logAction: _simulatorTestProvider!.logActions);
    }
  }

  Future<void> _deleteAllAnswer() async {
    List<String> answers = _simulatorTestProvider!.answerList;

    if (answers.isEmpty) return;

    for (String answer in answers) {
      FileStorageHelper.deleteFile(answer, MediaType.audio,
              _simulatorTestProvider!.currentTestDetail.testId.toString())
          .then((value) {
        if (false == value) {
          // showDialog(
          //     context: context,
          //     builder: (context) {
          //       return MessageDialog(
          //           context: context, message: "Can not delete files!");
          //     });
        }
      });
    }
  }

  Widget _buildBody() {
    return Consumer<SimulatorTestProviderNew>(
        builder: (context, provider, child) {
      if (kDebugMode) {
        print("DEBUG: SimulatorTest --- build -- buildBody");
      }

      if (provider.isDownloadProgressing) {
        DownloadInfo downloadInfo = DownloadInfo(provider.downloadingIndex,
            provider.downloadingPercent, provider.total);
        return Column(
          children: [
            DownloadProgressingWidget(downloadInfo),
            Visibility(
              visible: provider.startNowAvailable,
              child: StartNowButtonWidget(
                startNowButtonTapped: () {
                  _checkPermission();
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
        return (provider.submitStatus == SubmitStatus.success &&
                widget.homeWorkModel != null)
            ? Expanded(
                child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 50),
                    child: Scaffold(
                      backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                      appBar: PreferredSize(
                          preferredSize: const Size.fromHeight(40),
                          child: Container(
                            margin: EdgeInsets.only(
                              left: 50,
                              right: 0,
                            ),
                            child: DefaultTabController(
                                initialIndex: 0,
                                length: (provider.submitStatus ==
                                        SubmitStatus.success)
                                    ? 3
                                    : 1,
                                child: TabBar(
                                    controller: _tabController,
                                    indicator: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(5),
                                            topRight: Radius.circular(5)),
                                        border: Border.all(
                                            color: Colors.black, width: 2)),
                                    indicatorColor: Colors.black,
                                    labelColor: Colors.black,
                                    unselectedLabelColor:
                                        AppColor.defaultGrayColor,
                                    tabs: _getTabs())),
                          )),
                      body: TabBarView(
                          controller: _tabController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            TestRoomSimulator(
                              activitiesModel: widget.homeWorkModel,
                              testDetailModel:
                                  _simulatorTestProvider!.currentTestDetail,
                              simulatorTestPresenter: _simulatorTestPresenter!,
                              simulatorTestProvider: _simulatorTestProvider!,
                            ),
                            //TODO
                            Container(),
                            Container(),
                            // HighLightHomeWorks(
                            //     provider: Provider.of<MyTestProvider>(context,
                            //         listen: false),
                            //     homeWorkModel: widget.homeWorkModel!),
                            // OtherHomeWorks(
                            //     provider: Provider.of<MyTestProvider>(context,
                            //         listen: false),
                            //     homeWorkModel: widget.homeWorkModel!)
                          ]),
                    )))
            : Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: TestRoomSimulator(
                  activitiesModel: widget.homeWorkModel,
                  testDetailModel: _simulatorTestProvider!.currentTestDetail,
                  simulatorTestPresenter: _simulatorTestPresenter!,
                  simulatorTestProvider: _simulatorTestProvider!,
                ),
              );
      }
    });
  }

  _getTabs() {
    return [
      Tab(text: Utils.multiLanguage("test_detail_title")),
      Tab(text: Utils.multiLanguage("highlight_title")),
      Tab(text: Utils.multiLanguage("others_list")),
    ];
  }

  Widget _buildDownloadAgain() {
    return Consumer<SimulatorTestProviderNew>(
        builder: (context, provider, child) {
      if (provider.needDownloadAgain) {
        return DownloadAgainWidget(
          simulatorTestPresenter: null,
          otherStudentTestPresenter: null,
          // onClickTryAgain: () {
          //   if (_simulatorTestPresenter != null) {
          //     _simulatorTestPresenter!.tryAgainToDownload();
          //   }
          // },
        );
      } else {
        return const SizedBox();
      }
    });
  }

  void _checkPermission() async {
    if (_microPermission == null) {
      await _initializePermission();
    }

    if (mounted) {
      _requestPermission(_microPermission!, context);
    }
  }

  Future<void> _requestPermission(
      Permission permission, BuildContext context) async {
    _simulatorTestProvider!.setPermissionDeniedTime();
    // ignore: unused_local_variable
    final status = await permission.request();
    _listenForPermissionStatus(context);
  }

  void _listenForPermissionStatus(BuildContext context) async {
    if (_microPermission != null) {
      _microPermissionStatus = await _microPermission!.status;

      if (_microPermissionStatus == PermissionStatus.denied) {
        if (_simulatorTestProvider!.permissionDeniedTime > 2) {
          _showConfirmDialog();
        }
      } else if (_microPermissionStatus == PermissionStatus.permanentlyDenied) {
        openAppSettings();
      } else {
        _startToDoTest();
      }
    }
  }

  Future<void> _initializePermission() async {
    _microPermission = Permission.microphone;
  }

  void _getTestDetail() async {
    await _simulatorTestPresenter!.initializeData();
    if (widget.homeWorkModel != null) {
      _simulatorTestPresenter!.getTestDetailByHomework(
          context, widget.homeWorkModel!.activityId.toString());
    } else {
      _simulatorTestPresenter!.getTestDetailByPractice(
          context: context,
          testOption: widget.testOption ?? 0,
          topicsId: widget.topicsId ?? [],
          isPredict: widget.isPredict ?? 0);
    }
  }

  void _startToDoTest() {
    _simulatorTestProvider!.setStartNowStatus(false);
    _simulatorTestProvider!.setGettingTestDetailStatus(false);

    //Hide Loading view
    _simulatorTestProvider!.setDownloadProgressingStatus(false);
  }

  void _showConfirmDialog() {
    if (false == _simulatorTestProvider!.dialogShowing) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertsDialog.init().showDialog(
              context,
              AlertClass.microPermissionAlert,
              this,
              keyInfo: StringClass.permissionDenied,
            );
          });
      _simulatorTestProvider!.setDialogShowing(true);
    }
  }

  bool _isNetworkDialogShowing = false;
  void _showCheckNetworkDialog() async {
    if (!_isNetworkDialogShowing) {
      bool okButtonTapped = false;
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: Utils.multiLanguage(StringConstants.warning_title),
            description:
                Utils.multiLanguage(StringConstants.network_error_message),
            okButtonTitle: StringConstants.ok_button_title,
            cancelButtonTitle:
                Utils.multiLanguage(StringConstants.cancel_button_title),
            borderRadius: 8,
            hasCloseButton: false,
            okButtonTapped: () {
              okButtonTapped = true;
              _simulatorTestPresenter!.tryAgainToDownload();
            },
            cancelButtonTapped: () {
              Navigator.of(context).pop();
            },
          );
        },
      );

      if (okButtonTapped) {
        // _authWidgetProvider!.setRefresh(_isExam);//TODO
        Navigator.of(context).pop();
      }
      _isNetworkDialogShowing = true;
    }
  }

  @override
  void onDownloadFailure(AlertInfo info) {
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(context: context, message: info.description);
        });
  }

  @override
  void onDownloadSuccess(TestDetailModel testDetail, String nameFile,
      double percent, int index, int total) {
    _simulatorTestProvider!.setTotal(total);
    _simulatorTestProvider!.updateDownloadingIndex(index);
    _simulatorTestProvider!.updateDownloadingPercent(percent);
    _simulatorTestProvider!.setActivityType(testDetail.activityType);

    //Enable Start Testing Button
    if (index >= 5) {
      _simulatorTestProvider!.setStartNowStatus(true);
    }

    if (index == total) {
      //Auto start to do test
      _simulatorTestProvider!.setDownloadAgainSuccess(true);
      _checkPermission();
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
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(context: context, message: message);
        });
  }

  @override
  void onGotoMyTestScreen(ActivityAnswer activityAnswer) {
    if (kDebugMode) {
      print("DEBUG: onGotoMyTestScreen");
    }

    //Update activityAnswer into current homeWorkModel
    if (widget.homeWorkModel != null) {
      //TODO
      // widget.homeWorkModel!.activityAnswer = activityAnswer;
      // Navigator.of(context).push(
      //   MaterialPageRoute(
      //     builder: (context) => MyTestScreen(homeWork: activitiesModel),
      //   ),
      // );
    }
  }

  @override
  void onHandleBackButtonSystemTapped() {
    // TODO: implement onHandleBackButtonSystemTapped
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
  void onReDownload() {
    _simulatorTestProvider!.setNeedDownloadAgain(true);
    _simulatorTestProvider!.setDownloadProgressingStatus(false);
    _simulatorTestProvider!.setGettingTestDetailStatus(false);
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
    Utils.sendLog();
    _loading!.hide();
    _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.fail);
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(context: context, message: msg);
        });
    //Go to MyTest Screen
    // Navigator.of(context).pop();
  }

  @override
  void onSubmitTestSuccess(String msg, ActivityAnswer activityAnswer) {
    Utils.sendLog();
    _loading!.hide();
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(context: context, message: msg);
        });
    if (mounted) {
      // _authWidgetProvider!.setRefresh(true);
      _simulatorTestProvider!.setVisibleSaveTheTest(false);
      _simulatorTestProvider!.clearReasnwersList();
      _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.success);
    }
    // //Go to MyTest Screen
    // _simulatorTestPresenter!.gotoMyTestScreen(activityAnswer);
    // Navigator.of(context).pop();
    // Navigator.of(context).pop();
  }

  @override
  void onTryAgainToDownload() {
    if (isOffline) {
      _showCheckNetworkDialog();
    } else {
      if (null != _simulatorTestPresenter!.testDetail &&
          null != _simulatorTestPresenter!.filesTopic) {
        updateStatusForReDownload();
        if (null == _simulatorTestPresenter!.dio) {
          _simulatorTestPresenter!.initializeData();
        }
        String? activityId;
        if (widget.homeWorkModel != null) {
          activityId = widget.homeWorkModel!.activityId.toString();
        }
        _simulatorTestPresenter!
            .reDownloadFiles(context, activityId: activityId);
      }
    }
  }

  void updateStatusForReDownload() {
    _simulatorTestProvider!.setDownloadAgain(true);
    _simulatorTestProvider!.setDownloadAgainSuccess(false);
    _simulatorTestProvider!.setNeedDownloadAgain(false);
    _simulatorTestProvider!.setStartNowStatus(false);
    _simulatorTestProvider!.setDownloadProgressingStatus(true);
  }

  @override
  void onAlertExit(String keyInfo) {
    // TODO: implement onAlertExit
  }

  @override
  void onAlertNextStep(String keyInfo) {
    // TODO: implement onAlertNextStep
  }
}
