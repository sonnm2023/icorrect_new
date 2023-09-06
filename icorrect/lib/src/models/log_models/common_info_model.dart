class CommonInfoModel {
  String? _os;
  String? _userId;
  String? _deviceId;
  String? _deviceName;
  String? _osVersion;
  String? _versionApp;

  CommonInfoModel({
    String? os,
    String? userId,
    String? deviceId,
    String? deviceName,
    String? osVersion,
    String? versionApp,
  }) {
    _os = os;
    _userId = userId;
    _deviceId = deviceId;
    _deviceName = deviceName;
    _osVersion = osVersion;
    _versionApp = versionApp;
  }
  
  String get os => _os ?? '';
  set os(String action) => _os = os;
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
    dataMap['os'] = _os;
    dataMap['user_id'] = _userId;
    dataMap['device_id'] = _deviceId;
    dataMap['device_name'] = _deviceName;
    dataMap['os_version'] = _osVersion;
    dataMap['version_app'] = _versionApp;
    return dataMap;
  }
}
