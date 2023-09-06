import 'dart:convert';

import 'package:icorrect/src/models/homework_models/homework_model.dart';



ListHomeWorkModel homeworkModelFromJson(String str) => ListHomeWorkModel.fromJson(json.decode(str));
String homeworkModelToJson(ListHomeWorkModel data) => json.encode(data.toJson());

class ListHomeWorkModel {
  List<HomeWorkModel>? _list;

  ListHomeWorkModel({List<HomeWorkModel>? list}) {
    _list = list;
  }

  List<HomeWorkModel> get list => _list ?? [];
  set orderId(List<HomeWorkModel> list) => _list = list;

  ListHomeWorkModel.fromJson(Map<String, dynamic> json) {
    _list = json['list'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['list'] = _list;
    return data;
  }
}
