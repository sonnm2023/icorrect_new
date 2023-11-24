class MyPracticeTestModel {
  int? _id;
  int? _status;
  String? _checkSum;
  int? _type;
  int? _createdBy;
  int? _updatedBy;
  String? _updatedAt;
  String? _createdAt;
  String? _deleteAt;
  String? _duration;

  MyPracticeTestModel(
      [this._id,
      this._status,
      this._checkSum,
      this._type,
      this._createdBy,
      this._updatedBy,
      this._updatedAt,
      this._createdAt,
      this._deleteAt,
      this._duration]);

  int get id => _id ?? 0;

  set id(int? value) => _id = value;

  int get status => _status ?? 0;

  set status(value) => _status = value;

  String get checkSum => _checkSum ?? "";

  set checkSum(value) => _checkSum = value;

  int get type => _type ?? 0;

  set type(value) => _type = value;

  int get createdBy => _createdBy ?? 0;

  set createdBy(value) => _createdBy = value;

  int get updatedBy => _updatedBy ?? 0;

  set updatedBy(value) => _updatedBy = value;

  String get updatedAt => _updatedAt ?? "";

  set updatedAt(value) => _updatedAt = value;

  String get createdAt => _createdAt ?? "";

  set createdAt(value) => _createdAt = value;

  String get deleteAt => _deleteAt ?? "";

  set deleteAt(value) => _deleteAt = value;

  String get duration => _duration ?? "";

  set duration(value) => _duration = value;

  MyPracticeTestModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'] ?? 0;
    _status = json['status'] ?? 0;
    _checkSum = json['check_sum'] ?? "";
    _type = json['type'] ?? 0;
    _createdBy = json['created_by'] ?? 0;
    _updatedBy = json['updated_by'] ?? 0;
    _updatedAt = json['updated_at'] ?? "";
    _createdAt = json['created_at'] ?? "";
    _deleteAt = json['deleted_at'] ?? "";
    _duration = json['duration'] ?? "";
  }
}
