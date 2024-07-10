import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:icorrect_pc/src/data_source/dependency_injection.dart';
import 'package:icorrect_pc/src/data_source/repositories/auth_repository.dart';
import 'package:icorrect_pc/src/models/auth_models/class_merchant_model.dart';
import 'package:icorrect_pc/src/models/auth_models/student_merchant_model.dart';
import 'package:icorrect_pc/src/models/auth_models/verify_model.dart';
import 'package:icorrect_pc/src/models/log_models/log_model.dart';

import '../data_source/constants.dart';
import '../data_source/local/app_shared_preferences_keys.dart';
import '../data_source/local/app_shared_references.dart';
import '../utils/utils.dart';

abstract class VerifyViewContact {
  void onVerifyComplete(String merchantID);
  void onVerifyError(String message);
  void onGetListClassComplete(List<ClassModel> list);
  void onGetListClassError(String message);
  void onGetListStudentComplete(List<StudentModel> list);
  void onGetListStudentError(String message);
  void onVerifyConfigComplete();
  void onVerifyConfigError(String message);
  void onChangeDeviceNameComplete(String msg);
  void onChangeDeviceNameError(String msg);
}

class VerifyPresenter {
  final VerifyViewContact? _view;
  AuthRepository? _repository;
  VerifyPresenter(this._view) {
    _repository = Injector().getAuthRepository();
  }

  Future verify(BuildContext context, String licenseKey, String deviceName) async {
    assert(_view != null && _repository != null);

    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiVerify);
    }
    String deviceID = await Utils.instance().getDeviceIdentifier();

    _repository!.verifyDevice(licenseKey, deviceID, deviceName).then((value) async {
      VerifyModel verifyModel = VerifyModel.fromJson(jsonDecode(value));
      if (verifyModel.errorCode == 200) {
        Utils.instance().prepareLogData(
            log: log,
            data: jsonDecode(value),
            message: 'success',
            status: LogEvent.success
        );
        await _saveMerchainID(verifyModel.data!.merchantId);
        await _saveLicenseKey(licenseKey);
        await _saveDeviceName(deviceName);
        _view!.onVerifyComplete(verifyModel.data!.merchantId);
      } else if (verifyModel.errorCode == 401) {
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
      _view!.onVerifyError(onError.toString());
    });
  }

  Future _saveLicenseKey(String key) async {
    AppSharedPref.instance()
        .putString(key: AppSharedKeys.licenseKey, value: key);
  }

  Future _saveDeviceName(String deviceName) async {
    AppSharedPref.instance().putString(key: AppSharedKeys.deviceName, value: deviceName);
  }

  Future _saveMerchainID(String merchantID)  async {
    AppSharedPref.instance()
        .putString(key: AppSharedKeys.merchantID, value: merchantID);
  }

  void getListClass(BuildContext context, String merchantID) async {
    assert(_view != null && _repository != null);

    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiGetListClass);
    }
    String checksum = await Utils.instance().convertHMacSha256(param1: merchantID);
    _repository!.getListClass(merchantID, checksum).then((value) {
      ClassMerchantModel classMerchantModel = ClassMerchantModel.fromJson(jsonDecode(value));
      if (classMerchantModel.errorCode == 200) {
        List<ClassModel> classes = classMerchantModel.data!.data!;
        Utils.instance().prepareLogData(
            log: log,
            data: jsonDecode(value),
            message: classMerchantModel.message,
            status: LogEvent.success
        );
        _view!.onGetListClassComplete(classes);
      } else {
        if (classMerchantModel.message!.isNotEmpty) {
          Utils.instance().prepareLogData(
              log: log,
              data: jsonDecode(value),
              message: classMerchantModel.message,
              status: LogEvent.success
          );
        } else {
          Utils.instance().prepareLogData(
              log: log,
              data: jsonDecode(value),
              message: StringConstants.network_error_message,
              status: LogEvent.success
          );
        }
        _view!.onGetListClassError(classMerchantModel.message!);
      }
    }).catchError((onError) {
      _view!.onGetListClassError(onError.toString());
    });
  }

  void getListStudent(BuildContext context, int classID) async {
    assert(_view != null && _repository != null);

    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiGetListClass);
    }

    String? merchantID = await Utils.instance().getMerchantID();
    String checksum = await Utils.instance().convertHMacSha256(param1: merchantID);
    _repository!.getListStudent(merchantID!, classID, checksum).then((value) {
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
              message: StringConstants.network_error_message,
              status: LogEvent.success
          );
        }
        _view!.onGetListStudentError(model.messages!);
      }
    }).catchError((onError) {
      _view!.onGetListClassError(onError.toString());
    });
  }

  Future verifyConfig(BuildContext context, String key) async {
    assert(_view != null && _repository != null);

    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiVerify);
    }
    String deviceID = await Utils.instance().getDeviceIdentifier();
    deviceID = deviceID.replaceAll('{', '');
    deviceID = deviceID.replaceAll('}', '');
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
  }

  Future changeDeviceName(BuildContext context, String deviceName) async {
    assert(_view != null && _repository != null);

    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiVerify);
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