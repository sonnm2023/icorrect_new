class StudentModel {
  var _id;
  var _name;
  var _email;
  var _emailVerifyAt;
  var _createdAt;
  var _updatedAt;
  var _inviteCode;
  var _phone;
  var _rule;
  var _age;
  var _address;
  var _deletedAt;
  var _centerId;
  var _apiId;
  var _classId;
  var _uuid;
  var _canCreateMyBank;
  var _studentClassName;
  var _province;

  StudentModel([
    this._id,
    this._name,
    this._email,
    this._emailVerifyAt,
    this._createdAt,
    this._updatedAt,
    this._inviteCode,
    this._phone,
    this._rule,
    this._age,
    this._address,
    this._deletedAt,
    this._centerId,
    this._apiId,
    this._classId,
    this._uuid,
    this._canCreateMyBank,
    this._studentClassName,
    this._province,
  ]);

  get id => this._id;

  set id(value) => this._id = value;

  get name => this._name ?? '';

  set name(value) => this._name = value;

  get email => this._email ?? '';

  set email(value) => this._email = value;

  get emailVerifyAt => this._emailVerifyAt ?? '';

  set emailVerifyAt(value) => this._emailVerifyAt = value;

  get createdAt => this._createdAt ?? '';

  set createdAt(value) => this._createdAt = value;

  get updatedAt => this._updatedAt ?? '';

  set updatedAt(value) => this._updatedAt = value;

  get inviteCode => this._inviteCode ?? '';

  set inviteCode(value) => this._inviteCode = value;

  get phone => this._phone ?? '';

  set phone(value) => this._phone = value;

  get rule => this._rule ?? '';

  set rule(value) => this._rule = value;

  get age => this._age ?? '';

  set age(value) => this._age = value;

  get address => this._address ?? '';

  set address(value) => this._address = value;

  get deletedAt => this._deletedAt ?? '';

  set deletedAt(value) => this._deletedAt = value;

  get centerId => this._centerId ?? '';

  set centerId(value) => this._centerId = value;

  get apiId => this._apiId ?? '';

  set apiId(value) => this._apiId = value;

  get classId => this._classId ?? '';

  set classId(value) => this._classId = value;

  get uuid => this._uuid ?? '';

  set uuid(value) => this._uuid = value;

  get canCreateMyBank => this._canCreateMyBank ?? '';

  set canCreateMyBank(value) => this._canCreateMyBank = value;

  get studentClassName => this._studentClassName ?? '';

  set studentClassName(value) => this._studentClassName = value;

  get province => this._province ?? '';

  set province(value) => this._province = value;
}