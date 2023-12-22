import 'dart:convert';

import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';

TestDetailModel testDetailModelFromJson(String str) =>
    TestDetailModel.fromJson(json.decode(str));
String testDetailModelToJson(TestDetailModel data) =>
    json.encode(data.toJson());

class TestDetailModel {
  String? _activityType;
  int? _testOption;
  TopicModel? _introduce;
  List<TopicModel>? _part1;
  String? _domainName;
  int? _testId;
  String? _checkSum;
  TopicModel? _part2;
  TopicModel? _part3;
  String? _id;
  String? _status;
  String? _updateAt;
  String? _hasOrder;
  double? _normalSpeed;
  double? _firstRepeatSpeed;
  double? _secondRepeatSpeed;
  int? _part1Time;
  int? _part2Time;
  int? _part3Time;
  int? _takeNoteTime;

  TestDetailModel({
    String? activityType,
    int? testOption,
    TopicModel? introduce,
    List<TopicModel>? part1,
    String? domainName,
    int? testId,
    String? checkSum,
    String? id,
    String? status,
    String? updateAt,
    String? hasOrder,
    double? normalSpeed,
    double? firstRepeatSpeed,
    double? secondRepeatSpeed,
    TopicModel? part2,
    TopicModel? part3,
    int? part1Time,
    int? part2Time,
    int? part3Time,
    int? takeNoteTime,
  }) {
    _activityType = activityType;
    _testOption = testOption;
    _introduce = introduce;
    _part1 = part1;
    _domainName = domainName;
    _testId = testId;
    _checkSum = checkSum;
    _id = id;
    _status = status;
    _updateAt = updateAt;
    _hasOrder = hasOrder;
    _normalSpeed = normalSpeed;
    _firstRepeatSpeed = firstRepeatSpeed;
    _secondRepeatSpeed = secondRepeatSpeed;
    _part2 = part2;
    _part3 = part3;
    _part1Time = part1Time;
    _part2Time = part2Time;
    _part3Time = part3Time;
    _takeNoteTime = takeNoteTime;
  }

  String get activityType => _activityType ?? "";
  set activityType(String activityType) => _activityType = activityType;
  int get testOption => _testOption ?? 0;
  set testOption(int testOption) => _testOption = testOption;
  TopicModel get introduce => _introduce ?? TopicModel(id: 0);
  set introduce(TopicModel introduce) => _introduce = introduce;
  List<TopicModel> get part1 => _part1 ?? [];
  set part1(List<TopicModel> part1) => _part1 = part1;
  String get domainName => _domainName ?? "";
  set domainName(String domainName) => _domainName = domainName;
  int get testId => _testId ?? 0;
  set testId(int testId) => _testId = testId;
  String get checkSum => _checkSum ?? "";
  set checkSum(String checkSum) => _checkSum = checkSum;
  String get id => _id ?? "";
  set id(String id) => _id = id;
  String get status => _status ?? "";
  set status(String status) => _status = status;
  String get updateAt => _updateAt ?? "";
  set updateAt(String updateAt) => _updateAt = updateAt;
  String get hasOrder => _hasOrder ?? "";
  set hasOrder(String hasOrder) => _hasOrder = hasOrder;
  double get normalSpeed => _normalSpeed ?? 1.0;
  set normalSpeed(double normalSpeed) => _normalSpeed = normalSpeed;
  double get firstRepeatSpeed => _firstRepeatSpeed ?? 0.9;
  set firstRepeatSpeed(double firstRepeatSpeed) =>
      _firstRepeatSpeed = firstRepeatSpeed;
  double get secondRepeatSpeed => _secondRepeatSpeed ?? 1;
  set secondRepeatSpeed(double secondRepeatSpeed) =>
      _secondRepeatSpeed = secondRepeatSpeed;
  TopicModel get part2 => _part2 ?? TopicModel();
  set part2(TopicModel part2) => _part2 = part2;
  TopicModel get part3 => _part3 ?? TopicModel();
  set part3(TopicModel part3) => _part3 = part3;
  int get part1Time => _part1Time ?? 30;
  set part1Time(int part1Time) => _part1Time = part1Time;
  int get part2Time => _part2Time ?? 120;
  set part2Time(int part2Time) => _part2Time = part2Time;
  int get part3Time => _part3Time ?? 45;
  set part3Time(int part3Time) => _part3Time = part3Time;
  int get takeNoteTime => _takeNoteTime ?? 60;
  set takeNoteTime(int takeNoteTime) => _takeNoteTime = takeNoteTime;

  TestDetailModel.fromJson(Map<String, dynamic> json) {
    _activityType = json['activity_type'];
    _testOption = json['test_option'];
    _introduce = json['introduce'] != null
        ? TopicModel.fromJson(json['introduce'])
        : null;
    if (json['part1'] != null) {
      _part1 = <TopicModel>[];

      json['part1'].forEach((v) {
        if (v != null) {
          _part1!.add(TopicModel.fromJson(v));
        }
      });
    }
    _domainName = json['domain_name'];
    _testId = json['test_id'];
    _checkSum = json['check_sum'];
    _id = json['_id'];
    _status = json['status'];
    _updateAt = json['updated_at'];
    _hasOrder = json['has_order'];
    _normalSpeed = json['normal_speed'] != null
        ? Utils.convertToDouble(json['normal_speed'])
        : 1.0;
    _firstRepeatSpeed = json['first_repeat_speed'] != null
        ? Utils.convertToDouble(json['first_repeat_speed'])
        : 0.9;
    _secondRepeatSpeed = json['second_repeat_speed'] != null
        ? Utils.convertToDouble(json['second_repeat_speed'])
        : 1;
    _part2 = json['part2'] != null ? TopicModel.fromJson(json['part2']) : null;
    if (_part2 != null) {
      _part2!.numPart = PartOfTest.part2.get;
    }
    _part3 = json['part3'] != null ? TopicModel.fromJson(json['part3']) : null;
    if (_part3 != null) {
      _part3!.numPart = PartOfTest.part3.get;
    }
    _part1Time = json['part1_time'] ?? 30;
    _part2Time = json['part2_time'] ?? 120;
    _part3Time = json['part3_time'] ?? 45;
    _takeNoteTime = json['take_note_time'] ?? 60;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['activity_type'] = _activityType;
    data['test_option'] = _testOption;
    if (_introduce != null) {
      data['introduce'] = _introduce!.toJson();
    }
    if (_part1 != null) {
      data['part1'] = _part1!.map((v) => v.toJson()).toList();
    }
    data['domain_name'] = _domainName;
    data['test_id'] = _testId;
    data['check_sum'] = _checkSum;
    data['_id'] = _id;
    data['status'] = _status;
    data['updated_at'] = _updateAt;
    data['has_order'] = _hasOrder;
    data['normal_speed'] = _normalSpeed;
    data['first_repeat_speed'] = _firstRepeatSpeed;
    data['second_repeat_speed'] = _secondRepeatSpeed;
    if (_part2 != null) {
      data['part2'] = _part2!.toJson();
    }
    if (_part3 != null) {
      data['part3'] = _part3!.toJson();
    }
    data['part1_time'] = _part1Time;
    data['part2_time'] = _part2Time;
    data['part3_time'] = _part3Time;
    data['take_note_time'] = _takeNoteTime;

    return data;
  }

  TestDetailModel.fromMyTestJson(Map<String, dynamic> json) {
    _id = json['_id'] ?? '';
    _status = json['status'].toString();
    _checkSum = json['check_sum'] ?? '';
    _testId = json['test_id'] ?? 0;
    _updateAt = json['updated_at'] ?? '';
    _hasOrder = json['has_order'].toString();

    _activityType = json['test']['activity_type'] ?? '';
    _testOption = json['test']['test_option'] ?? 0;
    _domainName = json['test']['domain_name'] ?? '';

    _introduce = json['test']['introduce'] != null
        ? TopicModel.fromJson(json['test']['introduce'])
        : null;
    if (json['test']['part1'] != null) {
      _part1 = <TopicModel>[];
      json['test']['part1'].forEach((v) {
        _part1!.add(TopicModel.fromJson(v));
      });
    }
    _part2 = json['test']['part2'] != null
        ? TopicModel.fromJson(json['test']['part2'])
        : null;
    _part3 = json['test']['part3'] != null
        ? TopicModel.fromJson(json['test']['part3'])
        : null;
  }
}
