class FileAuthDetailModel {
  int? _id;
  String? _url;
  String? _fileName;
  String? _description;
  int? _type;
  int? _createdBy;
  int? _updatedBy;
  String? _updateAt;
  String? _createAt;
  String? _deleteAt;
  int? _staffId;
  String? _distributeCode;
  int? _userId;

  FileAuthDetailModel(
      [this._id,
      this._url,
      this._fileName,
      this._description,
      this._type,
      this._createdBy,
      this._updatedBy,
      this._updateAt,
      this._createAt,
      this._deleteAt,
      this._staffId,
      this._distributeCode,
      this._userId]);

  int? get id => _id ?? 0;

  set id(int? value) => _id = value;

  String get url => _url ?? "";

  set url(value) => _url = value;

  String get fileName => _fileName ?? "";

  set fileName(value) => _fileName = value;

  String get description => _description ?? "";

  set description(value) => _description = value;

  int get type => _type ?? 0;

  set type(value) => _type = value;

  int get createdBy => _createdBy ?? 0;

  set createdBy(value) => _createdBy = value;

  int get updatedBy => _updatedBy ?? 0;

  set updatedBy(value) => _updatedBy = value;

  String get updateAt => _updateAt ?? "";

  set updateAt(value) => _updateAt = value;

  String get createAt => _createAt ?? "";

  set createAt(value) => _createAt = value;

  String get deleteAt => _deleteAt ?? "";

  set deleteAt(value) => _deleteAt = value;

  int get staffId => _staffId ?? 0;

  set staffId(value) => _staffId = value;

  String get distributeCode => _distributeCode ?? "";

  set distributeCode(value) => _distributeCode = value;

  int get userId => _userId ?? 0;

  set userId(value) => _userId = value;

  FileAuthDetailModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'] ?? 0;
    _url = json['url'] ?? "";
    _fileName = json['file_name'] ?? "";
    _description = json['description'] ?? "";
    _type = json['type'] ?? 0;
    _createdBy = json['created_by'] ?? 0;
    _updatedBy = json['updated_by'] ?? 0;
    _updateAt = json['updated_at'] ?? "";
    _createAt = json['created_at'] ?? "";
    _deleteAt = json['deleted_at'] ?? "";
    _staffId = json['staff_id'] ?? 0;
    _distributeCode = json['distribute_code'] ?? "";
    _userId = json['user_id'] ?? 0;
  }
}
