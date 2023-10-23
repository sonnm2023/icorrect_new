// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/models/ui_models/alert_info.dart';

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

enum UserAuthStatus {
  draft(0),
  active(1),
  lock(2),
  reject(4),
  waitingModelFile(3),
  errorAuth(99);

  const UserAuthStatus(this.get);

  final int get;
}

enum FileAuthStatus {
  newAdd(0),
  waitingModelFile(1);

  const FileAuthStatus(this.get);

  final int get;
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
  allHomework(2),
  playOff(10);

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
    Alert.actionTitle: 'Out the exam',
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

enum MediaType { video, audio, none }

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
  static final practiceScreenScaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'PracticeScreenTestScaffoldKey');
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
  static const TextStyle appbarTitle = TextStyle(
    color: AppColor.defaultPurpleColor,
    fontWeight: FontWeight.w800,
    fontSize: FontsSize.fontSize_18,
  );

  static const TextStyle textBoldGreen_16 = TextStyle(
    color: Colors.green,
    fontWeight: FontWeight.w600,
    fontSize: FontsSize.fontSize_16,
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
    fontWeight: FontWeight.w400,
    fontSize: FontsSize.fontSize_15,
  );

  static const TextStyle textWhiteBold_16 = TextStyle(
    color: AppColor.defaultWhiteColor,
    fontWeight: FontWeight.w500,
    fontSize: FontsSize.fontSize_16,
  );

  static const TextStyle textBoldGreen_15 = TextStyle(
    color: Colors.green,
    fontWeight: FontWeight.w600,
    fontSize: FontsSize.fontSize_15,
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

class LogEvent {
  //Status
  static const String success = "success";
  static const String failed = "failed";
  static const String none = "none"; //For action log

  //Api log event
  static const String callApiLogin = 'call_api_login';
  static const String callApiAppConfig = 'call_api_app_config';
  static const String callApiGetUserInfo = 'call_api_get_user_info';
  static const String callApiLogout = 'call_api_logout';
  static const String callApiGetListHomework = 'call_api_get_list_homework';
  static const String callApiChangePassword = 'call_api_change_password';
  static const String callApiGetTestDetail =
      'call_api_get_test_detail'; //api/v1/ielts-test/syllabus/create
  static const String callApiDownloadFile =
      'call_api_download_file'; //${apiDomain}file?filename=$name
  static const String callApiSubmitTest =
      'call_api_submit_test'; //'${icorrectDomain}api/v1/ielts-test/submit-v2'
  static const String callApiUpdateAnswer =
      'call_api_update_answer'; //'${icorrectDomain}api/v1/ielts-test/submit-v2'
  static const String callApiGetMyTestDetail =
      'call_api_get_my_test_detail'; //${icorrectDomain}api/v1/ielts-test/show/$testId
  static const String callApiUpdateMyAnswer =
      'call_api_update_my_answer'; //'${icorrectDomain}api/v1/ielts-test/submit-v2'
  static const String callApiGetResponse =
      'call_api_get_response'; //'${toolDomain}api/response?order_id=$orderId';
  static const String callApiGetSpecialHomework =
      'call_api_get_special_homework'; //specialHomeWorksEP
  static const String callApiGetUserAuthDetail =
      'call_api_get_user_auth_detail';
  static const String callApiSubmitAuth = 'call_api_submit_auth';

  //Action log event
  static const String actionLogin = 'action_login';
  static const String actionLogout = 'action_logout';
  static const String actionChangePassword = 'action_change_password';
  static const String actionClickOnHomeworkItem =
      'action_click_on_homework_item';
  static const String actionStartToDoTest = 'action_start_to_do_test';
  static const String actionPlayVideoQuestion = 'action_play_video_question';
  static const String actionRecordAnswer = 'action_record_answer';
  static const String actionFinishAnswer = 'action_finish_answer';
  static const String actionFinishReAnswer = 'action_finish_re_answer';
  static const String actionRepeatQuestion = 'action_repeat_question';
  static const String actionSubmitTest = 'action_submit_test';
  static const String actionUpdateAnswer = 'action_update_answer';
}

const sendLogsTask = "com.csupporter.sendlogtask";

class StringConstants {
  //Button Titles
  static const String sign_in_button_title = "Sign In";
  static const String sign_up_button_title = "Sign Up";
  static const String forgot_password_button_title = "Forgot password?";
  static const String save_change_button_title = "Save change";
  static const String cancel_button_title = "Cancel";
  static const String ok_button_title = "OK";
  static const String close_button_title = "Close";
  static const String done_button_title = "Done";
  static const String clear_button_title = "Clear";
  static const String try_again_button_title = "Try Again";
  static const String view_sample_button_title = "View Sample";
  static const String view_tips_button_title = "View Tips";
  static const String back_button_title = "Back";
  static const String view_ai_response_button_title = "View AI Response";
  static const String update_answer_button_title = "Update Your Answer";
  static const String save_button_title = "Save";
  static const String dont_save_button_title = "Don't Save";
  static const String re_answer_button_title = "Re-answer";
  static const String finish_button_title = "Finish";
  static const String save_the_exam_button_title = "SAVE THE EXAM";
  static const String start_now_button_title = "Start Now";
  static const String repeat_button_title = "Repeat";
  static const String exit_button_title = "Exit";
  static const String later_button_title = "Later";
  static const String submit_button_title = "Submit";
  static const String start_record_video_title = "Start Recording Video";
  static const String record_video_again_title = "Record Video Again";
  static const String record_video_authentication_title =
      "Record Video Authentication";
  static const String submit_now_title = "Submit Now";
  static const String record_new_video_title = "Record New Video";
  //Dialog
  static const String dialog_title = "Notification";
  static const String exit_app_message = "Do you want to exit app?";
  static const String quit_the_test_message =
      "The test is not completed! Are you sure to quit?";
  static const String sample_video = "Sample Video";
  static const String sample_audio = "Sample Audio";
  static const String confirm_to_go_out_screen = "Are you sure to back?";
  static const String confirm_title = "Confirm";
  static const String confirm_save_change_answers_message =
      "Are you sure to save change your answers?";
  static const String confirm_save_change_answers_message_1 =
      "Your answers have changed. Do you want to save this change?";
  static const String confirm_before_quit_the_test_message =
      "Do you want to save this test before quit?";
  static const String confirm_reanswer_when_reviewing_message =
      "You are going to re-answer this question.The reviewing process will be stopped. Are you sure?";
  static const String confirm_save_the_test_message =
      "Do you want to save this test?";
  static const String confirm_exit_screen_title = "Are you sure to exit?";
  static const String confirm_exit_content =
      "Your video authentication is recording, are you sure to exit?";
  static const String confirm_submit_before_out_screen =
      "Your video authentication is not submitted, do you want to submit and exit?";
  static const String waiting_review_video =
      "Your sample is waiting for review";
  static const String confirm_record_new_video =
      "Are you sure to create new sample and sent to review ?";

  //Screen Titles
  static const String change_password_screen_title = "Change password";
  static const String my_homework_screen_title = "MY HOMEWORK";
  static const String tips_screen_title = "Tips for you";
  static const String practice_screen_title = "PRACTICE";
  static const String topics_screen_title = "Topics";
  static const String icorrect_title = "ICORRECT";

  //Tab titles
  static const String test_detail_tab_title = "Test Detail";
  static const String correction_tab_title = "Correction";
  static const String my_exam_tab_title = "MY EXAM";
  static const String response_tab_title = "RESPONSE";
  static const String highlight_tab_title = "HIGHLIGHT";
  static const String others_tab_title = "OTHERS";
  static const String filter_choose_class_tab_title = "CHOOSE CLASS";
  static const String filter_choose_status_tab_title = "CHOOSE STATUS";

  //Text
  static const String add_your_filter = "Add your filter!";
  static const String cue_card = "Cue Card";
  static const String another_tips = "Another tips";
  static const String nothing_tips = "Nothing tips for you in here";
  static const String practice_card_part_1_title = "Part I";
  static const String practice_card_part_1_description =
      "Examiner will ask general questions on familiar topic";
  static const String practice_card_part_2_title = "Part II";
  static const String practice_card_part_2_description =
      "Test ability to talk about a topic, develop your ideas about a topic and relevant";
  static const String practice_card_part_3_title = "Part III";
  static const String practice_card_part_3_description =
      "Examiner will ask you talk about topics and include the point that you can cover";
  static const String practice_card_part_2_3_title = "Part II and III";
  static const String practice_card_part_2_3_description =
      "You will take test of part II and Ill with same topic";
  static const String practice_card_full_test_title = "Full test";
  static const String practice_card_full_test_description =
      "You will take a full sample test of IELTS Speaking Test";
  static const String selected_topics = "Selected topic (0/24)";
  static const String downloading = "Downloading...";
  static const String overview = "Overview";
  static const String show_less = "Show less";
  static const String show_more = "Show more";
  static const String overall_score = "Overall score:";
  static const String fluency = "Fluency:";
  static const String lexical_resource = "Lexical Resource:";
  static const String grammatical = "Grammatical:";
  static const String pronunciation = "Pronunciation:";
  static const String problem = "Problem";
  static const String solution = "Solution";
  static const String nothing = "Nothing in here!";
  static const String answer_being_recorded = "Your answer is being recorded";
  static const String confirm_access_micro_permission_message =
      "This app needs to grant access to the microphone in order to record the answers during the exam process. Without granting permission, you will not be able to proceed with the exam.";
  static const String start_now_description =
      "Start the exam now or wait until the processing finished!";
  static const String part_1_header = "Practice Part 1";
  static const String part_2_header = "Practice Part 2";
  static const String part_3_header = "Practice Part 3";
  static const String answer_of_part_2 = "Answer of Part 2";
  static const String csupporter = "@Csupporter JSC";
  static const String contact = "Contact: support@ielts-correction.com";
  static const String unknown = "Unknown";
  static const String home_menu_item_title = "Home";
  static const String change_password_menu_item_title = "Change password";
  static const String logout_menu_item_title = "Logout";
  static const String email = "Email";
  static const String part = "Part";
  static const String logo_text = "REACH YOUR DREAM TARGET";
  static const String password = "Password";
  static const String retype_password = "Retype Password";
  static const String current_password = "Current password";
  static const String new_password = "New password";
  static const String confirm_new_password = "Confirm new password";
  static const String video_authen_menu_item_title = "Videos Authentication";
  static const String sampleTextTitle = "Sample Text :";
  static const String sampleTextContent =
      "Hello, my full name is ... (Nguyen Van Nam)."
      "I am ... (12) years old. I come from ...(Ninh Bình). I live with my family. I like to eat apples and bananas. "
      "My school's name is ... (Đồng Phong). Nice to meet you. can you introduce yourself?";
  static const String require_user_authentication_title =
      "Please send video sample for authentication";
  static const String confirm_submit_video_auth_title =
      "Confirm to submit your video !";
  static const String confirm_submit_video_auth_content =
      "This video will be used to confirm when you do your exam. So you want submit this video ?";
  static const String not_auth_title = "Not Authenticated";
  static const String not_auth_content =
      "You need to record and send video for authentication";
  static const String reject_auth_title = "Authentication video was rejected";
  static const String reject_auth_content =
      "You need to record a new video for authentication .Click the button below!";
  static const String user_authed_title = "You have been authenticated";
  static const String user_authed_content = "Get ready for the upcoming exams";
  static const String progress_auth_title = "Authentication in progress";
  static const String progress_auth_content =
      "The verification process takes some time, please wait until the results are available";
  static const String lock_auth_title = "You was locked";
  static const String lock_auth_content =
      "Please contact the I Correct administrator for assistance";
  static const String error_auth_title = "Error Authentication";
  static const String error_auth_content =
      "An error occurs during verification,please contact ICorrect support";

  //Warning Message
  static const String choose_filter_message =
      "You must choose at least one class and one status!";
  static const String no_data_filter_message =
      "No data, please choose other filter!";
  static const String test_correction_wait_response_message =
      "Please wait until the response from examiners is finish!";
  static const String nothing_problem_message = "Nothing Problem in here";
  static const String no_answer_message = "No answer in here!";
  static const String no_data_message = "No data, please come back later!";
  static const String re_answer_not_be_save_message =
      "Your re-answers will not be saved.";
  static const String can_not_delete_files_message = "Can not delete files!";
  static const String wait_until_the_exam_finished_message =
      "Please wait until the exam finished!";
  static const String feature_not_available_message =
      "This feature is not available!";
  static const String answer_must_be_greater_than_2_seconds_message =
      "Your answer must be greater than 2 seconds";
  static const String no_answer_please_start_your_test_message =
      "Oops, No answer here, please start your test!";
  static const String empty_email_error_message = "E-mail can't be empty";
  static const String invalid_email_error_message =
      "Invalid email .Please try again !";
  static const String empty_password_error_message = "Password can't be empty";
  static const String password_min_lenght_message =
      "Your password must be longer than 6 characters.";
  static const String password_max_lenght_message =
      "Your password must be shorter than 32 characters.";
  static const String video_record_duration_less_than_15s =
      "This video record must be greater than 15s";

  //Error message
  static const String getting_app_config_information_error_message =
      "Has an error when getting app config information!";
  static const String confirm_new_password_error_message =
      "Confirm new password must be equal new password!";
  static const String data_downloaded_error_message =
      "A part of data has not downloaded properly. Please check your internet connection and try again.";
  static const String network_error_message =
      "An error occur. Please check your connection!";
  static const String submit_test_error_messge =
      "An error occur, please try again later!";
  static const String common_error_messge =
      "An error occur, please try again later!";
}

const int timeout = 60;
