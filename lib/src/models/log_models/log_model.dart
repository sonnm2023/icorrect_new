class LogModel {
  String? _action;
  String? _status;
  int? _createdTime;
  String? _message;
  String? _os;
  int? _userId;
  String? _deviceId;
  String? _deviceName;
  String? _osVersion;
  String? _versionApp;
  String? _previousAction;
  int? _responseTime;
  Map<String, dynamic>? _data = {};

  LogModel({
    String? action,
    String? status,
    int? createdTime,
    String? message,
    String? os,
    int? userId,
    String? deviceId,
    String? deviceName,
    String? osVersion,
    String? versionApp,
    String? previousAction,
    int? responseTime,
    Map<String, dynamic>? data,
  }) {
    _action = action;
    _status = status;
    _createdTime = createdTime;
    _message = message;
    _os = os;
    _userId = userId;
    _deviceId = deviceId;
    _deviceName = deviceName;
    _osVersion = osVersion;
    _versionApp = versionApp;
    _previousAction = previousAction;
    _responseTime = responseTime;

    if (data != null) {
      _data!.addAll(data);
    } else {
      _data = {};
    }
  }

  String get action => _action ?? '';
  set action(String action) => _action = action;
  String get status => _status ?? '';
  set status(String status) => _status = status;
  int get createdTime => _createdTime ?? 0;
  set createdTime(int createdTime) => _createdTime = createdTime;
  String get message => _message ?? '';
  set message(String message) => _message = message;
  String get os => _os ?? '';
  set os(String os) => _os = os;
  int get userId => _userId ?? 0;
  set userId(int userId) => _userId = userId;
  String get deviceId => _deviceId ?? '';
  set deviceId(String deviceId) => _deviceId = deviceId;
  String get deviceName => _deviceName ?? '';
  set deviceName(String deviceName) => _deviceName = deviceName;
  String get osVersion => _osVersion ?? '';
  set osVersion(String osVersion) => _osVersion = osVersion;
  String get versionApp => _versionApp ?? '';
  set versionApp(String versionApp) => _versionApp = versionApp;
  String get previousAction => _previousAction ?? '';
  set previousAction(String previousAction) => _previousAction = previousAction;
  int get responseTime => _responseTime ?? 0;
  set responseTime(int responseTime) => _responseTime = responseTime;
  Map<String, dynamic>? get data => _data ?? {};
  set data(Map<String, dynamic>? data) => _data = data;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['action'] = _action;
    dataMap['status'] = _status;
    dataMap['created_time'] = _createdTime;
    dataMap['message'] = _message;
    dataMap['os'] = _os;
    dataMap['user_id'] = _userId;
    dataMap['device_id'] = _deviceId;
    dataMap['device_name'] = _deviceName;
    dataMap['os_version'] = _osVersion;
    dataMap['version_app'] = _versionApp;
    dataMap['previous_action'] = _previousAction;
    dataMap['response_time'] = _responseTime;

    if (_data != null) {
      dataMap['data'] = _data;
    } else {
      dataMap['data'] = Map<String, dynamic>;
    }
    return dataMap;
  }

  void addData({required String key, required dynamic value}) {
    if (_data != null) {
      data = {};
    }
    _data![key] = value;
  }
}
