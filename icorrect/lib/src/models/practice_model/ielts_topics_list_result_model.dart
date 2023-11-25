import 'package:icorrect/src/models/practice_model/ielts_topic_model.dart';

class IELTSListResultModel {
  List<dynamic>? _topicsStatus = [];
  List<dynamic>? _topicTypes = [];
  List<dynamic>? _predicts = [];
  List<dynamic>? _accesses = [];
  List<IELTSTopicModel>? _topics = [];

  List<dynamic> get topicsStatus => _topicsStatus ?? [];

  set topicsStatus(value) => _topicsStatus = value;

  List<dynamic> get topicTypes => _topicTypes ?? [];

  set topicTypes(value) => _topicTypes = value;

  List<dynamic> get predicts => _predicts ?? [];

  set predicts(value) => _predicts = value;

  List<dynamic> get accesses => _accesses ?? [];

  set accesses(value) => _accesses = value;

  List<IELTSTopicModel> get topics => _topics ?? [];

  set topics(value) => _topics = value;

  IELTSListResultModel.fromJson(Map<String, dynamic> json) {
    if (json['topic_status'] != null) {
      json['topic_status'].forEach((v) {
        _topicsStatus!.add(v);
      });
    }

    if (json['topic_type'] != null) {
      json['topic_type'].forEach((v) {
        _topicTypes!.add(v);
      });
    }

    if (json['predict'] != null) {
      json['predict'].forEach((v) {
        _predicts!.add(v);
      });
    }
    if (json['access'] != null) {
      json['access'].forEach((v) {
        _accesses!.add(v);
      });
    }

    if (json['data'] != null) {
      json['data'].forEach((v) {
        _topics!.add(IELTSTopicModel.fromJson(v));
      });
    }
  }
}
