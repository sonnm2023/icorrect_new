import 'dart:convert';
import 'package:icorrect/src/models/homework_models/new_api_135/activity_answer_model.dart';

ActivitiesModel activitiesModelFromJson(String str) => ActivitiesModel.fromJson(json.decode(str));
String activitiesModelToJson(ActivitiesModel data) => json.encode(data.toJson());

class ActivitiesModel {
  int? _classId;
  int? _syllabusId;
  int? _activityId;
  String? _activityName;
  String? _activityEndTime;
  String? _activityReleaseTime;
  String? _activityType;
  int? _activityStatus;
  ActivityAnswer? _activityAnswer;

  ActivitiesModel(
      {int? classId,
      int? syllabusId,
      int? activityId,
      String? activityName,
      String? activityEndTime,
      String? activityReleaseTime,
      String? activityType,
      int? activityStatus,
      ActivityAnswer? activityAnswer}) {
    _classId = classId;
    _syllabusId = syllabusId;
    _activityId = activityId;
    _activityName = activityName;
    _activityEndTime = activityEndTime;
    _activityReleaseTime = activityReleaseTime;
    _activityType = activityType;
    _activityStatus = activityStatus;
    _activityAnswer = activityAnswer;
  }

  int get classId => _classId ?? 0;
  set classId(int classId) => _classId = classId;
  int get syllabusId => _syllabusId ?? 0;
  set syllabusId(int syllabusId) => _syllabusId = syllabusId;
  int get activityId => _activityId ?? 0;
  set activityId(int activityId) => _activityId = activityId;
  String get activityName => _activityName ?? "";
  set activityName(String activityName) => _activityName = activityName;
  String get activityEndTime => _activityEndTime ?? "";
  set activityEndTime(String activityEndTime) =>
      _activityEndTime = activityEndTime;
  String get activityReleaseTime => _activityReleaseTime ?? "";
  set activityReleaseTime(String activityReleaseTime) =>
      _activityReleaseTime = activityReleaseTime;
  String get activityType => _activityType ?? "";
  set activityType(String activityType) => _activityType = activityType;
  int get activityStatus => _activityStatus ?? 0;
  set activityStatus(int activityStatus) => _activityStatus = activityStatus;
  ActivityAnswer get activityAnswer => _activityAnswer ?? ActivityAnswer();
  set activityAnswer(ActivityAnswer activityAnswer) =>
      _activityAnswer = activityAnswer;

  ActivitiesModel.fromJson(Map<String, dynamic> json) {
    _classId = json['class_id'];
    _syllabusId = json['syllabus_id'];
    _activityId = json['activity_id'];
    _activityName = json['activity_name'];
    _activityEndTime = json['activity_end_time'];
    _activityReleaseTime = json['activity_release_time'];
    _activityType = json['activity_type'];
    _activityStatus = json['activity_status'];
    _activityAnswer = json['activity_answer'] != null
        ? ActivityAnswer.fromJson(json['activity_answer'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['class_id'] = _classId;
    data['syllabus_id'] = _syllabusId;
    data['activity_id'] = _activityId;
    data['activity_name'] = _activityName;
    data['activity_end_time'] = _activityEndTime;
    data['activity_release_time'] = _activityReleaseTime;
    data['activity_type'] = _activityType;
    data['activity_status'] = _activityStatus;
    if (_activityAnswer != null) {
      data['activity_answer'] = _activityAnswer!.toJson();
    }
    return data;
  }
}