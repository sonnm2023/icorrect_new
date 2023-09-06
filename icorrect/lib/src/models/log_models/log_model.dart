import 'package:icorrect/src/models/log_models/common_info_model.dart';

class LogModel {
  String? _action;
  String? _status;
  String? _createdTime;
  String? _message;
  List<String>? _data = [];
  CommonInfoModel? _commonInfoModel;

  LogModel({
    String? action,
    String? status,
    String? createdTime,
    String? message,
    List<String>? data,
    CommonInfoModel? commonInfoModel,
  }) {
    _action = action;
    _status = status;
    _createdTime = createdTime;
    _message = message;

    if (data != null) {
      _data!.addAll(data);
    } else {
      _data = [];
    }

    _commonInfoModel = commonInfoModel;
  }

  String get action => _action ?? '';
  set action(String action) => _action = action;
  String get status => _status ?? '';
  set status(String status) => _status = status;
  String get createdTime => _createdTime ?? '';
  set createdTime(String createdTime) => _createdTime = createdTime;
  String get message => _message ?? '';
  set message(String message) => _message = message;
  List<String>? get data => _data ?? [];
  set data(List<String>? data) => _data = data;
  CommonInfoModel? get commonInfoModel => _commonInfoModel;
  set commonInfoModel(CommonInfoModel? commonInfoModel) => _commonInfoModel = commonInfoModel;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['action'] = _action;
    dataMap['status'] = _status;
    dataMap['created_time'] = _createdTime;
    dataMap['message'] = _message;

    if (_data != null) {
      dataMap['data'] = _data;
    } else {
      dataMap['data'] = <String>[];
    }

    if (_commonInfoModel != null) {
      dataMap['common_info'] = _commonInfoModel!.toJson();
    }
    return dataMap;
  }
}
