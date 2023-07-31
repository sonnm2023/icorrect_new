import 'package:icorrect/src/models/ui_models/alert_info.dart';

enum ToastStatesType {
  success,
  error,
  warning,
}

enum AuthType {
  login,
  register,
  getUserInfor,
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
  hightLight(1),
  others(0),
  hadScrore(1),
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
