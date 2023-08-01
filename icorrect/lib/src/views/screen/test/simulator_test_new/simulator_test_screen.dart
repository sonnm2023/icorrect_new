import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constant_strings.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/models/homework_models/homework_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect/src/models/ui_models/alert_info.dart';
import 'package:icorrect/src/presenters/simulator_test_presenter.dart';
import 'package:icorrect/src/provider/simulator_test_provider.dart';
import 'package:icorrect/src/provider/test_room_provider.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/alert_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/confirm_dialog.dart';
import 'package:icorrect/src/views/screen/test/my_test/my_test_screen.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/back_button_widget.dart';
import 'package:icorrect/src/views/widget/default_loading_indicator.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/download_progressing_widget.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/start_now_button_widget.dart';
import 'package:icorrect/src/views/screen/test/simulator_test_new/test_room_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class SimulatorTestScreen extends StatefulWidget {
  const SimulatorTestScreen({super.key, required this.homeWorkModel});

  final HomeWorkModel homeWorkModel;

  @override
  State<SimulatorTestScreen> createState() => _SimulatorTestScreenState();
}

class _SimulatorTestScreenState extends State<SimulatorTestScreen>
    implements SimulatorTestViewContract, ActionAlertListener {
  SimulatorTestPresenter? _simulatorTestPresenter;

  SimulatorTestProvider? _simulatorTestProvider;

  Permission? _microPermission;
  PermissionStatus _microPermissionStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    _simulatorTestProvider =
        Provider.of<SimulatorTestProvider>(context, listen: false);
    _simulatorTestPresenter = SimulatorTestPresenter(this);

    _getTestDetail();
  }

  @override
  void dispose() {
    _simulatorTestProvider!.resetAll();

    if (!_simulatorTestProvider!.isDisposed) {
      _simulatorTestProvider!.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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
                BackButtonWidget(backButtonTapped: _backButtonTapped),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _backButtonTapped() async {
    //Disable back button when submitting test
    if (_simulatorTestProvider!.submitStatus ==
        SubmitStatus.submitting) {
      if (kDebugMode) {
        print("Status is submitting!");
      }
      return;
    }

    switch (_simulatorTestProvider!.doingStatus.get) {
      case -1:
        {
          //None
          if (kDebugMode) {
            print("Status is not start to do the test!");
          }
          Navigator.of(context).pop();
          break;
        }
      case 0:
        {
          //Doing
          if (kDebugMode) {
            print("Status is doing the test!");
          }

          bool okButtonTapped = false;

          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return ConfirmDialogWidget(
                title: "Notification",
                message: "The test is not completed! Are you sure to quit?",
                cancelButtonTitle: "Cancel",
                okButtonTitle: "OK",
                cancelButtonTapped: () {
                  if (kDebugMode) print("_cancelButtonTapped");
                },
                okButtonTapped: () {
                  okButtonTapped = true;
                  _deleteAllAnswer();
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
            print("Status is finish doing the test!");
          }

          bool cancelButtonTapped = false;

          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return ConfirmDialogWidget(
                title: "Notification",
                message: "Do you want to save this test before quit?",
                cancelButtonTitle: "Don't Save",
                okButtonTitle: "Save",
                cancelButtonTapped: () {
                  cancelButtonTapped = true;
                  _deleteAllAnswer();
                },
                okButtonTapped: () {
                  //Submit
                  _simulatorTestProvider!
                      .updateSubmitStatus(SubmitStatus.submitting);
                  _simulatorTestPresenter!.submitTest(
                    testId: _simulatorTestProvider!
                        .currentTestDetail.testId
                        .toString(),
                    activityId: widget.homeWorkModel.id.toString(),
                    questions: _simulatorTestProvider!.questionList,
                  );
                },
              );
            },
          );

          if (cancelButtonTapped) {
            Navigator.of(context).pop();
          }

          break;
        }
    }
  }

  Future<void> _deleteAllAnswer() async {
    List<String> answers = _simulatorTestProvider!.answerList;

    if (answers.isEmpty) return;

    for (String answer in answers) {
      FileStorageHelper.deleteFile(
              answer,
              MediaType.audio,
              _simulatorTestProvider!.currentTestDetail.testId
                  .toString())
          .then((value) {
        if (false == value) {
          showToastMsg(
            msg: "Can not delete files!",
            toastState: ToastStatesType.warning,
          );
        }
      });
    }
  }

  Widget _buildBody() {
    return Consumer<SimulatorTestProvider>(
      builder: (context, provider, child) {
        if (provider.isProcessing) {
          return const DefaultLoadingIndicator(
            color: AppColor.defaultPurpleColor,
          );
        }

        if (provider.isDownloading) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const DownloadProgressingWidget(),
              Visibility(
                visible: provider.canStartNow,
                child: StartNowButtonWidget(
                  startNowButtonTapped: () {
                    _checkPermission();
                  },
                ),
              ),
            ],
          );
        }

        return Stack(
          children: [
            ChangeNotifierProvider(
              create: (_) => TestRoomProvider(),
              child: TestRoomWidget(
                homeWorkModel: widget.homeWorkModel,
                simulatorTestPresenter: _simulatorTestPresenter!,
              ),
            ),
            Visibility(
              visible: provider.submitStatus == SubmitStatus.submitting,
              child: const DefaultLoadingIndicator(
                color: AppColor.defaultPurpleColor,
              ),
            ),
          ],
        );
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

  void _getTestDetail() {
    _simulatorTestPresenter!.getTestDetail(widget.homeWorkModel.id.toString());

    Future.delayed(Duration.zero, () {
      _simulatorTestProvider!.updateProcessingStatus();
    });
  }

  void _startToDoTest() {
    //Hide StartNow button
    _simulatorTestProvider!.setStartNowButtonStatus(false);

    //Hide Loading view
    _simulatorTestProvider!.setDownloadingStatus(false);

    _simulatorTestProvider!.updateDoingStatus(DoingStatus.doing);
  }

  @override
  void onDownloadFailure(AlertInfo info) {
    if (mounted) {
      if (!_simulatorTestProvider!.dialogShowing) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertsDialog.init().showDialog(
              context,
              info,
              this,
              keyInfo: StringClass.failDownloadVideo,
            );
          },
        );
        _simulatorTestProvider!.setDialogShowing(true);
      }
    }
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
      _simulatorTestProvider!.setStartNowButtonStatus(true);
    }

    if (index == total) {
      //Auto start to do test
      _checkPermission();
    }
  }

  @override
  void onGetTestDetailComplete(TestDetailModel testDetailModel, int total) {
    _simulatorTestProvider!.setCurrentTestDetail(testDetailModel);
    _simulatorTestProvider!.updateProcessingStatus();
    _simulatorTestProvider!.setDownloadingStatus(true);
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
  void onGotoMyTestScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MyTestScreen(
          homeWorkModel: widget.homeWorkModel,
          isFromSimulatorTest: true,
        ),
      ),
    );
  }

  @override
  void onSubmitTestFail(String msg) {
    _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.fail);

    showToastMsg(
      msg: msg,
      toastState: ToastStatesType.error,
    );

    //Go to MyTest Screen
    Navigator.of(context).pop();
  }

  @override
  void onSubmitTestSuccess(String msg) {
    _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.success);

    showToastMsg(
      msg: msg,
      toastState: ToastStatesType.success,
    );

    //Go to MyTest Screen
    _simulatorTestPresenter!.gotoMyTestScreen();
  }
}
