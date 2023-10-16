import 'dart:convert';

import 'package:icorrect/src/models/user_authentication/file_authentication_detail.dart';

UserAuthenDetailModel userAuthDetailModelFromJson(String str) =>
    UserAuthenDetailModel.fromJson(json.decode(str));

class UserAuthenDetailModel {
  int? _id;
  int? _userId;
  String? _userCode;
  String? _createAt;
  String? _updateAt;
  String? _deleteAt;
  int? _status;
  String? _merchantId;
  String? _note;
  List<FileAuthDetailModel>? _audioAuthDetail;
  List<FileAuthDetailModel>? _videoAuthDetail;

  UserAuthenDetailModel(
      [this._id,
      this._userId,
      this._userCode,
      this._createAt,
      this._updateAt,
      this._deleteAt,
      this._status,
      this._merchantId,
      this._note,
      this._audioAuthDetail,
      this._videoAuthDetail]);

  int? get id => _id ?? 0;

  set id(int? value) => _id = value;

  int get userId => _userId ?? 0;

  set userId(value) => _userId = value;

  get userCode => _userCode;

  set userCode(value) => _userCode = value;

  String get createAt => _createAt ?? "";

  set createAt(value) => _createAt = value;

  String get updateAt => _updateAt ?? "";

  set updateAt(value) => _updateAt = value;

  String get deleteAt => _deleteAt ?? "";

  set deleteAt(value) => _deleteAt = value;

  int get status => _status ?? 0;

  set status(value) => _status = value;

  String get merchantId => _merchantId ?? "";

  set merchantId(value) => _merchantId = value;

  String get note => _note ?? "";

  set note(value) => _note = value;
  List<FileAuthDetailModel> get audiosAuthDetail => _audioAuthDetail ?? [];

  set audioAuthDetail(List<FileAuthDetailModel>? value) =>
      _audioAuthDetail = value;

  List<FileAuthDetailModel> get videosAuthDetail => _videoAuthDetail ?? [];

  set setvideoAuthDetail(value) => _videoAuthDetail = value;
  UserAuthenDetailModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'] ?? 0;
    _userId = json['user_id'] ?? 0;
    _userCode = json['user_code'] ?? "";
    _createAt = json['created_at'] ?? "";
    _updateAt = json['updated_at'] ?? "";
    _deleteAt = json['deleted_at'] ?? "";
    _status = json['status'] ?? 0;
    _merchantId = json['merchant_id'] ?? "";
    _note = json['note'] ?? "";

    _audioAuthDetail = [];
    _videoAuthDetail = [];

    if (json['audios'] != null) {
      List<dynamic> audioList = json['audios'] ?? [];
      for (int i = 0; i < audioList.length; i++) {
        _audioAuthDetail!.add(FileAuthDetailModel.fromJson(json['audios'][i]));
      }
    }

    if (json['videos'] != null) {
      List<dynamic> videoList = json['videos'] ?? [];
      for (int i = 0; i < videoList.length; i++) {
        _videoAuthDetail!.add(FileAuthDetailModel.fromJson(json['videos'][i]));
      }
    }
  }
}
