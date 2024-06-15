import 'dart:convert';

CountryModel countryModelFromJson(String str) => CountryModel.fromJson(json.decode(str));
String countryModelToJson(CountryModel data) => json.encode(data.toJson());

class CountryModel {
  int? _id = 0;
  String? _iso;
  String? _name;
  String? _nicename;
  String? _iso3;
  int? _numcode;
  int? _phonecode;

  CountryModel(
      {int? id,
        String? iso,
        String? name,
        String? nicename,
        String? iso3,
        int? numcode,
        int? phonecode}) {
    _id = id;
    _iso = iso;
    _name = name;
    _nicename = nicename;
    _iso3 = iso3;
    _numcode = numcode;
    _phonecode = phonecode;
  }

  int get id => _id ?? 0;
  set id(int id) => _id = id;
  String get iso => _iso ?? "";
  set iso(String iso) => _iso = iso;
  String get name => _name ?? "";
  set name(String name) => _name = name;
  String get nicename => _nicename ?? "";
  set nicename(String nicename) => _nicename = nicename;
  String get iso3 => _iso3 ?? "";
  set iso3(String iso3) => _iso3 = iso3;
  int get numcode => _numcode ?? 0;
  set numcode(int numcode) => _numcode = numcode;
  int get phonecode => _phonecode ?? 0;
  set phonecode(int phonecode) => _phonecode = phonecode;

  CountryModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _iso = json['iso'];
    _name = json['name'];
    _nicename = json['nicename'];
    _iso3 = json['iso3'];
    _numcode = json['numcode'];
    _phonecode = json['phonecode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['iso'] = _iso;
    data['name'] = _name;
    data['nicename'] = _nicename;
    data['iso3'] = _iso3;
    data['numcode'] = _numcode;
    data['phonecode'] = _phonecode;
    return data;
  }
}