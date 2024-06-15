import 'dart:convert';

import 'package:icorrect/src/models/homework_models/syllabus_model.dart';


ClassModel classModelFromJson(String str) => ClassModel.fromJson(json.decode(str));
String classModelToJson(ClassModel data) => json.encode(data.toJson());

class ClassModel {
  int? _id = 0;
  String? _name;
  int? _centerId;
  String? _createdAt;
  String? _updatedAt;
  String? _deletedAt;
  int? _teacherId;
  int? _syllabusId;
  String? _syllabusName;
  String? _startDate;
  String? _status;
  int? _allTestOfActivity;
  String? _classId;
  SyllabusModel? _syllabus;
  String? _text;
  String? _distributeCode;

  ClassModel(
      { int? id,
        String? name,
        int? centerId,
        String? createdAt,
        String? updatedAt,
        String? deletedAt,
        int? teacherId,
        int? syllabusId,
        String? syllabusName,
        String? startDate,
        String? status,
        int? allTestOfActivity,
        String? classId,
        SyllabusModel? syllabus,
        String? text,
        String? distributeCode}) {
    _id = id;
    _name = name;
    _centerId = centerId;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _deletedAt = deletedAt;
    _teacherId = teacherId;
    _syllabusId = syllabusId;
    _syllabusName = syllabusName;
    _startDate = startDate;
    _status = status;
    _allTestOfActivity = allTestOfActivity;
    _classId = classId;
    _syllabus = syllabus;
    _text = text;
    _distributeCode = distributeCode;
  }

  int get id => _id ?? 0;
  set id(int id) => _id = id;
  String get name => _name ?? "";
  set name(String name) => _name = name;
  int get centerId => _centerId ?? 0;
  set centerId(int centerId) => _centerId = centerId;
  String get createdAt => _createdAt ?? "";
  set createdAt(String createdAt) => _createdAt = createdAt;
  String get updatedAt => _updatedAt ?? "";
  set updatedAt(String updatedAt) => _updatedAt = updatedAt;
  String get deletedAt => _deletedAt ?? "";
  set deletedAt(String deletedAt) => _deletedAt = deletedAt;
  int get teacherId => _teacherId ?? 0;
  set teacherId(int teacherId) => _teacherId = teacherId;
  int get syllabusId => _syllabusId ?? 0;
  set syllabusId(int syllabusId) => _syllabusId = syllabusId;
  String get syllabusName => _syllabusName ?? "";
  set syllabusName(String syllabusName) => _syllabusName = syllabusName;
  String get startDate => _startDate ?? "";
  set startDate(String startDate) => _startDate = startDate;
  String get status => _status ?? "";
  set status(String status) => _status = status;
  int get allTestOfActivity => _allTestOfActivity ?? 0;
  set allTestOfActivity(int allTestOfActivity) =>
      _allTestOfActivity = allTestOfActivity;
  String get classId => _classId ?? "";
  set classId(String classId) => _classId = classId;
  SyllabusModel get syllabus => _syllabus ?? SyllabusModel(id: 0);
  set syllabus(SyllabusModel syllabus) => _syllabus = syllabus;
  String get text => _text ?? "";
  set text(String text) => _text = text;
  String get distributeCode => _distributeCode ?? "";
  set distributeCode(String distributeCode) => _distributeCode = distributeCode;

  ClassModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _name = json['name'];
    _centerId = json['center_id'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _deletedAt = json['deleted_at'];
    _teacherId = json['teacher_id'];
    _syllabusId = json['syllabus_id'];
    _syllabusName = json['syllabus_name'];
    _startDate = json['start_date'];
    _status = json['status'];
    _allTestOfActivity = json['all_test_of_activity'];
    _classId = json['class_id'];
    _syllabus = json['syllabus'] != null
        ? SyllabusModel.fromJson(json['syllabus'])
        : null;
    _text = json['text'];
    _distributeCode = json['distribute_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['name'] = _name;
    data['center_id'] = _centerId;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    data['deleted_at'] = _deletedAt;
    data['teacher_id'] = _teacherId;
    data['syllabus_id'] = _syllabusId;
    data['syllabus_name'] = _syllabusName;
    data['start_date'] = _startDate;
    data['status'] = _status;
    data['all_test_of_activity'] = _allTestOfActivity;
    data['class_id'] = _classId;
    if (_syllabus != null) {
      data['syllabus'] = _syllabus!.toJson();
    }
    data['text'] = _text;
    data['distribute_code'] = _distributeCode;
    return data;
  }
}