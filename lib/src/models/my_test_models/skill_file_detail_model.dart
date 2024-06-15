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

  int? get id => _id ?? 0;

  set id(int? value) => _id = value;

  get url => _url ?? '';

  set url(value) => _url = value;

  get fileName => _fileName ?? '';

  set fileName(value) => _fileName = value;

  get description => _description ?? '';

  set description(value) => _description = value;

  get type => _type ?? 0;

  set type(value) => _type = value;

  get createdBy => _createdBy ?? 0;

  set createdBy(value) => _createdBy = value;

  get updatedBy => _updatedBy ?? 0;

  set updatedBy(value) => _updatedBy = value;

  get updatedAt => _updatedAt ?? '';

  set updatedAt(value) => _updatedAt = value;

  get createdAt => _createdAt ?? '';

  set createdAt(value) => _createdAt = value;

  get deletedAt => _deletedAt ?? '';

  set deletedAt(value) => _deletedAt = value;

  get staffId => _staffId ?? 0;

  set staffId(value) => _staffId = value;

  get distributeCode => _distributeCode ?? '';

  set distributeCode(value) => _distributeCode = value;

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
