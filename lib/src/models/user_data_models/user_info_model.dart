import 'dart:convert';

UserInfoModel userInfoModelFromJson(String str) => UserInfoModel.fromJson(json.decode(str));
String userInfoModelToJson(UserInfoModel data) => json.encode(data.toJson());

class UserInfoModel {
  int? _id = 0;
  String? _userName;
  String? _email;
  String? _code;
  int? _type;
  int? _createdBy;
  int? _updatedBy;
  String? _updatedAt;
  String? _createdAt;
  String? _deletedAt;
  int? _isTest;
  String? _inviteCode;
  String? _distributorCode;
  String? _experimentStatus;

  UserInfoModel(
      {int? id,
      String? userName,
      String? email,
      String? code,
      int? type,
      int? createdBy,
      int? updatedBy,
      String? updatedAt,
      String? createdAt,
      String? deletedAt,
      int? isTest,
      String? inviteCode,
      String? distributorCode,
      String? experimentStatus}) {
    id = id;
    userName = userName;
    email = email;
    code = code;
    type = type;
    createdBy = createdBy;
    updatedBy = updatedBy;
    updatedAt = updatedAt;
    createdAt = createdAt;
    deletedAt = deletedAt;
    isTest = isTest;
    inviteCode = inviteCode;
    distributorCode = distributorCode;
    experimentStatus = experimentStatus;
  }

  int get id => _id ?? 0;
  set id(int id) => _id = id;
  String get userName => _userName ?? "";
  set userName(String userName) => _userName = userName;
  String get email => _email ?? "";
  set email(String email) => _email = email;
  String get code => _code ?? "";
  set code(String code) => _code = code;
  int get type => _type ?? 0;
  set type(int type) => _type = type;
  int get createdBy => _createdBy ?? 0;
  set createdBy(int createdBy) => _createdBy = createdBy;
  int get updatedBy => _updatedBy ?? 0;
  set updatedBy(int updatedBy) => _updatedBy = updatedBy;
  String get updatedAt => _updatedAt ?? "";
  set updatedAt(String updatedAt) => _updatedAt = updatedAt;
  String get createdAt => _createdAt ?? "";
  set createdAt(String createdAt) => _createdAt = createdAt;
  String get deletedAt => _deletedAt ?? "";
  set deletedAt(String deletedAt) => _deletedAt = deletedAt;
  int get isTest => _isTest ?? 0;
  set isTest(int isTest) => _isTest = isTest;
  String get inviteCode => _inviteCode ?? "";
  set inviteCode(String inviteCode) => _inviteCode = inviteCode;
  String get distributorCode => _distributorCode ?? "";
  set distributorCode(String distributorCode) =>
      _distributorCode = distributorCode;
  String get experimentStatus => _experimentStatus ?? "";
  set experimentStatus(String experimentStatus) =>
      _experimentStatus = experimentStatus;

  UserInfoModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _userName = json['user_name'];
    _email = json['email'];
    _code = json['code'];
    _type = json['type'];
    _createdBy = json['created_by'];
    _updatedBy = json['updated_by'];
    _updatedAt = json['updated_at'];
    _createdAt = json['created_at'];
    _deletedAt = json['deleted_at'];
    _isTest = json['is_test'];
    _inviteCode = json['invite_code'];
    _distributorCode = json['distributor_code'];
    _experimentStatus = json['experiment_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['user_name'] = _userName;
    data['email'] = _email;
    data['code'] = _code;
    data['type'] = _type;
    data['created_by'] = _createdBy;
    data['updated_by'] = _updatedBy;
    data['updated_at'] = _updatedAt;
    data['created_at'] = _createdAt;
    data['deleted_at'] = _deletedAt;
    data['is_test'] = _isTest;
    data['invite_code'] = _inviteCode;
    data['distributor_code'] = _distributorCode;
    data['experiment_status'] = _experimentStatus;
    return data;
  }
}
