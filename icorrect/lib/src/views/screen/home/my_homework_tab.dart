// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:grouped_list/sliver_grouped_list.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/ui_models/alert_info.dart';
import 'package:icorrect/src/presenters/homework_presenter.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/provider/homework_provider.dart';
import 'package:icorrect/src/provider/my_practice_list_provider.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/alert_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/circle_loading.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/custom_alert_dialog.dart';
import 'package:icorrect/src/views/screen/test/my_test/my_test_screen.dart';
import 'package:icorrect/src/views/screen/test/simulator_test/simulator_test_screen.dart';
import 'package:icorrect/src/views/widget/filter_content_widget.dart';
import 'package:icorrect/src/views/widget/homework_widget.dart';
import 'package:icorrect/src/views/widget/no_data_widget.dart';
import 'package:icorrect/src/views/widget/not_connect_view_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

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
  ActivitiesModel? _selectedActivityModel;
  final FlutterLocalization localization = FlutterLocalization.instance;
  CircleLoading? _loading;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loading = CircleLoading();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            _buildTopFilter(),
            _buildListHomeWork(),
          ],
        ),
        Consumer<HomeWorkProvider>(
          builder: (context, homeWorkProvider, child) {
            if (kDebugMode) {
              print(
                  "DEBUG: HomeworkScreen: update UI with processing: ${homeWorkProvider.isProcessing}");
            }
            if (homeWorkProvider.isProcessing) {
              _loading!.show(context: context, isViewAIResponse: false);
            } else {
              Utils.hideLoading(_loading);
            }
            return const SizedBox();
          },
        ),
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
                    style: CustomTextStyle.textWithCustomInfo(
                      context: context,
                      color: AppColor.defaultBlackColor,
                      fontsSize: FontsSize.fontSize_14,
                      fontWeight: FontWeight.w600,
                    ),
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
              onPressed: _showFilterView,
              child: Image.asset(
                'assets/images/ic_filter.png',
                height: CustomSize.size_25,
                width: CustomSize.size_25,
              ),
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
        return FilterContentWidget(homeWorkProvider: widget.homeWorkProvider);
      },
    );
  }

  Widget _buildListHomeWork() {
    return Expanded(
      child: Container(
        color: AppColor.defaultWhiteColor,
        child: Consumer<HomeWorkProvider>(
            builder: (context, homeworkProvider, child) {
          if (!homeworkProvider.isConnected && !homeworkProvider.isProcessing) {
            homeworkProvider.updateFilterString(
                Utils.multiLanguage(StringConstants.default_filter_title)!);
            return NotConnectViewWidget(
              msg: Utils.multiLanguage(
                  StringConstants.log_connection_error_message)!,
              reloadCallBack: _reloadCallBack,
            );
          }
          if (homeworkProvider.listFilteredHomeWorks.isEmpty &&
              !homeworkProvider.isProcessing) {
            homeworkProvider.updateFilterString(
                Utils.multiLanguage(StringConstants.default_filter_title)!);
            return NoDataWidget(
              msg: Utils.multiLanguage(StringConstants.no_data_filter_message)!,
              reloadCallBack: _reloadCallBack,
            );
          }
          return RefreshIndicator(
            onRefresh: widget.pullToRefreshCallBack,
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverGroupedListView<ActivitiesModel, String>(
                      elements: homeworkProvider.listFilteredHomeWorks,
                      groupBy: (element) => element.classId.toString(),
                      groupComparator: (value1, value2) =>
                          value2.compareTo(value1),
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
                            style: CustomTextStyle.textWithCustomInfo(
                              context: context,
                              color: AppColor.defaultBlackColor,
                              fontsSize: FontsSize.fontSize_16,
                              fontWeight: FontWeight.w600,
                            ),
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
                Container(
                  alignment: Alignment.bottomRight,
                  margin: const EdgeInsets.all(20),
                  child: _languageSelectionButton(),
                )
              ],
            ),
          );
        }),
      ),
    );
  }

  void _updateFilterText() {
    widget.homeWorkProvider.prepareToUpdateFilterString();
  }

  void _refreshMyPracticeList() {
    Provider.of<MyPracticeListProvider>(context, listen: false)
        .refreshList(true);
  }

  Widget _languageSelectionButton() {
    return SpeedDial(
      backgroundColor: AppColor.defaultPurpuleTransparent,
      overlayColor: Colors.black,
      overlayOpacity: 0.6,
      spaceBetweenChildren: 10,
      activeBackgroundColor: AppColor.defaultPurpuleLight02,
      activeIcon: Icons.close,
      children: [
        SpeedDialChild(
          onTap: () {
            localization.translate('en');
            _updateFilterText();
            _refreshMyPracticeList();
          },
          child: const Padding(
            padding: EdgeInsets.all(2),
            child: Image(
              image: AssetImage(AppAsset.imgEnglish),
            ),
          ),
          label: StringConstants.ens_upppercase,
          labelStyle: const TextStyle(
            color: AppColor.defaultPurpleColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        SpeedDialChild(
          onTap: () {
            localization.translate('vi');
            _updateFilterText();
            _refreshMyPracticeList();
          },
          child: const Padding(
            padding: EdgeInsets.all(2),
            child: Image(
              image: AssetImage(AppAsset.imgVietName),
            ),
          ),
          label: StringConstants.vn_uppercase,
          labelStyle: const TextStyle(
            color: AppColor.defaultPurpleColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: Image(
              image: AssetImage(
                Utils.getCurrentLanguage()[StringConstants.k_image_url],
              ),
            ),
          ),
          Text(
            Utils.getCurrentLanguage()[StringConstants.k_data],
            style: const TextStyle(color: Colors.white, fontSize: 13),
          )
        ],
      ),
    );
  }

  void _clickOnHomeWorkItem(ActivitiesModel homeWorkModel) async {
    widget.homeWorkPresenter
        .clickOnHomeworkItem(context: context, homework: homeWorkModel);

    if (homeWorkModel.activityType == "homework") {
      _requestMicroPermission(homeWorkModel);
    } else {
      _requestMicroAndCameraPermissions(homeWorkModel);
    }
  }

  Future _requestMicroPermission(ActivitiesModel homeWorkModel) async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.microphone,
      ].request();

      if (statuses[Permission.microphone]! ==
          PermissionStatus.permanentlyDenied) {
        _showConfirmDeniedDialog(AlertClass.microPermissionAlert);
        return;
      }

      if (statuses[Permission.microphone]! == PermissionStatus.denied) {
        if (widget.homeWorkProvider.permissionDeniedTime >= 1) {
          _showConfirmDeniedDialog(AlertClass.microPermissionAlert);
        } else {
          widget.homeWorkProvider.setPermissionDeniedTime();
        }
      } else {
        _selectedActivityModel = homeWorkModel;
        widget.homeWorkProvider.resetPermissionDeniedTime();
        _gotoHomeworkDetail();
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("DEBUG: Permission error ${e.toString()}");
      }
    }
  }

  Future _requestMicroAndCameraPermissions(
      ActivitiesModel homeWorkModel) async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.microphone,
      ].request();

      if (statuses[Permission.microphone]! ==
          PermissionStatus.permanentlyDenied) {
        _showConfirmDeniedDialog(AlertClass.microPermissionAlert);
        return;
      }

      if (statuses[Permission.microphone]! == PermissionStatus.denied) {
        if (widget.homeWorkProvider.permissionDeniedTime >= 1) {
          _showConfirmDeniedDialog(AlertClass.microPermissionAlert);
        } else {
          widget.homeWorkProvider.setPermissionDeniedTime();
        }
      } else {
        try {
          Map<Permission, PermissionStatus> otherStatuses =
              await [Permission.camera].request();
          if (otherStatuses[Permission.camera]! ==
              PermissionStatus.permanentlyDenied) {
            _showConfirmDeniedDialog(AlertClass.cameraPermissionAlert);
            return;
          }
          if (otherStatuses[Permission.camera]! == PermissionStatus.denied) {
            if (widget.homeWorkProvider.permissionDeniedTime >= 1) {
              _showConfirmDeniedDialog(AlertClass.cameraPermissionAlert);
            } else {
              widget.homeWorkProvider.setPermissionDeniedTime();
            }
          } else {
            _selectedActivityModel = homeWorkModel;
            widget.homeWorkProvider.resetPermissionDeniedTime();
            _gotoHomeworkDetail();
          }
        } on PlatformException catch (e) {
          if (kDebugMode) {
            print("DEBUG: Permission error ${e.toString()}");
          }
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

  void _showActivityIsLoadedDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: Utils.multiLanguage(StringConstants.dialog_title)!,
          description:
              Utils.multiLanguage(StringConstants.activity_is_loaded_message)!,
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

  void _gotoHomeworkDetail() async {
    if (_selectedActivityModel!.activityStatus == 99) {
      _showActivityIsLoadedDialog(context);
    } else {
      Utils.checkInternetConnection().then((isConnected) async {
        if (isConnected) {
          Map<String, dynamic> statusMap = Utils.getHomeWorkStatus(
            _selectedActivityModel!,
            widget.homeWorkProvider.serverCurrentTime,
          );

          if (statusMap[StringConstants.k_title] ==
                  StringConstants.activity_status_out_of_date ||
              statusMap[StringConstants.k_title] ==
                  StringConstants.activity_status_not_completed) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SimulatorTestScreen(
                  activitiesModel: _selectedActivityModel!,
                  testOption: null,
                  topicsId: null,
                  isPredict: null,
                  testDetail: null,
                  onRefresh: null,
                ),
              ),
            );

            if (!mounted) return;
            // After the SimulatorTest returns a result
            // and refresh list of homework if needed
            if (result == StringConstants.k_refresh) {
              widget.homeWorkPresenter.refreshListHomework();
            }
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MyTestScreen(
                  activitiesModel: _selectedActivityModel!,
                  isFromSimulatorTest: false,
                ),
              ),
            );
          }
        } else {
          _handleConnectionError();
        }
      });
    }
  }

  void _handleConnectionError() {
    //Show connect error here
    if (kDebugMode) {
      print("DEBUG: Connect error here!");
    }
    Utils.showConnectionErrorDialog(context);

    Utils.addConnectionErrorLog(context);
  }

  void _reloadCallBack() async {
    if (kDebugMode) {
      print("DEBUG: MyHomeworkTab - _reloadCallBack");
    }
    widget.homeWorkPresenter.refreshListHomework();
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
