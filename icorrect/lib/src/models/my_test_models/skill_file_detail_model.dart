class SkillFileDetail {
  var _id;
  var _url;
  var _fileName;
  var _description;
  var _type;
  var _createdBy;
  var _updatedBy;
  var _updatedAt;
  var _createdAt;
  var _deletedAt;
  var _staffId;
  var _distributeCode;

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

  get id => this._id;

  set id(value) => this._id = value;

  get url => this._url;

  set url(value) => this._url = value;

  get fileName => this._fileName;

  set fileName(value) => this._fileName = value;

  get description => this._description;

  set description(value) => this._description = value;

  get type => this._type;

  set type(value) => this._type = value;

  get createdBy => this._createdBy;

  set createdBy(value) => this._createdBy = value;

  get updatedBy => this._updatedBy;

  set updatedBy(value) => this._updatedBy = value;

  get updatedAt => this._updatedAt;

  set updatedAt(value) => this._updatedAt = value;

  get createdAt => this._createdAt;

  set createdAt(value) => this._createdAt = value;

  get deletedAt => this._deletedAt;

  set deletedAt(value) => this._deletedAt = value;

  get staffId => this._staffId;

  set staffId(value) => this._staffId = value;

  get distributeCode => this._distributeCode;

  set distributeCode(value) => this._distributeCode = value;
}