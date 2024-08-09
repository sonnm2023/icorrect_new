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
}