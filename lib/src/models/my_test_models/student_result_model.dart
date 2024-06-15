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

  int? get id => _id;

  set id(int? value) => _id = value;

  get activityId => _activityId;

  set activityId(value) => _activityId = value;

  get testId => _testId;

  set testId(value) => _testId = value;

  get email => _email;

  set email(value) => _email = value;

  get createdAt => _createdAt;

  set createdAt(value) => _createdAt = value;

  get updateAt => _updateAt;

  set updateAt(value) => _updateAt = value;

  get orderId => _orderId;

  set orderId(value) => _orderId = value;

  get publishResponse => _publishResponse;

  set publishResponse(value) => _publishResponse = value;

  get overallScore => _overallScore ?? "";

  set overallScore(value) => _overallScore = value;

  get publish => _publish;

  set publish(value) => _publish = value;

  get realActivityId => _realActivityId;

  set realActivityId(value) => _realActivityId = value;

  get example => _example;

  set example(value) => _example = value;

  get teacherId => _teacherId;

  set teacherId(value) => _teacherId = value;

  get aiOrder => _aiOrder;

  set aiOrder(value) => _aiOrder = value;

  get aiScore => _aiScore ?? "";

  set aiScore(value) => _aiScore = value;

  get students => _students;

  set students(value) => _students = value;

  get activityResult => _activityResult;

  set activityResult(value) => _activityResult = value;

  get status => _status;

  set status(value) => _status = value;

  get teacherName => _teacherName;

  set teacherName(value) => _teacherName = value;

  bool haveResponse() {
    return _orderId != null &&
        _orderId != 0 &&
        _overallScore != null &&
        _overallScore != "0.0";
  }

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
