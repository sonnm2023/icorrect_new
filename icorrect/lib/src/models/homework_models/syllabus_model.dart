import 'dart:convert';

SyllabusModel syllabusModelFromJson(String str) => SyllabusModel.fromJson(json.decode(str));
String syllabusModelToJson(SyllabusModel data) => json.encode(data.toJson());

class SyllabusModel {
  int? _id = 0;
  String? _name;
  String? _slug;
  String? _mota;
  String? _level;
  int? _createdBy;
  int? _centerId;
  int? _classId;
  int? _status;
  String? _createdAt;
  String? _updatedAt;
  int? _giaotrinhId;
  String? _startDate;

  SyllabusModel(
      {int? id,
        String? name,
        String? slug,
        String? mota,
        String? level,
        int? createdBy,
        int? centerId,
        int? classId,
        int? status,
        String? createdAt,
        String? updatedAt,
        int? giaotrinhId,
        String? startDate}) {
    _id = id;
    _name = name;
    _slug = slug;
    _mota = mota;
    _level = level;
    _createdBy = createdBy;
    _centerId = centerId;
    _classId = classId;
    _status = status;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _giaotrinhId = giaotrinhId;
    _startDate = startDate;
  }

  int get id => _id ?? 0;
  set id(int id) => _id = id;
  String get name => _name ?? "";
  set name(String name) => _name = name;
  String get slug => _slug ?? "";
  set slug(String slug) => _slug = slug;
  String get mota => _mota ?? "";
  set mota(String mota) => _mota = mota;
  String get level => _level ?? "";
  set level(String level) => _level = level;
  int get createdBy => _createdBy ?? 0;
  set createdBy(int createdBy) => _createdBy = createdBy;
  int get centerId => _centerId ?? 0;
  set centerId(int centerId) => _centerId = centerId;
  int get classId => _classId ?? 0;
  set classId(int classId) => _classId = classId;
  int get status => _status ?? 0;
  set status(int status) => _status = status;
  String get createdAt => _createdAt ?? "";
  set createdAt(String createdAt) => _createdAt = createdAt;
  String get updatedAt => _updatedAt ?? "";
  set updatedAt(String updatedAt) => _updatedAt = updatedAt;
  int get giaotrinhId => _giaotrinhId ?? 0;
  set giaotrinhId(int giaotrinhId) => _giaotrinhId = giaotrinhId;
  String get startDate => _startDate ?? "";
  set startDate(String startDate) => _startDate = startDate;

  SyllabusModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _name = json['name'];
    _slug = json['slug'];
    _mota = json['mota'];
    _level = json['level'];
    _createdBy = json['created_by'];
    _centerId = json['center_id'];
    _classId = json['class_id'];
    _status = json['status'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _giaotrinhId = json['giaotrinh_id'];
    _startDate = json['start_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['name'] = _name;
    data['slug'] = _slug;
    data['mota'] = _mota;
    data['level'] = _level;
    data['created_by'] = _createdBy;
    data['center_id'] = _centerId;
    data['class_id'] = _classId;
    data['status'] = _status;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    data['giaotrinh_id'] = _giaotrinhId;
    data['start_date'] = _startDate;
    return data;
  }
}