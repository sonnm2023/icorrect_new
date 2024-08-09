import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/models/homework_models/new_api_135/activity_answer_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/file_path_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect_pc/src/models/ui_models/alert_info.dart';
import 'package:icorrect_pc/src/models/ui_models/download_info.dart';
import 'package:icorrect_pc/src/providers/auth_widget_provider.dart';
import 'package:icorrect_pc/src/providers/my_test_provider.dart';
import 'package:icorrect_pc/src/providers/window_manager_provider.dart';
import 'package:icorrect_pc/src/utils/navigations.dart';
import 'package:icorrect_pc/src/views/dialogs/circle_loading.dart';
import 'package:icorrect_pc/src/views/test/my_test/highlight_activities.dart';
import 'package:icorrect_pc/src/views/test/my_test/other_activities.dart';
import 'package:icorrect_pc/src/views/test/simulator_test/test_room_simulator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../../../core/app_colors.dart';
import '../../../data_source/constants.dart';
import '../../../data_source/local/file_storage_helper.dart';
import '../../../models/homework_models/new_api_135/activities_model.dart';
import '../../../models/log_models/log_model.dart';
import '../../../presenters/simulator_test_presenter.dart';
import '../../../providers/camera_preview_provider.dart';
import '../../../providers/simulator_test_provider.dart';
import '../../../utils/utils.dart';
import '../../dialogs/alert_dialog.dart';
import '../../dialogs/custom_alert_dialog.dart';
import '../../dialogs/message_alert.dart';
import '../../widgets/default_loading_indicator.dart';
import '../../widgets/download_again_widget.dart';
import '../../widgets/simulator_test_widgets/download_progressing_widget.dart';
import '../../widgets/simulator_test_widgets/start_now_button_widget.dart';

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
    with TickerProviderStateMixin, WindowListener
    implements SimulatorTestViewContract, ActionAlertListener {
  double w = 0;
  double h = 0;
  SimulatorTestPresenter? _simulatorTestPresenter;

  SimulatorTestProvider? _simulatorTestProvider;
  AuthWidgetProvider? _authWidgetProvider;
  CameraPreviewProvider? _cameraPreviewProvider;
  late WindowManagerProvider _windowManagerProvider;

  Permission? _microPermission;
  CircleLoading? _loading;
  PermissionStatus _microPermissionStatus = PermissionStatus.denied;
  TabController? _tabController;

  StreamSubscription? connection;
  bool isOffline = false;
  bool _isExam = false;
  bool _dialogNotShowing = true;

  @override
  void initState() {
    windowManager.addListener(this);
    _init();
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

      if (isOffline && _simulatorTestProvider!.isDownloadProgressing) {
        _handleConnectionError();
        // Future.delayed(const Duration(seconds: 30)).then((value) {
        //   _simulatorTestProvider!.setVisibleDownloadAgain(true);
        // },);
        return;
      }
      if (_canRedownload()) {
        _dialogNotShowing = true;
        // _simulatorTestProvider!.resetAll();
        // _getTestDetail();
        if (!_simulatorTestProvider!.visibleDownloadAgain) {
          _simulatorTestPresenter!.tryAgainToDownload();
        }
        return;
      }
    });

    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    _loading = CircleLoading();

    _simulatorTestProvider =
        Provider.of<SimulatorTestProvider>(context, listen: false);
    _cameraPreviewProvider =
        Provider.of<CameraPreviewProvider>(context, listen: false);

    _authWidgetProvider =
        Provider.of<AuthWidgetProvider>(context, listen: false);
    _simulatorTestPresenter = SimulatorTestPresenter(this);

    _windowManagerProvider = Provider.of<WindowManagerProvider>(context, listen: false);

    WidgetsBinding.instance
        .addPostFrameCallback((_) => setState(() {
      _simulatorTestProvider!.resetAll();
    }));
    if (widget.homeWorkModel != null) {
      _isExam = widget.homeWorkModel!.activityType == ActivityType.exam.name ||
          widget.homeWorkModel!.activityType == ActivityType.test.name;
    } else {
      _isExam = false;
    }
    _getTestDetail();
  }


  void _init() async {
    await windowManager.setPreventClose(true);
    setState(() {

    });
  }

  @override
  void onWindowClose() {
    super.onWindowClose();
    _closeWindowDialog();
  }

  void _closeWindowDialog() async {
    switch (_simulatorTestProvider!.doingStatus.get) {
      case 0:
        {
          //Doing
          if (kDebugMode) {
            print("DEBUG: Status is doing the test!");
          }
          if (mounted) {
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomAlertDialog(
                  title: Utils.instance()
                      .multiLanguage(StringConstants.dialog_title),
                  description: Utils.instance()
                      .multiLanguage(
                      StringConstants.exit_while_testing_confirm),
                  okButtonTitle: StringConstants.ok_button_title,
                  cancelButtonTitle: Utils.instance()
                      .multiLanguage(StringConstants.cancel_button_title),
                  borderRadius: 8,
                  hasCloseButton: false,
                  okButtonTapped: () async {
                    _createLog(action: LogEvent.actionCloseApp,
                        data: {
                          StringConstants
                              .k_doing_status: _simulatorTestProvider!
                              .doingStatus.name
                        });
                    await windowManager.destroy();
                  },
                  cancelButtonTapped: () {
                    Navigator.of(context).pop();
                  },
                );
              },
            );
          }
          break;
        }
      case 1:
        {
          //Finish
          if (kDebugMode) {
            print("DEBUG: Status is finish doing the test!");
          }

          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomAlertDialog(
                title: Utils.instance()
                    .multiLanguage(StringConstants.dialog_title),
                description: Utils.instance()
                    .multiLanguage(StringConstants.save_before_exit_message),
                okButtonTitle: Utils.instance()
                    .multiLanguage(StringConstants.save_button_title),
                cancelButtonTitle: Utils.instance()
                    .multiLanguage(StringConstants.dont_save_button_title),
                borderRadius: 8,
                hasCloseButton: false,
                okButtonTapped: () async {
                  //Submit
                  _createLog(action: LogEvent.actionCloseApp, data: {StringConstants.k_doing_status: _simulatorTestProvider!.doingStatus.name});
                  _onSubmitTest();
                  await windowManager.destroy();
                },
                cancelButtonTapped: () {
                  Navigator.of(context).pop();
                },
              );
            },
          );

          break;
        }
    }
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
                        color: AppColors.defaultPurpleColor,
                        size: 30,
                      ),
                    ),
                  ),
                  Text(
                      (widget.homeWorkModel != null)
                          ? widget.homeWorkModel!.activityName
                          : "",
                      style: const TextStyle(
                          color: AppColors.defaultPurpleColor,
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
    windowManager.removeListener(this);
    super.dispose();
    // CameraService.instance()
    //     .disposeCurrentCamera(provider: _cameraPreviewProvider!);
    connection!.cancel();
    _simulatorTestPresenter!.closeClientRequest();
    _simulatorTestPresenter!.resetAutoRequestDownloadTimes();
    _windowManagerProvider.setShowExitAppDoingTest(false);
    // if (context.mounted) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _simulatorTestProvider!.resetAll();
    },);
    // }
  }

  void _createLog(
      {required String action, required Map<String, dynamic>? data}) async {
    if (context.mounted) {
      //Add action log
      LogModel actionLog =
      await Utils.instance().prepareToCreateLog(context, action: action);
      if (null != data) {
        if (data.isNotEmpty) {
          actionLog.addData(
              key: StringConstants.k_data, value: jsonEncode(data));
        }
      }
      Utils.instance().addLog(actionLog, LogEvent.none);
    }
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
              title:
              Utils.instance().multiLanguage(StringConstants.dialog_title),
              description: Utils.instance().multiLanguage(
                  StringConstants.save_change_before_exit_message),
              okButtonTitle: StringConstants.ok_button_title,
              cancelButtonTitle: Utils.instance()
                  .multiLanguage(StringConstants.cancel_button_title),
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
          // _authWidgetProvider!.setRefresh(true);
          Navigator.of(context).pop();
        }
      } else {
        _authWidgetProvider!.setRefresh(true);
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
          _simulatorTestProvider!.setVisibleDownloadAgain(false);
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
                title: Utils.instance()
                    .multiLanguage(StringConstants.dialog_title),
                description: Utils.instance()
                    .multiLanguage(StringConstants.exit_while_testing_confirm),
                okButtonTitle: StringConstants.ok_button_title,
                cancelButtonTitle: Utils.instance()
                    .multiLanguage(StringConstants.cancel_button_title),
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
            _authWidgetProvider!.setRefresh(_isExam);
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
                title: Utils.instance()
                    .multiLanguage(StringConstants.dialog_title),
                description: Utils.instance()
                    .multiLanguage(StringConstants.save_before_exit_message),
                okButtonTitle: Utils.instance()
                    .multiLanguage(StringConstants.save_button_title),
                cancelButtonTitle: Utils.instance()
                    .multiLanguage(StringConstants.dont_save_button_title),
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
            _authWidgetProvider!.setRefresh(_isExam);
            Navigator.of(context).pop();
          }

          break;
        }
    }
  }

  Future _onSubmitTest() async {
    Utils.instance().checkInternetConnection().then((isConnected) {
      if (isConnected) {
        _loading!.show(context);

        String activityId = "";
        if (widget.homeWorkModel != null) {
          activityId = widget.homeWorkModel!.activityId.toString();
        }
        if (_simulatorTestProvider!.reanswersList.isNotEmpty) {
          _simulatorTestPresenter!.submitTest(
              context: context,
              testId:
              _simulatorTestProvider!.currentTestDetail.testId.toString(),
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
              testId:
              _simulatorTestProvider!.currentTestDetail.testId.toString(),
              activityId: activityId,
              questions: _simulatorTestProvider!.questionList,
              isExam: _isExam,
              isUpdate: false,
              videoConfirmFile:
              File(pathVideo).existsSync() ? File(pathVideo) : null,
              logAction: _simulatorTestProvider!.logActions);
        }
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
    if (_dialogNotShowing) {
      // Utils.instance().showConnectionErrorDialog(context);
      Utils.instance().addConnectionErrorLog(context);
      if (!_simulatorTestProvider!.startNowAvailable) {
        if (_simulatorTestProvider!.downloadingIndex >= 5 &&
            !_simulatorTestProvider!.isDownloadAgain) {
          _simulatorTestProvider!.setStartNowStatus(true);
        }
      }
      _dialogNotShowing = false;
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
    return Consumer<SimulatorTestProvider>(builder: (context, provider, child) {
      if (kDebugMode) {
        print("DEBUG: SimulatorTest --- build -- buildBody");
      }
      if (provider.isDownloadProgressing) {
        DownloadInfo downloadInfo = DownloadInfo(provider.downloadingIndex,
            provider.downloadingPercent, provider.total);
        return Visibility(
          visible: !provider.visibleDownloadAgain,
          child: Column(
            children: [
              DownloadProgressingWidget(downloadInfo, reDownload: () {
                if (isOffline) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return MessageDialog(context: context, message: Utils.instance().multiLanguage(StringConstants.network_error_message));
                      });
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
                setState(() {});
              }, visible: provider.isDownloadAgainSuccess),
              Visibility(
                visible: provider.startNowAvailable,
                child: StartNowButtonWidget(
                  isDownloadSuccess: provider.isDownloadAgainSuccess,
                  startNowButtonTapped: () {
                    _createLog(action: 'click_start_now_button', data: {});
                    _checkPermission();
                  },
                ),
              ),
            ],
          ),
        );
      }

      if (provider.isGettingTestDetail) {
        return const DefaultLoadingIndicator(
          color: AppColors.defaultPurpleColor,
        );
      } else {
        return ((provider.submitStatus == SubmitStatus.success) &&
            widget.homeWorkModel != null)
            ? Expanded(
            child: Container(
              // margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                margin: const EdgeInsets.fromLTRB(50, 50, 50, 20),
                child: Scaffold(
                  backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                  appBar: PreferredSize(
                      preferredSize: const Size.fromHeight(40),
                      child: Container(
                        margin: EdgeInsets.only(
                            left: 50,
                            right: (w < SizeLayout.MyTestScreenSize)
                                ? 0
                                : 600),
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
                                        color: AppColors.black, width: 2)),
                                indicatorColor: AppColors.black,
                                labelColor: AppColors.black,
                                unselectedLabelColor:
                                AppColors.defaultGrayColor,
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
                          simulatorTestProvider: _simulatorTestProvider!, windowManagerProvider: _windowManagerProvider,
                        ),
                        HighLightHomeWorks(
                            provider: Provider.of<MyTestProvider>(context,
                                listen: false),
                            homeWorkModel: widget.homeWorkModel!),
                        OtherHomeWorks(
                            provider: Provider.of<MyTestProvider>(context,
                                listen: false),
                            homeWorkModel: widget.homeWorkModel!)
                      ]),
                )))
            : Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          child: TestRoomSimulator(
            activitiesModel: widget.homeWorkModel,
            testDetailModel: _simulatorTestProvider!.currentTestDetail,
            simulatorTestPresenter: _simulatorTestPresenter!,
            simulatorTestProvider: _simulatorTestProvider!, windowManagerProvider: _windowManagerProvider,
          ),
        );
      }
    });
  }

  _getTabs() {
    return [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Tab(
            text: Utils.instance()
                .multiLanguage(StringConstants.test_detail_title)),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Tab(
            text: Utils.instance()
                .multiLanguage(StringConstants.highlight_title)),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Tab(
            text: Utils.instance().multiLanguage(StringConstants.others_list)),
      ),
    ];
  }

  Widget _buildDownloadAgain() {
    return Consumer<SimulatorTestProvider>(builder: (context, provider, child) {
      // if (provider.needDownloadAgain) {
      return Visibility(
        visible: provider.visibleDownloadAgain,
        child: Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 50),
            child: DownloadAgainWidget(
              isOffline: isOffline,
              onClickTryAgain: () {
                _createLog(action: 'click_try_again_download', data: {});
                if (_simulatorTestPresenter != null) {
                  if (isOffline) {
                    _simulatorTestProvider!.setVisibleDownloadAgain(true);
                    Utils.instance().showConnectionErrorDialog(context);
                  } else {
                    _simulatorTestPresenter!.tryAgainToDownload();
                    _simulatorTestProvider!.setVisibleDownloadAgain(false);
                  }
                }
              },
            ),
          ),
        ),
      );
      // } else {
      //   return const SizedBox();
      // }
    });
  }

  void _checkPermission() async {
    if (isOffline) {
      _handleConnectionError();
      _startToDoTest();
    } else {
      if (_microPermission == null) {
        await _initializePermission();
      }

      if (mounted) {
        _requestPermission(_microPermission!, context);
      }
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
    // _simulatorTestProvider!.setVisibleButtonReDownload(false);
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

  void _showCheckNetworkDialog() async {
    if (_dialogNotShowing) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: Utils.instance().multiLanguage(StringConstants.dialog_title),
            description: Utils.instance()
                .multiLanguage(StringConstants.network_error_message),
            okButtonTitle:
            Utils.instance().multiLanguage(StringConstants.ok_button_title),
            cancelButtonTitle: Utils.instance()
                .multiLanguage(StringConstants.exit_button_title),
            borderRadius: 8,
            hasCloseButton: false,
            okButtonTapped: () {
              _dialogNotShowing = true;
              Utils.instance().checkInternetConnection().then((isConnected) {
                if (isConnected) {
                  Navigator.of(context).pop();
                  String? activityId;
                  if (widget.homeWorkModel != null) {
                    activityId = widget.homeWorkModel!.activityId.toString();
                  }
                  _simulatorTestPresenter!
                      .reDownloadFiles(context, activityId: activityId);
                } else {
                  _showCheckNetworkDialog();
                }
              });
            },
            cancelButtonTapped: () {
              _dialogNotShowing = true;
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          );
        },
      );
      _dialogNotShowing = false;
    }
  }

  @override
  void onDownloadFailure(AlertInfo info, FilePathModel savePath) {
    _simulatorTestProvider!.deleteSavePathFromList(savePath);
    _simulatorTestProvider!.setListSavePath(savePath);
    // print('aadnas');
    // showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (context) {
    //       return CustomAlertDialog(
    //         title: Utils.instance().multiLanguage(StringConstants.dialog_title),
    //         description: info.description,
    //         okButtonTitle: Utils.instance()
    //             .multiLanguage(StringConstants.try_again_button_title),
    //         cancelButtonTitle: Utils.instance()
    //             .multiLanguage(StringConstants.exit_button_title),
    //         borderRadius: 8,
    //         hasCloseButton: false,
    //         okButtonTapped: () {
    //           _simulatorTestPresenter!.tryAgainToDownload();
    //           Navigator.of(context).pop();
    //         },
    //         cancelButtonTapped: () {
    //           Navigator.of(context).pop();
    //           Navigator.of(context).pop();
    //         },
    //       );
    //     });
  }

  @override
  void onDownloadSuccess(TestDetailModel testDetail, String nameFile,
      double percent, int index, int total, FilePathModel filePath) {
    _simulatorTestProvider!.setTotal(total);
    _simulatorTestProvider!.updateDownloadingIndex(index);
    _simulatorTestProvider!.updateDownloadingPercent(percent);
    _simulatorTestProvider!.setActivityType(testDetail.activityType);
    _simulatorTestProvider!.deleteSavePathFromList(filePath);
    _simulatorTestProvider!.setListSavePath(filePath);

    //Enable Start Testing Button
    if (index >= 5 && !_simulatorTestProvider!.isDownloadAgain) {
      _simulatorTestProvider!.setStartNowStatus(true);
    }

    if (index == total) {
      //Auto start to do test
      if (_simulatorTestProvider!.isDownloadAgain) {
        _simulatorTestProvider!.setDownloadAgainSuccess(true);
        _simulatorTestProvider!.setStartNowStatus(true);
      }
      // if (_simulatorTestProvider!.startNowAvailable == false) {
      //   _simulatorTestProvider!.setStartNowStatus(true);
      // }
      else {
        _checkPermission();
      }
    }
  }

  @override
  void onGetTestDetailComplete(TestDetailModel testDetailModel, int total) {
    _simulatorTestProvider!.setPackageID(widget.homeWorkModel!.activityPackageId);
    _simulatorTestProvider!.setCurrentTestDetail(testDetailModel);
    _simulatorTestProvider!.setDownloadProgressingStatus(true);
    _simulatorTestProvider!.setTotal(total);
  }

  @override
  void onGetTestDetailError(String message) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return CustomAlertDialog(
            title: Utils.instance().multiLanguage(StringConstants.dialog_title),
            description: message,
            okButtonTitle: Utils.instance()
                .multiLanguage(StringConstants.try_again_button_title),
            cancelButtonTitle: Utils.instance()
                .multiLanguage(StringConstants.exit_button_title),
            borderRadius: 8,
            hasCloseButton: false,
            okButtonTapped: () {
              _simulatorTestProvider!.resetAll();
              _getTestDetail();
              Navigator.of(context).pop();
            },
            cancelButtonTapped: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          );
        });
  }

  @override
  void onGotoMyTestScreen(ActivityAnswer activityAnswer) {
    if (kDebugMode) {
      print("DEBUG: onGotoMyTestScreen");
    }

    //Update activityAnswer into current homeWorkModel
    if (widget.homeWorkModel != null) {
      widget.homeWorkModel!.activityAnswer = activityAnswer;
      Navigations.instance().goToMyTest(context, widget.homeWorkModel!);
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
    if (isOffline) {
      _showCheckNetworkDialog();
    } else {
      if (_simulatorTestProvider!.doingStatus == DoingStatus.doing) {
        _simulatorTestProvider!.setNeedDownloadAgain(false);
      } else {
        _simulatorTestProvider!.setNeedDownloadAgain(true);
      }
      _simulatorTestProvider!.setStartNowStatus(false);
      _simulatorTestProvider!.setDownloadAgain(true);
      _simulatorTestProvider!.setDownloadProgressingStatus(true);
      _simulatorTestProvider!.setGettingTestDetailStatus(false);
    }
  }

  @override
  void onSaveTopicListIntoProvider(List<TopicModel> list) {
    _simulatorTestProvider!.setTopicsList(list);
    Queue<TopicModel> queue = Queue<TopicModel>();
    queue.addAll(list);
    _simulatorTestProvider!.setTopicsQueue(queue);
  }

  @override
  void onSubmitTestFail(String msg, int errorCode) {
    print('errorCode: $errorCode');
    Utils.instance().sendLog(errorCode: errorCode);
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
  void onSubmitTestSuccess(String msg, ActivityAnswer activityAnswer, int errorCode) {
    print('errorCode: $errorCode');
    Utils.instance().sendLog(errorCode: errorCode);
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
    _simulatorTestProvider!.setIsTestRoom(false);
    if (isOffline) {
      _showCheckNetworkDialog();
      _simulatorTestProvider!.setVisibleDownloadAgain(true);
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
    if (_simulatorTestProvider!.doingStatus == DoingStatus.doing) {
      _simulatorTestProvider!.setNeedDownloadAgain(false);
    } else {
      _simulatorTestProvider!.setNeedDownloadAgain(true);
    }
    _simulatorTestProvider!.setStartNowStatus(false);
    _simulatorTestProvider!.setDownloadAgain(true);
    _simulatorTestProvider!.setDownloadProgressingStatus(true);
    _simulatorTestProvider!.setGettingTestDetailStatus(false);

  }

  void updateStatusForReDownload() {
    _simulatorTestProvider!.setNeedDownloadAgain(false);
    _simulatorTestProvider!.setDownloadAgain(true);
    _simulatorTestProvider!.setStartNowStatus(false);
    _simulatorTestProvider!.setDownloadProgressingStatus(true);
  }

  bool _canRedownload() {
    return !isOffline &&
        _simulatorTestProvider!.downloadingIndex <
            _simulatorTestProvider!.total &&
        _simulatorTestProvider!.isDownloadProgressing;
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
  void onDownloadFailureErrorTimeOut(FilePathModel savePath) {
    _simulatorTestProvider!.deleteSavePathFromList(savePath);
    _simulatorTestProvider!.setListSavePath(savePath);
    if (!_simulatorTestProvider!.isTestRoom) {
      _simulatorTestProvider!.setVisibleDownloadAgain(true);
    }
  }

  @override
  void onGetTestDetailCompleteForTool(String testID) {
    String activityId = "";
    if (widget.homeWorkModel != null) {
      activityId = widget.homeWorkModel!.activityId.toString();
    }
    _simulatorTestProvider!.setSuccessCreateTest();

    _simulatorTestProvider!.setCallSubmitTest();
    print(testID);
    _simulatorTestPresenter!.submitTestForTool(context: context,
        testId: testID,
        activityId: activityId,
        questions: _simulatorTestProvider!.questionList,
        isExam: _isExam,
        isUpdate: true,
        logAction: _simulatorTestProvider!.logActions);
  }

  @override
  void onGetTestDetailErrorForTool() {
    _simulatorTestProvider!.setFailCreateTest();
  }

  @override
  void onSubmitTestFailForTool() {
    _simulatorTestProvider!.setFailSubmitTest();
  }

  @override
  void onSubmitTestSuccessForTool() {
    _simulatorTestProvider!.setSuccessSubmitTest();
  }
}
