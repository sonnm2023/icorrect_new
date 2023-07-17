

import 'package:icorrect/src/models/my_test_models/activity_result_model.dart';
import 'package:icorrect/src/models/user_data_models/student_model.dart';

class StudentResultModel {
  var _id;
  var _activityId;
  var _testId;
  var _email;
  var _createdAt;
  var _updateAt;
  var _orderId;
  var _publishResponse;
  var _overallScore;
  var _publish;
  var _realActivityId;
  var _example;
  var _teacherId;
  var _aiOrder;
  var _aiScore;
  StudentModel? _students;
  ActivityResult? _activityResult;
  var _status;
  var _teacherName;

  StudentResultModel([
    this._id,
    this._activityId,
    this._testId,
    this._email,
    this._createdAt,
    this._updateAt,
    this._orderId,
    this._publishResponse,
    this._overallScore,
    this._publish,
    this._realActivityId,
    this._example,
    this._teacherId,
    this._aiOrder,
    this._aiScore,
    this._students,
    this._activityResult,
    this._status,
    this._teacherName,
  ]);

  get id => this._id ?? '';

  set id(value) => this._id = value;

  get activityId => this._activityId ?? '';

  set activityId(value) => this._activityId = value;

  get testId => this._testId ?? '';

  set testId(value) => this._testId = value;

  get email => this._email ?? '';

  set email(value) => this._email = value;

  get createdAt => this._createdAt ?? '';

  set createdAt(value) => this._createdAt = value;

  get updateAt => this._updateAt ?? '';

  set updateAt(value) => this._updateAt = value;

  get orderId => this._orderId ?? '';

  set orderId(value) => this._orderId = value;

  get publishResponse => this._publishResponse ?? '';

  set publishResponse(value) => this._publishResponse = value;

  get overallScore => this._overallScore ?? '';

  set overallScore(value) => this._overallScore = value;

  get publish => this._publish ?? '';

  set publish(value) => this._publish = value;

  get realActivityId => this._realActivityId ?? '';

  set realActivityId(value) => this._realActivityId = value;

  get example => this._example ?? '';

  set example(value) => this._example = value;

  get teacherId => this._teacherId ?? '';

  set teacherId(value) => this._teacherId = value;

  get aiOrder => this._aiOrder ?? '';

  set aiOrder(value) => this._aiOrder = value;

  get aiScore => this._aiScore ?? '';

  set aiScore(value) => this._aiScore = value;

  StudentModel? get students => this._students ?? StudentModel();

  set students(value) => this._students = value;

  ActivityResult? get activityResult =>
      this._activityResult ?? ActivityResult();

  set activityResult(value) => this._activityResult = value;

  get status => this._status ?? '';

  set status(value) => this._status = value;

  get teacherName => this._teacherName ?? '';

  set teacherName(value) => this._teacherName = value;
}