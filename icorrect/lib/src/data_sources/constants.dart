// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/utils.dart';
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

enum LanguageSelector { english, vietnamese }

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

enum ActivityType {
  exam,
  test,
  homework,
  practice;
}

enum ReviewingStatus {
  none(-1),
  playing(0),
  pause(1),
  restart(2);

  const ReviewingStatus(this.get);
  final int get;
}

enum IELTSPartType {
  part1(['1']),
  part2(['2']),
  part3(['3']),
  part2and3(['2', '3']),
  full(['4']);

  const IELTSPartType(this.get);
  final List<String> get;
}

enum IELTSTestOption {
  part1(1),
  part2(2),
  part3(3),
  part2and3(4),
  full(5);

  const IELTSTestOption(this.get);
  final int get;
}

enum IELTSStatus {
  eachPart('3'),
  fullPart('2');

  const IELTSStatus(this.get);
  final String get;
}

enum IELTSPredict {
  normalQuestion(0),
  all(1402),
  randomQuestion(1);

  const IELTSPredict(this.get);
  final int get;
}

enum Alert {
  networkError({
    Alert.cancelTitle: StringConstants.exit_button_title,
    Alert.actionTitle: StringConstants.try_again_button_title,
    Alert.icon: 'assets/images/img_no_internet.png'
  }),

  serverError({
    Alert.cancelTitle: StringConstants.exit_button_title,
    Alert.actionTitle: StringConstants.contact_with_us,
    Alert.icon: 'assets/images/img_server_error.png'
  }),

  warning({
    Alert.cancelTitle: StringConstants.cancel_button_title,
    Alert.actionTitle: StringConstants.out_the_exam,
    Alert.icon: 'assets/images/img_warning.png'
  }),

  downloadError({
    Alert.cancelTitle: StringConstants.exit_button_title,
    Alert.actionTitle: StringConstants.try_again_button_title,
    Alert.icon: 'assets/images/img_server_error.png'
  }),

  dataNotFound({
    Alert.cancelTitle: StringConstants.exit_button_title,
    Alert.actionTitle: StringConstants.try_again_button_title,
    Alert.icon: 'assets/images/img_not_found.png'
  }),

  permissionDenied({
    Alert.cancelTitle: StringConstants.exit_button_title,
    Alert.actionTitle: StringConstants.go_to_setting,
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
  static Map<String, dynamic> selectAll = {"id": -111, "name": "Select All"};
  static Map<String, dynamic> submitted = {"id": 1, "name": "Submitted"};
  static Map<String, dynamic> corrected = {"id": 2, "name": "Corrected"};
  static Map<String, dynamic> notCompleted = {"id": 0, "name": "Not Completed"};
  static Map<String, dynamic> late = {"id": -1, "name": "Late"};
  static Map<String, dynamic> outOfDate = {"id": -2, "name": "Out Of Date"};
  static Map<String, dynamic> loadedTest = {"id": 99, "name": "Loaded Test"};
}

class StringClass {
  static const video = "videos";
  static const audio = "audios";
  static const images = "images";

  static const String errorRequestTest = 'ERROR_REQUEST_TEST';
  static const String failDownloadVideo = 'FAIL_DOWNLOAD_VIDEO';
  static const String warningOutTheTest = 'WARNING_OUT_THE_TEST';
  static const String submitHomeworkFail = 'SUBMIT_HOMEWORK_FAIL';
  static const String videoPathError = 'VIDEO_PATH_ERROR';
  static const String permissionDenied = 'PERMISSION_DENIED';
}

enum MediaType { video, audio, image, none }

class AlertClass {
  static AlertInfo downloadVideoErrorAlert = AlertInfo(
    Utils.multiLanguage(StringConstants.fail_to_load_your_test_message),
    Utils.multiLanguage(StringConstants.cannot_download_video),
    Alert.networkError.type,
  );

  static AlertInfo microPermissionAlert = AlertInfo(
    Utils.multiLanguage(StringConstants.warning_title),
    Utils.multiLanguage(StringConstants.require_micro_permission_content),
    Alert.permissionDenied.type,
  );

  static AlertInfo cameraPermissionAlert = AlertInfo(
    Utils.multiLanguage(StringConstants.warning_title),
    Utils.multiLanguage(StringConstants.require_camera_permission_content),
    Alert.permissionDenied.type,
  );

  static AlertInfo microCameraPermissionAlert = AlertInfo(
    Utils.multiLanguage(StringConstants.warning_title),
    Utils.multiLanguage(
        StringConstants.require_micro_and_camera_permission_content),
    Alert.permissionDenied.type,
  );

  static AlertInfo storagePermissionAlert = AlertInfo(
    Utils.multiLanguage(StringConstants.warning_title),
    Utils.multiLanguage(StringConstants.require_storage_permission_content),
    Alert.permissionDenied.type,
  );

  static AlertInfo videoPathIncorrectAlert = AlertInfo(
    Utils.multiLanguage(StringConstants.warning_title),
    Utils.multiLanguage(StringConstants.video_path_incorrect_message),
    Alert.dataNotFound.type,
  );

  static AlertInfo getTestDetailAlert = AlertInfo(
    Utils.multiLanguage(StringConstants.warning_title),
    Utils.multiLanguage(StringConstants.error_load_this_test_message),
    Alert.dataNotFound.type,
  );
  static AlertInfo notResponseLoadTestAlert = AlertInfo(
    Utils.multiLanguage(StringConstants.warning_title),
    Utils.multiLanguage(
        StringConstants.error_load_test_and_contact_admin_message),
    Alert.dataNotFound.type,
  );

  static AlertInfo timeOutUpdateAnswer = AlertInfo(
    Utils.multiLanguage(StringConstants.warning_title),
    Utils.multiLanguage(StringConstants.timeout_update_answer_message),
  );

  static AlertInfo errorWhenUpdateAnswer(String message) =>
      AlertInfo(Utils.multiLanguage(StringConstants.warning_title), message);
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
  static final myPracticeSettingScreenScaffoldKey = GlobalKey<ScaffoldState>(
      debugLabel: 'MyPracticeSettingScreenScaffoldKey');
  static final fullImageScaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'FullImageScaffoldKey');
}

class FontsSize {
  static const double fontSize_8 = 8.0;
  static const double fontSize_13 = 13.0;
  static const double fontSize_14 = 14.0;
  static const double fontSize_15 = 15.0;
  static const double fontSize_16 = 16.0;
  static const double fontSize_17 = 17.0;
  static const double fontSize_18 = 18.0;
  static const double fontSize_20 = 20.0;
  static const double fontSize_22 = 22.0;
}

class CustomPadding {
  static const double padding_1 = 1.0;
  static const double padding_2 = 2.0;
  static const double padding_5 = 5.0;
  static const double padding_10 = 10.0;
  static const double padding_15 = 15.0;
  static const double padding_11 = 11.0;
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
  static TextStyle textWithCustomInfo({
    required BuildContext context,
    required Color color,
    required double fontsSize,
    required FontWeight fontWeight,
  }) {
    double size = Utils.fixSizeOfText(context: context, fontSize: fontsSize);

    return TextStyle(
      color: color,
      fontWeight: fontWeight,
      fontSize: size,
    );
  }
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
  static const String callApiTestPosition = 'call_api_test_position';
  static const String crash_bug_audio_record = 'crash_bug_audio_record';
  static const String callApiGetListTopicOfBank =
      'call_api_get_list_topic_of_bank';

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
  static const String compressVideoFile = 'compress_video_file';
  static const String checkConnection = 'check_connection';
  static const String imageDownload = 'image_download';
  static const String createVideoSource = 'create_video_source';
  static const String start_audio_record = 'start_audio_record';
  static const String init_audio_record_error = 'init_audio_record_error';
  static const String init_audio_record_success = 'init_audio_record_success';
  static const String init_video_player_error = 'init_video_player_error';
  static const String init_video_player_success = 'init_video_player_success';
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
  static const String start_test_button_title = "Start Test";
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
  static const String reload_button_title = "Reload";
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
  static const String confirm_to_log_out = "Do you want to logout?";
  static const String default_filter_title = 'Add your filter!';
  static const String repeat_question = "Ask for repeating the question !";
  static const String delete_this_test_confirm =
      "Are you sure to delete this test ?";

  //Screen Titles
  static const String change_password_screen_title = "Change password";
  static const String my_homework_screen_title = "MY HOMEWORK";
  static const String tips_screen_title = "Tips for you";
  static const String practice_screen_title = "PRACTICE";
  static const String topics_screen_title = "TOPICS";
  static const String icorrect_title = "ICORRECT";

  //Tab titles
  static const String topic_tab_title = "Topics";
  static const String practice_setting = "Setting";
  static const String test_detail_tab_title = "Test Detail";
  static const String correction_tab_title = "Correction";
  static const String my_exam_tab_title = "MY EXAM";
  static const String response_tab_title = "RESPONSE";
  static const String highlight_tab_title = "HIGHLIGHT";
  static const String others_tab_title = "OTHERS";
  static const String filter_choose_class_tab_title = "CHOOSE CLASS";
  static const String filter_choose_status_tab_title = "CHOOSE STATUS";
  static const String filter_string = "Filter ";
  static const String class_string = "Class";
  static const String status_string = "Status";

  //Text
  static const String start_to_pratice = "Start to practice";
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
  static const String selected_topics = "Selected topic (%a/%a)";
  static const String my_pratice_selected_topics = " Topics";
  static const String my_pratice_selected_subtopics = " Sub Topics";
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
  static const String practice_menu_item_title = "Practice";
  static const String my_test_menu_item_title = "My Practices";
  static const String my_test_title = "MY PRACTICES";
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
  static const String save_answer_success_message =
      "Save your answers successfully!";
  static const String submit_test_success_message =
      "The test has been submitted successfully!";
  static const String submit_test_success_message_with_code_5013 =
      "The test has been submitted successfully!\nYou can't update it.";
  static const String submit_authen_success_message =
      "Submit file to authentication successfully. Waiting for confirmation!";
  static const String submit_authen_fail_message =
      "Submit file to authentication fail!";
  static const String submit_authen_fail_timeout_message =
      "Submit file to authentication fail: TimeoutException!";
  static const String submit_authen_fail_socket_message =
      "Submit file to authentication fail: TimeoutException!";
  static const String submit_authen_fail_client_message =
      "Submit file to authentication fail: TimeoutException!";
  static const String contact_with_us = 'Contact with us';
  static const String out_the_exam = 'Out the exam';
  static const String go_to_setting = 'Go to setting';
  static const String select_your_language_title = 'Select your language';
  static const String number_of_topics = 'Number of topics';
  static const String number_question_of_part_1 = 'Number question of Part 1';
  static const String number_question_of_part_2 = 'Number question of Part 2';
  static const String cue_card_time_of_part_2 = 'Cue card time of Part 2';
  static const String speed_of_first_time = 'Speed of the first time';
  static const String speed_of_second_time = 'Speed of the second time';
  static const String speed_of_third_time = 'Speed of the third time';

  //Compress video message
  static const String cancel_and_text = "Cancel and Later";
  static const String skip_and_text = "Skip and Later";
  static const String submit_now_text = "Submit Now";
  static const String continue_prepare_text = "Continue";
  static const String warning_skip_compress_video_text =
      "Do you want to submit now?";
  static const String warning_skip_compress_video_content =
      'Your test video will not be sent'
      ' and you will have to verify again at Video Authentication.';

  //Warning Message
  static const String email_or_password_wrong_message =
      "Opps! Something went wrong, email or password is not found.";
  static const String choose_filter_message =
      "You must choose at least one class and one status!";
  static const String no_data_filter_message =
      "No data, please choose other filter!";
  static const String my_practice_no_data_message =
      "There are currently no practice sessions.!";
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
  static const String not_authen_user_message =
      "You have not been added to the testing system, please contact admin for better understanding!";
  static const String get_authen_user_fail_message =
      "Something went wrong when load your authentication!";
  static const String delete_test_success_message =
      "Delete this test successfully!";
  //Error message
  static const String getting_app_config_information_error_message =
      "Has an error when getting app config information!";
  static const String confirm_new_password_error_message =
      "Confirm new password must be equal new password!";
  static const String old_password_equals_new_password_error_message =
      "The new password must be different from the old password!";
  static const String data_downloaded_error_message =
      "A part of data has not downloaded properly. Please check your internet connection and try again.";
  static const String network_error_message =
      "An error occur. Please check your connection!";
  static const String common_error_message =
      "An error occur, please try again later!";
  static const String http_client_exception_error_message =
      "An error occur, client exception error, please try again later!";
  static const String timeout_exception_error_message =
      "An error occur, timeout exception error, please try again later!";
  static const String error_when_resize_file =
      'An error occurred while resizing the video file!';
  static const String error_when_delete_file =
      'An error occurred while deleting the video file!';
  static const String log_connection_error_message =
      'Your internet is not connect!';
  static const String load_image_error_message = "Can not load image!";
  static const String load_list_homework_error_message =
      "Loading list homework error!";
  static const String load_result_response_error_message =
      "Loading result response fail!";
  static const String can_not_load_response_message = "Can't load response";
  static const String load_detail_homework_error_message =
      "Loading detail homework error!";
  static const String submit_test_error_message =
      "Has an error when submit this test. Please try again later!";
  static const String submit_test_error_invalid_return_type_message =
      "Has an error when submit this test!\n[Error: invalid type]";
  static const String submit_test_error_timeout =
      "TimeoutException: Has an error when submit this test!";
  static const String submit_test_error_socket =
      "SocketException: Has an error when submit this test!";
  static const String submit_test_error_client =
      "ClientException: Has an error when submit this test!";
  static const String submit_test_error_other =
      "OtherException: Has an error when submit this test!";
  static const String get_activity_list_error_other =
      "OtherException: Has an error when getting activity list!";
  static const String submit_test_error_parse_json =
      "ParseJsonException: Has an error when submit this test!";
  static const String parse_json_error =
      "ParseJsonException: Has an error when parse json from response!";
  static const String get_special_homework_error_message =
      "GetSpecialHomeWorks: result fail!";
  static const String compress_video_error_message = "Compress video file fail";
  static const String activity_is_loaded_message =
      "This test is loaded but not completed. Please contact admin to reset it!";
  static const String update_answer_error_message =
      "An error when update your answers. Please try again!";
  static const String change_password_success_message =
      "Change password successfully!";
  static const String multi_language = "Multi Language";
  static const String ens = "English";
  static const String vn = "Tiếng Việt";
  static const String ens_upppercase = "ENGLISH";
  static const String vn_uppercase = "VIETNAMESE";
  static const String en_shortest = "EN";
  static const String vn_shortest = "VN";
  static const String choose_at_least_3_topics =
      "You must choose at least 3 topics";
  static const String choose_at_least_3_topics_at_part1_message =
      "You must choose at least 3 topics at part I";
  static const String choose_at_least_1_topics_at_part23_message =
      "You must choose at least 1 topics at part II and III";
  static const String delete_action_title = "Delete";
  static const String loading_title = "Loading Data";

  static const String fail_to_load_your_test_message = 'Fail to load your test';
  static const String cannot_download_video =
      'Can not download video. Please try again!';
  static const String warning_title = "Warning";
  static const String require_micro_permission_content =
      "This app needs to access microphone to do the homeworks or the exam.";
  static const String require_camera_permission_content =
      "This app needs to access camera to do the homeworks or the exam.";
  static const String permission_warning_title = 'Permission Warning';
  static const String require_micro_and_camera_permission_content =
      "This app needs to access microphone and camera to do the homeworks or the exam.";
  static const String require_storage_permission_content =
      "You must allow storage permission to continue.";
  static const String video_path_incorrect_message =
      'Video path was incorrect. Please try again !';
  static const String error_load_this_test_message =
      'Error when load your test. Please try again !';
  static const String error_load_test_and_contact_admin_message =
      "'Error when load your test. Let contact to admin to support !";
  static const String timeout_update_answer_message =
      'Timeout to update your changes. Please try again !';
  static const String search_title = "Search";
  static const String my_practice_selected_topic_error_message =
      'You must choose at least 1 topic!';
  static const String my_practice_setting_number_topic_error_message =
      'You must set up at least 1 topic!';
  static const String my_practice_setting_number_question_error_message =
      'You must set up at least 1 question!';
  static const String my_practice_setting_take_note_time_error_message =
      'You must set up the take note time greater than 0 second!';

  static const String out_of_date_title = "Out Of Date";
  static const String not_completed_title = "Not Completed";
  static const String corrected_title = "Corrected";
  static const String submitted_title = "Submitted";
  static const String late_title = "Late";
  static const String ai_scored_title = " AI Scored";
  static const String not_evaluated_title = "Not Evaluated";
  static const String loaded_test_title = "Loaded Test";
  static const String select_all_title = "Select All";
  //Activity status
  static const String activity_status_out_of_date =
      "activity_status_out_of_date"; //"Out Of Date";
  static const String activity_status_not_completed =
      "activity_status_not_completed"; //"Not Completed";
  static const String activity_status_corrected =
      "activity_status_corrected"; //"Corrected";
  static const String activity_status_submitted =
      "activity_status_submitted"; //"Submitted";
  static const String activity_status_late = "activity_status_late"; //"Late";
  static const String activity_status_ai_scored =
      "activity_status_ai_scored"; //" AI Scored";
  static const String ai_score_response_not_evaluated = "Not Evaluated";
  static const String activity_status_loaded_test =
      "activity_status_loaded_test"; //"Loaded Test";
  static const String select_all = "select_all"; //"Select All";
  static const String prepare_compress_video_title = "Preparing for submitting";

  //keywords
  static const String k_email = "email";
  static const String k_password = "password";
  static const String k_device_id = "device_id";
  static const String k_app_version = "app_version";
  static const String k_os = "os";
  static const String k_old_password = "password_old";
  static const String k_confirmation_password = "password_confirmation";
  static const String k_status = "status";
  static const String k_activity_id = "activity_id";
  static const String k_distribute_code = "distribute_code";
  static const String k_platform = "platform";
  static const String k_title = "title";
  static const String k_color = "color";
  static const String k_score = "score";
  static const String k_data = "data";
  static const String k_test = "test";
  static const String k_error_code = "error_code";
  static const String k_access_token = "access_token";
  static const String k_message = "message";
  static const String k_messages = "messages";
  static const String k_current_time = "current_time";
  static const String k_content_type = "Content-Type";
  static const String k_authorization = "Authorization";
  static const String k_test_id = "test_id";
  static const String k_is_update = "is_update";
  static const String k_accept = "'Accept'";
  static const String k_file_name = "file_name";
  static const String k_file_path = "file_path";
  static const String k_file_download_info = "file_download_info";
  static const String k_response = "response";
  static const String k_request_data = "request_data";
  static const String k_image_url = "image_url";
  static const String k_log_action = "log_action";
  static const String k_video_confirm = "video_confirm";
  static const String k_question_id = "question_id";
  static const String k_question_text = "question_text";
  static const String k_type = "type";
  static const String k_time = "time";
  static const String k_question_content = "question_content";
  static const String k_file_id = "file_id";
  static const String k_file_url = "file_url";
  static const String k_api_url = "api_url";
  static const String k_secretkey = "secretkey";
  static const String k_refresh = "refresh";
  static const String k_topic_type = "topic_type[]";
  static const String k_test_option = "option";
  static const String k_required_topic = "required_topic";
  static const String k_is_predict = "is_predict";
  static const String k_has_order = "has_order";
  static const String k_duration = "duration";
}

const int timeout = 60;
