import 'dart:convert';

import 'package:icorrect/src/data_sources/utils.dart';

FileTopicModel fileTopicModelFromJson(String str) =>
    FileTopicModel.fromJson(json.decode(str));
String fileTopicModelToJson(FileTopicModel data) => json.encode(data.toJson());

enum FileTopicType {none, introduce, question, answer, followup, end_of_take_note, end_of_test }

class FileTopicModel {
  int? _id;
  String? _url;
  int? _type;
  int? _numPart;
  FileTopicType? _fileTopicType;

  FileTopicModel({int? id, String? url, int? type, int? numPart, FileTopicType? fileTopicType}) {
    _id = id;
    _url = url;
    _type = type;
    _numPart = numPart;
    _fileTopicType = fileTopicType;
  }

  int get id => _id ?? 0;
  set id(int id) => _id = id;
  String get url => _url ?? "";
  set url(String url) => _url = url;
  int get type => _type ?? 0;
  set type(int type) => _type = type;
  int get numPart => _numPart ?? 0;
  set numPart(int numPart) => _numPart = numPart;
  FileTopicType get fileTopicType => _fileTopicType ?? FileTopicType.none;
  set fileTopicType(FileTopicType fileTopicType) => _fileTopicType = fileTopicType;

  FileTopicModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    if (json['url'] != null) {
      _url = Utils.convertFileName(json['url']);
    }
    _type = json['type'];
  }

  FileTopicModel.fromAnswerJson(Map<String, dynamic> json) {
    _id = json['file_id'];
    if (json['file_link'] != null) {
      _url = json['file_link'].toString();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['url'] = _url;
    data['type'] = _type;
    return data;
  }
}
