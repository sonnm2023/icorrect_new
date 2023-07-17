import 'dart:convert';
import 'dart:core';

import 'package:icorrect/src/models/user_data_models/profile_model.dart';
import 'package:icorrect/src/models/user_data_models/user_info_model.dart';



UserDataModel userDataModelFromJson(String str) => UserDataModel.fromJson(json.decode(str));
String userDataModelToJson(UserDataModel data) => json.encode(data.toJson());

class UserDataModel {
  UserDataModel({
    UserInfoModel? userInfoModel,
    ProfileModel? profileModel,
    int? notify,
    bool? showDosmesticTranfer,
    bool? showDistributor,
    bool? showFreeCredit,
    String? prepaid,
    int? showConversation,
    int? conversationMessage,
    int? fistDeposit,
}) {
    _userInfoModel = userInfoModel;
    _profileModel = profileModel;
    _notify = notify;
    _showDosmesticTranfer = showDosmesticTranfer;
    _showDistributor = showDistributor;
    _showFreeCredit = showFreeCredit;
    _prepaid = prepaid;
    _showConversation = showConversation;
    _conversationMessage = conversationMessage;
    _fistDeposit = fistDeposit;
}

  UserInfoModel? _userInfoModel;
  ProfileModel? _profileModel;
  int? _notify;
  bool? _showDosmesticTranfer;
  bool? _showDistributor;
  bool? _showFreeCredit;
  String? _prepaid;
  int? _showConversation;
  int? _conversationMessage;
  int? _fistDeposit;

  UserDataModel copyWith({
    UserInfoModel? userInfoModel,
    ProfileModel? profileModel,
    int? notify,
    bool? showDosmesticTranfer,
    bool? showDistributor,
    bool? showFreeCredit,
    String? prepaid,
    int? showConversation,
    int? conversationMessage,
    int? fistDeposit,
  }) =>
      UserDataModel(
        userInfoModel: userInfoModel ?? _userInfoModel,
        profileModel: profileModel ?? _profileModel,
        notify: notify ?? _notify,
        showDosmesticTranfer: showDosmesticTranfer ?? _showDosmesticTranfer,
        showDistributor: showDistributor ?? _showDistributor,
        showFreeCredit: showFreeCredit ?? _showFreeCredit,
        prepaid: prepaid ?? _prepaid,
        showConversation: showConversation ?? _showConversation,
        conversationMessage: conversationMessage ?? _conversationMessage,
        fistDeposit: fistDeposit ?? _fistDeposit,
      );

  UserInfoModel get userInfoModel => _userInfoModel ?? UserInfoModel(id: 0);
  ProfileModel get profileModel => _profileModel ?? ProfileModel(id: 0, userId: 0);
  int get notify => _notify ?? 0;
  bool get showDosmesticTranfer => _showDosmesticTranfer ?? false;
  bool get showDistributor => _showDistributor ?? false;
  bool get showFreeCredit => _showFreeCredit ?? false;
  String get prepaid => _prepaid ?? "";
  int get showConversation => _showConversation ?? 0;
  int get conversationMessage => _conversationMessage ?? 0;
  int get fistDeposit => _fistDeposit ?? 0;

  UserDataModel.fromJson(dynamic json) {
    _userInfoModel = json['user_info'] != null ? UserInfoModel.fromJson(json['user_info']) : null;
    _profileModel = json['profile'] != null ? ProfileModel.fromJson(json['profile']) : null;
    _notify = json['notify'];
    _showDosmesticTranfer = json['show_dosmestic_tranfer'];
    _showDistributor = json['show_distributor'];
    _showFreeCredit = json['show_free_credit'];
    _prepaid = json['prepaid'];
    _showConversation = json['show_conversation'];
    _conversationMessage = json['conversation_message'];
    _fistDeposit = json['fist_deposit'];
  }


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (_userInfoModel != null) {
      map['user_info'] = _userInfoModel?.toJson();
    }

    if (_profileModel != null) {
      map['profile'] = _profileModel?.toJson();
    }
    map['notify'] = _notify;
    map['show_dosmestic_tranfer'] = _showDosmesticTranfer;
    map['show_distributor'] = _showDistributor;
    map['show_free_credit'] = _showFreeCredit;
    map['prepaid'] = _prepaid;
    map['show_conversation'] = _showConversation;
    map['conversation_message'] = _conversationMessage;
    map['fist_deposit'] = _fistDeposit;

    return map;
  }
}