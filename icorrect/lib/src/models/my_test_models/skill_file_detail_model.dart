class SkillFileDetail {
  int? _id;
  String? _url;
  String? _fileName;
  String? _description;
  int? _type;
  int? _createdBy;
  int? _updatedBy;
  String? _updatedAt;
  String? _createdAt;
  String? _deletedAt;
  int? _staffId;
  String? _distributeCode;

  SkillFileDetail(
      [this._id,
      this._url,
      this._fileName,
      this._description,
      this._type,
      this._createdBy,
      this._updatedBy,
      this._updatedAt,
      this._createdAt,
      this._deletedAt,
      this._staffId,
      this._distributeCode]);

  int? get id => this._id ?? 0;

  set id(int? value) => this._id = value;

  get url => this._url ?? '';

  set url(value) => this._url = value;

  get fileName => this._fileName ?? '';

  set fileName(value) => this._fileName = value;

  get description => this._description ?? '';

  set description(value) => this._description = value;

  get type => this._type ?? 0;

  set type(value) => this._type = value;

  get createdBy => this._createdBy ?? 0;

  set createdBy(value) => this._createdBy = value;

  get updatedBy => this._updatedBy ?? 0;

  set updatedBy(value) => this._updatedBy = value;

  get updatedAt => this._updatedAt ?? '';

  set updatedAt(value) => this._updatedAt = value;

  get createdAt => this._createdAt ?? '';

  set createdAt(value) => this._createdAt = value;

  get deletedAt => this._deletedAt ?? '';

  set deletedAt(value) => this._deletedAt = value;

  get staffId => this._staffId ?? 0;

  set staffId(value) => this._staffId = value;

  get distributeCode => this._distributeCode ?? '';

  set distributeCode(value) => this._distributeCode = value;

  SkillFileDetail.fromJson(Map<String, dynamic> json) {
    _id = json['id'] ?? 0;
    _url = json['url'] ?? '';
    _fileName = json['file_name'] ?? '';
    _description = json['description'] ?? '';
    _type = json['type'] ?? 0;
    _createdBy = json['created_by'] ?? 0;
    _updatedBy = json['updated_by'] ?? 0;
    _updatedAt = json['updated_at'] ?? '';
    _createdAt = json['created_at'] ?? '';
    _deletedAt = json['deleted_at'] ?? '';
    _staffId = json['staff_id'] ?? 0;
    _distributeCode = json['distribute_code'] ?? '';
  }
}
