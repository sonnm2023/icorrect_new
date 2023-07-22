import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constant_strings.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences_keys.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/models/homework_models/homework_model.dart';
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

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

  static Map<String, dynamic> getHomeWorkStatus(HomeWorkModel homeWorkModel) {
    switch (homeWorkModel.completeStatus) {
      case 1:
        return {
          'title': 'Submitted',
          'color': const Color.fromARGB(255, 45, 117, 243)
        };
      case 2:
        return {
          'title': 'Corrected',
          'color': const Color.fromARGB(255, 12, 201, 110)
        };
      case 0:
        return {
          'title': 'Not Completed',
          'color': const Color.fromARGB(255, 237, 179, 3)
        };
      case -1:
        return {
          'title': 'Late',
          'color': Colors.orange,
        };
      case -2:
        return {
          'title': 'Out of date',
          'color': Colors.red,
        };
      default:
        return {};
    }
  }

  static String haveAiResponse(HomeWorkModel homeWorkModel) {
    return (homeWorkModel.haveAiReponse == Status.trueStatus.get)
        ? '& AI Scored'
        : '';
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
        await FileStorageHelper.getFilePath(fileName, MediaType.video);

    if (decodedBytes.isEmpty) {
      //From second time and before
      decodedVideoFile = File(filePath);
    } else {
      //Convert for first time
      decodedVideoFile = await File(filePath).writeAsBytes(decodedBytes);
    }
    return decodedVideoFile;
  }

  static Future<File> prepareAudioFile(String fileName) async {
    File decodedVideoFile;
    String bs4str =
        await FileStorageHelper.readVideoFromFile(fileName, MediaType.audio);
    Uint8List decodedBytes = base64.decode(bs4str);
    String filePath =
        await FileStorageHelper.getFilePath(fileName, MediaType.audio);
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
        // return 1; //For test
        return 30;
      case 1: //Answer for question in part 1
        // return 1; //For test
        return 30;
      case 2: //Answer for question in part 2
        // return 10; //For test
        return 120;
      case 3: //Answer for question in part 3
        // return 3; //For test
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
}
