class ActivityResult {
  int? _id;
  String? _name;
  String? _type;
  String? _test;
  String? _startDate;
  String? _startTime;
  String? _endTime;
  String? _endDate;
  int? _syllabusId;
  int? _status;
  String? _createdAt;
  String? _updatedAt;
  int? _activityId;
  String? _tips;
  int? _cost;
  int? _bankClone;
  int? _sendEmail;
  String? _uuid;
  String? _activityBankMyBank;
  int? _packageId;
  int? _bank;
  String? _bankName;
  int? _question;
  int? _bankType;
  String? _bankDistributeCode;
  int? _isTested;
  String? _activityType;
  int? _questionIndex;

  ActivityResult([
    this._id,
    this._name,
    this._type,
    this._test,
    this._startDate,
    this._startTime,
    this._endTime,
    this._endDate,
    this._syllabusId,
    this._status,
    this._createdAt,
    this._updatedAt,
    this._activityId,
    this._tips,
    this._cost,
    this._bankClone,
    this._sendEmail,
    this._uuid,
    this._activityBankMyBank,
    this._packageId,
    this._bank,
    this._bankName,
    this._question,
    this._bankType,
    this._bankDistributeCode,
    this._isTested,
    this._activityType,
    this._questionIndex,
  ]);

  get id => _id ?? 0;

  set id(value) => _id = value;

  get name => _name ?? '';

  set name(value) => _name = value;

  get type => _type ?? '';

  set type(value) => _type = value;

  get test => _test;

  set test(value) => _test = value;

  get startDate => _startDate;

  set startDate(value) => _startDate = value;

  get startTime => _startTime;

  set startTime(value) => _startTime = value;

  get endTime => _endTime;

  set endTime(value) => _endTime = value;

  get endDate => _endDate;

  set endDate(value) => _endDate = value;

  get syllabusId => _syllabusId;

  set syllabusId(value) => _syllabusId = value;

  get status => _status;

  set status(value) => _status = value;

  get createdAt => _createdAt;

  set createdAt(value) => _createdAt = value;

  get updatedAt => _updatedAt;

  set updatedAt(value) => _updatedAt = value;

  get activityId => _activityId;

  set activityId(value) => _activityId = value;

  get tips => _tips;

  set tips(value) => _tips = value;

  get cost => _cost;

  set cost(value) => _cost = value;

  get bankClone => _bankClone;

  set bankClone(value) => _bankClone = value;

  get sendEmail => _sendEmail;

  set sendEmail(value) => _sendEmail = value;

  get uuid => _uuid;

  set uuid(value) => _uuid = value;

  get activityBankMyBank => _activityBankMyBank;

  set activityBankMyBank(value) => _activityBankMyBank = value;

  get packageId => _packageId;

  set packageId(value) => _packageId = value;

  get bank => _bank;

  set bank(value) => _bank = value;

  get bankName => _bankName;

  set bankName(value) => _bankName = value;

  get question => _question;

  set question(value) => _question = value;

  get bankType => _bankType;

  set bankType(value) => _bankType = value;

  get bankDistributeCode => _bankDistributeCode;

  set bankDistributeCode(value) => _bankDistributeCode = value;

  get isTested => _isTested;

  set isTested(value) => _isTested = value;

  get activityType => _activityType;

  set activityType(value) => _activityType = value;

  get questionIndex => _questionIndex;

  set questionIndex(value) => _questionIndex = value;

  ActivityResult.fromJson(Map<String, dynamic> itemData) {
    _id = itemData['id'] ?? 0;
    _name = itemData['name'] ?? '';
    _type = itemData['type'] ?? '';
    _test = itemData['test'] ?? '';
    _startDate = itemData['start_date'] ?? '';
    _startTime = itemData['start_time'] ?? '';
    _endTime = itemData['end_time'] ?? '';
    _endDate = itemData['end_date'] ?? '';
    _syllabusId = itemData['giaotrinh_id'] ?? 0;
    _status = itemData['status'] ?? 0;
    _createdAt = itemData['created_at'] ?? '';
    _updatedAt = itemData['updated_at'] ?? '';
    _activityId = itemData['activity_id'] ?? 0;
    _tips = itemData['tips'] ?? '';
    _cost = itemData['cost'] ?? 0;
    _bankClone = itemData['bank_clone'] ?? 0;
    _sendEmail = itemData['send_email'] ?? 0;
    _uuid = itemData['uuid'] ?? '';
    _activityBankMyBank = itemData['activity_bank_my_bank'] ?? '';
    _packageId = itemData['package_id'] ?? 0;
    _bank = itemData['bank'] ?? 0;
    _bankName = itemData['bank_name'] ?? '';
    _question = itemData['question'] ?? 0;
    _bankType = itemData['bank_type'] ?? 0;
    _bankDistributeCode = itemData['bank_distribute_code'] ?? '';
    _isTested = itemData['is_tested'] ?? 0;
    _activityType = itemData['activity_type'] ?? '';
    _questionIndex = itemData['question_index'] ?? 0;
  }
}
