import 'package:icorrect/src/models/my_practice_test_model/my_practice_test_data_model.dart';

class MyPracticeResponseModel {
  int? _userId;
  MyPracticeDataModel? _myPracticeDataModel;

  MyPracticeResponseModel([this._userId, this._myPracticeDataModel]);

  int get userId => _userId ?? 0;

  set userId(int? value) => _userId = value;

  MyPracticeDataModel get myPracticeDataModel =>
      _myPracticeDataModel ?? MyPracticeDataModel();

  set myPracticeDataModel(value) => _myPracticeDataModel = value;

  MyPracticeResponseModel.fromJson(Map<String, dynamic> json) {
    _userId = json['user_id'] ?? 0;
    if (json['data'] != null) {
      _myPracticeDataModel = MyPracticeDataModel.fromJson(json['data']);
    }
  }
}
