// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/connectivity_service.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences_keys.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/new_class_model.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:icorrect/src/presenters/homework_presenter.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/views/widget/drawer_items.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_asset.dart';
import '../../core/app_color.dart';
import '../models/my_test_models/student_result_model.dart';
import '../models/ui_models/user_authen_status.dart';
import '../provider/homework_provider.dart';
import '../views/screen/other_views/dialog/custom_alert_dialog.dart';
import 'api_urls.dart';
import 'package:path_provider/path_provider.dart';

class Utils {
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
    if (null == homeWorkModel.activityAnswer) {
      bool timeCheck =
          isExpired(homeWorkModel.activityEndTime, serverCurrentTime);
      if (timeCheck) {
        return {
          'title': 'Out of date',
          'color': Colors.red,
        };
      }

      return {
        'title': 'Not Completed',
        'color': const Color.fromARGB(255, 237, 179, 3)
      };
    } else {
      if (homeWorkModel.activityAnswer!.orderId != 0) {
        return {
          'title': 'Corrected',
          'color': const Color.fromARGB(255, 12, 201, 110)
        };
      } else {
        if (homeWorkModel.activityAnswer!.late == 0) {
          return {
            'title': 'Submitted',
            'color': const Color.fromARGB(255, 45, 117, 243)
          };
        }

        if (homeWorkModel.activityAnswer!.late == 1) {
          return {
            'title': 'Late',
            'color': Colors.orange,
          };
        }

        if (homeWorkModel.activityEndTime.isNotEmpty) {
          DateTime endTime = DateTime.parse(homeWorkModel.activityEndTime);
          DateTime createTime =
              DateTime.parse(homeWorkModel.activityAnswer!.createdAt);
          if (endTime.compareTo(createTime) < 0) {
            return {
              'title': 'Out of date',
              'color': Colors.red,
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
          return " AI Scored";
        }
      }
    }
    return '';
  }

  static int getFilterStatus(String status) {
    switch (status) {
      case 'Submitted':
        return 1;
      case 'Corrected':
        return 2;
      case 'Not Completed':
        return 0;
      case 'Late':
        return -1;
      case 'Out of date':
        return -2;
      default:
        return -10;
    }
  }

  static Map<String, dynamic> scoreReponse(StudentResultModel resultModel) {
    if (resultModel.overallScore.isNotEmpty &&
        resultModel.overallScore != "0.0") {
      return {'color': Colors.green, 'score': resultModel.overallScore};
    } else {
      String aiScore = resultModel.aiScore;
      if (aiScore.isNotEmpty) {
        if (isNumeric(aiScore) &&
            (double.parse(aiScore) == -1.0 || double.parse(aiScore) == -2.0)) {
          return {'color': Colors.red, 'score': 'Not Evaluated'};
        } else {
          return {'color': Colors.blue, 'score': aiScore};
        }
      } else {
        return {'color': Colors.red, 'score': 'Not Evaluated'};
      }
    }
  }

  static bool isNumeric(String str) {
    try {
      var value = double.parse(str);
    } on FormatException {
      return false;
    } finally {
      return true;
    }
  }

  static UserAuthenStatusUI getUserAuthenStatus(int status) {
    switch (status) {
      case 0:
        return UserAuthenStatusUI(
            title: StringConstants.not_auth_title,
            description: StringConstants.not_auth_content,
            icon: Icons.cancel_outlined,
            backgroundColor: const Color.fromARGB(255, 248, 179, 179),
            titleColor: Colors.red,
            iconColor: Colors.red);
      case 4:
        return UserAuthenStatusUI(
            title: StringConstants.reject_auth_title,
            description: StringConstants.reject_auth_content,
            icon: Icons.video_camera_front_outlined,
            backgroundColor: const Color.fromARGB(255, 248, 233, 179),
            titleColor: Colors.amber,
            iconColor: Colors.amber);
      case 1:
        return UserAuthenStatusUI(
            title: StringConstants.user_authed_title,
            description: StringConstants.user_authed_content,
            icon: Icons.check_circle_outline_rounded,
            backgroundColor: const Color.fromARGB(255, 179, 248, 195),
            titleColor: Colors.green,
            iconColor: Colors.green);
      case 3:
        return UserAuthenStatusUI(
            title: StringConstants.progress_auth_title,
            description: StringConstants.progress_auth_content,
            icon: Icons.change_circle_sharp,
            backgroundColor: const Color.fromARGB(255, 179, 222, 248),
            titleColor: Colors.blue,
            iconColor: Colors.blue);
      case 2:
        return UserAuthenStatusUI(
            title: StringConstants.lock_auth_title,
            description: StringConstants.lock_auth_content,
            icon: Icons.lock,
            backgroundColor: const Color.fromARGB(255, 248, 179, 179),
            titleColor: Colors.red,
            iconColor: Colors.red);
      case 99:
      default:
        return UserAuthenStatusUI(
            title: StringConstants.error_auth_title,
            description: StringConstants.error_auth_content,
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

    // File decodedVideoFile;
    // String bs4str =
    //     await FileStorageHelper.readVideoFromFile(fileName, MediaType.video);
    // Uint8List decodedBytes = base64.decode(bs4str);
    // String filePath =
    //     await FileStorageHelper.getFilePath(fileName, MediaType.video, null);
    //
    // if (decodedBytes.isEmpty) {
    //   //From second time and before
    //   decodedVideoFile = File(filePath);
    // } else {
    //   //Convert for first time
    //   decodedVideoFile = await File(filePath).writeAsBytes(decodedBytes);
    // }
    // return decodedVideoFile;
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

  static Future<String> getPathToRecordReAnswer(
      QuestionTopicModel question, String? testId) async {
    String fileName = '';
    if (question.answers.length > 1) {
      if (question.repeatIndex == 0) {
        fileName = question.answers.last.url;
      } else {
        fileName = question.answers.elementAt(question.repeatIndex - 1).url;
      }
    } else {
      fileName = question.answers.first.url;
    }

    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    String path = "${appDocDirectory.path}/$fileName.wav";
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

  //huy copied functions

  static Widget navbar({
    required BuildContext context,
    required HomeWorkPresenter? homeWorkPresenter,
  }) {
    return Drawer(
      backgroundColor: AppColor.defaultWhiteColor,
      child:
          navbarItems(context: context, homeWorkPresenter: homeWorkPresenter),
    );
  }

  static Widget drawHeader(UserDataModel user) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: CustomSize.size_30,
        horizontal: CustomSize.size_10,
      ),
      color: AppColor.defaultPurpleColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: CustomSize.size_60,
            height: CustomSize.size_60,
            child: CircleAvatar(
              child: Consumer<HomeWorkProvider>(
                  builder: (context, homeWorkProvider, child) {
                return CachedNetworkImage(
                  imageUrl:
                      fileEP(homeWorkProvider.currentUser.profileModel.avatar),
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(CustomSize.size_100),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                        colorFilter: const ColorFilter.mode(
                          Colors.transparent,
                          BlendMode.colorBurn,
                        ),
                      ),
                    ),
                  ),
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => CircleAvatar(
                    child: Image.asset(
                      AppAsset.defaultAvt,
                      width: CustomSize.size_40,
                      height: CustomSize.size_40,
                    ),
                  ),
                );
              }),
            ),
          ),
          Container(
            width: CustomSize.size_200,
            margin: const EdgeInsets.symmetric(
              horizontal: CustomSize.size_10,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: CustomSize.size_10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.profileModel.displayName.toString(),
                  style: CustomTextStyle.textWhiteBold_15,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                //TODO: Cần check kỹ và giải thích cho việc dùng các gói VIP ...
                /*
                const SizedBox(height: CustomSize.size_5),
                Row(
                  children: [
                    Text(
                      "Dimond: ${user.profileModel.wallet.usd.toString()}",
                      style: CustomTextStyle.textWhite_14,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: CustomSize.size_10,
                      ),
                      child: const Image(
                        width: CustomSize.size_20,
                        image: AssetImage(AppAsset.dimond),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: CustomSize.size_5),
                Row(
                  children: [
                    Text(
                      "Gold: ${user.profileModel.pointTotal.toString()}",
                      style: CustomTextStyle.textWhite_14,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: CustomSize.size_10,
                      ),
                      child: const Image(
                        width: CustomSize.size_20,
                        image: AssetImage(
                          AppAsset.gold,
                        ),
                      ),
                    ),
                  ],
                ),
                */
              ],
            ),
          )
        ],
      ),
    );
  }

  static void toggleDrawer() async {
    if (GlobalKey<ScaffoldState>().currentState != null) {
      if (GlobalKey<ScaffoldState>().currentState!.isDrawerOpen) {
        GlobalKey<ScaffoldState>().currentState!.openEndDrawer();
      } else {
        GlobalKey<ScaffoldState>().currentState!.openDrawer();
      }
    }
  }

  static void showLogoutConfirmDialog({
    required BuildContext context,
    required HomeWorkPresenter? homeWorkPresenter,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: "Notification",
          description: "Do you want to logout?",
          okButtonTitle: "OK",
          cancelButtonTitle: "Cancel",
          borderRadius: 8,
          hasCloseButton: false,
          okButtonTapped: () async {
            if (null != homeWorkPresenter) {
              var connectivity =
                  await ConnectivityService().checkConnectivity();
              if (connectivity.name != "none") {
                homeWorkPresenter.logout(context);
              } else {
                //Show connect error here
                if (kDebugMode) {
                  print("DEBUG: Connect error here!");
                }
                Utils.showConnectionErrorDialog(context);

                Utils.addConnectionErrorLog(context);
              }
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
      log.addData(key: "data", value: jsonEncode(data));
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
          title: StringConstants.dialog_title,
          description: StringConstants.network_error_message,
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
      log = await prepareToCreateLog(context,
          action: LogEvent.checkConnection);
    }

    //Add log
    prepareLogData(
      log: log,
      data: null,
      message: StringConstants.log_connection_error_message,
      status: LogEvent.failed,
    );
  }

  static Future<String> getLocalImagePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
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
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    bool result = await File(filePath).exists();
    return result;
  }
}
