import 'dart:convert';

ActivityStatusModel homeworkStatusModelFromJson(String str) =>
    ActivityStatusModel.fromJson(json.decode(str));
String homeworkStatusModelToJson(ActivityStatusModel data) =>
    json.encode(data.toJson());

class ActivityStatusModel {
  int? _id = 0;
  String? _name;

  ActivityStatusModel({required int id, String? name}) {
    _id = id;
    _name = name;
  }

  int get id => _id ?? 0;
  set id(int id) => _id = id;
  String get name => _name ?? "";
  set name(String name) => _name = name;

  ActivityStatusModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['name'] = _name;
    return data;
  }
}
