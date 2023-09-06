import 'dart:convert';

SubmittedDateModel submittedDateModelFromJson(String str) => SubmittedDateModel.fromJson(json.decode(str));
String submittedDateModelToJson(SubmittedDateModel data) => json.encode(data.toJson());

class SubmittedDateModel {
  String? _date;
  int? _timezoneType;
  String? _timezone;

  SubmittedDateModel({
    String? date,
    int? timezoneType,
    String? timezone,
  }) {
    _date = date;
    _timezoneType = timezoneType;
    _timezone = timezone;
  }

  String get date => _date ?? "";
  set date(String date) => _date = date;
  int get timezoneType => _timezoneType ?? 0;
  set timezoneType(int timezoneType) => _timezoneType = timezoneType;
  String get timezone => _timezone ?? "";
  set timezone(String timezone) => _timezone = timezone;

  SubmittedDateModel.fromJson(Map<String, dynamic> json) {
    _date = json['date'];
    _timezoneType = json['timezone_type'];
    _timezone = json['timezone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = _date;
    data['timezone_type'] = _timezoneType;
    data['timezone'] = _timezone;
    return data;
  }
}
