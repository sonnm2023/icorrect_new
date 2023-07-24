import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constant_strings.dart';
import 'package:icorrect/src/models/homework_models/homework_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect/src/models/ui_models/alert_info.dart';
import 'package:icorrect/src/presenters/simulator_test_presenter.dart';
import 'package:icorrect/src/provider/prepare_simulator_test_provider.dart';
import 'package:icorrect/src/provider/test_provider.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/alert_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/confirm_dialog.dart';
import 'package:icorrect/src/views/screen/test/simulator_test_new/back_button_widget.dart';
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

  PrepareSimulatorTestProvider? _prepareSimulatorTestProvider;

  Permission? _microPermission;
  PermissionStatus _microPermissionStatus = PermissionStatus.denied;
  bool needUpdate = false;

  @override
  void initState() {
    super.initState();

    _prepareSimulatorTestProvider =
        Provider.of<PrepareSimulatorTestProvider>(context, listen: false);

    _simulatorTestPresenter = SimulatorTestPresenter(this);
    _getTestDetail();
  }

  @override
  void dispose() {
    if (!_prepareSimulatorTestProvider!.isDisposed) {
      _prepareSimulatorTestProvider!.dispose();
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

  void _backButtonTapped() {
    if (_prepareSimulatorTestProvider!.isDoingTest) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ConfirmDialogWidget(
            title: "Notification",
            message: "The test is not completed! Are you sure to quit?",
            cancelButtonTitle: "Cancel",
            okButtonTitle: "OK",
            cancelButtonTapped: _cancelButtonTapped,
            okButtonTapped: _okButtonTapped,
          );
        },
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _cancelButtonTapped() {
    if (kDebugMode) print("_cancelButtonTapped");
  }

  void _okButtonTapped() {
    //TODO: Call TestRoom stop to record
    // _recordController.stop();

    // if (null != _testProvider!.playController) {
    //   _testProvider!.playController!.pause();
    // }

    // _playAnswerProvider!.resetAll(); //TODO: Call TestRoom resetAll
    // _timerProvider!.resetAll(); //TODO: Call TestRoom resetAll
    // _testProvider!.resetAll();
    setState(() {
      needUpdate = true;
    });

    Navigator.of(context).pop();
  }

  Widget _buildBody() {
    return Consumer<PrepareSimulatorTestProvider>(
      builder: (context, provider, child) {
        if (provider.isProcessing) {
          if (kDebugMode) {
            print("SimulatorTestScreen - DefaultLoadingIndicator");
          }

          return const DefaultLoadingIndicator(
            color: AppColor.defaultPurpleColor,
          );
        }

        if (provider.isDownloading) {
          if (kDebugMode) print("SimulatorTestScreen - isDownloading");
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

        if (kDebugMode) print("SimulatorTestScreen - TestRoomWidget");
        return ChangeNotifierProvider(
          create: (_) => TestProvider(),
          child: TestRoomWidget(needUpdate: needUpdate,),
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
    _prepareSimulatorTestProvider!.setPermissionDeniedTime();
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
        if (_prepareSimulatorTestProvider!.permissionDeniedTime > 2) {
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
    if (false == _prepareSimulatorTestProvider!.dialogShowing) {
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
      _prepareSimulatorTestProvider!.setDialogShowing(true);
    }
  }

  void _getTestDetail() {
    _simulatorTestPresenter!.getTestDetail(widget.homeWorkModel.id.toString());

    Future.delayed(Duration.zero, () {
      _prepareSimulatorTestProvider!.updateProcessingStatus();
    });
  }

  void _startToDoTest() {
    //Hide StartNow button
    _prepareSimulatorTestProvider!.setStartNowButtonStatus(false);

    //Hide Loading view
    _prepareSimulatorTestProvider!.setDownloadingStatus(false);

    _prepareSimulatorTestProvider!.setIsDoingTest(true);
  }

  @override
  void onDownloadFailure(AlertInfo info) {
    if (mounted) {
      if (!_prepareSimulatorTestProvider!.dialogShowing) {
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
        _prepareSimulatorTestProvider!.setDialogShowing(true);
      }
    }
  }

  @override
  void onDownloadSuccess(TestDetailModel testDetail, String nameFile,
      double percent, int index, int total) {
    _prepareSimulatorTestProvider!.setTotal(total);
    _prepareSimulatorTestProvider!.updateDownloadingIndex(index);
    _prepareSimulatorTestProvider!.updateDownloadingPercent(percent);

    //Enable Start Testing Button
    if (index >= 5) {
      _prepareSimulatorTestProvider!.setStartNowButtonStatus(true);
    }

    if (index == total) {
      //Auto start to do test
      _checkPermission();
    }
  }

  @override
  void onGetTestDetailComplete(TestDetailModel testDetailModel, int total) {
    _prepareSimulatorTestProvider!.updateProcessingStatus();
    _prepareSimulatorTestProvider!.setDownloadingStatus(true);
    _prepareSimulatorTestProvider!.setTotal(total);
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
    list.sort((a, b) => a.numPart.compareTo(b.numPart));
    _prepareSimulatorTestProvider!.setTopicsList(list);
    Queue<TopicModel> queue = Queue<TopicModel>();
    queue.addAll(list);
    _prepareSimulatorTestProvider!.setTopicsQueue(queue);
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
