import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';

class IELTSTopicModel {
  int? _id;
  String? _title;
  String? _description;
  int? _topicType;
  int? _status;
  int? _level;
  int? _staffCreated;
  int? _staffUpdated;
  String? _updatedAt;
  String? _createdAt;
  String? _deletedAt;
  String? _distributeCode;
  String? _merchantId;
  List<FileTopicModel>? _files= [];

  int get id => _id ?? 0;

  set id(int? value) => _id = value;

  String get title => _title ?? "";

  set title(value) => _title = value;

  String get description => _description ?? "";

  set description(value) => _description = value;

  int get topicType => _topicType ?? 0;

  set topicType(value) => _topicType = value;

  int get status => _status ?? 0;

  set status(value) => _status = value;

  int get level => _level ?? 0;

  set level(value) => _level = value;

  int get staffCreated => _staffCreated ?? 0;

  set staffCreated(value) => _staffCreated = value;

  int get staffUpdated => _staffUpdated ?? 0;

  set staffUpdated(value) => _staffUpdated = value;

  String get updatedAt => _updatedAt ?? "";

  set updatedAt(value) => _updatedAt = value;

  String get createdAt => _createdAt ?? "";

  set createdAt(value) => _createdAt = value;

  String get deletedAt => _deletedAt ?? "";

  set deletedAt(value) => _deletedAt = value;

  String get distributeCode => _distributeCode ?? "";

  set distributeCode(value) => _distributeCode = value;

  String get merchantId => _merchantId ?? "";

  set merchantId(value) => _merchantId = value;

  List<FileTopicModel> get files => _files ?? [];

  set files(value) => _files = value;

  IELTSTopicModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _title = json['title'];
    _description = json['description'];
    _topicType = json['topic_type'];
    _status = json['status'];
    _level = json['level'];
    _staffCreated = json['staff_created'];
    _staffUpdated = json['staff_updated'];
    _updatedAt = json['updated_at'];
    _createdAt = json['created_at'];
    _deletedAt = json['deleted_at'];
    _distributeCode = json['distribute_code'];
    _merchantId = json['merchant_id'];

    if (json['files'] != null) {
      json['files'].forEach((v) {
        if (_files!.isEmpty) {
          _files!.add(FileTopicModel.fromJson(v));
        }
      });
    }
  }
}
