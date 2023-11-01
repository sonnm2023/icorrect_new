import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/user_authen_repository.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';
import 'package:icorrect/src/models/user_authentication/user_authentication_detail.dart';

abstract class UserAuthDetailContract {
  void getUserAuthDetailSuccess(UserAuthenDetailModel userAuthenDetailModel);
  void getUserAuthDetailFail(String message);
  void userNotFoundWhenLoadAuth(String message);
}

class UserAuthDetailPresenter {
  final UserAuthDetailContract? _view;
  UserAuthRepository? _repository;

  UserAuthDetailPresenter(this._view) {
    _repository = Injector().getUserAuthDetailRepository();
  }

  Future getUserAuthDetail(BuildContext context) async {
    assert(_view != null);
    LogModel? log;
    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiGetUserAuthDetail);
    }

    _repository!.getUserAuthDetail().then((value) {
      Map<String, dynamic> map = jsonDecode(value);

      if (kDebugMode) {
        print('data: ${map.toString()}');
      }

      if (map[StringConstants.k_error_code] == 200 &&
          map[StringConstants.k_status] == 'success') {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: null,
          status: LogEvent.success,
        );

        Map<String, dynamic> data = map[StringConstants.k_data] ?? {};
        if (data.isNotEmpty) {
          UserAuthenDetailModel userAuthenDetailModel =
              UserAuthenDetailModel.fromJson(data);
          _view!.getUserAuthDetailSuccess(userAuthenDetailModel);
        } else {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: null,
            message: StringConstants.not_authen_user_message,
            status: LogEvent.failed,
          );

          _view!.userNotFoundWhenLoadAuth(
              StringConstants.not_authen_user_message);
        }
      } else {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message: StringConstants.get_authen_user_fail_message,
          status: LogEvent.failed,
        );
        _view!.getUserAuthDetailFail(
            StringConstants.get_authen_user_fail_message);
      }
    }).catchError((e) {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: null,
        message: "An Error : ${e.toString()}!",
        status: LogEvent.failed,
      );
      _view!
          .getUserAuthDetailFail(StringConstants.get_authen_user_fail_message);
    });
  }
}
