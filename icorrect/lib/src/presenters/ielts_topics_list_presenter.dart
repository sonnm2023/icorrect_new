import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/repositories/practice_repository.dart';
import 'package:icorrect/src/models/practice_model/ielts_topic_model.dart';
import 'package:icorrect/src/models/practice_model/ielts_topics_list_result_model.dart';

import '../data_sources/constants.dart';
import '../data_sources/dependency_injection.dart';

abstract class IELTSTopicsListConstract {
  void getIELTSTopicsSuccess(List<IELTSTopicModel> topicsList);
  void getIELTSTopicsFail(String message);
}

class IELTSTopicsListPresenter {
  final IELTSTopicsListConstract? _view;
  PracticeRepository? _repository;

  IELTSTopicsListPresenter(this._view) {
    _repository = Injector().getPracticeRepository();
  }

  Future getIELTSTopicsList(List<String> topicTypes, String status) async {
    assert(_view != null && _repository != null);
  
    _repository!.getPracticeTopicsList(topicTypes, status).then((value) {
      if (kDebugMode) {
        print("DEBUG:getIELTSTopicsList: $value ");
      }
      Map<String, dynamic> dataMap = jsonDecode(value);

      if (dataMap[StringConstants.k_error_code] == 200) {
        IELTSListResultModel resultModel =
            IELTSListResultModel.fromJson(dataMap);
        _view!.getIELTSTopicsSuccess(resultModel.topics);
      } else {
        _view!.getIELTSTopicsFail(StringConstants.common_error_message);
      }
    }).catchError((error) {
      _view!.getIELTSTopicsFail(StringConstants.common_error_message);
    });
  }
}