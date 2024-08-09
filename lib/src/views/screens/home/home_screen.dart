import 'dart:async';
import 'dart:io';

import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect_pc/src/models/user_data_models/user_data_model.dart';
import 'package:icorrect_pc/src/providers/auth_widget_provider.dart';
import 'package:icorrect_pc/src/providers/home_provider.dart';
import 'package:icorrect_pc/src/providers/main_widget_provider.dart';
import 'package:icorrect_pc/src/views/dialogs/test_video_dialog.dart';
import 'package:icorrect_pc/src/views/dialogs/test_record_dialog.dart';
import 'package:icorrect_pc/src/views/widgets/grid_view_widget.dart';

import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/app_colors.dart';
import '../../../data_source/local/file_storage_helper.dart';
import '../../../models/homework_models/new_api_135/new_class_model.dart';
import '../../../models/log_models/log_model.dart';
import '../../../presenters/home_presenter.dart';
import '../../../providers/camera_preview_provider.dart';
import '../../../utils/Navigations.dart';
import '../../../utils/utils.dart';
import '../../dialogs/circle_loading.dart';
import '../../dialogs/custom_alert_dialog.dart';
import '../../dialogs/message_alert.dart';
import '../../widgets/nothing_widget.dart';
import 'package:record/record.dart';

class HomeWorksWidget extends StatefulWidget {
  const HomeWorksWidget({super.key});

  @override
  State<HomeWorksWidget> createState() => _HomeWorksWidgetState();
}

class _HomeWorksWidgetState extends State<HomeWorksWidget> implements HomeWorkViewContract {
  double w = 0, h = 0;
  late HomeProvider _provider;
  String _choosenStatus = '';
  bool _dialogNotShowing = true;

  CircleLoading? _loading;
  late HomeWorkPresenter _presenter;
  CameraPreviewProvider? _cameraPreviewProvider;
  MainWidgetProvider? _mainWidgetProvider;
  Timer? _countDownTime;
  Record? _recordController;
  AudioPlayer? _audioPlayer;
  ActivitiesModel? _activitiesModel;
  VideoPlayerController? _videoPlayerController;

  late Duration maxDuration;
  late Duration elapsedDuration;
  late List<double> samples = [];
  FToast? fToast;

  @override
  void initState() {
    super.initState();
    _recordController = Record();
    _audioPlayer = AudioPlayer();
    _provider = Provider.of<HomeProvider>(context, listen: false);
    _cameraPreviewProvider =
        Provider.of<CameraPreviewProvider>(context, listen: false);
    _mainWidgetProvider = Provider.of<MainWidgetProvider>(context, listen: false);
    _choosenStatus = _provider.statusSelections.first;
    _loading = CircleLoading();

    _loading?.show(context);
    _presenter = HomeWorkPresenter(this);
    _presenter.getListHomeWork(context);

    Future.delayed(Duration.zero, () {
      _provider.clearData();
    });

    Utils.instance().sendLog();
    fToast = FToast();
    fToast!.init(context);
  }

  @override
  void dispose() {
    dispose();
    super.dispose();
    _provider.dispose();
    _loading!.hide();
  }
  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Consumer<AuthWidgetProvider>(builder: (context, provider, child) {
      if (provider.isRefresh) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loading?.show(context);
          _provider.setStatusActivity(
              Utils.instance().multiLanguage(StringConstants.all));
          _presenter.getListHomeWork(context);
          provider.setRefresh(false);
        });
      }
      return (w < SizeLayout.HomeScreenTabletSize)
          ? _buildTabletLayout()
          : _buildDesktopLayout();
    });
  }

  Widget _buildDesktopLayout() {
    return Container(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 170),
                child: Row(
                  // children: [_builClassFilter(), _buildStatusFilter()],
                  children: [_buildStatusFilter()],
                )),
            _buildHomeworkList()
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Container(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                height: 80,
                margin: const EdgeInsets.symmetric(horizontal: 170, vertical: 10),
                child: Column(
                  // children: [_builClassFilter(), _buildStatusFilter()],
                  children: [_buildStatusFilter()],
                )),
            _buildHomeworkList()
          ],
        ),
      ),
    );
  }

  Widget _builClassFilter() {
    return Expanded(
        child: Consumer<HomeProvider>(builder: (context, provider, child) {
          return Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Utils.instance().multiLanguage(StringConstants.class_filter),
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<NewClassModel>(
                    value: provider.classSelected,
                    items: provider.classesList.map((NewClassModel value) {
                      return DropdownMenuItem<NewClassModel>(
                        value: value,
                        child: Text(
                          value.name,
                          style: const TextStyle(fontSize: 15),
                        ),
                      );
                    }).toList(),
                    onChanged: (NewClassModel? newValue) {
                      if (kDebugMode) {
                        print("DEBUG: ${newValue!.name}");
                      }
                      provider.setClassSelection(newValue!);
                      List<ActivitiesModel> activities =
                      _presenter.filterActivities(
                          newValue.id,
                          newValue.activities,
                          provider.statusActivity,
                          provider.currentTime);
                      if (kDebugMode) {
                        print("DEBUG: activities: ${activities.length}");
                      }
                      provider.setActivitiesFilter(activities);
                    },
                    decoration: InputDecoration(
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      filled: true,
                      fillColor: AppColors.defaultGraySlightColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppColors.defaultPurpleColor, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppColors.defaultPurpleColor, width: 1),
                      ),
                    ),
                  ),
                ],
              ));
        }));
  }

  Widget _buildStatusFilter() {
    return Expanded(
        child: Consumer<HomeProvider>(builder: (context, provider, child) {
          return Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      Utils.instance().multiLanguage(StringConstants.status_filter),
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: provider.statusActivity,
                    items: provider.statusSelections.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(fontSize: 15),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      provider.setStatusActivity(newValue!);
                      List<ActivitiesModel> activities =
                      _presenter.filterActivities(
                          provider.classSelected.id,
                          provider.activitiesList,
                          newValue,
                          provider.currentTime);
                      provider.setActivitiesFilter(activities);
                    },
                    decoration: InputDecoration(
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      filled: true,
                      fillColor: Colors.grey[200],
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppColors.defaultPurpleColor, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppColors.defaultPurpleColor, width: 1),
                      ),
                    ),
                  ),
                ],
              ));
        }));
  }

  Widget _buildHomeworkList() {
    double height = 450;
    double w = MediaQuery.of(context).size.width;
    return Container(
        width: w,
        margin: const EdgeInsets.only(top: 20, left: 100, right: 100),
        child: Consumer<HomeProvider>(builder: (context, provider, child) {
          return DottedBorder(
              borderType: BorderType.RRect,
              radius: const Radius.circular(25),
              dashPattern: const [6, 3, 6, 3],
              strokeWidth: 2,
              color: AppColors.defaultPurpleColor,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.purpleSlight2,
                      Color.fromARGB(0, 255, 255, 255),
                      Color.fromARGB(0, 255, 255, 255)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    InkWell(
                        onTap: () {
                          _loading?.show(context);
                          _provider.setStatusActivity(Utils.instance()
                              .multiLanguage(StringConstants.all));
                          _presenter.getListHomeWork(context);
                        },
                        child: SizedBox(
                          width: 120,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(Icons.refresh_rounded),
                                const SizedBox(width: 5),
                                Text(
                                    Utils.instance().multiLanguage(
                                        StringConstants.refresh_data),
                                    style: const TextStyle(
                                      color: AppColors.purple,
                                      fontSize: 16,
                                    )),
                              ]),
                        )),
                    if (w < SizeLayout.HomeScreenTabletSize)
                      _buildTabletList()
                    else
                      _buildDesktopList()
                  ],
                ),
              ));
        }));
  }

  Widget _buildDesktopList() {
    double height = 450;
    return Consumer<HomeProvider>(builder: (context, provider, child) {
      return SingleChildScrollView(
          child: Container(
            height: height,
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            padding: const EdgeInsets.only(bottom: 20),
            child: (provider.activitiesFilter.isNotEmpty)
                ? MyGridView(
                data: provider.activitiesFilter,
                itemWidget: (itemModel, index) {
                  return _questionItem(itemModel);
                })
                : NothingWidget.init().buildNothingWidget(
                Utils.instance()
                    .multiLanguage(StringConstants.nothing_your_homework),
                widthSize: 180,
                heightSize: 180),
          ));
    });
  }

  Widget _buildTabletList() {
    double height = 450;
    return Consumer<HomeProvider>(builder: (context, provider, child) {
      return SingleChildScrollView(
          child: Container(
            height: height,
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            padding: const EdgeInsets.only(bottom: 20),
            child: (provider.activitiesFilter.isNotEmpty)
                ? ListView.builder(
                shrinkWrap: true,
                itemCount: provider.activitiesFilter.length,
                itemBuilder: (context, index) {
                  return _questionItem(
                      provider.activitiesFilter.elementAt(index));
                })
                : NothingWidget.init().buildNothingWidget(
                Utils.instance()
                    .multiLanguage(StringConstants.nothing_your_homework),
                widthSize: 180,
                heightSize: 180),
          ));
    });
  }

  Widget _questionItem(ActivitiesModel homeWork) {
    Map<String, dynamic> statusMap =
        Utils.instance().getHomeWorkStatus(homeWork, _provider.currentTime) ??
            {};

    int activityStatus = Utils.instance().getFilterStatus(statusMap['title']);
    return Wrap(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(width: 1, color: AppColors.purple),
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: Row(
            // alignment: Alignment.centerRight,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.only(right: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(width: 2, color: AppColors.purple),
                        borderRadius:
                        const BorderRadius.all(Radius.circular(100))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            Utils.instance()
                                .multiLanguage(StringConstants.part),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppColors.purple,
                                fontWeight: FontWeight.w400,
                                fontSize: 8)),
                        Text(
                            Utils.instance().getPartOfTestWithString(
                                homeWork.activityTestOption),
                            style: const TextStyle(
                                color: AppColors.purple,
                                fontWeight: FontWeight.bold,
                                fontSize: 14))
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: _getSizeTextResponse(),
                          height: 50,
                          child: Row(
                            children: [
                              (homeWork.isExam())
                                  ? Text(
                                  Utils.instance().multiLanguage(
                                      StringConstants.test_status),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 17,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold))
                                  : Container(),
                              SizedBox(
                                width: _getSizeTextResponse(),
                                child: Text(homeWork.activityName.toString(),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    softWrap: true,
                                    style: const TextStyle(
                                        fontSize: 17, color: Colors.black)),
                              )
                            ],
                          )),
                      SizedBox(
                        width: w / 4,
                        child: Row(
                          children: [
                            Text(
                                '${Utils.instance().multiLanguage(StringConstants.time_end_title)}: ',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                            Text(
                                (homeWork.activityEndTime.isNotEmpty)
                                    ? homeWork.activityEndTime.toString()
                                    : '0000-00-00 00:00',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black)),
                            const Text(' | ',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black)),
                            SizedBox(
                              width: (w / 4) - 200,
                              child: Text(_statusOfActivity(homeWork),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: _getColor(homeWork),
                                  )),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
              (activityStatus == Status.notComplete.get ||
                  activityStatus == Status.outOfDate.get ||
                  homeWork.activityStatus == Status.loadedTest.get)
                  ? SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () async {
                    _onClickStartTest(homeWork);
                  },
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                          AppColors.purple),
                      shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                        Utils.instance()
                            .multiLanguage(StringConstants.start_title),
                        style: const TextStyle(color: Colors.white)),
                  ),
                ),
              )
                  : SizedBox(
                width: 100,
                child: ElevatedButton(
                    onPressed: () async {
                      _onClickMyTest(homeWork);
                    },
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            Colors.green),
                        shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                          Utils.instance().multiLanguage(
                              StringConstants.detail_title),
                          style: const TextStyle(color: Colors.white)),
                    )),
              )
            ],
          ),
        )
      ],
    );
  }

  double _getSizeTextResponse() {
    if (w < SizeLayout.HomeScreenTabletSize) {
      return w / 3;
    } else {
      return w / 4 - 80;
    }
  }

  String _statusOfActivity(ActivitiesModel activitiesModel) {
    String status = Utils.instance()
        .getHomeWorkStatus(activitiesModel, _provider.currentTime)['title'];
    String aiStatus = Utils.instance().haveAiResponse(activitiesModel);
    if (aiStatus.isNotEmpty) {
      return "${status == Utils.instance().multiLanguage(StringConstants.corrected) ? '$status &' : ''}$aiStatus";
    } else {
      return status;
    }
  }

  Color _getColor(ActivitiesModel activitiesModel) {
    String aiStatus = Utils.instance().haveAiResponse(activitiesModel);
    if (aiStatus.isNotEmpty) {
      return const Color.fromARGB(255, 12, 201, 110);
    } else {
      return Utils.instance()
          .getHomeWorkStatus(activitiesModel, _provider.currentTime)['color'];
    }
  }

  void _prepareForRecord() {
    _provider.setCurrentCount(0);
    String timeFormat = Utils.instance().formattedTime(timeInSecond: 0);
    _provider.setOkTitle('Dừng lại');
    _provider.setStrCountDown(timeFormat);
    _provider.setIsRecord(false);
    _provider.setStartDoingTest(false);
    _provider.setDescriptionRecordDialog('Bạn đang ghi âm vui lòng nói gì đó để kiểm tra thiết bị!');
    samples = [];
  }

  Future<void> _onClickStartTest(ActivitiesModel homeWork) async {
    if (homeWork.activityStatus == Status.loadedTest.get) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: Utils.instance().multiLanguage(StringConstants.dialog_title),
            description: Utils.instance()
                .multiLanguage(StringConstants.loaded_test_warning_message),
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
      return;
    }
    if (homeWork.isExam()) {
      // CameraService.instance()
      //     .initializeCamera(provider: _cameraPreviewProvider!);
    }

    Utils.instance().checkInternetConnection().then((isConnected) async {
      if (isConnected) {
        //show dialog checking audio, record
        _activitiesModel = homeWork;
        // _showDialogStartChecking();
        if (_mainWidgetProvider!.isShowTestDevice) {
          _startChecking();
        } else {
          //start now
          Navigations.instance()
              .goToSimulatorTestRoom(context, activitiesModel: homeWork);
          //Add action log
          LogModel actionLog = await Utils.instance().prepareToCreateLog(context,
              action: LogEvent.actionClickOnHomeworkItem);
          actionLog.addData(
              key: StringConstants.k_activity_id,
              value: homeWork.activityId.toString());
          Utils.instance().addLog(actionLog, LogEvent.none);
        }
      } else {
        _handleConnectionError();
      }
    });
  }

  Future<void> _onClickMyTest(ActivitiesModel homeWork) async {
    Utils.instance().checkInternetConnection().then((isConnected) async {
      if (isConnected) {
        Navigations.instance().goToMyTest(context, homeWork);
        //Add action log
        LogModel actionLog = await Utils.instance().prepareToCreateLog(context,
            action: LogEvent.actionClickOnHomeworkItem);
        actionLog.addData(
            key: StringConstants.k_activity_id,
            value: homeWork.activityId.toString());
        Utils.instance().addLog(actionLog, LogEvent.none);
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
    Utils.instance().showConnectionErrorDialog(context);

    Utils.instance().addConnectionErrorLog(context);
  }

  void _showDialogTestRecord() {
    if (_videoPlayerController != null && _videoPlayerController!.value.isPlaying) {
      _videoPlayerController!.pause();
      _provider.resetVideoPlayerController();
    }
    _provider.setCurrentCount(0);
    String timeFormat = Utils.instance().formattedTime(timeInSecond: 0);
    _provider.setStrCountDown(timeFormat);
    _provider.setOkTitle((Utils.instance().multiLanguage(StringConstants.start_title)));
    _provider.setCanDoNextStep(false);
    _provider.setIsRecord(false);
    _provider.setStartDoingTest(false);
    _provider.setStatusButton(ButtonTestDevice.isRecord);
    _provider.setDescriptionRecordDialog(
        'Bắt đầu ghi âm và kiểm tra mic có hoạt động hay không, nếu có vấn đề vui lòng báo lại giám khảo');
    _provider.setRightButtonTitle('Bước tiếp');
    _provider.setStatusButtonRight(ButtonTestDevice.nothing);
    _provider.setMsgToast('Hãy bắt đầu để có thể kiểm tra âm thanh');
    Navigator.of(context).pop();
    showDialog(
      barrierDismissible: false,
      context: context, builder: (context) {
      // return Consumer<HomeProvider>(builder: (context, provider, child) {
        return TestRecordDialog(
          borderRadius: 12,
          hasCloseButton: true,
          cancelButtonTitle: 'Huỷ bỏ',
          okButtonTapped: okButtonTap,
          cancelButtonTapped: rightButtonTap,
          closeButtonTapped: _closeButtonTap,
          samples: samples,
        );
      // });
    },);
  }

  void _showDialogTestVideo() {
    _provider.setRightButtonTitle('Bước tiếp');
    _provider.setStatusButtonRight(ButtonTestDevice.nothing);
    _provider.setMsgToast('Hãy bấm bắt đầu để nghe hết đoạn video để kiểm tra thiết bị và bấm bươc tiếp');
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
     return Consumer<HomeProvider>(builder: (context, provider, child) {
       return TestVideoDialog(
              borderRadius: 12,
              hasCloseButton: true,
              okButtonTapped: _startCheckingVideo,
              closeButtonTapped: _closeButtonTap,
              cancelButtonTapped: rightButtonTestVideo,
            );
          });
        });
  }

  void _showDialogTestAudio() async {
    _provider.setCanDoNextStep(false);
    String path = await FileStorageHelper.newGetFilePath(
        'test_record.wav', MediaType.audio);
    Uint8List list = await File(path).readAsBytes();
    samples = list.map((e) => e.toDouble()).toList();
    samples = loadParseJson('jsonBody');
    _provider.setListSamples(samples);
    _provider.setMaxDuration(const Duration(milliseconds: 1000));
    _provider.setElapsedDuration(const Duration(milliseconds: 0));
    print('samples: ${samples.length}');
    // _startPlayAudio();
  }

  Future<void> _readAssetToFile() async {
    final ByteData data = await rootBundle.load('assets/videos/745.mp4');

    final path = await FileStorageHelper.getFolderPath(MediaType.video, null);
    final filePath = '$path/745.mp4';
    final File file = File(filePath);
    if (!await file.exists()) {
      await file.writeAsBytes(data.buffer.asUint8List());
    }
  }

  void _startChecking() async {
    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: 'initVideoTest');
    }

    if (_videoPlayerController != null) {
      _videoPlayerController!.dispose();
    }
    _provider.setCanDoNextStep(false);
    await _readAssetToFile();
    String path = await FileStorageHelper.newGetFilePath('745.mp4', MediaType.video);
    _videoPlayerController = VideoPlayerController.file(File(path));
    await _videoPlayerController!.initialize().then((value) {
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: 'init video success',
        status: LogEvent.success,
      );
    }).catchError((e) {
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: e.toString(),
        status: LogEvent.failed,
      );
    });
    _provider.setOkTitle((Utils.instance().multiLanguage(StringConstants.start_title)));
    _provider.setStatusButton(ButtonTestDevice.isPlayVideo);
    _showDialogTestVideo();
  }

  void _startCheckingVideo() async {
    if (_provider.statusButton == ButtonTestDevice.isPlayVideo) {
      playVideo();
      _provider.setMsgToast('Hãy nghe hết đoạn video và kiểm tra lại');
    } else if (_provider.statusButton == ButtonTestDevice.isNextStep) {
      if (_provider.canDoNextStep) {
        _showDialogTestRecord();
      }
    }
  }

  void rightButtonTestVideo() {
    if (_provider.statusButtonRight == ButtonTestDevice.nothing) {
      _showToast();
    } else if (_provider.statusButtonRight == ButtonTestDevice.isRePlayVideo) {
      playVideo();
    }
  }

  void playVideo() async {
    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: 'playVideo');
    }
    if (_videoPlayerController != null) {
      _videoPlayerController!.pause();
    }

    try {
      _videoPlayerController!.value.isPlaying
          ? _videoPlayerController!.pause()
          : _videoPlayerController!.play();
      setState(() {});
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: 'play video success',
        status: LogEvent.success,
      );

      _provider.setVideoPlayerController(_videoPlayerController!);

      _videoPlayerController!.addListener(() {
        if (_videoPlayerController!.value.position.inSeconds > 1) {
          _provider.setCanDoNextStep(true);
        }

        if (_videoPlayerController!.value.isCompleted) {
          _provider.setCanDoNextStep(true);
          _provider.setStatusButtonRight(ButtonTestDevice.isRePlayVideo);
        }
      });
      _provider.setOkTitle('Bước tiếp');
      _provider.setStatusButton(ButtonTestDevice.isNextStep);
      _provider.setRightButtonTitle('Nghe lại');
    } catch (e){
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: e.toString(),
        status: LogEvent.failed,
      );
    }
  }

  Future<void> _startDoingTest() async {
    if (_provider.isStartDoingTest) {
      _closeButtonTap();
      _mainWidgetProvider!.setIsShowTestDevice(false);
      Navigator.of(context).pop();
      Navigations.instance()
          .goToSimulatorTestRoom(context, activitiesModel: _activitiesModel!);
      //Add action log
      LogModel actionLog = await Utils.instance().prepareToCreateLog(context,
          action: LogEvent.actionClickOnHomeworkItem);
      actionLog.addData(
          key: StringConstants.k_activity_id,
          value: _activitiesModel!.activityId.toString());
      Utils.instance().addLog(actionLog, LogEvent.none);
    }
  }

  Future<void> okButtonTap() async {
    if (_provider.statusButton == ButtonTestDevice.isRecord) {
      _prepareForRecord();
      _startTestRecord();
      _provider.setStatusButton(ButtonTestDevice.isStopRecord);
      // _provider.setStatusButtonRight(ButtonTestDevice.isReRecord);
      _provider.setRightButtonTitle('Bước tiếp');
      _provider.setMsgToast('Bạn đang ghi âm, hãy bấm dừng lại và kiểm tra âm thanh');
    } else if (_provider.statusButton == ButtonTestDevice.isPlayAudio) {
      _provider.setDescriptionRecordDialog('Bạn đang nghe lại đoạn ghi âm để kiểm tra \n Nếu có lỗi hãy báo ngay cho giám khảo \n nếu không hãy bấm bước tiếp để bắt đầu bài kiểm tra');
      _startPlayAudio();
      _provider.setCanDoNextStep(false);
      _provider.setOkTitle('Bước tiếp');
      _provider.setStatusButton(ButtonTestDevice.isNextStep);
    }
    else if (_provider.statusButton == ButtonTestDevice.isStopRecord) {
      if (_provider.canDoNextStep) {
        await _stopRecord();
        _provider.setOkTitle('Nghe lại');
        _provider.setIsRecord(false);
        _provider.setDescriptionRecordDialog('Bạn đã ghi âm xong vui lòng nghe lại để kiểm tra MIC');
        _provider.setStatusButton(ButtonTestDevice.isPlayAudio);
        _provider.setStatusButtonRight(ButtonTestDevice.isReRecord);
        _provider.setRightButtonTitle('Ghi âm lại');
        _showDialogTestAudio();
      }
    } else if (_provider.statusButton == ButtonTestDevice.isNextStep) {
      _startDoingTest();
    }
  }

  Future<void> rightButtonTap() async {
    if (_provider.statusButtonRight == ButtonTestDevice.isRecord) {
      _prepareForRecord();
      _startTestRecord();
      _provider.setStatusButton(ButtonTestDevice.isStopRecord);
      _provider.setStatusButtonRight(ButtonTestDevice.isReRecord);
    } else if (_provider.statusButtonRight == ButtonTestDevice.isNextStep) {
      _startDoingTest();
    } else if (_provider.statusButtonRight == ButtonTestDevice.isReRecord) {
      if (_provider.canDoNextStep) {
        await _stopRecord();
        _prepareForRecord();
        _startTestRecord();
        _provider.setStatusButton(ButtonTestDevice.isStopRecord);
        _provider.setStatusButtonRight(ButtonTestDevice.isReRecord);
      }
    } else if (_provider.statusButtonRight == ButtonTestDevice.isStopRecord) {
      if (_provider.canDoNextStep) {
        await _stopRecord();
        _provider.setOkTitle('Nghe lại');
        _provider.setIsRecord(false);
        _provider.setStatusButton(ButtonTestDevice.isPlayAudio);
        _provider.setDescriptionRecordDialog('Nghe lại đoạn ghi âm để kiểm tra \n Nếu có lỗi hãy báo ngay cho giám khảo');
      }
    } else if (_provider.statusButtonRight == ButtonTestDevice.nothing) {
      _showToast();
    }
  }

  Future<void> _startTestRecord() async {
    if (_countDownTime != null) {
      _countDownTime!.cancel();
    }
    String fileName = await FileStorageHelper.getFilePath(
        'test_record.wav', MediaType.audio, null);
    await _recordController!.start(
      path: fileName,
      encoder: Platform.isWindows ? AudioEncoder.wav : AudioEncoder.pcm16bit,
      bitRate: 128000,
      numChannels: 1,
      samplingRate: 44100,
    );
    _countDownTime = _presenter.startCountDown(context: context, count: _provider.currentCount);
    _provider.setIsRecord(true);
  }

  Future<void> _stopRecord() async {
    await _recordController!.stop();
    if (null != _countDownTime) {
      _countDownTime!.cancel();
    }

    if (_audioPlayer != null) {
      _audioPlayer!.stop();
      _audioPlayer!.dispose();
      _audioPlayer = null;
    }

    if (_recordController != null && await _recordController!.isRecording()) {
      _recordController!.stop();
      _recordController!.dispose();
    }

    _provider.setCurrentCount(0);
    String timeFormat = Utils.instance().formattedTime(timeInSecond: 0);
    _provider.setStrCountDown(timeFormat);
    _provider.setOkTitle((Utils.instance().multiLanguage(StringConstants.start_title)));
  }
  
  Future<void> _startPlayAudio() async {
    if (_audioPlayer != null) {
      _audioPlayer!.dispose();
      _audioPlayer = null;
    }

    if (_countDownTime != null) {
      _countDownTime!.cancel();
      _countDownTime = null;
    }

    _provider.setCurrentCount(0);
    String timeFormat = Utils.instance().formattedTime(timeInSecond: 0);
    _provider.setStrCountDown(timeFormat);
    _countDownTime = _presenter.startCountDown(context: context, count: 0);

    _audioPlayer = AudioPlayer();
    String fileName = await FileStorageHelper.getFilePath(
        'test_record.wav', MediaType.audio, null);
    await _audioPlayer!.play(DeviceFileSource(fileName),
    mode: PlayerMode.mediaPlayer);
    Duration? maxDurationInMilliseconds =
    await _audioPlayer!.getDuration();
    maxDuration = Duration(milliseconds: maxDurationInMilliseconds!.inMilliseconds);
    _provider.setMaxDuration(maxDuration);

    _audioPlayer!.onPositionChanged.listen((Duration timeElapsed) {
      _provider.setElapsedDuration(timeElapsed);
      if (timeElapsed.inSeconds >= 1) {
        // _provider.setOkTitle(Utils.instance().multiLanguage(StringConstants.start_title));
        _provider.setStartDoingTest(true);
        _provider.setCanDoNextStep(true);
      }
    });

    _audioPlayer!.onPlayerComplete.listen((event) {
      _provider.setElapsedDuration(maxDuration);
      _countDownTime!.cancel();
      _provider.setStatusButton(ButtonTestDevice.isNextStep);
      _provider.setStartDoingTest(true);
    });
  }

  void _closeButtonTap() {
    if (_audioPlayer != null) {
      _audioPlayer!.pause();
      _audioPlayer!.dispose();
      _audioPlayer = null;
    }

    if (_countDownTime != null) {
      _countDownTime!.cancel();
      _countDownTime = null;
    }

    if (_recordController != null) {
      _recordController!.dispose();
    }

    if (_videoPlayerController != null && _videoPlayerController!.value.isPlaying) {
      _videoPlayerController!.pause();
      _provider.resetVideoPlayerController();
    }
  }

  List<double> loadParseJson(String jsonBody) {
    final List<double> points = samples;
    List<int> filteredData = [];
    // Change this value to number of audio samples you want.
    // Values between 256 and 1024 are good for showing [RectangleWaveform] and [SquigglyWaveform]
    // While the values above them are good for showing [PolygonWaveform]
    const int sample = 64;
    final double blockSize = points.length / sample;

    for (int i = 0; i < sample; i++) {
      final double blockStart =
          blockSize * i; // the location of the first sample in the block
      int sum = 0;
      for (int j = 0; j < blockSize; j++) {
        sum = sum +
            points[(blockStart + j).toInt()]
                .toInt(); // find the sum of all the samples in the block

      }
      filteredData.add((sum / blockSize)
          .round() // take the average of the block and add it to the filtered data
          .toInt()); // divide the sum by the block size to get the average
    }
    final maxNum = filteredData.reduce((a, b) => math.max(a.abs(), b.abs()));

    final double multiplier = math.pow(maxNum, -1).toDouble();

    return filteredData.map<double>((e) => (e * multiplier)).toList();
  }

  _showToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.defaultPurpleColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_provider.msgToast, style: const TextStyle(
           color: AppColors.defaultAppColor,
           fontWeight: FontWeight.w500,
           fontSize: 16
          )),
        ],
      ),
    );


    fToast!.showToast(
      child: toast,
      gravity: ToastGravity.CENTER,
      toastDuration: const Duration(seconds: 2),
    );
  }

  @override
  void onGetListHomeworkComplete(List<ActivitiesModel> homeworks,
      List<NewClassModel> classes, String currrentTime) {
    _provider.setCurrentTime(currrentTime);
    _provider.setActivitiesList(homeworks);
    _provider.setActivitiesFilter(homeworks);

    NewClassModel classModel = NewClassModel();
    classModel.id = 0;
    classModel.name = Utils.instance().multiLanguage(StringConstants.all);
    classModel.activities = homeworks;
    classes.add(classModel);
    _provider.setClassesList(classes);
    _provider.setClassSelection(classModel);
    _loading?.hide();
  }

  @override
  void onGetListHomeworkError(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(context: context, message: message);
        });
    _loading?.hide();
  }

  @override
  void onLogoutComplete() {
    _loading?.hide();
  }

  @override
  void onLogoutError(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(context: context, message: message);
        });
    _loading?.hide();
  }

  @override
  void onUpdateCurrentUserInfo(UserDataModel userDataModel) {
    _provider.setCurrentUser(userDataModel);
  }

  @override
  void onCountDown(String strCount, int count) {
    print(_provider.currentCount);
    _provider.setCurrentCount(count);
    _provider.setStrCountDown(strCount);
    if (count > 1) {
      _provider.setCanDoNextStep(true);
    }
  }
}
