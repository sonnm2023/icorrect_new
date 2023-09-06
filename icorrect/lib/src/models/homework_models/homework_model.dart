import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:icorrect/src/models/homework_models/submited_model.dart';

HomeWorkModel homeworkModelFromJson(String str) =>
    HomeWorkModel.fromJson(json.decode(str));
String homeworkModelToJson(HomeWorkModel data) => json.encode(data.toJson());

class HomeWorkModel {
  int? _id;
  String? _name;
  String? _type;
  String? _test;
  String? _startDate;
  String? _startTime;
  String? _endTime;
  String? _endDate;
  String? _giaotrinhId;
  int? _status;
  String? _createdAt;
  String? _updatedAt;
  int? _activityId;
  String? _tips;
  int? _cost;
  int? _sendEmail;
  String? _uuid;
  dynamic _activityBankMyBank;
  int? _packageId;
  String? _dateTimeRelease;
  String? _dateTimeEnd;
  int? _question;
  String? _start;
  String? _end;
  int? _completeStatus;
  SubmittedDateModel? _submittedDateModel;
  String? _orderId;
  String? _aiResponseLink;
  int? _haveAiReponse;
  String? _aiScore;
  int? _aiOrder;
  String? _testId;
  int? _testOption;
  String? _className;
  int? _classId;
  int? _bank;
  String? _bankName;
  int? _bankType;
  String? _bankDistributeCode;
  int? _isTested;
  String? _activityType;
  int? _questionIndex;

  HomeWorkModel(
      {int? id,
      String? name,
      String? type,
      String? test,
      String? startDate,
      String? startTime,
      String? endTime,
      String? endDate,
      String? giaotrinhId,
      int? status,
      String? createdAt,
      String? updatedAt,
      int? activityId,
      String? tips,
      int? cost,
      dynamic bankClone,
      int? sendEmail,
      String? uuid,
      dynamic activityBankMyBank,
      int? packageId,
      String? dateTimeRelease,
      String? dateTimeEnd,
      int? question,
      String? start,
      String? end,
      int? completeStatus,
      SubmittedDateModel? submitedDateModel,
      String? orderId,
      String? aiResponseLink,
      int? haveAiReponse,
      String? aiScore,
      int? aiOrder,
      String? testId,
      int? testOption,
      String? className,
      int? classId,
      int? bank,
      String? bankName,
      int? bankType,
      String? bankDistributeCode,
      int? isTested,
      String? activityType,
      int? questionIndex}) {
    _id = id;
    _name = name;
    _type = type;
    _test = test;
    _startDate = startDate;
    _startTime = startTime;
    _endTime = endTime;
    _endDate = endDate;
    _giaotrinhId = giaotrinhId;
    _status = status;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _activityId = activityId;
    _tips = tips;
    _cost = cost;
    _sendEmail = sendEmail;
    _uuid = uuid;
    _activityBankMyBank = activityBankMyBank;
    _packageId = packageId;
    _dateTimeRelease = dateTimeRelease;
    _dateTimeEnd = dateTimeEnd;
    _question = question;
    _start = start;
    _end = end;
    _completeStatus = completeStatus;
    _submittedDateModel = submittedDateModel;
    _orderId = orderId;
    _aiResponseLink = aiResponseLink;
    _haveAiReponse = haveAiReponse;
    _aiScore = aiScore;
    _aiOrder = aiOrder;
    _testId = testId;
    _testOption = testOption;
    _className = className;
    _classId = classId;
    _bank = bank;
    _bankName = bankName;
    _bankType = bankType;
    _bankDistributeCode = bankDistributeCode;
    _isTested = isTested;
    _activityType = activityType;
    _questionIndex = questionIndex;
  }

  int get id => _id ?? 0;
  set id(int id) => _id = id;
  String get name => _name ?? "";
  set name(String name) => _name = name;
  String get type => _type ?? "";
  set type(String type) => _type = type;
  String get test => _test ?? "";
  set test(String test) => _test = test;
  String get startDate => _startDate ?? "";
  set startDate(String startDate) => _startDate = startDate;
  String get startTime => _startTime ?? "";
  set startTime(String startTime) => _startTime = startTime;
  String get endTime => _endTime ?? "";
  set endTime(String endTime) => _endTime = endTime;
  String get endDate => _endDate ?? "";
  set endDate(String endDate) => _endDate = endDate;
  String get giaotrinhId => _giaotrinhId ?? "";
  set giaotrinhId(String giaotrinhId) => _giaotrinhId = giaotrinhId;
  int get status => _status ?? 0;
  set status(int status) => _status = status;
  String get createdAt => _createdAt ?? "";
  set createdAt(String createdAt) => _createdAt = createdAt;
  String get updatedAt => _updatedAt ?? "";
  set updatedAt(String updatedAt) => _updatedAt = updatedAt;
  int get activityId => _activityId ?? 0;
  set activityId(int activityId) => _activityId = activityId;
  String get tips => _tips ?? "";
  set tips(String tips) => _tips = tips;
  int get cost => _cost ?? 0;
  set cost(int cost) => _cost = cost;
  int get sendEmail => _sendEmail ?? 0;
  set sendEmail(int sendEmail) => _sendEmail = sendEmail;
  String get uuid => _uuid ?? "";
  set uuid(String uuid) => _uuid = uuid;
  String get activityBankMyBank => _activityBankMyBank;
  set activityBankMyBank(String activityBankMyBank) =>
      _activityBankMyBank = activityBankMyBank;
  int get packageId => _packageId ?? 0;
  set packageId(int packageId) => _packageId = packageId;
  String get dateTimeRelease => _dateTimeRelease ?? "";
  set dateTimeRelease(String dateTimeRelease) =>
      _dateTimeRelease = dateTimeRelease;
  String get dateTimeEnd => _dateTimeEnd ?? "";
  set dateTimeEnd(String dateTimeEnd) => _dateTimeEnd = dateTimeEnd;
  int get question => _question ?? 0;
  set question(int question) => _question = question;
  String get start => _start ?? "";
  set start(String start) => _start = start;
  String get end => _end ?? "";
  set end(String end) => _end = end;
  int get completeStatus => _completeStatus ?? 0;
  set completeStatus(int completeStatus) => _completeStatus = completeStatus;
  SubmittedDateModel get submittedDateModel =>
      _submittedDateModel ?? SubmittedDateModel();
  set submittedDate(SubmittedDateModel submittedDateModel) =>
      _submittedDateModel = submittedDateModel;
  String get orderId => _orderId ?? "";
  set orderId(String orderId) => _orderId = orderId;
  String get aiResponseLink => _aiResponseLink ?? "";
  set aiResponseLink(String aiResponseLink) => _aiResponseLink = aiResponseLink;
  int get haveAiReponse => _haveAiReponse ?? 0;
  set haveAiReponse(int haveAiReponse) => _haveAiReponse = haveAiReponse;
  String get aiScore => _aiScore ?? "";
  set aiScore(String aiScore) => _aiScore = aiScore;
  int get aiOrder => _aiOrder ?? 0;
  set aiOrder(int aiOrder) => _aiOrder = aiOrder;
  String get testId => _testId ?? "";
  set testId(String testId) => _testId = testId;
  int get testOption => _testOption ?? 0;
  set testOption(int testOption) => _testOption = testOption;
  String get className => _className ?? "";
  set className(String className) => _className = className;
  int get classId => _classId ?? 0;
  set classId(int classId) => _classId = classId;
  int get bank => _bank ?? 0;
  set bank(int bank) => _bank = bank;
  String get bankName => _bankName ?? "";
  set bankName(String bankName) => _bankName = bankName;
  int get bankType => _bankType ?? 0;  
  set bankType(int bankType) => _bankType = bankType;
  String get bankDistributeCode => _bankDistributeCode ?? "";
  set bankDistributeCode(String bankDistributeCode) =>
      _bankDistributeCode = bankDistributeCode;
  int get isTested => _isTested ?? 0;
  set isTested(int isTested) => _isTested = isTested;
  String get activityType => _activityType ?? "";
  set activityType(String activityType) => _activityType = activityType;
  int get questionIndex => _questionIndex ?? 0;
  set questionIndex(int questionIndex) => _questionIndex = questionIndex;

  bool hasTeacherResponse() {
    if (kDebugMode) {
      print('DEBUG: _orderId: ${_orderId.toString()}');
    }
    return _orderId != '0' && _orderId!.isNotEmpty;
  }

  bool canReanswer() {
    if (_aiOrder != 0 || _orderId != '0' || _type != 'homework') {
      return false;
    }
    return true;
  }

  HomeWorkModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _name = json['name'];
    _type = json['type'];
    _test = json['test'];
    _startDate = json['start_date'];
    _startTime = json['start_time'];
    _endTime = json['end_time'];
    _endDate = json['end_date'];
    _giaotrinhId = json['giaotrinh_id'];
    _status = json['status'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _activityId = json['activity_id'];
    _tips = json['tips'];
    _cost = json['cost'];
    _sendEmail = json['send_email'];
    _uuid = json['uuid'];
    _activityBankMyBank = json['activity_bank_my_bank'];
    _packageId = json['package_id'];
    _dateTimeRelease = json['date_time_release'];
    _dateTimeEnd = json['date_time_end'];
    _question = json['question'];
    _start = json['start'];
    _end = json['end'];
    _completeStatus = json['complete_status'];
    if (json['submited_date'].toString() != '') {
      _submittedDateModel = json['submited_date'] != null
          ? SubmittedDateModel.fromJson(json['submited_date'])
          : null;
    } else {
      _submittedDateModel = null;
    }

    _orderId = json['order_id'].toString();
    _aiResponseLink = json['ai_response_link'];
    _haveAiReponse = json['have_ai_reponse'];
    _aiScore = json['ai_score'].toString();
    _aiOrder = json['ai_order'];
    _testId = json['test_id'].toString();
    _testOption = json['test_option'];
    _className = json['class_name'];
    _classId = json['class_id'];
    _bank = json['bank'];
    _bankName = json['bank_name'];
    _bankType = json['bank_type'];
    _bankDistributeCode = json['bank_distribute_code'];
    _isTested = json['is_tested'];
    _activityType = json['activity_type'];
    _questionIndex = json['question_index'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['name'] = _name;
    data['type'] = _type;
    data['test'] = _test;
    data['start_date'] = _startDate;
    data['start_time'] = _startTime;
    data['end_time'] = _endTime;
    data['end_date'] = _endDate;
    data['giaotrinh_id'] = _giaotrinhId;
    data['status'] = _status;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    data['activity_id'] = _activityId;
    data['tips'] = _tips;
    data['cost'] = _cost;
    data['send_email'] = _sendEmail;
    data['uuid'] = _uuid;
    data['activity_bank_my_bank'] = _activityBankMyBank;
    data['package_id'] = _packageId;
    data['date_time_release'] = _dateTimeRelease;
    data['date_time_end'] = _dateTimeEnd;
    data['question'] = _question;
    data['start'] = _start;
    data['end'] = _end;
    data['complete_status'] = _completeStatus;
    if (_submittedDateModel != null) {
      data['submited_date'] = _submittedDateModel!.toJson();
    }
    data['order_id'] = _orderId;
    data['ai_response_link'] = _aiResponseLink;
    data['have_ai_reponse'] = _haveAiReponse;
    data['ai_score'] = _aiScore;
    data['ai_order'] = _aiOrder;
    data['test_id'] = _testId;
    data['test_option'] = _testOption;
    data['class_name'] = _className;
    data['class_id'] = _classId;
    data['bank'] = _bank;
    data['bank_name'] = _bankName;
    data['bank_type'] = _bankType;
    data['bank_distribute_code'] = _bankDistributeCode;
    data['is_tested'] = _isTested;
    data['activity_type'] = _activityType;
    data['question_index'] = _questionIndex;
    return data;
  }
}
