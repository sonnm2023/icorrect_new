import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  Future<Map<Permission, PermissionStatus>> requestPermissions(
      List<Permission> permissions) async {
    return permissions.request();
  }

  bool isPermissionGranted(PermissionStatus status) {
    return status.isGranted;
  }
}

class PermissionService{
  final PermissionHandler _permissionHandler = PermissionHandler();

  Future<bool> _requestPermission() async {
    var result = await _permissionHandler.requestPermissions([Permission.microphone, Permission.camera]);
    // ignore: unrelated_type_equality_checks
    if (result == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

  Future<bool> requestPermission({required Function onPermissionDenied}) async {
    var granted = await _requestPermission();
    if (!granted) {
      onPermissionDenied();
    }
    return granted;
  }

  Future<bool> hasCameraPermission() async {
    return hasPermission(Permission.camera);
  }

  Future<bool> hasMicrophonePermission() async {
    return hasPermission(Permission.microphone);
  }

  Future<bool> hasPermission(Permission permission) async {
    return _permissionHandler.isPermissionGranted(permission.status as PermissionStatus);
  }
}