import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/user_authen_repository.dart';
import 'package:icorrect/src/models/user_authentication/user_authentication_detail.dart';
import 'package:path/path.dart';

import '../data_sources/utils.dart';
import 'package:http/http.dart' as http;

abstract class UserAuthDetailContract {
  void getUserAuthDetailSuccess(UserAuthenDetailModel userAuthenDetailModel);
  void getUserAuthDetailFail(String message);
  void userNotFoundWhenLoadAuth(String message);
}

class UserAuthDetailPresenter {
  final UserAuthDetailContract? _view;
  UserAuthRepository? _repository;

  UserAuthDetailPresenter(this._view) {
    _repository = Injector().getUserAuthDetailRepository();
  }

  Future getUserAuthDetail() async {
    assert(_view != null);
    _repository!.getUserAuthDetail().then((value) {
      Map<String, dynamic> map = jsonDecode(value);
      print('dada: ${map.toString()}');
      if (map['error_code'] == 200 && map['status'] == 'success') {
        Map<String, dynamic> data = map['data'] ?? {};
        if (data.isNotEmpty) {
          UserAuthenDetailModel userAuthenDetailModel =
              UserAuthenDetailModel.fromJson(data);
          _view!.getUserAuthDetailSuccess(userAuthenDetailModel);
        } else {
          _view!.userNotFoundWhenLoadAuth(
              "You have not been added to the testing system, please contact admin for better understanding !");
        }
      } else {
        _view!.getUserAuthDetailFail(
            "Something went wrong when load your authentication !");
      }
    }).catchError((e) {
      _view!.getUserAuthDetailFail("An Error : ${e.toString()}!");
    });
  }
}
