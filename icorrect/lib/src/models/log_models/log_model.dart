class LogModel {
  String? _action;
  String? _os;
  String? _status;
  String? _createdTime;
  String? _message;
  List<String>? _data = [];
  String? _userId;
  String? _deviceId;
  String? _deviceName;
  String? _osVersion;
  String? _versionApp;

  LogModel({
    String? action,
    String? os,
    String? status,
    String? createdTime,
    String? message,
    List<String>? data,
    String? userId,
    String? deviceId,
    String? deviceName,
    String? osVersion,
    String? versionApp,
  }) {
    _action = action;
    _os = os;
    _status = status;
    _createdTime = createdTime;
    _message = message;

    if (data != null) {
      _data!.addAll(data);
    } else {
      _data = [];
    }

    _userId = userId;
    _deviceId = deviceId;
    _deviceName = deviceName;
    _osVersion = osVersion;
    _versionApp = versionApp;
  }

  String get action => _action ?? '';
  set action(String action) => _action = action;
  String get os => _os ?? '';
  set os(String action) => _os = os;
  String get status => _status ?? '';
  set status(String status) => _status = status;
  String get createdTime => _createdTime ?? '';
  set createdTime(String createdTime) => _createdTime = createdTime;
  String get message => _message ?? '';
  set message(String message) => _message = message;
  List<String>? get data => _data ?? [];
  set data(List<String>? data) => _data = data;
  String get userId => _userId ?? '';
  set userId(String userId) => _userId = userId;
  String get deviceId => _deviceId ?? '';
  set deviceId(String deviceId) => _deviceId = deviceId;
  String get deviceName => _deviceName ?? '';
  set deviceName(String deviceName) => _deviceName = deviceName;
  String get osVersion => _osVersion ?? '';
  set osVersion(String osVersion) => _osVersion = osVersion;
  String get versionApp => _versionApp ?? '';
  set versionApp(String versionApp) => _versionApp = versionApp;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['action'] = _action;
    dataMap['os'] = _os;
    dataMap['status'] = _status;
    dataMap['created_time'] = _createdTime;
    dataMap['message'] = _message;
    dataMap['user_id'] = _userId;
    dataMap['device_id'] = _deviceId;
    dataMap['device_name'] = _deviceName;
    dataMap['os_version'] = _osVersion;
    dataMap['version_app'] = _versionApp;

    if (_data != null) {
      dataMap['data'] = _data;
    } else {
      dataMap['data'] = <String>[];
    }
    return dataMap;
  }
}
