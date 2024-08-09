import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data_source/constants.dart';
import '../data_source/dependency_injection.dart';
import '../data_source/local/app_shared_preferences_keys.dart';
import '../data_source/local/app_shared_references.dart';
import '../data_source/repositories/auth_repository.dart';
import '../models/app_config_info_models/app_config_info_model.dart';
import '../models/auth_models/auth_model.dart';
import '../models/auth_models/class_merchant_model.dart';
import '../models/auth_models/student_merchant_model.dart';
import '../models/auth_models/verify_model.dart';
import '../models/log_models/log_model.dart';
import '../models/user_data_models/user_data_model.dart';
import '../utils/utils.dart';
import 'package:http/http.dart' as http;

abstract class LoginViewContract {
  void onLoginComplete();
  void onLoginError(String message);
  void onVerifyComplete(String merchantID);
  void onVerifyError(String message);
  void onGetListClassComplete(List<ClassModel> list, int lastPage, int totalClass);
  void onGetListClassError(String message);
  void onGetListStudentComplete(List<StudentModel> list);
  void onGetListStudentError(String message);
  void onVerifyConfigComplete();
  void onVerifyConfigError(String message);
  void onChangeDeviceNameComplete(String msg);
  void onChangeDeviceNameError(String msg);
}

class LoginPresenter {
  final LoginViewContract? _view;
  AuthRepository? _repository;
  LoginPresenter(this._view) {
    _repository = Injector().getAuthRepository();
  }

  Future<void> loginWithClassID(BuildContext context, String userId, String classID) async{
    assert(_view != null && _repository != null);
    String? licenseKey = await Utils.instance().getLicenseKey();
    String? merchantID = await Utils.instance().getMerchantID();
    LogModel? log;
    if (context.mounted) {
      log  =await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiLoginClassID);
    }

    String checksum = await Utils.instance().convertHMacSha256(param1: classID, param2: merchantID, param3: userId);
    _repository!.loginWithClassID(userId, classID, licenseKey!, merchantID!, checksum).then((value) async {
      AuthModel authModel = AuthModel.fromJson(jsonDecode(value));
      print(value);
      if (authModel.errorCode == 200) {
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: authModel.message,
          status: LogEvent.success,
        );
        await _saveAccessToken(authModel.data.accessToken);
        // ignore: use_build_context_synchronously
        _getUserInfo(context);
        // _view!.onLoginComplete();
      } else if (authModel.errorCode == 401) {
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: authModel.status,
          status: LogEvent.success,
        );
        _view!.onLoginError(authModel.status);
      } else {
        if (authModel.message.isNotEmpty) {
          _view!.onLoginError(authModel.message);
          //Add log
          Utils.instance().prepareLogData(
            log: log,
            data: jsonDecode(value),
            message: StringConstants.network_error_message,
            status: LogEvent.failed,
          );
        } else {
          _view!.onLoginError(Utils.instance()
              .multiLanguage(StringConstants.network_error_message));
          //Add log
          Utils.instance().prepareLogData(
            log: log,
            data: jsonDecode(value),
            message: '${authModel.errorCode}: ${authModel.status}',
            status: LogEvent.failed,
          );
        }
      }
    }).catchError((onError) {
      if (onError is http.ClientException || onError is SocketException) {
        _view!.onLoginError(Utils.instance()
            .multiLanguage(StringConstants.network_error_message));
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: null,
          message: StringConstants.network_error_message,
          status: LogEvent.failed,
        );
      } else {
        _view!.onLoginError(Utils.instance()
            .multiLanguage(StringConstants.network_error_message));
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: null,
          message: StringConstants.network_error_message,
          status: LogEvent.failed,
        );
      }
    });
  }

  Future<void> login(
      BuildContext context, String email, String password) async {
    assert(_view != null && _repository != null);

    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiLogin);
    }

    _repository!.login(email, password).then((value) async {
      AuthModel authModel = AuthModel.fromJson(jsonDecode(value));
      if (authModel.errorCode == 200) {
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: authModel.message,
          status: LogEvent.success,
        );
        await _saveAccessToken(authModel.data.accessToken);
        // ignore: use_build_context_synchronously
        _getUserInfo(context);
      } else if (authModel.errorCode == 401) {
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: authModel.status,
          status: LogEvent.success,
        );
        _view!.onLoginError(authModel.status);
      } else {
        if (authModel.message.isNotEmpty) {
          _view!.onLoginError(Utils.instance()
              .multiLanguage(StringConstants.network_error_message));
          //Add log
          Utils.instance().prepareLogData(
            log: log,
            data: jsonDecode(value),
            message: StringConstants.network_error_message,
            status: LogEvent.failed,
          );
        } else {
          _view!.onLoginError(Utils.instance()
              .multiLanguage(StringConstants.network_error_message));
          //Add log
          Utils.instance().prepareLogData(
            log: log,
            data: jsonDecode(value),
            message: '${authModel.errorCode}: ${authModel.status}',
            status: LogEvent.failed,
          );
        }
      }
    }).catchError((onError) {
      if (onError is http.ClientException || onError is SocketException) {
        _view!.onLoginError(Utils.instance()
            .multiLanguage(StringConstants.network_error_message));
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: null,
          message: StringConstants.network_error_message,
          status: LogEvent.failed,
        );
      } else {
        _view!.onLoginError(Utils.instance()
            .multiLanguage(StringConstants.network_error_message));
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: null,
          message: StringConstants.network_error_message,
          status: LogEvent.failed,
        );
      }
    });
  }

  Future<void> _saveAccessToken(String token) async {
    AppSharedPref.instance()
        .putString(key: AppSharedKeys.apiToken, value: token);
  }

  void _getUserInfo(BuildContext context) async {
    assert(_view != null && _repository != null);

    String deviceId = await Utils.instance().getDeviceIdentifier();
    String appVersion = await Utils.instance().getAppVersion();
    String os = await Utils.instance().getOS();
    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiGetUserInfo);
    }
    _repository!.getUserInfo(deviceId, appVersion, os).then((value) async {
      Map<String, dynamic> dataMap = jsonDecode(value);
      print(value);
      if (dataMap['error_code'] == 200) {
        UserDataModel userDataModel = UserDataModel.fromJson(dataMap['data']);
        Utils.instance().setCurrentUser(userDataModel);
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: null,
          status: LogEvent.success,
        );
        _view!.onLoginComplete();
      } else {
        Utils.instance().prepareLogData(
          log: log,
          data: jsonDecode(value),
          message:
              "GetUserInfo error: ${dataMap[StringConstants.k_error_code]}${dataMap[StringConstants.k_status]}",
          status: LogEvent.failed,
        );

        _view!.onLoginError(
            "${Utils.instance().multiLanguage(StringConstants.login_error_title)}:"
            "${dataMap['error_code']}${dataMap['status']}");
      }
    }).catchError(
      (onError) {
        Utils.instance().prepareLogData(
          log: log,
          data: null,
          message: onError.toString(),
          status: LogEvent.failed,
        );
        _view!.onLoginError(onError.toString());
      },
    );
  }

  Future verify(BuildContext context, String licenseKey, String deviceName) async {
    assert(_view != null && _repository != null);

    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiVerify);
    }

    try {
      String deviceID = await Utils.instance().getDeviceIdentifier();
      await _saveDeviceID(deviceID);

      _repository!.verifyDevice(licenseKey, deviceID, deviceName).then((value) async {
        VerifyModel verifyModel = VerifyModel.fromJson(jsonDecode(value));
        if (verifyModel.errorCode == 200) {
          Utils.instance().prepareLogData(
              log: log,
              data: jsonDecode(value),
              message: 'success',
              status: LogEvent.success
          );
          await _saveMerchantID(verifyModel.data!.merchantId);
          await _saveLicenseKey(licenseKey);
          await _saveDeviceName(deviceName);
          _view!.onVerifyComplete(verifyModel.data!.merchantId);
        } else if (verifyModel.errorCode == 400) {
          Utils.instance().prepareLogData(
              log: log,
              data: jsonDecode(value),
              message: verifyModel.messages,
              status: LogEvent.failed
          );
          _view!.onVerifyError(verifyModel.messages!);
        }
        else if (verifyModel.errorCode == 401) {
          Utils.instance().prepareLogData(
              log: log,
              data: jsonDecode(value),
              message: verifyModel.messages,
              status: LogEvent.failed
          );
          _view!.onVerifyError(verifyModel.messages!);
        } else {
          Utils.instance().prepareLogData(
              log: log,
              data: jsonDecode(value),
              message: StringConstants.network_error_message,
              status: LogEvent.failed
          );
          _view!.onVerifyError(verifyModel.messages!);
        }
      }).catchError((onError) {
        _view!.onVerifyError(Utils.instance().multiLanguage(StringConstants.network_error_message));
      });
    } on TimeoutException {
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: StringConstants.time_out_error_message,
        status: LogEvent.failed,
      );
      _view!.onVerifyError(Utils.instance()
          .multiLanguage(StringConstants.time_out_error_message));
    } on http.ClientException {
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: StringConstants.client_error_message,
        status: LogEvent.failed,
      );
      _view!.onVerifyError(
          Utils.instance().multiLanguage(StringConstants.client_error_message));
    } on SocketException {
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: StringConstants.socket_error_message,
        status: LogEvent.failed,
      );
      _view!.onVerifyError(
          Utils.instance().multiLanguage(StringConstants.socket_error_message));
    }
  }

  Future _saveDeviceID(String id) async {
    AppSharedPref.instance().putString(key: AppSharedKeys.deviceID, value: id);
  }

  Future _saveLicenseKey(String key) async {
    AppSharedPref.instance()
        .putString(key: AppSharedKeys.licenseKey, value: key);
  }

  Future _saveDeviceName(String deviceName) async {
    AppSharedPref.instance().putString(key: AppSharedKeys.deviceName, value: deviceName);
  }

  Future _saveMerchantID(String merchantID)  async {
    AppSharedPref.instance()
        .putString(key: AppSharedKeys.merchantID, value: merchantID);
  }

  void getListClass(BuildContext context, int page) async {
    assert(_view != null && _repository != null);

    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiGetListClass);
    }
    try {

      String? merchantID = await Utils.instance().getMerchantID();
      String checksum = await Utils.instance().convertHMacSha256(param1: merchantID, param2: page.toString());
      _repository!.getListClass(merchantID!, checksum, page).then((value) {
        print(value);
        ClassMerchantModel classMerchantModel = ClassMerchantModel.fromJson(jsonDecode(value));
        if (classMerchantModel.errorCode == 200) {
          List<ClassModel> classes = classMerchantModel.data!.data!;
          Utils.instance().prepareLogData(
              log: log,
              data: jsonDecode(value),
              message: classMerchantModel.message,
              status: LogEvent.success
          );
          _view!.onGetListClassComplete(classes, classMerchantModel.data!.lastPage!, classMerchantModel.data!.total!);
        } else {
          if (classMerchantModel.message!.isNotEmpty) {
            Utils.instance().prepareLogData(
                log: log,
                data: jsonDecode(value),
                message: classMerchantModel.message,
                status: LogEvent.failed
            );
          } else {
            Utils.instance().prepareLogData(
                log: log,
                data: jsonDecode(value),
                message: StringConstants.network_error_message,
                status: LogEvent.failed
            );
          }
          _view!.onGetListClassError('Có lỗi xảy ra trong quá trình tải danh sách lớp, xin vui lòng liên hệ đội ngũ hỗ trợ! \n ${classMerchantModel.message!}');
        }
      }).catchError((onError) {
        _view!.onGetListClassError(Utils.instance()
            .multiLanguage(StringConstants.network_error_message));
      });
    } on TimeoutException {
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: StringConstants.time_out_error_message,
        status: LogEvent.failed,
      );
      _view!.onGetListClassError(Utils.instance()
          .multiLanguage(StringConstants.time_out_error_message));
    } on http.ClientException {
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: StringConstants.client_error_message,
        status: LogEvent.failed,
      );
      _view!.onGetListClassError(
          Utils.instance().multiLanguage(StringConstants.client_error_message));
    } on SocketException {
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: StringConstants.socket_error_message,
        status: LogEvent.failed,
      );
      _view!.onGetListClassError(
          Utils.instance().multiLanguage(StringConstants.socket_error_message));
    }
  }

  void getListStudent(BuildContext context) async {
    assert(_view != null && _repository != null);

    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiGetListStudent);
    }
    try {
      String classID = await AppSharedPref.instance().getString(key: AppSharedKeys.classID);
      String? merchantID = await Utils.instance().getMerchantID();
      String checksum = await Utils.instance().convertHMacSha256(param1: merchantID);
      _repository!.getListStudent(merchantID!, int.parse(classID), checksum).then((value) {
        StudentMerchantModel model = StudentMerchantModel.fromJson(jsonDecode(value));
        if (model.errorCode == 200) {
          List<StudentModel> students = model.data!;
          Utils.instance().prepareLogData(
              log: log,
              data: jsonDecode(value),
              message: 'success',
              status: LogEvent.success
          );
          _view!.onGetListStudentComplete(students);
        } else {
          if (model.messages!.isNotEmpty) {
            Utils.instance().prepareLogData(
                log: log,
                data: jsonDecode(value),
                message: model.messages,
                status: LogEvent.success
            );
          } else {
            Utils.instance().prepareLogData(
                log: log,
                data: jsonDecode(value),
                message: model.status,
                status: LogEvent.failed
            );
          }
          _view!.onGetListStudentError('Có lỗi xảy ra trong quá trình tải danh sách học sinh, xin vui lòng liên hệ đội ngũ hỗ trợ. \n ${model.messages!}');
        }
      }).catchError((onError) {
        _view!.onGetListStudentError(Utils.instance().multiLanguage(StringConstants.network_error_message));
      });
    } on TimeoutException {
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: StringConstants.time_out_error_message,
        status: LogEvent.failed,
      );
      _view!.onGetListStudentError(Utils.instance()
          .multiLanguage(StringConstants.time_out_error_message));
    } on http.ClientException {
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: StringConstants.client_error_message,
        status: LogEvent.failed,
      );
      _view!.onGetListStudentError(
          Utils.instance().multiLanguage(StringConstants.client_error_message));
    } on SocketException {
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: StringConstants.socket_error_message,
        status: LogEvent.failed,
      );
      _view!.onGetListStudentError(
          Utils.instance().multiLanguage(StringConstants.socket_error_message));
    } on Exception {
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: StringConstants.client_error_message,
        status: LogEvent.failed,
      );
      _view!.onGetListStudentError(
          Utils.instance().multiLanguage(StringConstants.client_error_message));
    }
  }

  Future verifyConfig(BuildContext context, String key) async {
    assert(_view != null && _repository != null);

    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiVerifyConfig);
    }

    try {
      String deviceID = await Utils.instance().getDeviceIdentifier();
      String? merchantID = await Utils.instance().getMerchantID();
      String checksum = await Utils.instance().convertHMacSha256(param1: deviceID, param2: key, param3: merchantID!);
      _repository!.verifyConfig(key, deviceID, checksum, merchantID).then((value) async {
        VerifyModel verifyModel = VerifyModel.fromJson(jsonDecode(value));
        if (verifyModel.errorCode == 200) {
          Utils.instance().prepareLogData(
              log: log,
              data: jsonDecode(value),
              message: 'success',
              status: LogEvent.success
          );
          _view!.onVerifyConfigComplete();
        } else if (verifyModel.errorCode == 401) {
          Utils.instance().prepareLogData(
              log: log,
              data: jsonDecode(value),
              message: verifyModel.messages,
              status: LogEvent.failed
          );
          _view!.onVerifyConfigError(verifyModel.messages!);
        } else {
          Utils.instance().prepareLogData(
              log: log,
              data: jsonDecode(value),
              message: StringConstants.network_error_message,
              status: LogEvent.failed
          );
          _view!.onVerifyConfigError(verifyModel.messages!);
        }
      }).catchError((onError) {
        _view!.onVerifyConfigError(onError.toString());
      });
    } on TimeoutException {
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: StringConstants.time_out_error_message,
        status: LogEvent.failed,
      );
      _view!.onVerifyConfigError(Utils.instance()
          .multiLanguage(StringConstants.time_out_error_message));
    } on http.ClientException {
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: StringConstants.client_error_message,
        status: LogEvent.failed,
      );
      _view!.onVerifyConfigError(
          Utils.instance().multiLanguage(StringConstants.client_error_message));
    } on SocketException {
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: StringConstants.socket_error_message,
        status: LogEvent.failed,
      );
      _view!.onVerifyConfigError(
          Utils.instance().multiLanguage(StringConstants.socket_error_message));
    }
  }

  Future changeDeviceName(BuildContext context, String deviceName) async {
    assert(_view != null && _repository != null);

    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiChangeDeviceName);
    }
    String? merchantID = await Utils.instance().getMerchantID();
    String deviceID = await Utils.instance().getDeviceIdentifier();
    deviceID = deviceID.replaceAll('{', '');
    deviceID = deviceID.replaceAll('}', '');
    String checksum = await Utils.instance().convertHMacSha256(param1: deviceName, param2: merchantID);
    _repository!.changeDeviceName(deviceID, deviceName, merchantID!, checksum).then((value) async {
      VerifyModel verifyModel = VerifyModel.fromJson(jsonDecode(value));
      if (verifyModel.errorCode == 200) {
        Utils.instance().prepareLogData(
            log: log,
            data: jsonDecode(value),
            message: 'success',
            status: LogEvent.success
        );
        Utils.instance().setDeviceNameForSchool(deviceName);
        _view!.onChangeDeviceNameComplete('Đổi tên thiết bị thành công!');
      } else if (verifyModel.errorCode == 401) {
        Utils.instance().prepareLogData(
            log: log,
            data: jsonDecode(value),
            message: verifyModel.messages,
            status: LogEvent.failed
        );
        _view!.onChangeDeviceNameError(verifyModel.messages!);
      } else {
        Utils.instance().prepareLogData(
            log: log,
            data: jsonDecode(value),
            message: StringConstants.network_error_message,
            status: LogEvent.failed
        );
        _view!.onChangeDeviceNameError(verifyModel.messages!);
      }
    }).catchError((onError) {
      _view!.onChangeDeviceNameError(onError.toString());
    });
  }
}
