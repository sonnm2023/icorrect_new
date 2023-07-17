import 'dart:convert';

Status statusFromJson(String str) => Status.fromJson(json.decode(str));
String statusToJson(Status data) => json.encode(data.toJson());

class Status {
  Status({
    int? errorCode,
    String? msg,
  }) {
    _errorCode = errorCode;
    _msg = msg;
  }

  Status.fromJson(dynamic json) {
    _errorCode = json['error_code'];
    _msg = json['status'];
  }
  int? _errorCode;
  String? _msg;

  Status copyWith({
    int? errorCode,
    String? msg,
  }) =>
      Status(
        errorCode: errorCode ?? _errorCode,
        msg: msg ?? _msg,
      );
  int get errorCode => _errorCode ?? 0;
  String get msg => _msg ?? '';

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['error_code'] = _errorCode;
    map['status'] = _msg;
    return map;
  }
}