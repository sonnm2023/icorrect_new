
import 'dart:convert';

ActivityAnswer activityAnswerFromJson(String str) => ActivityAnswer.fromJson(json.decode(str));
String activityAnswerToJson(ActivityAnswer data) => json.encode(data.toJson());

class ActivityAnswer {
  int? _activityId;
  int? _testId;
  String? _createdAt;
  String? _updatedAt;
  int? _orderId;
  int? _publis;
  int? _realActivityId;
  int? _aiOrder;
  String? _email;
  int? _id;
  int? _late;
  String? _aiResponseLink;

  ActivityAnswer({
    int? activityId,
    int? testId,
    String? createdAt,
    String? updatedAt,
    int? orderId,
    int? publis,
    int? realActivityId,
    int? aiOrder,
    String? email,
    int? id,
    int? late,
    String? aiResponseLink
}) {
    _activityId = activityId;
    _testId = testId;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _orderId = orderId;
    _publis = publis;
    _realActivityId = realActivityId;
    _aiOrder = aiOrder;
    _email = email;
    _id = id;
    _late = late;
    _aiResponseLink = aiResponseLink;
  }

  int get activityId => _activityId ?? 0;
  set activityId(int activityId) => _activityId = activityId;
  int get testId => _testId ?? 0;
  set testId(int testId) => _testId = testId;
  String get createdAt => _createdAt ?? "";
  set createdAt(String createdAt) => _createdAt = createdAt;
  String get updatedAt => _updatedAt ?? "";
  set updatedAt(String updatedAt) => _updatedAt = updatedAt;
  int get orderId => _orderId ?? 0;
  set orderId(int orderId) => _orderId = orderId;
  int get publis => _publis ?? 0;
  set publis(int publis) => _publis = publis;
  int get realActivityId => _realActivityId ?? 0;
  set realActivityId(int realActivityId) => _realActivityId = realActivityId;
  int get aiOrder => _aiOrder ?? 0;
  set aiOrder(int aiOrder) => _aiOrder = aiOrder;
  String get email => _email ?? "";
  set email(String email) => _email = email;
  int get id => _id ?? 0;
  set id(int id) => _id = id;
  int get late => _late ?? 0;
  set late(int late) => _late = late;
  String get aiResponseLink => _aiResponseLink ?? "";
  set aiResponseLink(String aiResponseLink) => _aiResponseLink = aiResponseLink;

   bool hasTeacherResponse() {
    print('_orderId: ${_orderId.toString()}');
    return _orderId != 0 && _orderId.toString().isNotEmpty;
  }


  ActivityAnswer.fromJson(Map<String, dynamic> json) {
    _activityId = json['activity_id'];
    _testId = json['test_id'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _orderId = json['order_id'];
    _publis = json['publis'];
    _realActivityId = json['real_activity_id'];
    _aiOrder = json['ai_order'];
    _email = json['email'];
    _id = json['id'];
    _late = json['late'];
    _aiResponseLink = json['ai_response_link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['activity_id'] = _activityId;
    data['test_id'] = _testId;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    data['order_id'] = _orderId;
    data['publis'] = _publis;
    data['real_activity_id'] = _realActivityId;
    data['ai_order'] = _aiOrder;
    data['email'] = _email;
    data['id'] = _id;
    data['late'] = _late;
    data['ai_response_link'] = _aiResponseLink;
    return data;
  }
}