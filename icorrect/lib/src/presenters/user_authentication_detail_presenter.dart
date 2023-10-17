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
        print('dada: ${map.toString()}');
      }

      if (map['error_code'] == 200 && map['status'] == 'success') {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: null,
          status: LogEvent.success,
        );

        Map<String, dynamic> data = map['data'] ?? {};
        if (data.isNotEmpty) {
          UserAuthenDetailModel userAuthenDetailModel =
              UserAuthenDetailModel.fromJson(data);
          _view!.getUserAuthDetailSuccess(userAuthenDetailModel);
        } else {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: null,
            message:
                "You have not been added to the testing system, please contact admin for better understanding!",
            status: LogEvent.failed,
          );

          _view!.userNotFoundWhenLoadAuth(
              "You have not been added to the testing system, please contact admin for better understanding!");
        }
      } else {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message: "Something went wrong when load your authentication!",
          status: LogEvent.failed,
        );
        _view!.getUserAuthDetailFail(
            "Something went wrong when load your authentication!");
      }
    }).catchError((e) {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: null,
        message: "Something went wrong when load your authentication!",
        status: LogEvent.failed,
      );
      _view!.getUserAuthDetailFail("An Error : ${e.toString()}!");
    });
  }
}
