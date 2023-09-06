import 'dart:convert';

import 'package:icorrect/src/models/homework_models/new_api_135/new_class_model.dart';

Api135ResponseModel api135ResponseModelFromJson(String str) =>
    Api135ResponseModel.fromJson(json.decode(str));
String api135ResponseModelToJson(Api135ResponseModel data) =>
    json.encode(data.toJson());

class Api135ResponseModel {
  int? _errorCode;
  String? _status;
  String? _message;
  int? _userId;
  List<NewClassModel>? _data;

  Api135ResponseModel(int? errorCode, String? status, String? message,
      int? userId, List<NewClassModel>? data) {
    _errorCode = errorCode;
    _status = status;
    _message = message;
    _userId = userId;
    _data = data;
  }

  int get errorCode => _errorCode ?? 0;
  set errorCode(int errorCode) => _errorCode = errorCode;
  String get status => _status ?? "";
  set status(String status) => _status = status;
  String get message => _message ?? "";
  set message(String message) => _message = message;
  int get userId => _userId ?? 0;
  set userId(int userId) => _userId = userId;
  List<NewClassModel> get data => _data ?? [];
  set data(List<NewClassModel> data) => _data = data;

  Api135ResponseModel.fromJson(Map<String, dynamic> json) {
    _errorCode = json['error_code'];
    _status = json['status'];
    _message = json['message'];
    _userId = json['user_id'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data!.add(NewClassModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error_code'] = _errorCode;
    data['status'] = _status;
    data['message'] = _message;
    data['user_id'] = _userId;
    if (_data != null) {
      data['data'] = _data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
