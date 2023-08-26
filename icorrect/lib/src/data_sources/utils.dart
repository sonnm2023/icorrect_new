import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences_keys.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/new_class_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:icorrect/src/views/widget/drawer_items.dart';
import 'package:provider/provider.dart';

import '../../core/app_asset.dart';
import '../../core/app_color.dart';
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
    String os = "unknown";

    if (Platform.isAndroid) {
      os = "android";
    } else if (Platform.isIOS) {
      os = "ios";
    } else if (kIsWeb) {
      os = "web";
    } else if (Platform.isLinux) {
      os = "linux";
    } else if (Platform.isMacOS) {
      os = "macos";
    } else if (Platform.isWindows) {
      os = "window";
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

  static Map<String, dynamic> getHomeWorkStatus(ActivitiesModel homeWorkModel) {
    if (null == homeWorkModel.activityAnswer) {
      //TODO: Check time end so voi time hien tai
      //Can server tra ve time hien tai - de thong nhat, do phai check timezone
      //End time > time hien tai ==> out of date
      //End time < time hien tai ==> Not Complete
      return {
        'title': 'Not Completed',
        'color': const Color.fromARGB(255, 237, 179, 3)
      };
    } else {
      if (homeWorkModel.activityAnswer!.aiOrder != 0 ||
          homeWorkModel.activityAnswer!.orderId != 0) {
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
      if (homeWorkModel.activityAnswer!.aiResponseLink.isNotEmpty) {
        return "& AI Scored";
      } else {
        return '';
      }
    } else {
      return '';
    }
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
    String letter = '/';
    String newLetter = '-';
    if (nameFile.contains(letter)) {
      nameFile = nameFile.replaceAll(letter, newLetter);
    }

    return nameFile;
  }

  static String reConvertFileName(String nameFile) {
    String letter = '-';
    String newLetter = '/';
    if (nameFile.contains(letter)) {
      nameFile = nameFile.replaceAll(letter, newLetter);
    }

    return nameFile;
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
    File decodedVideoFile;
    String bs4str =
        await FileStorageHelper.readVideoFromFile(fileName, MediaType.video);
    Uint8List decodedBytes = base64.decode(bs4str);
    String filePath =
        await FileStorageHelper.getFilePath(fileName, MediaType.video, null);

    if (decodedBytes.isEmpty) {
      //From second time and before
      decodedVideoFile = File(filePath);
    } else {
      //Convert for first time
      decodedVideoFile = await File(filePath).writeAsBytes(decodedBytes);
    }
    return decodedVideoFile;
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
        fileName = question.answers.last.url;
      } else {
        fileName = question.answers.elementAt(question.repeatIndex - 1).url;
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

  static Widget navbar(BuildContext context) {
    return Drawer(
      backgroundColor: AppColor.defaultWhiteColor,
      child: navbarItems(context),
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

  static void showLogoutConfirmDialog(BuildContext context) async {
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
          okButtonTapped: () {
            Navigator.of(context).pop();
          },
          cancelButtonTapped: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
