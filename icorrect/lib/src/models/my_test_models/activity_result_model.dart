class ActivityResult {
  var _id;
  var _name;
  var _type;
  var _test;
  var _startDate;
  var _startTime;
  var _endTime;
  var _endDate;
  var _syllabusId;
  var _status;
  var _createdAt;
  var _updatedAt;
  var _activityId;
  var _tips;
  var _cost;
  var _bankClone;
  var _sendEmail;
  var _uuid;
  var _activityBankMyBank;
  var _packageId;
  var _bank;
  var _bankName;
  var _question;
  var _bankType;
  var _bankDistributeCode;
  var _isTested;
  var _activityType;
  var _questionType;
  var _questionIndex;

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
    this._questionType,
    this._questionIndex,
  ]);

  get id => this._id;

  set id(value) => this._id = value;

  get name => this._name ?? '';

  set name(value) => this._name = value;

  get type => this._type ?? '';

  set type(value) => this._type = value;

  get test => this._test ?? '';

  set test(value) => this._test = value;

  get startDate => this._startDate ?? '';

  set startDate(value) => this._startDate = value;

  get startTime => this._startTime ?? '';

  set startTime(value) => this._startTime = value;

  get endTime => this._endTime ?? '';

  set endTime(value) => this._endTime = value;

  get endDate => this._endDate ?? '';

  set endDate(value) => this._endDate = value;

  get syllabusId => this._syllabusId ?? '';

  set syllabusId(value) => this._syllabusId = value;

  get status => this._status ?? '';

  set status(value) => this._status = value;

  get createdAt => this._createdAt ?? '';

  set createdAt(value) => this._createdAt = value;

  get updatedAt => this._updatedAt ?? '';

  set updatedAt(value) => this._updatedAt = value;

  get activityId => this._activityId ?? '';

  set activityId(value) => this._activityId = value;

  get tips => this._tips ?? '';

  set tips(value) => this._tips = value;

  get cost => this._cost ?? '';

  set cost(value) => this._cost = value;

  get bankClone => this._bankClone ?? '';

  set bankClone(value) => this._bankClone = value;

  get sendEmail => this._sendEmail ?? '';

  set sendEmail(value) => this._sendEmail = value;

  get uuid => this._uuid ?? '';

  set uuid(value) => this._uuid = value;

  get activityBankMyBank => this._activityBankMyBank ?? '';

  set activityBankMyBank(value) => this._activityBankMyBank = value;

  get packageId => this._packageId ?? '';

  set packageId(value) => this._packageId = value;

  get bank => this._bank ?? '';

  set bank(value) => this._bank = value;

  get bankName => this._bankName ?? '';

  set bankName(value) => this._bankName = value;

  get question => this._question ?? '';

  set question(value) => this._question = value;

  get bankType => this._bankType ?? '';

  set bankType(value) => this._bankType = value;

  get bankDistributeCode => this._bankDistributeCode ?? '';

  set bankDistributeCode(value) => this._bankDistributeCode = value;

  get isTested => this._isTested ?? '';

  set isTested(value) => this._isTested = value;

  get activityType => this._activityType ?? '';

  set activityType(value) => this._activityType = value;

  get questionType => this._questionType ?? '';

  set questionType(value) => this._questionType = value;

  get questionIndex => this._questionIndex ?? '';

  set questionIndex(value) => this._questionIndex = value;
}