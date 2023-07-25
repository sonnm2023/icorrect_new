class ActivityResult {
  int? _id;
  String? _name;
  String? _type;
  String? _test;
  String? _startDate;
  String? _startTime;
  String? _endTime;
  String? _endDate;
  String? _syllabusId;
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

  get id => this._id ?? 0;

  set id(value) => this._id = value;

  get name => this._name ?? '';

  set name(value) => this._name = value;

  get type => this._type ?? '';

  set type(value) => this._type = value;

  get test => this._test;

  set test(value) => this._test = value;

  get startDate => this._startDate;

  set startDate(value) => this._startDate = value;

  get startTime => this._startTime;

  set startTime(value) => this._startTime = value;

  get endTime => this._endTime;

  set endTime(value) => this._endTime = value;

  get endDate => this._endDate;

  set endDate(value) => this._endDate = value;

  get syllabusId => this._syllabusId;

  set syllabusId(value) => this._syllabusId = value;

  get status => this._status;

  set status(value) => this._status = value;

  get createdAt => this._createdAt;

  set createdAt(value) => this._createdAt = value;

  get updatedAt => this._updatedAt;

  set updatedAt(value) => this._updatedAt = value;

  get activityId => this._activityId;

  set activityId(value) => this._activityId = value;

  get tips => this._tips;

  set tips(value) => this._tips = value;

  get cost => this._cost;

  set cost(value) => this._cost = value;

  get bankClone => this._bankClone;

  set bankClone(value) => this._bankClone = value;

  get sendEmail => this._sendEmail;

  set sendEmail(value) => this._sendEmail = value;

  get uuid => this._uuid;

  set uuid(value) => this._uuid = value;

  get activityBankMyBank => this._activityBankMyBank;

  set activityBankMyBank(value) => this._activityBankMyBank = value;

  get packageId => this._packageId;

  set packageId(value) => this._packageId = value;

  get bank => this._bank;

  set bank(value) => this._bank = value;

  get bankName => this._bankName;

  set bankName(value) => this._bankName = value;

  get question => this._question;

  set question(value) => this._question = value;

  get bankType => this._bankType;

  set bankType(value) => this._bankType = value;

  get bankDistributeCode => this._bankDistributeCode;

  set bankDistributeCode(value) => this._bankDistributeCode = value;

  get isTested => this._isTested;

  set isTested(value) => this._isTested = value;

  get activityType => this._activityType;

  set activityType(value) => this._activityType = value;

  get questionIndex => this._questionIndex;

  set questionIndex(value) => this._questionIndex = value;

  ActivityResult.fromJson(Map<String, dynamic> itemData) {
    _id = itemData['id'] ?? 0;
    _name = itemData['name'] ?? '';
    _type = itemData['type'] ?? '';
    _test = itemData['test'] ?? '';
    _startDate = itemData['start_date'] ?? '';
    _startTime = itemData['start_time'] ?? '';
    _endTime = itemData['end_time'] ?? '';
    _endDate = itemData['end_date'] ?? '';
    _syllabusId = itemData['giaotrinh_id'] ?? '';
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
