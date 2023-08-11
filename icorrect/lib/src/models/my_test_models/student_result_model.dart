import 'package:icorrect/src/models/my_test_models/activity_result_model.dart';
import 'package:icorrect/src/models/user_data_models/student_model.dart';

class StudentResultModel {
  int? _id;
  int? _activityId;
  int? _testId;
  String? _email;
  String? _createdAt;
  String? _updateAt;
  int? _orderId;
  int? _publishResponse;
  String? _overallScore;
  int? _publish;
  int? _realActivityId;
  int? _example;
  int? _teacherId;
  int? _aiOrder;
  String? _aiScore;
  StudentModel? _students;
  ActivityResult? _activityResult;
  int? _status;
  String? _teacherName;

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

  int? get id => this._id;

  set id(int? value) => this._id = value;

  get activityId => this._activityId;

  set activityId(value) => this._activityId = value;

  get testId => this._testId;

  set testId(value) => this._testId = value;

  get email => this._email;

  set email(value) => this._email = value;

  get createdAt => this._createdAt;

  set createdAt(value) => this._createdAt = value;

  get updateAt => this._updateAt;

  set updateAt(value) => this._updateAt = value;

  get orderId => this._orderId;

  set orderId(value) => this._orderId = value;

  get publishResponse => this._publishResponse;

  set publishResponse(value) => this._publishResponse = value;

  get overallScore => this._overallScore ?? "";

  set overallScore(value) => this._overallScore = value;

  get publish => this._publish;

  set publish(value) => this._publish = value;

  get realActivityId => this._realActivityId;

  set realActivityId(value) => this._realActivityId = value;

  get example => this._example;

  set example(value) => this._example = value;

  get teacherId => this._teacherId;

  set teacherId(value) => this._teacherId = value;

  get aiOrder => this._aiOrder;

  set aiOrder(value) => this._aiOrder = value;

  get aiScore => this._aiScore ?? "";

  set aiScore(value) => this._aiScore = value;

  get students => this._students;

  set students(value) => this._students = value;

  get activityResult => this._activityResult;

  set activityResult(value) => this._activityResult = value;

  get status => this._status;

  set status(value) => this._status = value;

  get teacherName => this._teacherName;

  set teacherName(value) => this._teacherName = value;

  StudentResultModel.fromJson(Map<String, dynamic> item) {
    StudentModel studentModel = StudentModel.fromJson(item['student']);
    ActivityResult activityResult = ActivityResult.fromJson(item['activity']);
    _id = item['id'] ?? 0;
    _activityId = item['activity_id'] ?? 0;
    _testId = item['test_id'] ?? 0;
    _email = item['email'] ?? '';
    _createdAt = item['created_at'] ?? '';
    _updateAt = item['updated_at'] ?? '';
    _orderId = item['order_id'] ?? 0;
    _publishResponse = item['publish_response'] ?? 0;
    _overallScore = item['overall_score'] ?? '';
    _publish = item['pushlis'] ?? 0;
    _realActivityId = item['real_activity_id'] ?? 0;
    _example = item['example'] ?? 0;
    _teacherId = item['teacher_id'] ?? 0;
    _aiOrder = item['ai_order'] ?? 0;
    _aiScore = item['ai_score'] ?? '';
    _students = studentModel;
    _activityResult = activityResult;
    _status = item['status'] ?? 0;
    _teacherName = item['teacher_name'] ?? '';
  }
}
