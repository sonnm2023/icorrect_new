import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/homework_repository.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/new_class_model.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';

abstract class MyHomeWorkTabViewContract {
  void onGetListActivitySuccess(List<ActivitiesModel> activities,
      List<NewClassModel> classes, String serverCurrentTime);
  void onGetListActivityError(String message);
  void onRefreshListActivity();
}

class MyHomeWorkTabPresenter {
  final MyHomeWorkTabViewContract? _view;
  HomeWorkRepository? _homeWorkRepository;

  MyHomeWorkTabPresenter(this._view) {
    _homeWorkRepository = Injector().getHomeWorkRepository();
  }

  void getListActivity(BuildContext context) async {
    assert(_view != null && _homeWorkRepository != null);

    UserDataModel? currentUser = await Utils.getCurrentUser();
    if (currentUser == null) {
      _view!.onGetListActivityError(Utils.multiLanguage(
          StringConstants.load_list_homework_error_message)!);
      return;
    }

    String email = currentUser.userInfoModel.email;
    String status = Status.allHomework.get.toString();

    LogModel? log;
    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiGetListHomework);
    }

    _homeWorkRepository!.getListHomeWork(email, status).then((value) async {
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap[StringConstants.k_error_code] == 200) {
        List<NewClassModel> classes =
            await _createListNewClass(dataMap[StringConstants.k_data]);

        List<ActivitiesModel> homeworks = await _createListActivity(classes);

        if (kDebugMode) {
          print("DEBUG: Homework: getListHomeWork class: ${classes.length}");
          print(
              "DEBUG: Homework: getListHomeWork homework: ${homeworks.length}");
        }

        //Add log
        Utils.prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: null,
          status: LogEvent.success,
        );

        _view!.onGetListActivitySuccess(
            homeworks, classes, dataMap[StringConstants.k_current_time]);
      } else {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message:
              "Loading list homework error: ${dataMap['error_code']}${dataMap['status']}",
          status: LogEvent.failed,
        );

        _view!.onGetListActivityError(
            Utils.multiLanguage(StringConstants.common_error_message)!);
      }
    }).catchError(
      // ignore: invalid_return_type_for_catch_error
      (onError) {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message: onError.toString(),
          status: LogEvent.failed,
        );

        _view!.onGetListActivityError(
            Utils.multiLanguage(StringConstants.common_error_message)!);
      },
    );
  }

  void refreshListActivity() {
    _view!.onRefreshListActivity();
  }

  Future<List<NewClassModel>> _createListNewClass(List<dynamic> data) async {
    List<NewClassModel> temp = [];
    for (int i = 0; i < data.length; i++) {
      NewClassModel item = NewClassModel.fromJson(data[i]);
      temp.add(item);
    }
    return temp;
  }

  Future<List<ActivitiesModel>> _createListActivity(
      List<NewClassModel> data) async {
    List<ActivitiesModel> temp = [];
    for (int i = 0; i < data.length; i++) {
      NewClassModel classModel = data[i];
      temp.addAll(classModel.activities);
    }
    return temp;
  }
}
