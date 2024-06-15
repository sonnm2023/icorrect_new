import 'dart:convert';

import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';

TopicModel topicModelFromJson(String str) =>
    TopicModel.fromJson(json.decode(str));
String topicModelToJson(TopicModel data) => json.encode(data.toJson());

class TopicModel {
  int? _id;
  String? _title;
  String? _description;
  int? _topicType;
  int? _status;
  int? _level;
  int? _staffCreated;
  int? _staffUpdated;
  String? _updatedAt;
  String? _createdAt;
  dynamic _deletedAt;
  String? _distributeCode;
  String? _merchantId;
  int? _numPart;
  List<QuestionTopicModel>? _followUp;
  FileTopicModel? _fileEndOfTest; //End of test video file
  FileTopicModel? _endOfTakeNote; //End of take note video file
  List<FileTopicModel>? _files; //Introduce video file
  List<QuestionTopicModel>? _questions; //Question video file

  TopicModel(
      {int? id,
        String? title,
        String? description,
        int? topicType,
        int? status,
        int? level,
        int? staffCreated,
        int? staffUpdated,
        String? updatedAt,
        String? createdAt,
        dynamic deletedAt,
        String? distributeCode,
        String? merchantId,
        int? numPart,
        List<QuestionTopicModel>? followUp,
        FileTopicModel? fileEndOfTest,
        List<FileTopicModel>? files,
        List<QuestionTopicModel>? questions,
        FileTopicModel? endOfTakeNote}) {
    _id = id;
    _title = title;
    _description = description;
    _topicType = topicType;
    _status = status;
    _level = level;
    _staffCreated = staffCreated;
    _staffUpdated = staffUpdated;
    _updatedAt = updatedAt;
    _createdAt = createdAt;
    _deletedAt = deletedAt;
    _distributeCode = distributeCode;
    _merchantId = merchantId;
    _numPart = numPart;
    _followUp = followUp;
    _fileEndOfTest = fileEndOfTest;
    _files = files;
    _questions = questions;
    _endOfTakeNote = endOfTakeNote;
  }

  int get id => _id ?? 0;
  set id(int id) => _id = id;
  String get title => _title ?? "";
  set title(String title) => _title = title;
  String get description => _description ?? "";
  set description(String description) => _description = description;
  int get topicType => _topicType ?? 0;
  set topicType(int topicType) => _topicType = topicType;
  int get status => _status ?? 0;
  set status(int status) => _status = status;
  int get level => _level ?? 0;
  set level(int level) => _level = level;
  int get staffCreated => _staffCreated ?? 0;
  set staffCreated(int staffCreated) => _staffCreated = staffCreated;
  int get staffUpdated => _staffUpdated ?? 0;
  set staffUpdated(int staffUpdated) => _staffUpdated = staffUpdated;
  String get updatedAt => _updatedAt ?? '';
  set updatedAt(String updatedAt) => _updatedAt = updatedAt;
  String get createdAt => _createdAt ?? '';
  set createdAt(String createdAt) => _createdAt = createdAt;
  dynamic get deletedAt => _deletedAt;
  set deletedAt(dynamic deletedAt) => _deletedAt = deletedAt;
  String get distributeCode => _distributeCode ?? "";
  set distributeCode(String distributeCode) => _distributeCode = distributeCode;
  String get merchantId => _merchantId ?? "";
  set merchantId(String merchantId) => _merchantId = merchantId;
  int get numPart => _numPart ?? 0;
  set numPart(int numPart) => _numPart = numPart;
  List<QuestionTopicModel> get followUp => _followUp ?? [];
  set followUp(List<QuestionTopicModel> followUp) => _followUp = followUp;
  List<FileTopicModel> get files => _files ?? [];
  set files(List<FileTopicModel> files) => _files = files;
  List<QuestionTopicModel> get questionList => _questions ?? [];
  set questionList(List<QuestionTopicModel> questions) => _questions = questions;
  FileTopicModel get fileEndOfTest => _fileEndOfTest ?? FileTopicModel();
  set fileEndOfTest(FileTopicModel fileEndOfTest) => _fileEndOfTest = fileEndOfTest;
  FileTopicModel get endOfTakeNote => _endOfTakeNote ?? FileTopicModel();
  set endOfTakeNote(FileTopicModel endOfTakeNote) => _endOfTakeNote = endOfTakeNote;

  TopicModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _title = json['title'];
    _description = json['description'];
    _topicType = json['topic_type'];
    _status = json['status'];
    _level = json['level'];
    _staffCreated = json['staff_created'];
    _staffUpdated = json['staff_updated'];
    _updatedAt = json['updated_at'];
    _createdAt = json['created_at'];
    _deletedAt = json['deleted_at'];
    _distributeCode = json['distribute_code'];
    _merchantId = json['merchant_id'];
    _numPart = json['num_part'];

    if (json['files'] != null) {
      _files = <FileTopicModel>[];
      json['files'].forEach((v) {
        if (_files!.isEmpty) {
          _files!.add(FileTopicModel.fromJson(v));
        }
      });
    }

    if (json['questions'] != null) {
      _questions = <QuestionTopicModel>[];
      json['questions'].forEach((v) {
        _questions!.add(QuestionTopicModel.fromJson(v));
      });
    }

    if (json['followup'] != null && json['followup'] != "") {
      _followUp = <QuestionTopicModel>[];
      json['followup'].forEach((v) {
        _followUp!.add(QuestionTopicModel.fromJson(v));
      });
    }

    if (json['end_of_test'] != null) {
      _fileEndOfTest = FileTopicModel.fromJson(json['end_of_test']);
    }

    if (json['end_of_take_note'] != null) {
      _endOfTakeNote = FileTopicModel.fromJson(json['end_of_take_note']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['title'] = _title;
    data['description'] = _description;
    data['topic_type'] = _topicType;
    data['status'] = _status;
    data['level'] = _level;
    data['staff_created'] = _staffCreated;
    data['staff_updated'] = _staffUpdated;
    data['updated_at'] = _updatedAt;
    data['created_at'] = _createdAt;
    data['deleted_at'] = _deletedAt;
    data['distribute_code'] = _distributeCode;
    data['merchant_id'] = _merchantId;
    data['followup'] = _followUp;
    if (_files != null) {
      data['files'] = _files!.map((v) => v.toJson()).toList();
    }
    if (_questions != null) {
      data['questions'] = _questions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}