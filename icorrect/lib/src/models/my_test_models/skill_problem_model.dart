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

  int? get id => _id ?? 0;

  set id(int? value) => _id = value;

  get problem => _problem ?? '';

  set problem(value) => _problem = value;

  get solution => _solution ?? '';

  set solution(value) => _solution = value;

  get type => _type ?? 0;
  set type(value) => _type = value;

  get orderId => _orderId ?? 0;

  set orderId(value) => _orderId = value;

  get component => _component ?? '';

  set component(value) => _component = value;

  get fileId => _fileId ?? 0;

  set fileId(value) => _fileId = value;

  get exampleText => _exampleText ?? '';

  set exampleText(value) => _exampleText = value;

  get updatedAt => _updatedAt ?? '';

  set updatedAt(value) => _updatedAt = value;

  get createdAt => _createdAt ?? '';

  set createdAt(value) => _createdAt = value;

  get deletedAt => _deletedAt ?? '';

  set deletedAt(value) => _deletedAt = value;

  get typeName => _typeName ?? '';

  set typeName(value) => _typeName = value;

  get fileName => _fileName ?? '';

  set fileName(value) => _fileName = value;

  SkillFileDetail? get fileDetail => _fileDetail;

  set fileDetail(value) => _fileDetail = value;

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
    _fileDetail = SkillFileDetail.fromJson(json['file'] ?? {});
  }
}
