// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences_keys.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/data_sources/multi_language.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/new_class_model.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/my_practice_test_model.dart';
import 'package:icorrect/src/models/my_test_models/student_result_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/ui_models/user_authen_status.dart';
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:icorrect/src/presenters/homework_presenter.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/custom_alert_dialog.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

class Utils {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static Future<String> getDeviceIdentifier() async {
    String deviceIdentifier = "unknown";
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceIdentifier = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceIdentifier = iosInfo.identifierForVendor ?? "unknown";
    } else if (kIsWeb) {
      WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;
      if (webInfo.userAgent != null) {
        deviceIdentifier =
            "${webInfo.vendor} ${webInfo.userAgent!} ${webInfo.hardwareConcurrency.toString()}";
      }
    } else if (Platform.isLinux) {
      LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
      deviceIdentifier = linuxInfo.machineId ?? "unknown";
    } else if (Platform.isMacOS) {
      MacOsDeviceInfo macOsDeviceInfo = await deviceInfo.macOsInfo;
      deviceIdentifier = macOsDeviceInfo.systemGUID ?? "unknown";
    } else if (Platform.isWindows) {
      WindowsDeviceInfo windowsDeviceInfo = await deviceInfo.windowsInfo;
      deviceIdentifier = windowsDeviceInfo.deviceId;
    }
    return deviceIdentifier;
  }

  static Future<String> getOS() async {
    String os = "unknown_flutter";

    if (Platform.isAndroid) {
      os = "android_flutter";
    } else if (Platform.isIOS) {
      os = "ios_flutter";
    } else if (kIsWeb) {
      os = "web_flutter";
    } else if (Platform.isLinux) {
      os = "linux_flutter";
    } else if (Platform.isMacOS) {
      os = "macos_flutter";
    } else if (Platform.isWindows) {
      os = "window_flutter";
    }
    return os;
  }

  static void setAppVersion(String version) {
    AppSharedPref.instance()
        .putString(key: AppSharedKeys.appVersion, value: version);
  }

  static Future<String> getAppVersion() {
    return AppSharedPref.instance().getString(key: AppSharedKeys.appVersion);
  }

  static void setCurrentUser(UserDataModel user) {
    AppSharedPref.instance()
        .putString(key: AppSharedKeys.currentUser, value: jsonEncode(user));
  }

  static void clearCurrentUser() {
    AppSharedPref.instance()
        .putString(key: AppSharedKeys.currentUser, value: null);
  }

  static Future<String> getAccessToken() {
    return AppSharedPref.instance().getString(key: AppSharedKeys.apiToken);
  }

  static void setAccessToken(String token) {
    return AppSharedPref.instance()
        .putString(key: AppSharedKeys.apiToken, value: token);
  }

  static Future<UserDataModel?> getCurrentUser() async {
    String userJson = await AppSharedPref.instance()
        .getString(key: AppSharedKeys.currentUser);
    if (userJson.isEmpty) {
      return null;
    }

    Map<String, dynamic> userMap = jsonDecode(userJson) ?? {};
    if (userMap.isEmpty) {
      return null;
    }
    return UserDataModel.fromJson(userMap);
  }

  static String getPartOfTest(int option) {
    switch (option) {
      case 1:
        return 'I';
      case 2:
        return 'II';
      case 3:
        return 'III';
      case 4:
        return 'II&III';
      case 5:
        return 'FULL';
      case 6:
        return 'I&II';
      default:
        return 'NULL';
    }
  }

  static String getPartOfTestWithString(String option) {
    switch (option) {
      case 'part1':
        return 'I';
      case 'part2':
        return 'II';
      case "part3":
        return 'III';
      case "part23":
        return 'II&III';
      case 'full':
        return 'FULL';
      case "part12":
        return 'I&II';
      default:
        return 'NULL';
    }
  }

  static DateTime convertStringToDateTime(String str) {
    DateTime tempDate = DateTime.parse(str);
    return tempDate;
  }

  static Map<String, dynamic> getHomeWorkStatus(
      ActivitiesModel homeWorkModel, String serverCurrentTime) {
    if (homeWorkModel.activityStatus == 99) {
      return {
        StringConstants.k_title: StringConstants.activity_status_loaded_test,
        StringConstants.k_color: Colors.brown,
      };
    }

    if (null == homeWorkModel.activityAnswer) {
      bool timeCheck =
          isExpired(homeWorkModel.activityEndTime, serverCurrentTime);
      if (timeCheck) {
        return {
          StringConstants.k_title: StringConstants.activity_status_out_of_date,
          StringConstants.k_color: Colors.red,
        };
      }

      return {
        StringConstants.k_title: StringConstants.activity_status_not_completed,
        StringConstants.k_color: const Color.fromARGB(255, 237, 179, 3)
      };
    } else {
      if (homeWorkModel.activityAnswer!.orderId != 0) {
        return {
          StringConstants.k_title: StringConstants.activity_status_corrected,
          StringConstants.k_color: const Color.fromARGB(255, 12, 201, 110)
        };
      } else {
        if (homeWorkModel.activityAnswer!.late == 0) {
          return {
            StringConstants.k_title: StringConstants.activity_status_submitted,
            StringConstants.k_color: const Color.fromARGB(255, 45, 117, 243)
          };
        }

        if (homeWorkModel.activityAnswer!.late == 1) {
          return {
            StringConstants.k_title: StringConstants.activity_status_late,
            StringConstants.k_color: Colors.red,
          };
        }

        if (homeWorkModel.activityEndTime.isNotEmpty) {
          DateTime endTime = DateTime.parse(homeWorkModel.activityEndTime);
          DateTime createTime =
              DateTime.parse(homeWorkModel.activityAnswer!.createdAt);
          if (endTime.compareTo(createTime) < 0) {
            return {
              StringConstants.k_title:
                  StringConstants.activity_status_out_of_date,
              StringConstants.k_color: Colors.red,
            };
          }
        }
      }

      return {}; //Error
    }
  }

  static String haveAiResponse(ActivitiesModel homeWorkModel) {
    if (null != homeWorkModel.activityAnswer) {
      if (homeWorkModel.activityAnswer!.aiResponseLink.isNotEmpty &&
          isNumeric(homeWorkModel.activityAnswer!.aiScore)) {
        double score = double.parse(homeWorkModel.activityAnswer!.aiScore);
        if (score != -1 && score != -2) {
          return StringConstants.activity_status_ai_scored;
        }
      }
    }
    return '';
  }

  static int getFilterStatus(String status) {
    switch (status) {
      case StringConstants.activity_status_submitted:
        return 1;
      case StringConstants.activity_status_corrected:
        return 2;
      case StringConstants.activity_status_not_completed:
        return 0;
      case StringConstants.activity_status_late:
        return -1;
      case StringConstants.activity_status_out_of_date:
        return -2;
      default:
        return -10;
    }
  }

  static Map<String, dynamic> scoreReponse(StudentResultModel resultModel) {
    if (resultModel.overallScore.isNotEmpty &&
        resultModel.overallScore != "0.0") {
      return {
        StringConstants.k_color: Colors.green,
        StringConstants.k_score: resultModel.overallScore
      };
    } else {
      String aiScore = resultModel.aiScore;
      if (aiScore.isNotEmpty) {
        if (isNumeric(aiScore) &&
            (double.parse(aiScore) == -1.0 || double.parse(aiScore) == -2.0)) {
          return {
            StringConstants.k_color: Colors.red,
            StringConstants.k_score: Utils.multiLanguage(
                StringConstants.ai_score_response_not_evaluated)
          };
        } else {
          return {
            StringConstants.k_color: Colors.blue,
            StringConstants.k_score: aiScore
          };
        }
      } else {
        return {
          StringConstants.k_color: Colors.red,
          StringConstants.k_score: Utils.multiLanguage(
              StringConstants.ai_score_response_not_evaluated)
        };
      }
    }
  }

  static String multiLanguage(String constantString) {
    final FlutterLocalization localization = FlutterLocalization.instance;
    if (localization.currentLocale == null) {
      localization.init(
        mapLocales: [
          const MapLocale('en', MultiLanguage.EN),
          const MapLocale('vi', MultiLanguage.VN),
        ],
        initLanguageCode: 'vi',
      );
    }
    return Intl.message(
        localization.currentLocale!.languageCode == "vi"
            ? MultiLanguage.VN[constantString]
            : MultiLanguage.EN[constantString],
        name: constantString);
  }

  static Map<String, dynamic> getCurrentLanguage() {
    final FlutterLocalization localization = FlutterLocalization.instance;
    if (localization.currentLocale == null) {
      localization.init(
        mapLocales: [
          const MapLocale('en', MultiLanguage.EN),
          const MapLocale('vi', MultiLanguage.VN),
        ],
        initLanguageCode: 'vi',
      );
    }

    if (localization.currentLocale!.languageCode == "vi") {
      return {
        StringConstants.k_title: StringConstants.vn_uppercase,
        StringConstants.k_image_url: AppAsset.imgVietName,
        StringConstants.k_data: StringConstants.vn_shortest
      };
    } else {
      return {
        StringConstants.k_title: StringConstants.ens_upppercase,
        StringConstants.k_image_url: AppAsset.imgEnglish,
        StringConstants.k_data: StringConstants.en_shortest
      };
    }
  }

  static bool isNumeric(String str) {
    return int.tryParse(str) != null || double.tryParse(str) != null;
  }

  static double convertToDouble(dynamic data) {
    if (data is int) {
      return double.parse('$data.0');
    }
    return double.parse('$data');
  }

  static UserAuthenStatusUI getUserAuthenStatus(
      BuildContext context, int status) {
    switch (status) {
      case 0:
        return UserAuthenStatusUI(
            title: Utils.multiLanguage(StringConstants.not_auth_title),
            description: Utils.multiLanguage(StringConstants.not_auth_content),
            icon: Icons.cancel_outlined,
            backgroundColor: const Color.fromARGB(255, 248, 179, 179),
            titleColor: Colors.red,
            iconColor: Colors.red);
      case 4:
        return UserAuthenStatusUI(
            title: Utils.multiLanguage(StringConstants.reject_auth_title),
            description:
                Utils.multiLanguage(StringConstants.reject_auth_content),
            icon: Icons.video_camera_front_outlined,
            backgroundColor: const Color.fromARGB(255, 248, 233, 179),
            titleColor: Colors.amber,
            iconColor: Colors.amber);
      case 1:
        return UserAuthenStatusUI(
            title: Utils.multiLanguage(StringConstants.user_authed_title),
            description:
                Utils.multiLanguage(StringConstants.user_authed_content),
            icon: Icons.check_circle_outline_rounded,
            backgroundColor: const Color.fromARGB(255, 179, 248, 195),
            titleColor: Colors.green,
            iconColor: Colors.green);
      case 3:
        return UserAuthenStatusUI(
            title: Utils.multiLanguage(StringConstants.progress_auth_title),
            description:
                Utils.multiLanguage(StringConstants.progress_auth_content),
            icon: Icons.change_circle_sharp,
            backgroundColor: const Color.fromARGB(255, 179, 222, 248),
            titleColor: Colors.blue,
            iconColor: Colors.blue);
      case 2:
        return UserAuthenStatusUI(
            title: Utils.multiLanguage(StringConstants.lock_auth_title),
            description: Utils.multiLanguage(StringConstants.lock_auth_content),
            icon: Icons.lock,
            backgroundColor: const Color.fromARGB(255, 248, 179, 179),
            titleColor: Colors.red,
            iconColor: Colors.red);
      case 99:
      default:
        return UserAuthenStatusUI(
            title: Utils.multiLanguage(StringConstants.error_auth_title),
            description:
                Utils.multiLanguage(StringConstants.error_auth_content),
            icon: Icons.error_outline,
            backgroundColor: const Color.fromARGB(255, 248, 179, 179),
            titleColor: Colors.red,
            iconColor: Colors.red);
    }
  }

  static String base64String(Uint8List data) {
    return base64Encode(data);
  }

  static Future<String> convertVideoToBase64(http.Response response) async {
    final bytes = response.bodyBytes;
    return base64Encode(bytes);
  }

  static Future<File> convertBase64ToFile(
      String base64String, String path) async {
    Uint8List decodedBytes = base64.decode(base64String);
    File decodedFile = await File(path).writeAsBytes(decodedBytes);
    return decodedFile;
  }

  static String convertFileName(String nameFile) {
    String letter1 = '/';
    String letter2 = '*';
    String newLetter = '_sl_';

    if (nameFile.contains(letter1)) {
      nameFile = nameFile.replaceAll(letter1, newLetter);
    }

    if (nameFile.contains(letter2)) {
      nameFile = nameFile.replaceAll(letter2, newLetter);
    }

    return nameFile;
  }

  static String reConvertFileName(String nameFile) {
    String letter = '_sl_';
    String newLetter = '/';
    if (nameFile.contains(letter)) {
      nameFile = nameFile.replaceAll(letter, newLetter);
    }

    return nameFile;
  }

  static int getTestOption(List<String> topicType) {
    int testOption = IELTSTestOption.full.get;
    if (topicType == IELTSTopicType.part1.get) {
      testOption = IELTSTestOption.part1.get;
    } else if (topicType == IELTSTopicType.part2.get) {
      testOption = IELTSTestOption.part2.get;
    } else if (topicType == IELTSTopicType.part3.get) {
      testOption = IELTSTestOption.part3.get;
    } else if (topicType == IELTSTopicType.part2and3.get) {
      testOption = IELTSTestOption.part2and3.get;
    }
    return testOption;
  }

  static File changeFileNameSync(File file, String newFileName) {
    var path = file.path;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + newFileName;
    return file.renameSync(newPath);
  }

  static String fileType(String filePath) {
    String fileExtension = filePath.split('.').last.toLowerCase();
    if (fileExtension == 'mp4' ||
        fileExtension == 'mov' ||
        fileExtension == 'avi') {
      return StringClass.video;
    }
    if (fileExtension == 'wav' ||
        fileExtension == 'mp3' ||
        fileExtension == 'm4a' ||
        fileExtension == 'aac') {
      return StringClass.audio;
    }
    return '';
  }

  static Future<String> generateAudioFileName() async {
    DateTime dateTime = DateTime.now();
    String timeNow =
        '${dateTime.year}${dateTime.month}${dateTime.day}_${dateTime.hour}${dateTime.minute}${dateTime.second}';

    return '${timeNow}_reanswer';
  }

  static Future<File> prepareVideoFile(String fileName) async {
    String filePath =
        await FileStorageHelper.getFilePath(fileName, MediaType.video, null);
    return File(filePath);
  }

  static Future<File> prepareAudioFile(String fileName, String? testId) async {
    File decodedVideoFile;
    String bs4str =
        await FileStorageHelper.readVideoFromFile(fileName, MediaType.audio);
    Uint8List decodedBytes = base64.decode(bs4str);
    String filePath =
        await FileStorageHelper.getFilePath(fileName, MediaType.audio, testId);
    if (decodedBytes.isEmpty) {
      decodedVideoFile = File(filePath);
    } else {
      decodedVideoFile = await File(filePath).writeAsBytes(decodedBytes);
    }
    return decodedVideoFile;
  }

  static int getRecordTime(int type) {
    switch (type) {
      case 0: //Answer for question in introduce
        return 30;
      case 1: //Answer for question in part 1
        return 30;
      case 2: //Answer for question in part 2
        return 120;
      case 3: //Answer for question in part 3
        return 45;
      default:
        return 0;
    }
  }

  static String getTimeRecordString(int timerCount) {
    String result = '';

    if (timerCount < 10) {
      return "00:0$timerCount";
    }

    if (timerCount < 60) {
      return "00:$timerCount";
    }

    if (timerCount > 60) {
      int seconds = (timerCount / 60).floor();
      int ms = (timerCount - seconds * 60);
      String str1 = seconds < 10 ? "0$seconds" : "$seconds";
      String str2 = ms < 10 ? '0$ms' : '$ms';
      return "$str1:$str2";
    }

    return result;
  }

  static String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  static Future<String> getAudioPathToPlay(
      QuestionTopicModel question, String? testId) async {
    String fileName = '';
    if (question.answers.length > 1) {
      if (question.repeatIndex == 0) {
        fileName = question.answers.first.url;
      } else {
        fileName = question.answers.elementAt(question.repeatIndex).url;
      }
    } else {
      fileName = question.answers.first.url;
    }
    String path =
        await FileStorageHelper.getFilePath(fileName, MediaType.audio, testId);
    return path;
  }

  static Future<String> getReviewingAudioPathToPlay(
      QuestionTopicModel question, String? testId) async {
    String fileName = question.answers.first.url;
    String path =
        await FileStorageHelper.getFilePath(fileName, MediaType.audio, testId);
    return path;
  }

  static String getClassNameWithId(String id, List<NewClassModel> list) {
    if (list.isEmpty) return "";

    for (int i = 0; i < list.length; i++) {
      NewClassModel c = list[i];
      if (c.id.toString() == id) {
        return c.name;
      }
    }

    return "";
  }

  static void showLogoutConfirmDialog({
    required BuildContext context,
    required HomeWorkPresenter? homeWorkPresenter,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: Utils.multiLanguage(StringConstants.dialog_title),
          description: Utils.multiLanguage(StringConstants.confirm_to_log_out),
          okButtonTitle: Utils.multiLanguage(StringConstants.ok_button_title),
          cancelButtonTitle:
              Utils.multiLanguage(StringConstants.cancel_button_title),
          borderRadius: 8,
          hasCloseButton: false,
          okButtonTapped: () async {
            if (null != homeWorkPresenter) {
              Utils.checkInternetConnection().then((isConnected) {
                if (isConnected) {
                  homeWorkPresenter.logout(context);
                } else {
                  //Show connect error here
                  if (kDebugMode) {
                    print("DEBUG: Connect error here!");
                  }
                  Utils.showConnectionErrorDialog(context);

                  Utils.addConnectionErrorLog(context);
                }
              });
            } else {
              Navigator.of(context).pop();
            }
          },
          cancelButtonTapped: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  static bool isExpired(String activityEndTime, String serverCurrentTime) {
    final t1 = DateTime.parse(activityEndTime);

    var inputFormat = DateFormat('MM/dd/yyyy HH:mm:ss');
    var inputDate = inputFormat.parse(serverCurrentTime);
    var outputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final t2 = DateTime.parse(outputFormat.format(inputDate));
    if (t1.compareTo(t2) < 0) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> validateImage(String imageUrl) async {
    http.Response res;
    try {
      res = await http.get(Uri.parse(imageUrl));
    } catch (e) {
      return false;
    }

    if (res.statusCode != 200) return false;
    Map<String, dynamic> data = res.headers;
    return checkIfImage(data['content-type']);
  }

  static bool checkIfImage(String param) {
    if (param == 'image/jpeg' || param == 'image/png' || param == 'image/gif') {
      return true;
    }
    return false;
  }

  static bool checkHasImage({required QuestionTopicModel question}) {
    if (question.files.length > 1) {
      String fileName = question.files.last.url;
      String type = fileName.split('.').last;

      if (type == 'jpeg' || type == 'jpg' || type == 'png') {
        return true;
      } else {
        return false;
      }
    }

    return false;
  }

  static Future<String> getOSVersion() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String version = "";
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      version =
          '${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      version = iosInfo.systemVersion;
    }
    return version;
  }

  static Future<String> getDeviceName() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceName = "";
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceName = androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceName = iosInfo.utsname.machine;
    }
    return deviceName;
  }

  static Future<LogModel> createLog({
    required String action,
    required String previousAction,
    required String status,
    required String message,
    required Map<String, String> data,
  }) async {
    LogModel log = LogModel();
    log.action = action;
    log.previousAction = previousAction;
    log.status = status;
    log.createdTime = getDateTimeNow();
    log.message = message;
    log.os = await getOS();
    UserDataModel? currentUser = await Utils.getCurrentUser();
    if (null == currentUser) {
      log.userId = 0;
    } else {
      log.userId = currentUser.userInfoModel.id;
    }
    log.deviceId = await getDeviceIdentifier();
    log.deviceName = await getDeviceName();
    log.osVersion = await getOSVersion();
    log.versionApp = await getAppVersion();
    log.data = data;
    return log;
  }

  static void prepareLogData({
    required LogModel? log,
    required Map<String, dynamic>? data,
    required String? message,
    required String status,
  }) {
    if (null == log) return;

    if (null != data) {
      log.addData(key: StringConstants.k_data, value: jsonEncode(data));
    }

    if (null != message) {
      log.message = message;
    }

    addLog(log, status);
  }

  static void addLog(LogModel log, String status) {
    if (status != "none") {
      //NOT Action log
      DateTime createdTime =
          DateTime.fromMillisecondsSinceEpoch(log.createdTime);
      DateTime responseTime = DateTime.now();

      Duration diff = responseTime.difference(createdTime);

      if (diff.inSeconds < 1) {
        log.responseTime = 1;
      } else {
        log.responseTime = diff.inSeconds;
      }
    }
    log.status = status;

    //Convert log into string before write into file
    String logString = convertLogModelToJson(log);
    writeLogIntoFile(logString);
  }

  static String convertLogModelToJson(LogModel log) {
    final String jsonString = jsonEncode(log);
    return jsonString;
  }

  static void writeLogIntoFile(String logString) async {
    String folderPath = await FileStorageHelper.getExternalDocumentPath();
    String path = "$folderPath/flutter_logs.txt";
    if (kDebugMode) {
      print("DEBUG: log file path = $path");
    }
    File file;

    bool isExistFile = await File(path).exists();

    if (isExistFile) {
      file = File(path);
      await file.writeAsString("\n", mode: FileMode.append);
    } else {
      file = await File(path).create();
    }

    try {
      await file.writeAsString(logString, mode: FileMode.append);
      if (kDebugMode) {
        print("DEBUG: write log into file success");
      }
    } catch (e) {
      if (kDebugMode) {
        print("DEBUG: write log into file failed");
      }
    }
  }

  //Check file is exist using file_storage
  static Future<bool> isExist(String fileName, MediaType mediaType) async {
    bool isExist =
        await FileStorageHelper.checkExistFile(fileName, mediaType, null);
    return isExist;
  }

  static int getDateTimeNow() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  static String getPreviousAction(BuildContext context) {
    String previousAction = "";
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    previousAction = authProvider.previousAction;
    return previousAction;
  }

  static void setPreviousAction(BuildContext context, String action) {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    authProvider.setPreviousAction(action);
  }

  static Future<LogModel> prepareToCreateLog(BuildContext context,
      {required String action}) async {
    String previousAction = getPreviousAction(context);
    LogModel log = await createLog(
        action: action,
        previousAction: previousAction,
        status: "",
        message: "",
        data: {});
    setPreviousAction(context, action);

    return log;
  }

  static Future<void> deleteLogFile() async {
    //Check logs file is exist
    String folderPath = await FileStorageHelper.getExternalDocumentPath();
    String path = "$folderPath/flutter_logs.txt";
    File file = File(path);

    try {
      if (await file.exists()) {
        await file.delete();
        if (kDebugMode) {
          print("DEBUG: Delete log file success");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("DEBUG: Delete log file error: ${e.toString()}");
      }
    }
  }

  static void showConnectionErrorDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: Utils.multiLanguage(StringConstants.dialog_title),
          description:
              Utils.multiLanguage(StringConstants.network_error_message),
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

  static Future<bool> checkVideoFileExist(
      String path, MediaType mediaType) async {
    bool result = await File(path).exists();
    return result;
  }

  static int getBeingOutTimeInSeconds(DateTime startTime, DateTime endTime) {
    Duration diff = endTime.difference(startTime);
    return diff.inSeconds;
  }

  static void addConnectionErrorLog(BuildContext context) async {
    LogModel? log;
    if (context.mounted) {
      log = await prepareToCreateLog(context, action: LogEvent.checkConnection);
    }

    //Add log
    prepareLogData(
      log: log,
      data: null,
      message:
          Utils.multiLanguage(StringConstants.log_connection_error_message),
      status: LogEvent.failed,
    );
  }

  static Future<String> getLocalImagePath(String fileName) async {
    String folderPath = await FileStorageHelper.getExternalDocumentPath();
    String filePath = "$folderPath/$fileName";
    if (kDebugMode) {
      print("DEBUG: load image from local: $filePath");
    }
    bool isExist = await checkImageFileExist(fileName);
    if (isExist) {
      return filePath;
    }

    return "";
  }

  static Future<bool> checkImageFileExist(String fileName) async {
    String folderPath = await FileStorageHelper.getExternalDocumentPath();
    String filePath = "$folderPath/$fileName";
    bool result = await File(filePath).exists();
    return result;
  }

  static double fixSizeOfText({
    required BuildContext context,
    required double fontSize,
  }) {
    MediaQueryData queryData = MediaQuery.of(context);
    double customFontSize = fontSize;
    double textScaleFactor = queryData.textScaleFactor;
    double adjustedFontSize = customFontSize / textScaleFactor;
    return adjustedFontSize;
  }

  static void sendLog() async {
    if (Platform.isIOS) {
      const MethodChannel channel = MethodChannel('nativeChannel');
      String apiUrl = await AppSharedPref.instance()
          .getString(key: AppSharedKeys.logApiUrl);
      String secretkey = await AppSharedPref.instance()
          .getString(key: AppSharedKeys.secretkey);
      String folderPath = await FileStorageHelper.getExternalDocumentPath();
      String filePath = "$folderPath/flutter_logs.txt";

      if (apiUrl.isEmpty || secretkey.isEmpty || filePath.isEmpty) {
        return;
      }

      channel.invokeMethod('com.csupporter.sendlogtask', {
        StringConstants.k_api_url: apiUrl,
        StringConstants.k_secretkey: secretkey,
        StringConstants.k_file_path: filePath,
      });
    } else {
      Workmanager().registerOneOffTask(
        sendLogsTask,
        sendLogsTask,
      );
    }
  }

  static void testCrashBug() {
    int result = 5 ~/ 0;
    if (kDebugMode) {
      print(result);
    }
  }

  //Firebase log
  static void addFirebaseLog({
    required String eventName,
    required Map<String, Object> parameters,
  }) {
    analytics.logEvent(name: eventName, parameters: parameters);
  }

  static Future<String> createNewFilePath(String fileName) async {
    String folderPath = await FileStorageHelper.getExternalDocumentPath();
    String path = "$folderPath/$fileName";
    return path;
  }

  static String convertActivityStatusToMulti(String status) {
    String rs = "";
    String temp = "";

    switch (status) {
      case "Select All":
        {
          temp = "select_all";
          break;
        }
      case "Out Of Date":
        {
          temp = "activity_status_out_of_date";
          break;
        }
      case "Not Completed":
        {
          temp = "activity_status_not_completed";
          break;
        }
      case "Corrected":
        {
          temp = "activity_status_corrected";
          break;
        }
      case "Submitted":
        {
          temp = "activity_status_submitted";
          break;
        }
      case "Late":
        {
          temp = "activity_status_late";
          break;
        }
      case " AI Scored":
        {
          temp = "activity_status_ai_scored";
          break;
        }
      case "Loaded Test":
        {
          temp = "activity_status_loaded_test";
          break;
        }
    }

    if (temp.isNotEmpty) {
      rs = multiLanguage(temp);
    }

    return rs;
  }

  static Future<bool> checkInternetConnection() async {
    return await InternetConnectionChecker().hasConnection;
  }

  static String getRatingText(double rate) {
    String ratingText = "Very Good";
    if (rate >= 0 && rate <= 2.5) {
      ratingText = "Bad";
    } else if (rate < 4.5) {
      ratingText = "Good";
    }
    return ratingText;
  }

  static String generateTitle(MyPracticeTestModel myPracticeTestModel) {
    String title = "";
    title = "${myPracticeTestModel.bankTitle}(#${myPracticeTestModel.id})";
    return title;
  }

  static double generateScore(MyPracticeTestModel myPracticeTestModel) {
    if (myPracticeTestModel.aiScore <= 0.0) {
      if (myPracticeTestModel.overallScore <= 0.0) {
        return 0.0;
      } else {
        return myPracticeTestModel.overallScore;
      }
    } else {
      if (myPracticeTestModel.overallScore <= 0.0) {
        return myPracticeTestModel.aiScore;
      } else {
        if (myPracticeTestModel.overallScore >= myPracticeTestModel.aiScore) {
          return myPracticeTestModel.overallScore;
        } else {
          return myPracticeTestModel.aiScore;
        }
      }
    }
  }
}
