import 'dart:convert';
import 'package:flutter/foundation.dart';

ActivityAnswer activityAnswerFromJson(String str) =>
    ActivityAnswer.fromJson(json.decode(str));
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
  String? _aiScore;
  String? _aiResponseLink;

  ActivityAnswer(
      {int? activityId,
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
      String? aiScore,
      String? aiResponseLink}) {
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
    _aiScore = aiScore;
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
  String get aiScore => _aiScore ?? "";
  set aiScore(value) => _aiScore = value;

  bool hasTeacherResponse() {
    if (kDebugMode) {
      print('DEBUG: _orderId: ${_orderId.toString()}');
    }
    return _orderId != 0 && _orderId.toString().isNotEmpty;
  }

  ActivityAnswer.fromJson(Map<String, dynamic> json) {
    if (json['activity_id'] is String) {
      _activityId = int.parse(json['activity_id']);
    } else {
      _activityId = json['activity_id'];
    }

    if (json['test_id'] is String) {
      _testId = int.parse(json['test_id']);
    } else {
      _testId = json['test_id'];
    }

    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _aiScore = json['ai_score'];

    if (json['order_id'] is String) {
      _orderId = int.parse(json['order_id']);
    } else {
      _orderId = json['order_id'];
    }

    _publis = json['publis'];
    _realActivityId = json['real_activity_id'];
    _aiOrder = json['ai_order'];
    _email = json['email'];

    if (json['id'] is String) {
      _id = int.parse(json['id']);
    } else {
      _id = json['id'];
    }

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

  @override
  String toString() {
    return 'ActivityAnswer{'
        '\n _activityId: $_activityId,'
        '\n _testId: $_testId,'
        '\n _createdAt: $_createdAt,'
        '\n _updatedAt: $_updatedAt,'
        '\n _orderId: $_orderId,'
        '\n _publis: $_publis,'
        '\n _realActivityId: $_realActivityId,'
        '\n _aiOrder: $_aiOrder,'
        '\n _email: $_email,'
        '\n _id: $_id,'
        '\n _late: $_late,'
        '\n _aiResponseLink: $_aiResponseLink'
        '\n}';
  }
}
