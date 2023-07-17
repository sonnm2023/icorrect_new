import 'dart:convert';

WalletModel walletModelFromJson(String str) => WalletModel.fromJson(json.decode(str));
String walletModelToJson(WalletModel data) => json.encode(data.toJson());

class WalletModel {
  int? _usd;
  int? _type;
  int? _point;
  String? _codeTransfer;
  int _id = 0;

  WalletModel({
    required int id,
    int? usd,
    int? type,
    int? point,
    String? codeTransfer,
  }) {
    _usd = usd;
    _type = type;
    _point = point;
    _codeTransfer = codeTransfer;
    _id = id;
  }

  int get usd => _usd ?? 0;
  set usd(int usd) => _usd = usd;
  int get type => _type ?? 0;
  set type(int type) => _type = type;
  int get point => _point ?? 0;
  set point(int point) => _point = point;
  String get codeTransfer => _codeTransfer ?? "";
  set codeTransfer(String codeTransfer) => _codeTransfer = codeTransfer;
  int get id => _id;
  set id(int id) => _id = id;

  WalletModel.fromJson(Map<String, dynamic> json) {
    _usd = json['usd'];
    _type = json['type'];
    _point = json['point'];
    _codeTransfer = json['code_transfer'];
    _id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['usd'] = _usd;
    data['type'] = _type;
    data['point'] = _point;
    data['code_transfer'] = _codeTransfer;
    data['id'] = _id;
    return data;
  }
}