import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect_pc/src/models/user_data_models/user_data_model.dart';
import 'package:icorrect_pc/src/providers/auth_widget_provider.dart';
import 'package:icorrect_pc/src/providers/home_provider.dart';
import 'package:icorrect_pc/src/providers/main_widget_provider.dart';
import 'package:icorrect_pc/src/views/widgets/grid_view_widget.dart';

import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../../../core/app_colors.dart';
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

class HomeWorksWidget extends StatefulWidget {
  const HomeWorksWidget({super.key});

  @override
  State<HomeWorksWidget> createState() => _HomeWorksWidgetState();
}

class _HomeWorksWidgetState extends State<HomeWorksWidget> with WindowListener
    implements HomeWorkViewContract {
  double w = 0, h = 0;
  late HomeProvider _provider;
  String _choosenStatus = '';
  bool _dialogNotShowing = true;

  CircleLoading? _loading;
  late HomeWorkPresenter _presenter;
  CameraPreviewProvider? _cameraPreviewProvider;
  MainWidgetProvider? _mainWidgetProvider;

  @override
  void initState() {
    if (!windowManager.hasListeners) {
    windowManager.addListener(this);
    }
    super.initState();
    _init();
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
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    dispose();
    super.dispose();
    _provider.dispose();
    _loading!.hide();
  }

  void _init() async {
    await windowManager.setPreventClose(true);
    setState(() {

    });
  }

  @override
  void onWindowClose() {
    super.onWindowClose();
    _showConfirmExitApp();
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
        // showDialog(
        //   context: context,
        //   builder: (BuildContext context) {
        //     return CustomAlertDialog(
        //       title: Utils.instance().multiLanguage(StringConstants.dialog_title),
        //       richText: RichText(
        //         text: TextSpan(
        //           // text: 'Bạn có muốn bắt đầu làm bài: ',
        //           // style: TextStyle(fontSize: FontsSize.fontSize_16,
        //           children: <TextSpan>[
        //             const TextSpan(text: 'Bạn có muốn bắt đầu làm bài: ', style: TextStyle(fontSize: FontsSize.fontSize_16, color: Colors.black)),
        //             TextSpan(text: homeWork.activityName, style: const TextStyle(fontSize: FontsSize.fontSize_16, fontWeight: FontWeight.bold, color: Colors.black)),
        //             const TextSpan(text: ', với tài khoản là ', style: TextStyle(fontSize: FontsSize.fontSize_16, color: Colors.black)),
        //             TextSpan(text: _mainWidgetProvider!.titleMain, style: const TextStyle(fontSize: FontsSize.fontSize_16, fontWeight: FontWeight.bold, color: Colors.black)),
        //             const TextSpan(text: ' không?', style: TextStyle(fontSize: FontsSize.fontSize_16, color: Colors.black))
        //           ]
        //         ),
        //       ),
        //       description: 'Bạn có muốn bắt đầu làm bài: ${homeWork.activityName}, với tài khoản là ${_mainWidgetProvider!.titleMain} không?',
        //       okButtonTitle: StringConstants.ok_button_title,
        //       cancelButtonTitle: Utils.instance().multiLanguage(StringConstants.cancel_button_title),
        //       borderRadius: 8,
        //       hasCloseButton: false,
        //       okButtonTapped: () async {
        //         Navigations.instance()
        //             .goToSimulatorTestRoom(context, activitiesModel: homeWork);
        //         //Add action log
        //         LogModel actionLog = await Utils.instance().prepareToCreateLog(context,
        //             action: LogEvent.actionClickOnHomeworkItem);
        //         actionLog.addData(
        //             key: StringConstants.k_activity_id,
        //             value: homeWork.activityId.toString());
        //         Utils.instance().addLog(actionLog, LogEvent.none);
        //       },
        //       cancelButtonTapped: () {
        //         Navigator.of(context).pop();
        //       },
        //     );
        //   },
        // );
        Navigations.instance()
            .goToSimulatorTestRoom(context, activitiesModel: homeWork);
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

  void _showConfirmExitApp() async {
    if (_dialogNotShowing) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: Utils.instance().multiLanguage(StringConstants.dialog_title),
            description: 'Bạn có chắc chắn muốn thoát khỏi phần mềm?',
            okButtonTitle:
            'Xác nhận',
            cancelButtonTitle: 'Để sau',
            borderRadius: 8,
            hasCloseButton: false,
            okButtonTapped: () {
              _dialogNotShowing = true;
              windowManager.destroy();
            },
            cancelButtonTapped: () {
              _dialogNotShowing = true;
              Navigator.of(context).pop();
            },
          );
        },
      );
      _dialogNotShowing = false;
    }
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
}
