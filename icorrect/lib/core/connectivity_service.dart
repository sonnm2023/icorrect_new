import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  Future<ConnectivityResult> checkConnectivity() async {
    return await Connectivity().checkConnectivity();
  }
}
