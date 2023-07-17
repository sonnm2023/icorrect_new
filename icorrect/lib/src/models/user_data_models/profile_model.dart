import 'dart:convert';

import 'package:icorrect/src/models/user_data_models/country_model.dart';
import 'package:icorrect/src/models/user_data_models/wallet_model.dart';



ProfileModel profileModelFromJson(String str) => ProfileModel.fromJson(json.decode(str));
String profileModelToJson(ProfileModel data) => json.encode(data.toJson());

class ProfileModel {
  int? _id = 0;
  int? _userId = 0;
  String? _phone;
  int? _countryCode;
  String? _gender;
  String? _displayName;
  String? _birthday;
  String? _avatar;
  int? _pointTotal;
  int? _isTester;
  String? _codeReferrer;
  String? _referrer;
  int? _vip;
  int? _target;
  String? _appVersion;
  String? _platform;
  int? _likes;
  int? _follow;
  int? _invited;
  int? _monthlyVip;
  WalletModel? _wallet;
  CountryModel? _country;

  ProfileModel(
      {int? id,
        int? userId,
        String? phone,
        int? countryCode,
        String? gender,
        String? displayName,
        String? birthday,
        String? avatar,
        int? pointTotal,
        int? isTester,
        String? codeReferrer,
        String? referrer,
        int? vip,
        int? target,
        String? appVersion,
        String? platform,
        int? likes,
        int? follow,
        int? invited,
        int? monthlyVip,
        WalletModel? wallet,
        CountryModel? country}) {
    _id = id ?? 0;
    _userId = userId ?? 0;
    _phone = phone ?? "";
    _countryCode = countryCode ?? 0;
    _gender = gender ?? "";
    _displayName = displayName ?? "";
    _birthday = birthday ?? "";
    _avatar = avatar ?? "";
    _pointTotal = pointTotal ?? 0;
    _isTester = isTester ?? 0;
    _codeReferrer = codeReferrer ?? "";
    _referrer = referrer ?? "";
    _vip = vip ?? 0;
    _target = target ?? 0;
    _appVersion = appVersion ?? "";
    _platform = platform ?? "";
    _likes = likes ?? 0;
    _follow = follow ?? 0;
    _invited = invited ?? 0;
    _monthlyVip = monthlyVip ?? 0;
    _wallet = wallet;
    _country = country;
  }

  int get id => _id ?? 0;
  set id(int id) => _id = id;
  int get userId => _userId ?? 0;
  set userId(int userId) => _userId = userId;
  String get phone => _phone ?? "";
  set phone(String phone) => _phone = phone;
  int get countryCode => _countryCode ?? 0;
  set countryCode(int countryCode) => _countryCode = countryCode;
  String get gender => _gender ?? "";
  set gender(String gender) => _gender = gender;
  String get displayName => _displayName ?? "";
  set displayName(String displayName) => _displayName = displayName;
  String get birthday => _birthday ?? "";
  set birthday(String birthday) => _birthday = birthday;
  String get avatar => _avatar ?? "";
  set avatar(String avatar) => _avatar = avatar;
  int get pointTotal => _pointTotal ?? 0;
  set pointTotal(int pointTotal) => _pointTotal = pointTotal;
  int get isTester => _isTester ?? 0;
  set isTester(int isTester) => _isTester = isTester;
  String get codeReferrer => _codeReferrer ?? "";
  set codeReferrer(String codeReferrer) => _codeReferrer = codeReferrer;
  String get referrer => _referrer ?? "";
  set referrer(String referrer) => _referrer = referrer;
  int get vip => _vip ?? 0;
  set vip(int vip) => _vip = vip;
  int get target => _target ?? 0;
  set target(int target) => _target = target;
  String get appVersion => _appVersion ?? "";
  set appVersion(String appVersion) => _appVersion = appVersion;
  String get platform => _platform ?? "";
  set platform(String platform) => _platform = platform;
  int get likes => _likes ?? 0;
  set likes(int likes) => _likes = likes;
  int get follow => _follow ?? 0;
  set follow(int follow) => _follow = follow;
  int get invited => _invited ?? 0;
  set invited(int invited) => _invited = invited;
  int get monthlyVip => _monthlyVip ?? 0;
  set monthlyVip(int monthlyVip) => _monthlyVip = monthlyVip;
  WalletModel get wallet => _wallet ?? WalletModel(id: 0);
  set wallet(WalletModel wallet) => _wallet = wallet;
  CountryModel get country => _country ?? CountryModel(id: 0);
  set country(CountryModel country) => _country = country;

  ProfileModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _userId = json['user_id'];
    _phone = json['phone'];
    _countryCode = json['country_code'];
    _gender = json['gender'];
    _displayName = json['display_name'];
    _birthday = json['birthday'];
    _avatar = json['avatar'];
    _pointTotal = json['point_total'];
    _isTester = json['is_tester'];
    _codeReferrer = json['code_referrer'];
    _referrer = json['referrer'];
    _vip = json['vip'];
    _target = json['target'];
    _appVersion = json['app_version'];
    _platform = json['platform'];
    _likes = json['likes'];
    _follow = json['follow'];
    _invited = json['invited'];
    _monthlyVip = json['monthly_vip'];
    _wallet =
    (json['wallet'] != null ? WalletModel.fromJson(json['wallet']) : null)!;
    _country =
    (json['country'] != null ? CountryModel.fromJson(json['country']) : null)!;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['user_id'] = _userId;
    data['phone'] = _phone;
    data['country_code'] = _countryCode;
    data['gender'] = _gender;
    data['display_name'] = _displayName;
    data['birthday'] = _birthday;
    data['avatar'] = _avatar;
    data['point_total'] = _pointTotal;
    data['is_tester'] = _isTester;
    data['code_referrer'] = _codeReferrer;
    data['referrer'] = _referrer;
    data['vip'] = _vip;
    data['target'] = _target;
    data['app_version'] = _appVersion;
    data['platform'] = _platform;
    data['likes'] = _likes;
    data['follow'] = _follow;
    data['invited'] = _invited;
    data['monthly_vip'] = _monthlyVip;
    if (_wallet != null) {
      data['wallet'] = _wallet!.toJson();
    }
    if (_country != null) {
      data['country'] = _country!.toJson();
    }
    return data;
  }
}