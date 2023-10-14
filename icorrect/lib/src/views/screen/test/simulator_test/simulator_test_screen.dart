import 'dart:async';
import 'dart:collection';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activity_answer_model.dart';
import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect/src/models/ui_models/alert_info.dart';
import 'package:icorrect/src/presenters/simulator_test_presenter.dart';
import 'package:icorrect/src/provider/homework_provider.dart';
import 'package:icorrect/src/provider/simulator_test_provider.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/alert_dialog.dart';
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
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class SimulatorTestScreen extends StatefulWidget {
  const SimulatorTestScreen({super.key, required this.homeWorkModel});

  final ActivitiesModel homeWorkModel;

  @override
  State<SimulatorTestScreen> createState() => _SimulatorTestScreenState();
}

class _SimulatorTestScreenState extends State<SimulatorTestScreen>
    with AutomaticKeepAliveClientMixin<SimulatorTestScreen>
    implements SimulatorTestViewContract, ActionAlertListener {
  SimulatorTestPresenter? _simulatorTestPresenter;

  SimulatorTestProvider? _simulatorTestProvider;

  Permission? _microPermission;
  PermissionStatus _microPermissionStatus = PermissionStatus.denied;

  // Map<Permission, PermissionStatus>? _statuses; //TODO

  StreamSubscription? connection;
  bool isOffline = false;
  CircleLoading? _loading;

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
    return const [
      Tab(
        child: Text(
          StringConstants.my_exam_tab_title,
          style: TextStyle(
            fontSize: FontsSize.fontSize_14,
            color: AppColor.defaultPurpleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Tab(
        child: Text(
          StringConstants.highlight_tab_title,
          style: TextStyle(
            fontSize: FontsSize.fontSize_14,
            color: AppColor.defaultPurpleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Tab(
        child: Text(
          StringConstants.others_tab_title,
          style: TextStyle(
            fontSize: FontsSize.fontSize_14,
            color: AppColor.defaultPurpleColor,
            fontWeight: FontWeight.bold,
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
    });

    super.initState();
    _simulatorTestProvider =
        Provider.of<SimulatorTestProvider>(context, listen: false);
    _simulatorTestPresenter = SimulatorTestPresenter(this);

    Provider.of<HomeWorkProvider>(context, listen: false)
        .setSimulatorTestPresenter(_simulatorTestPresenter);

    _loading = CircleLoading();

    _getTestDetail();
  }

  @override
  void dispose() {
    connection!.cancel();
    _simulatorTestPresenter!.closeClientRequest();
    _simulatorTestPresenter!.resetAutoRequestDownloadTimes();
    _simulatorTestProvider!.resetAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Consumer<SimulatorTestProvider>(
        builder: (context, simulatorTest, child) {
          if (simulatorTest.isShowConfirmSaveTest) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showConfirmSaveTestBeforeExit();
            });
          }
          if (simulatorTest.submitStatus == SubmitStatus.success) {
            return Stack(
              children: [
                DefaultTabController(
                  length: 3,
                  child: Scaffold(
                    key: _scaffoldKey,
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
                        widget.homeWorkModel.activityName,
                        style: CustomTextStyle.appbarTitle,
                      ),
                      bottom: PreferredSize(
                        preferredSize:
                            const Size.fromHeight(CustomSize.size_40),
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
                            child: Stack(
                              children: [
                                _buildBody(),
                              ],
                            ),
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
      ),
    );
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
      homeWorkModel: widget.homeWorkModel,
    );
  }

  Widget _buildOtherTab() {
    return OtherTab(
      provider: _simulatorTestProvider!,
      homeWorkModel: widget.homeWorkModel,
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
          builder: (BuildContext context) {
            return CustomAlertDialog(
              title: StringConstants.dialog_title,
              description:
                  StringConstants.confirm_save_change_answers_message_1,
              okButtonTitle: StringConstants.save_button_title,
              cancelButtonTitle: StringConstants.dont_save_button_title,
              borderRadius: 8,
              hasCloseButton: true,
              okButtonTapped: () {
                //Update reanswer
                _loading!.show(context);
                _simulatorTestProvider!.setVisibleSaveTheTest(false);
                _simulatorTestPresenter!.submitTest(
                  context: context,
                  testId: _simulatorTestProvider!.currentTestDetail.testId
                      .toString(),
                  activityId: widget.homeWorkModel.activityId.toString(),
                  questions: _simulatorTestProvider!.questionList,
                  isUpdate: true,
                );
              },
              cancelButtonTapped: () {
                cancelButtonTapped = true;
                Navigator.of(context).pop();
              },
            );
          },
        );

        if (cancelButtonTapped) {
          Navigator.of(context).pop();
        }
      } else {
        //Go back List homework screen
        Navigator.pop(context, 'refresh');
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
            Navigator.of(context).pop();
            break;
          }
        case 0:
          {
            //Doing
            if (kDebugMode) {
              print("DEBUG: Status is doing the exam!");
            }

            bool okButtonTapped = false;

            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomAlertDialog(
                  title: StringConstants.dialog_title,
                  description: StringConstants.quit_the_test_message,
                  okButtonTitle: StringConstants.ok_button_title,
                  cancelButtonTitle: StringConstants.cancel_button_title,
                  borderRadius: 8,
                  hasCloseButton: false,
                  okButtonTapped: () {
                    //Reset question image
                    _resetQuestionImage();

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
              Navigator.of(context).pop();
            }

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

  Future _showConfirmSaveTestBeforeExit() async {
    bool cancelButtonTapped = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: StringConstants.dialog_title,
          description: StringConstants.confirm_before_quit_the_test_message,
          okButtonTitle: StringConstants.save_button_title,
          cancelButtonTitle: StringConstants.cancel_button_title,
          borderRadius: 8,
          hasCloseButton: true,
          okButtonTapped: () {
            //Reset question image
            _resetQuestionImage();
          
            //Submit
            _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.submitting);
            _simulatorTestPresenter!.submitTest(
              context: context,
              testId:
                  _simulatorTestProvider!.currentTestDetail.testId.toString(),
              activityId: widget.homeWorkModel.activityId.toString(),
              questions: _simulatorTestProvider!.questionList,
              isUpdate: false,
            );
            _simulatorTestProvider!.setShowConfirmSaveTest(false);
          },
          cancelButtonTapped: () {
            cancelButtonTapped = true;
            _simulatorTestProvider!.setShowConfirmSaveTest(false);
            _deleteAllAnswer();
            Navigator.of(context).pop();
          },
        );
      },
    );

    if (cancelButtonTapped) {
      Navigator.of(context).pop();
    }
  }

  void _resetQuestionImage() {
    if (_simulatorTestProvider!.questionHasImage) {
      _simulatorTestProvider!.setQuestionHasImageStatus(false);
      _simulatorTestProvider!.resetQuestionImageUrl();
    }
  }

  Future<void> _deleteAllAnswer() async {
    List<String> answers = _simulatorTestProvider!.answerList;

    if (answers.isEmpty) return;

    for (String answer in answers) {
      FileStorageHelper.deleteFile(answer, MediaType.audio,
              _simulatorTestProvider!.currentTestDetail.testId.toString())
          .then(
        (value) {
          if (false == value) {
            showToastMsg(
              msg: StringConstants.can_not_delete_files_message,
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

  Future<void> _initializePermission() async {
    _microPermission = Permission.microphone;
    if (mounted) {
      _simulatorTestProvider!.setPermissionDeniedTime();

      //TODO
      // _statuses = await [Permission.microphone, Permission.camera].request();

      _listenForPermissionStatus(context);
    }
  }

  void _listenForPermissionStatus(BuildContext context) async {
    // Permission? _microPermission;
    // PermissionStatus _microPermissionStatus = PermissionStatus.denied;
    if (_microPermission != null) {
      _microPermissionStatus = await _microPermission!.status;

      if (_microPermissionStatus == PermissionStatus.denied) {
        if (_simulatorTestProvider!.permissionDeniedTime > 2) {
          // _simulatorTestProvider!.setDialogShowing(true);
          _showConfirmDialogWithMessage(
              StringConstants.confirm_access_micro_permission_message);
          // _showConfirmDialog();
        }
      } else if (_microPermissionStatus == PermissionStatus.permanentlyDenied) {
        // _simulatorTestProvider!.setDialogShowing(true);
        _showConfirmDialogWithMessage(
            StringConstants.confirm_access_micro_permission_message);
      } else {
        _startToDoTest();
      }
    }
  }

  // void _showConfirmDialog() {
  //   if (false == _simulatorTestProvider!.dialogShowing) {
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (context) {
  //         return AlertsDialog.init().showDialog(
  //           context,
  //           AlertClass.microPermissionAlert,
  //           this,
  //           keyInfo: StringClass.permissionDenied,
  //         );
  //       },
  //     );
  //     _simulatorTestProvider!.setDialogShowing(true);
  //   }
  // }

  void _showConfirmDialogWithMessage(String message) async {
    // if (true == _simulatorTestProvider!.dialogShowing) {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: StringConstants.dialog_title,
          description: message,
          okButtonTitle: StringConstants.ok_button_title,
          cancelButtonTitle: StringConstants.cancel_button_title,
          borderRadius: 8,
          hasCloseButton: false,
          okButtonTapped: () {
            // _simulatorTestProvider!.setDialogShowing(false);
            openAppSettings();
          },
          cancelButtonTapped: () {
            // _simulatorTestProvider!.setDialogShowing(false);
            Navigator.of(context).pop();
          },
        );
      },
    );
    // }
  }

  void _getTestDetail() async {
    await _simulatorTestPresenter!.initializeData();
    _simulatorTestPresenter!.getTestDetail(
        context: context,
        homeworkId: widget.homeWorkModel.activityId.toString());
  }

  void _startToDoTest() {
    _simulatorTestProvider!.setStartNowStatus(false);
    _simulatorTestProvider!.setGettingTestDetailStatus(false);

    //Hide Loading view
    _simulatorTestProvider!.setDownloadProgressingStatus(false);

    _simulatorTestProvider!.updateDoingStatus(DoingStatus.doing);
  }

  void _showCheckNetworkDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: StringConstants.dialog_title,
          description: StringConstants.network_error_message,
          okButtonTitle: StringConstants.ok_button_title,
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
    _simulatorTestProvider!.setActivityType(widget.homeWorkModel.activityType);

    //Enable Start Testing Button
    if (index >= 5) {
      _simulatorTestProvider!.setStartNowStatus(true);
    }

    if (index == total) {
      //Auto start to do test
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
    //Show error message
    showToastMsg(
      msg: message,
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
  void onAlertExit(String keyInfo) {
    // TODO: implement onAlertExit
  }

  @override
  void onAlertNextStep(String keyInfo) {
    // TODO: implement onAlertNextStep
  }

  @override
  void onSubmitTestFail(String msg) {
    if (_simulatorTestProvider!.doingStatus == DoingStatus.finish) {
      _loading!.hide();
    } else {
      _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.fail);
    }

    showToastMsg(
      msg: msg,
      toastState: ToastStatesType.error,
    );

    Navigator.of(context).pop();
  }

  @override
  void onSubmitTestSuccess(String msg, ActivityAnswer activityAnswer) {
    if (_simulatorTestProvider!.doingStatus == DoingStatus.finish) {
      _loading!.hide();
    } else {
      _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.success);
    }

    showToastMsg(
      msg: msg,
      toastState: ToastStatesType.success,
    );

    Navigator.pop(context, 'refresh');
  }

  @override
  void onReDownload() {
    _simulatorTestProvider!.setNeedDownloadAgain(true);
    _simulatorTestProvider!.setDownloadProgressingStatus(false);
    _simulatorTestProvider!.setGettingTestDetailStatus(false);
  }

  void updateStatusForReDownload() {
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
            context, widget.homeWorkModel.activityId.toString());
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
}
