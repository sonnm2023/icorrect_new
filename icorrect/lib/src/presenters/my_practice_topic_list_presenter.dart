import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/practice_repository.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/bank_topic_model.dart';

abstract class MyPracticeTopicListViewContract {
  void onGetListTopicOfBankSuccess(List<Topic> topics);
  void onGetListTopicOfBankError(String message);
  // void onGetListHomeworkComplete(List<ActivitiesModel> homeworks,
  //     List<NewClassModel> classes, String serverCurrentTime);

  // void onGetListHomeworkError(String message);

  // void onLogoutComplete();

  // void onLogoutError(String message);

  // void onUpdateCurrentUserInfo(UserDataModel userDataModel);

  // void onRefreshListHomework();
}

class MyPracticeTopicListPresenter {
  final MyPracticeTopicListViewContract? _view;
  PracticeRepository? _repository;

  MyPracticeTopicListPresenter(this._view) {
    _repository = Injector().getPracticeRepository();
  }

  void getListTopicOfBank(BuildContext context, String distributeCode) async {
    assert(_view != null && _repository != null);

    LogModel? log;
    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiGetListTopicOfBank);
    }

    Future<List<Topic>> _generateList(List<dynamic> data) async {
      List<Topic> temp = [];
      for (int i = 0; i < data.length; i++) {
        Topic item = Topic.fromJson(data[i]);
        temp.add(item);
      }
      return temp;
    }

    _repository!.getListTopicOfBank(distributeCode).then((value) async {
      if (kDebugMode) {
        print("DEBUG:getListTopicOfBank: $value ");
      }

      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap[StringConstants.k_error_code] == 200) {
        List<Topic> topics =
            await _generateList(dataMap[StringConstants.k_data]);

        Utils.prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: null,
          status: LogEvent.success,
        );

        _view!.onGetListTopicOfBankSuccess(topics);
      } else {
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message:
              "Loading list topic of bank error: ${dataMap['error_code']}${dataMap['status']}",
          status: LogEvent.failed,
        );

        _view!.onGetListTopicOfBankError(
            Utils.multiLanguage(StringConstants.common_error_message));
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

        _view!.onGetListTopicOfBankError(
            Utils.multiLanguage(StringConstants.common_error_message));
      },
    );
  }
}
