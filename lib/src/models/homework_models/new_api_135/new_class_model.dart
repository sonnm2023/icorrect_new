import 'dart:convert';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';

NewClassModel newClassModelFromJson(String str) =>
    NewClassModel.fromJson(json.decode(str));
String newClassModelToJson(NewClassModel data) => json.encode(data.toJson());

class NewClassModel {
  String? _name;
  int? _id;
  List<ActivitiesModel>? _activities;

  NewClassModel({
    String? name,
    int? id,
    List<ActivitiesModel>? activities,
  }) {
    _name = name;
    _id = id;
    _activities = activities;
  }

  String get name => _name ?? "";
  set name(String name) => _name = name;
  int get id => _id ?? 0;
  set id(int id) => _id = id;
  List<ActivitiesModel> get activities => _activities ?? [];
  set activities(List<ActivitiesModel> activities) => _activities = activities;

  NewClassModel.fromJson(Map<String, dynamic> json) {
    _name = json['name'];
    _id = json['id'];
    if (json['activities'] != null) {
      _activities = [];
      json['activities'].forEach((v) {
        _activities!.add(ActivitiesModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = _name;
    data['id'] = _id;
    if (_activities != null) {
      data['activities'] = _activities!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
