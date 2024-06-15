import 'dart:convert';

AuthModel authModelFromJson(String str) => AuthModel.fromJson(json.decode(str));
String authModelToJson(AuthModel data) => json.encode(data.toJson());

class AuthModel {
  int? _errorCode;
  String? _status;
  String? _message;
  Data? _data;

  AuthModel({int? errorCode, String? status, String? message, Data? data}) {
   _errorCode = errorCode;
   _status = status;
   _message = message;
   _data = data;
  }

  int get errorCode => _errorCode ?? 0;
  set errorCode(int errorCode) => _errorCode = errorCode;
  String get status => _status ?? "";
  set status(String status) => _status = status;
  String get message => _message ?? "";
  set message(String message) => _message = message;
  Data get data => _data ?? Data();
  set data(Data data) => _data = data;

  AuthModel.fromJson(Map<String, dynamic> json) {
    _errorCode = json['error_code'];
    _status = json['status'];
    _status = json['messages'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error_code'] = _errorCode;
    data['status'] = _status;
    data['messages'] = _message;
    if (_data != null) {
      data['data'] = _data!.toJson();
    }
    return data;
  }
}

class Data {
  String? _accessToken;
  String? _tokenType;
  int? _social;
  int? _expiresIn;

  Data({String? accessToken, String? tokenType, int? social, int? expiresIn}) {
    _accessToken = accessToken;
    _tokenType = tokenType;
    _social = social;
    _expiresIn = expiresIn;
  }

  String get accessToken => _accessToken ?? '';
  set accessToken(String accessToken) => _accessToken = accessToken;
  String get tokenType => _tokenType ?? "";
  set tokenType(String tokenType) => _tokenType = tokenType;
  int get social => _social ?? 0;
  set social(int social) => _social = social;
  int get expiresIn => _expiresIn ?? 0;
  set expiresIn(int expiresIn) => _expiresIn = expiresIn;

  Data.fromJson(Map<String, dynamic> json) {
    _accessToken = json['access_token'];
    _tokenType = json['token_type'];
    _social = json['social'];
    _expiresIn = json['expires_in'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['access_token'] = _accessToken;
    data['token_type'] = _tokenType;
    data['social'] = _social;
    data['expires_in'] = _expiresIn;
    return data;
  }
}
