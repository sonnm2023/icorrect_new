import 'dart:convert';

import 'package:icorrect/src/data_sources/constant_strings.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/auth_repository.dart';
import 'package:icorrect/src/data_sources/repositories/homework_repository.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/homework_models/class_model.dart';
import 'package:icorrect/src/models/homework_models/homework_model.dart';
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';

abstract class HomeWorkViewContract {
  void onGetListHomeworkComplete(
      List<HomeWorkModel> homeworks, List<ClassModel> classes);
  void onGetListHomeworkError(String message);
  void onLogoutComplete();
  void onLogoutError(String message);
  void onUpdateCurrentUserInfo(UserDataModel userDataModel);
}

class HomeWorkPresenter {
  final HomeWorkViewContract? _view;
  AuthRepository? _authRepository;
  HomeWorkRepository? _homeWorkRepository;

  HomeWorkPresenter(this._view) {
    _authRepository = Injector().getAuthRepository();
    _homeWorkRepository = Injector().getHomeWorkRepository();
  }

  void getListHomeWork() async {
    assert(_view != null && _homeWorkRepository != null);

    UserDataModel? currentUser = await Utils.getCurrentUser();
    if (currentUser == null) {
      _view!.onGetListHomeworkError("Loading list homework error");
      return;
    }

    _view!.onUpdateCurrentUserInfo(currentUser);

    String email = currentUser.userInfoModel.email;
    String status = Status.allHomework.get.toString();

    _homeWorkRepository!.getListHomeWork(email, status).then((value) async {
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap['error_code'] == 200) {
        List<HomeWorkModel> homeworks =
            await _generateListHomeWork(dataMap['result']);
        List<ClassModel> classes = await _generateListClass(dataMap['classes']);
        _view!.onGetListHomeworkComplete(homeworks, classes);
      } else {
        _view!.onGetListHomeworkError(
            "Loading list homework error: ${dataMap['error_code']}${dataMap['status']}");
      }
    }).catchError(
      // ignore: invalid_return_type_for_catch_error
      (onError) => _view!.onGetListHomeworkError(onError.toString()),
    );
  }

  Future<List<HomeWorkModel>> _generateListHomeWork(List<dynamic> data) async {
    List<HomeWorkModel> temp = [];
    for (int i = 0; i < data.length; i++) {
      HomeWorkModel item = HomeWorkModel.fromJson(data[i]);
      temp.add(item);
    }
    return temp;
  }

  Future<List<ClassModel>> _generateListClass(List<dynamic> data) async {
    List<ClassModel> temp = [];
    for (int i = 0; i < data.length; i++) {
      ClassModel item = ClassModel.fromJson(data[i]);
      temp.add(item);
    }
    return temp;
  }

  void logout() {
    assert(_view != null && _authRepository != null);

    _authRepository!.logout().then((value) async {
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap['error_code'] == 200) {
        //Delete access token
        Utils.setAccessToken('');

        //Delete current user
        Utils.clearCurrentUser();

        _view!.onLogoutComplete();
      } else {
        _view!.onLogoutError(
            "Logout error: ${dataMap['error_code']}${dataMap['status']}");
      }
    }).catchError(
      // ignore: invalid_return_type_for_catch_error
      (onError) => _view!.onLogoutError(onError.toString()),
    );
  }
}
