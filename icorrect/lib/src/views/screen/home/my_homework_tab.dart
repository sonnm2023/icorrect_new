import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grouped_list/sliver_grouped_list.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/presenters/homework_presenter.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/provider/homework_provider.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/alert_dialog.dart';
import 'package:icorrect/src/views/screen/test/my_test/my_test_screen.dart';
import 'package:icorrect/src/views/screen/test/simulator_test/simulator_test_screen.dart';
import 'package:icorrect/src/views/widget/filter_content_widget.dart';
import 'package:icorrect/src/views/widget/homework_widget.dart';
import 'package:icorrect/src/views/widget/no_data_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../models/ui_models/alert_info.dart';

class MyHomeWorkTab extends StatefulWidget {
  const MyHomeWorkTab(
      {Key? key,
      required this.homeWorkProvider,
      required this.homeWorkPresenter,
      required this.pullToRefreshCallBack})
      : super(key: key);

  final HomeWorkProvider homeWorkProvider;
  final HomeWorkPresenter homeWorkPresenter;
  final Future<void> Function() pullToRefreshCallBack;

  @override
  State<MyHomeWorkTab> createState() => _MyHomeWorkTabState();
}

class _MyHomeWorkTabState extends State<MyHomeWorkTab>
    implements ActionAlertListener {
  Permission? _storagePermission;
  PermissionStatus _storagePermissionStatus = PermissionStatus.denied;

  ActivitiesModel? _selectedHomeWorkModel;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopFilter(),
        _buildListHomeWork(),
      ],
    );
  }

  Widget _buildTopFilter() {
    return Container(
      height: CustomSize.size_40,
      decoration: const BoxDecoration(
        color: AppColor.defaultGraySlightColor,
        border: Border(
          top: BorderSide(
            color: AppColor.defaultPurpleColor,
            width: 1.5,
          ),
          bottom: BorderSide(
            color: AppColor.defaultPurpleColor,
            width: 1.3,
          ),
        ),
      ),
      child: Stack(
        children: [
          GestureDetector(
            onTap: _showFilterView,
            child: Container(
              alignment: Alignment.center,
              child: Consumer<HomeWorkProvider>(
                builder: (context, homeworkProvider, child) {
                  return Text(
                    homeworkProvider.filterString,
                    style: CustomTextStyle.textBoldBlack_14,
                  );
                },
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.defaultGraySlightColor,
                elevation: 0.0,
              ),
              child: Image.asset(
                'assets/images/ic_filter.png',
                height: CustomSize.size_25,
                width: CustomSize.size_25,
              ),
              onPressed: _showFilterView,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterView() {
    Provider.of<AuthProvider>(context, listen: false)
        .setShowDialogWithGlobalScaffoldKey(
      true,
      GlobalScaffoldKey.filterScaffoldKey,
    );

    showModalBottomSheet<void>(
      context: context,
      isDismissible: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: CustomSize.size_400,
          child: _buildFilterBottomSheet(),
        );
      },
    );
  }

  Widget _buildFilterBottomSheet() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: FilterContentWidget(homeWorkProvider: widget.homeWorkProvider),
        ),
        _buildButtons(),
      ],
    );
  }

  Widget _buildButtons() {
    double w = MediaQuery.of(context).size.width / 2;

    return Row(
      children: [
        Container(
          height: CustomSize.size_50,
          width: w,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColor.defaultGraySlightColor,
                width: 1,
              ),
              right: BorderSide(
                color: AppColor.defaultGraySlightColor,
                width: 1,
              ),
            ),
          ),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Center(
              child: Text(
                StringConstants.close_button_title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColor.defaultGrayColor,
                ),
              ),
            ),
          ),
        ),
        Container(
          height: CustomSize.size_50,
          width: w,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColor.defaultGraySlightColor,
                width: 1,
              ),
            ),
          ),
          child: InkWell(
            onTap: () {
              bool isValid = widget.homeWorkProvider.checkFilterSelected();
              widget.homeWorkProvider.setProcessingStatus(isProcessing: true);
              if (isValid) {
                widget.homeWorkProvider.filterHomeWork();
                Navigator.pop(context);
              } else {
                widget.homeWorkProvider
                    .setProcessingStatus(isProcessing: false);

                showToastMsg(
                  msg: StringConstants.choose_filter_message,
                  toastState: ToastStatesType.warning,
                );
              }
            },
            child: const Center(
              child: Text(
                StringConstants.done_button_title,
                style: CustomTextStyle.textBoldPurple_14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListHomeWork() {
    return Expanded(
      child: Container(
        color: AppColor.defaultWhiteColor,
        child: Consumer<HomeWorkProvider>(
            builder: (context, homeworkProvider, child) {
          if (homeworkProvider.listFilteredHomeWorks.isEmpty &&
              !homeworkProvider.isProcessing) {
            return const NoDataWidget(
                msg: StringConstants.no_data_filter_message);
          }
          return RefreshIndicator(
            onRefresh: widget.pullToRefreshCallBack,
            child: CustomScrollView(
              slivers: [
                SliverGroupedListView<ActivitiesModel, String>(
                  elements: homeworkProvider.listFilteredHomeWorks,
                  groupBy: (element) => element.classId.toString(),
                  groupComparator: (value1, value2) => value2.compareTo(value1),
                  order: GroupedListOrder.ASC,
                  groupSeparatorBuilder: (String classId) {
                    String className = Utils.getClassNameWithId(
                        classId, homeworkProvider.listClassForFilter);

                    return Padding(
                      padding: const EdgeInsets.only(
                        left: CustomSize.size_15,
                        top: CustomSize.size_5,
                        right: CustomSize.size_10,
                        bottom: CustomSize.size_5,
                      ),
                      child: Text(
                        className,
                        textAlign: TextAlign.left,
                        style: CustomTextStyle.textBoldBlack_16,
                      ),
                    );
                  },
                  itemBuilder: (c, element) {
                    return HomeWorkWidget(
                      homeWorkModel: element,
                      callBack: _clickOnHomeWorkItem,
                      homeWorkProvider: homeworkProvider,
                    );
                  },
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Future<void> _pullRefresh() async {
    if (kDebugMode) {
      print("DEBUG: _buildListHomeWork: _pullRefresh");
    }
  }

  void _clickOnHomeWorkItem(ActivitiesModel homeWorkModel) async {
    widget.homeWorkPresenter
        .clickOnHomeworkItem(context: context, homework: homeWorkModel);

    _requestMicroAndCameraPermissions(homeWorkModel);
  }

  Future _requestMicroAndCameraPermissions(
      ActivitiesModel homeWorkModel) async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      if (statuses[Permission.camera]! == PermissionStatus.denied ||
          statuses[Permission.microphone]! == PermissionStatus.denied) {
        if (widget.homeWorkProvider.permissionDeniedTime >= 1) {
          _showConfirmDeniedDialog(AlertClass.microCameraPermissionAlert);
        } else {
          widget.homeWorkProvider.setPermissionDeniedTime();
        }
      } else if (statuses[Permission.camera]! ==
              PermissionStatus.permanentlyDenied ||
          statuses[Permission.microphone]! ==
              PermissionStatus.permanentlyDenied) {
        openAppSettings();
      } else {
        _selectedHomeWorkModel = homeWorkModel;

        await _initializePermission();
        if (_storagePermission != null) {
          _requestPermission(_storagePermission!);
        }else{
          _gotoHomeworkDetail();
        }
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("DEBUG: Permission error ${e.toString()}");
      }
    }
  }

  void _showConfirmDeniedDialog(AlertInfo alertInfo) {
    if (false == widget.homeWorkProvider.dialogShowing) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertsDialog.init().showDialog(
              context,
              alertInfo,
              this,
              keyInfo: StringClass.permissionDenied,
            );
          });
      widget.homeWorkProvider.setDialogShowing(true);
    }
  }

  Future<void> _initializePermission() async {
    _storagePermission = Permission.storage;

    if (Platform.isAndroid) {
      AndroidDeviceInfo android = await DeviceInfoPlugin().androidInfo;
      int sdk = android.version.sdkInt;

      if (sdk >= 33) {
        _storagePermission = null;
      }
    }
  }

  void _listenForPermissionStatus() async {
    if (_storagePermission != null) {
      _storagePermissionStatus = await _storagePermission!.status;

      if (_storagePermissionStatus == PermissionStatus.denied) {
        if (widget.homeWorkProvider.permissionDeniedTime > 2) {
          _showConfirmDialog();
        }
      } else if (_storagePermissionStatus ==
          PermissionStatus.permanentlyDenied) {
        openAppSettings();
      } else {
        _gotoHomeworkDetail();
      }
    } else {
      _gotoHomeworkDetail();
    }
  }

  Future<void> _requestPermission(Permission? permission) async {
    // ignore: unused_local_variable
    if (permission != null) {
      final status = await permission.request();
      widget.homeWorkProvider.setPermissionDeniedTime();
    }
    _listenForPermissionStatus();
  }

  void _showConfirmDialog() {
    if (false == widget.homeWorkProvider.dialogShowing) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertsDialog.init().showDialog(
              context,
              AlertClass.storagePermissionAlert,
              this,
              keyInfo: StringClass.permissionDenied,
            );
          });
      widget.homeWorkProvider.setDialogShowing(true);
    }
  }

  void _gotoHomeworkDetail() async {
    Map<String, dynamic> statusMap = Utils.getHomeWorkStatus(
        _selectedHomeWorkModel!, widget.homeWorkProvider.serverCurrentTime);

    if (statusMap['title'] == 'Out of date' ||
        statusMap['title'] == 'Not Completed') {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SimulatorTestScreen(
            homeWorkModel: _selectedHomeWorkModel!,
          ),
        ),
      );

      if (!mounted) return;
      // After the SimulatorTest returns a result
      // and refresh list of homework if needed
      if (result == 'refresh') {
        widget.homeWorkPresenter.refreshListHomework();
      }
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MyTestScreen(
            homeWorkModel: _selectedHomeWorkModel!,
            isFromSimulatorTest: false,
          ),
        ),
      );
    }
  }

  @override
  void onAlertExit(String keyInfo) {
    widget.homeWorkProvider.setDialogShowing(false);
  }

  @override
  void onAlertNextStep(String keyInfo) {
    widget.homeWorkProvider.setDialogShowing(false);
    openAppSettings();
  }
}
