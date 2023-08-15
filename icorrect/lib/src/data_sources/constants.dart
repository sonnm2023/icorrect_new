import 'package:flutter/material.dart';
import 'package:icorrect/src/models/ui_models/alert_info.dart';

import '../../core/app_color.dart';

enum ToastStatesType {
  success,
  error,
  warning,
}

enum AuthType {
  login,
  register,
  getUserInfo,
}

enum PasswordType {
  password,
  confirmPassword,
  currentPassword,
  newPassword,
  confirmNewPassword,
}

enum HandleWhenFinish {
  introVideoType,
  cueCardVideoType,
  questionVideoType,
  followupVideoType,
  endOfTestVideoType,
  reviewingVideoType,
  reviewingPlayTheQuestionType,
}

enum Status {
  corrected(2),
  late(-1),
  outOfDate(-2),
  submitted(1),
  notComplete(0),
  trueStatus(1),
  falseStatus(0),
  highLight(1),
  others(0),
  hadScore(1),
  allHomework(2);

  const Status(this.get);

  final int get;
}

enum PartOfTest {
  introduce(0),
  part1(1),
  part2(2),
  part3(3),
  followUp(4),
  endOfTest(5);

  const PartOfTest(this.get);
  final int get;
}

enum DoingStatus {
  none(-1),
  doing(0),
  finish(1);

  const DoingStatus(this.get);
  final int get;
}

enum SubmitStatus {
  none(-1),
  success(0),
  fail(1),
  submitting(2);

  const SubmitStatus(this.get);
  final int get;
}

enum ReviewingStatus {
  none(-1),
  playing(0),
  pause(1),
  restart(2);

  const ReviewingStatus(this.get);
  final int get;
}

enum Alert {
  networkError({
    Alert.cancelTitle: 'Exit',
    Alert.actionTitle: 'Try again',
    Alert.icon: 'assets/images/img_no_internet.png'
  }),

  serverError({
    Alert.cancelTitle: 'Exit',
    Alert.actionTitle: 'Contact with us',
    Alert.icon: 'assets/images/img_server_error.png'
  }),

  warning({
    Alert.cancelTitle: 'Cancel',
    Alert.actionTitle: 'Out the test',
    Alert.icon: 'assets/images/img_warning.png'
  }),

  downloadError({
    Alert.cancelTitle: 'Exit',
    Alert.actionTitle: 'Try again',
    Alert.icon: 'assets/images/img_server_error.png'
  }),

  dataNotFound({
    Alert.cancelTitle: 'Exit',
    Alert.actionTitle: 'Try again',
    Alert.icon: 'assets/images/img_not_found.png'
  }),

  permissionDenied({
    Alert.cancelTitle: 'Exit',
    Alert.actionTitle: 'Go to setting',
    Alert.icon: 'assets/images/img_warning.png'
  });

  const Alert(this.type);
  static const cancelTitle = 'cancel_title';
  static const actionTitle = 'action_title';
  static const icon = 'icon';
  final Map<String, String> type;
}

enum SelectType { classType, statusType }

class FilterJsonData {
  static Map<String, dynamic> selectAll = {"id": -111, "name": "SelectAll"};
  static Map<String, dynamic> submitted = {"id": 1, "name": "Submitted"};
  static Map<String, dynamic> corrected = {"id": 2, "name": "Corrected"};
  static Map<String, dynamic> notCompleted = {"id": 0, "name": "Not Completed"};
  static Map<String, dynamic> late = {"id": -1, "name": "Late"};
  static Map<String, dynamic> outOfDate = {"id": -2, "name": "Out of date"};
}

class StringClass {
  static const video = "videos";
  static const audio = "audios";

  static const String errorRequestTest = 'ERROR_REQUEST_TEST';
  static const String failDownloadVideo = 'FAIL_DOWNLOAD_VIDEO';
  static const String warningOutTheTest = 'WARNING_OUT_THE_TEST';
  static const String submitHomeworkFail = 'SUBMIT_HOMEWORK_FAIL';
  static const String videoPathError = 'VIDEO_PATH_ERROR';
  static const String permissionDenied = 'PERMISSION_DENIED';
}

enum MediaType { video, audio }

class AlertClass {
  static AlertInfo downloadVideoErrorAlert = AlertInfo(
    'Fail to load your test',
    "Can not download video. Please try again!",
    Alert.networkError.type,
  );

  static AlertInfo microPermissionAlert = AlertInfo(
    'Warning',
    "You must allow micro permission to continue.",
    Alert.permissionDenied.type,
  );

  static AlertInfo storagePermissionAlert = AlertInfo(
    'Warning',
    "You must allow storage permission to continue.",
    Alert.permissionDenied.type,
  );

  static AlertInfo videoPathIncorrectAlert = AlertInfo(
    'Warning',
    'Video path was incorrect. Please try again !',
    Alert.dataNotFound.type,
  );

  static AlertInfo getTestDetailAlert = AlertInfo(
    'Warning',
    'Error when load your test. Please try again !',
    Alert.dataNotFound.type,
  );
  static AlertInfo notResponseLoadTestAlert = AlertInfo(
    'Warning',
    'Error when load your test. Let contact to admin to support !',
    Alert.dataNotFound.type,
  );

  static AlertInfo timeOutUpdateAnswer = AlertInfo(
      'Warning', 'Timeout to update your changes. Please try again !');

  static AlertInfo errorWhenUpdateAnswer = AlertInfo(
      'Warning', 'An error when update your answers. Please try again !');
}

class GlobalScaffoldKey {
  static final filterScaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'FilterScaffoldKeys');
  static final aiResponseScaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'AIResponseScaffoldKeys');
  static final showTipScaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'ShowTipScaffoldKey');
  static final showQuitTheTestScaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'ShowQuitTheTestScaffoldKey');
  static final myTestScaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'MyTestScaffoldKey');
  static final studentOtherScaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'StudentOtherScaffoldKey');
  static final homeScreenScaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'HomeScreenScaffoldKey');
  static final simulatorTestScaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'SimulatorTestScaffoldKey');
}



class FontsSize {
  static const double fontSize_8 = 8.0;
  static const double fontSize_13 = 13.0;
  static const double fontSize_14 = 14.0;
  static const double fontSize_15 = 15.0;
  static const double fontSize_16 = 16.0;
  static const double fontSize_18 = 18.0;
  static const double fontSize_20 = 20.0;
}

class CustomPadding {
  static const double padding_1 = 1.0;
  static const double padding_2 = 2.0;
  static const double padding_5 = 5.0;
  static const double padding_10 = 10.0;
  static const double padding_15 = 15.0;
  static const double padding_20 = 20.0;
  static const double padding_30 = 30.0;
  static const double padding_40 = 40.0;
  static const double padding_50 = 50.0;
  static const double padding_100 = 100.0;
}

class CustomSize {
  static const double size_5 = 5.0;
  static const double size_10 = 10.0;
  static const double size_15 = 15.0;
  static const double size_20 = 20.0;
  static const double size_25 = 25.0;
  static const double size_30 = 30.0;
  static const double size_40 = 40.0;
  static const double size_50 = 50.0;
  static const double size_60 = 60.0;
  static const double size_70 = 70.0;
  static const double size_80 = 80.0;
  static const double size_90 = 90.0;
  static const double size_100 = 100.0;
  static const double size_200 = 200.0;
  static const double size_400 = 400.0;
}

class CustomTextStyle {
  static const TextStyle appbarContent = TextStyle(
    color: AppColor.defaultPurpleColor,
    fontWeight: FontWeight.w800,
    fontSize: FontsSize.fontSize_18,
  );

  static const TextStyle textBoldGreen_16 = TextStyle(
    color: Colors.green,
    fontWeight: FontWeight.w600,
    fontSize: FontsSize.fontSize_16,
  );

  static const TextStyle textBoldGreen_15 = TextStyle(
    color: Colors.green,
    fontWeight: FontWeight.w600,
    fontSize: FontsSize.fontSize_15,
  );

  static TextStyle textGrey_16 = TextStyle(
    color: Colors.grey.withOpacity(0.6),
    fontWeight: FontWeight.w400,
    fontSize: FontsSize.fontSize_16,
  );

  static const TextStyle textBoldGrey_16 = TextStyle(
    color: AppColor.defaultGrayColor,
    fontWeight: FontWeight.w600,
    fontSize: FontsSize.fontSize_16,
  );

  static const TextStyle textBlack_16 = TextStyle(
    color: AppColor.defaultBlackColor,
    fontWeight: FontWeight.w400,
    fontSize: FontsSize.fontSize_16,
  );

  static const TextStyle textBoldBlack_16 = TextStyle(
    color: AppColor.defaultBlackColor,
    fontWeight: FontWeight.w600,
    fontSize: FontsSize.fontSize_16,
  );

  static const TextStyle textBoldPurple_16 = TextStyle(
    color: AppColor.defaultPurpleColor,
    fontWeight: FontWeight.w600,
    fontSize: FontsSize.fontSize_16,
  );

  static const TextStyle textGrey_15 = TextStyle(
    color: AppColor.defaultGrayColor,
    fontWeight: FontWeight.w400,
    fontSize: FontsSize.fontSize_15,
  );

  static const TextStyle textBoldGrey_15 = TextStyle(
    color: AppColor.defaultGrayColor,
    fontWeight: FontWeight.w600,
    fontSize: FontsSize.fontSize_15,
  );

  static const TextStyle textBlack_15 = TextStyle(
    color: AppColor.defaultBlackColor,
    fontWeight: FontWeight.w400,
    fontSize: FontsSize.fontSize_15,
  );

  static const TextStyle textBoldBlack_15 = TextStyle(
    color: AppColor.defaultBlackColor,
    fontWeight: FontWeight.w600,
    fontSize: FontsSize.fontSize_15,
  );

  static const TextStyle textBoldPurple_15 = TextStyle(
    color: AppColor.defaultPurpleColor,
    fontWeight: FontWeight.w600,
    fontSize: FontsSize.fontSize_15,
  );

  static const TextStyle textWhite_15 = TextStyle(
    color: AppColor.defaultWhiteColor,
    fontWeight: FontWeight.w400,
    fontSize: FontsSize.fontSize_15,
  );

  static const TextStyle textWhiteBold_15 = TextStyle(
    color: AppColor.defaultWhiteColor,
    fontWeight: FontWeight.w600,
    fontSize: FontsSize.fontSize_15,
  );

  static const TextStyle textWhiteBold_18 = TextStyle(
    color: AppColor.defaultWhiteColor,
    fontWeight: FontWeight.w600,
    fontSize: FontsSize.fontSize_18,
  );

  static const TextStyle textGrey_14 = TextStyle(
    color: AppColor.defaultGrayColor,
    fontWeight: FontWeight.w400,
    fontSize: FontsSize.fontSize_14,
  );

  static const TextStyle textBoldGrey_14 = TextStyle(
    color: AppColor.defaultGrayColor,
    fontWeight: FontWeight.w600,
    fontSize: FontsSize.fontSize_14,
  );

  static const TextStyle textBlack_14 = TextStyle(
    color: AppColor.defaultBlackColor,
    fontWeight: FontWeight.w400,
    fontSize: FontsSize.fontSize_14,
  );

  static const TextStyle textBoldBlack_14 = TextStyle(
    color: AppColor.defaultBlackColor,
    fontWeight: FontWeight.w600,
    fontSize: FontsSize.fontSize_14,
  );

  static const TextStyle textBoldPurple_14 = TextStyle(
    color: AppColor.defaultPurpleColor,
    fontWeight: FontWeight.w600,
    fontSize: FontsSize.fontSize_14,
  );

  static const TextStyle textWhite_14 = TextStyle(
    color: AppColor.defaultWhiteColor,
    fontWeight: FontWeight.w400,
    fontSize: FontsSize.fontSize_14,
  );

  static const TextStyle textWhiteBold_14 = TextStyle(
    color: AppColor.defaultWhiteColor,
    fontWeight: FontWeight.w400,
    fontSize: FontsSize.fontSize_14,
  );
}
