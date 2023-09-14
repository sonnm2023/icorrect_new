import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
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

class MyHomeWorkTab extends StatefulWidget {
  const MyHomeWorkTab(
      {Key? key,
      required this.homeWorkProvider,
      required this.homeWorkPresenter})
      : super(key: key);

  final HomeWorkProvider homeWorkProvider;
  final HomeWorkPresenter homeWorkPresenter;

  @override
  State<MyHomeWorkTab> createState() => _MyHomeWorkTabState();
}

class _MyHomeWorkTabState extends State<MyHomeWorkTab>
    implements ActionAlertListener {
  Permission? _storagePermission;
  PermissionStatus _storagePermissionStatus = PermissionStatus.denied;

  ActivitiesModel? _selectedHomeWorkModel;

  void clickOnHomeWorkItem(ActivitiesModel homeWorkModel) async {
    _selectedHomeWorkModel = homeWorkModel;

    if (_storagePermission == null) {
      await _initializePermission();
    }

    _requestPermission(_storagePermission!);
  }

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
             Container(
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
              onPressed: () {
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
              },
            ),
          ),
        ],
      ),
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
                "Close",
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
              widget.homeWorkProvider.updateProcessingStatus();
              if (isValid) {
                widget.homeWorkProvider.filterHomeWork();
                Navigator.pop(context);
              } else {
                widget.homeWorkProvider.updateProcessingStatus();
                showToastMsg(
                    msg: "You must choose at least one class and one status!",
                    toastState: ToastStatesType.warning);
              }
            },
            child: const Center(
              child: Text(
                "Done",
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
                msg: 'No data, please choose other filter!');
          }
          return CustomScrollView(
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
                    callBack: clickOnHomeWorkItem,
                    homeWorkProvider: homeworkProvider,
                  );
                },
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _initializePermission() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo android = await DeviceInfoPlugin().androidInfo;
      int sdk = android.version.sdkInt;

      sdk >= 33
          ? _storagePermission = Permission.manageExternalStorage
          : _storagePermission = Permission.storage;
    } else {
      _storagePermission = Permission.storage;
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
    }
  }

  Future<void> _requestPermission(Permission permission) async {
    // ignore: unused_local_variable
    final status = await permission.request();
    widget.homeWorkProvider.setPermissionDeniedTime();
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

  void _gotoHomeworkDetail() {
    //TODO: For test
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => SimulatorTestScreen(
    //       homeWorkModel: _selectedHomeWorkModel!,
    //     ),
    //   ),
    // );

    Map<String, dynamic> statusMap =
        Utils.getHomeWorkStatus(_selectedHomeWorkModel!, widget.homeWorkProvider.serverCurrentTime);

    if (statusMap['title'] == 'Out of date' ||
        statusMap['title'] == 'Not Completed') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SimulatorTestScreen(
            homeWorkModel: _selectedHomeWorkModel!,
          ),
        ),
      );
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
