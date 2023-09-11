import 'package:icorrect/src/models/my_test_models/skill_file_detail_model.dart';

class SkillProblem {
  int? _id;
  String? _problem;
  String? _solution;
  int? _type;
  int? _orderId;
  String? _component;
  int? _fileId;
  String? _exampleText;
  String? _updatedAt;
  String? _createdAt;
  String? _deletedAt;
  String? _typeName;
  String? _fileName;
  SkillFileDetail? _fileDetail;

  SkillProblem(
      [this._id,
      this._problem,
      this._solution,
      this._type,
      this._orderId,
      this._component,
      this._fileId,
      this._exampleText,
      this._updatedAt,
      this._createdAt,
      this._deletedAt,
      this._typeName,
      this._fileName,
      this._fileDetail]);

  int? get id => this._id ?? 0;

  set id(int? value) => this._id = value;

  get problem => this._problem ?? '';

  set problem(value) => this._problem = value;

  get solution => this._solution ?? '';

  set solution(value) => this._solution = value;

  get type => this._type ?? 0;
  set type(value) => this._type = value;

  get orderId => this._orderId ?? 0;

  set orderId(value) => this._orderId = value;

  get component => this._component ?? '';

  set component(value) => this._component = value;

  get fileId => this._fileId ?? 0;

  set fileId(value) => this._fileId = value;

  get exampleText => this._exampleText ?? '';

  set exampleText(value) => this._exampleText = value;

  get updatedAt => this._updatedAt ?? '';

  set updatedAt(value) => this._updatedAt = value;

  get createdAt => this._createdAt ?? '';

  set createdAt(value) => this._createdAt = value;

  get deletedAt => this._deletedAt ?? '';

  set deletedAt(value) => this._deletedAt = value;

  get typeName => this._typeName ?? '';

  set typeName(value) => this._typeName = value;

  get fileName => this._fileName ?? '';

  set fileName(value) => this._fileName = value;

 SkillFileDetail? get fileDetail => this._fileDetail;

  set fileDetail(value) => this._fileDetail = value;

  SkillProblem.fromJson(Map<String, dynamic> json) {
    _id = json['id'] ?? 0;
    _problem = json['problem'] ?? '';
    _solution = json['solution'] ?? '';
    _type = json['type'] ?? 0;
    _orderId = json['order_id'] ?? 0;
    _component = json['component'] ?? '';
    _fileId = json['file_id'] ?? 0;
    _exampleText = json['example_text'] ?? '';
    _updatedAt = json['updated_at'] ?? '';
    _createdAt = json['created_at'] ?? '';
    _deletedAt = json['deleted_at'] ?? '';
    _typeName = json['type_name'] ?? '';
    _fileName = json['file_name'] ?? '';
    _fileDetail = SkillFileDetail.fromJson(json['file'] ?? SkillFileDetail());
  }
}