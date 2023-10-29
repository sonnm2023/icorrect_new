class StudentModel {
  int? _id;
  String? _name;
  String? _email;
  String? _emailVerifyAt;
  String? _createdAt;
  String? _updatedAt;
  String? _inviteCode;
  String? _phone;
  int? _rule;
  String? _age;
  String? _address;
  String? _deletedAt;
  int? _centerId;
  int? _apiId;
  int? _classId;
  String? _uuid;
  int? _canCreateMyBank;
  String? _studentClassName;
  String? _province;

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

  get id => _id;

  set id(value) => _id = value;

  get name => _name ?? '';

  set name(value) => _name = value;

  get email => _email ?? '';

  set email(value) => _email = value;

  get emailVerifyAt => _emailVerifyAt ?? '';

  set emailVerifyAt(value) => _emailVerifyAt = value;

  get createdAt => _createdAt ?? '';

  set createdAt(value) => _createdAt = value;

  get updatedAt => _updatedAt ?? '';

  set updatedAt(value) => _updatedAt = value;

  get inviteCode => _inviteCode ?? '';

  set inviteCode(value) => _inviteCode = value;

  get phone => _phone ?? '';

  set phone(value) => _phone = value;

  get rule => _rule ?? '';

  set rule(value) => _rule = value;

  get age => _age ?? '';

  set age(value) => _age = value;

  get address => _address ?? '';

  set address(value) => _address = value;

  get deletedAt => _deletedAt ?? '';

  set deletedAt(value) => _deletedAt = value;

  get centerId => _centerId ?? '';

  set centerId(value) => _centerId = value;

  get apiId => _apiId ?? '';

  set apiId(value) => _apiId = value;

  get classId => _classId ?? '';

  set classId(value) => _classId = value;

  get uuid => _uuid ?? '';

  set uuid(value) => _uuid = value;

  get canCreateMyBank => _canCreateMyBank ?? '';

  set canCreateMyBank(value) => _canCreateMyBank = value;

  get studentClassName => _studentClassName ?? '';

  set studentClassName(value) => _studentClassName = value;

  get province => _province ?? '';

  set province(value) => _province = value;

  StudentModel.fromJson(Map<String, dynamic> itemData) {
    _id = itemData['id'] ?? 0;
    _name = itemData['name'] ?? '';
    _email = itemData['email'] ?? '';
    _emailVerifyAt = itemData['email_verified_at'] ?? '';
    _createdAt = itemData['created_at'] ?? '';
    _updatedAt = itemData['updated_at'] ?? '';
    _inviteCode = itemData['invite_code'] ?? '';
    _phone = itemData['phone'] ?? '';
    _rule = itemData['rule'] ?? 0;
    _age = itemData['age'] ?? '';
    _address = itemData['address'] ?? '';
    deletedAt = itemData['deleted_at'] ?? '';
    _centerId = itemData['center_id'] ?? 0;
    _apiId = itemData['api_id'] ?? 0;
    _classId = itemData['class_id'] ?? 0;
    _uuid = itemData['uuid'] ?? '';
    _canCreateMyBank = itemData['can_create_mybank'] ?? 0;
    _studentClassName = itemData['student_class_name'] ?? '';
    _province = itemData['province'] ?? '';
  }
}
