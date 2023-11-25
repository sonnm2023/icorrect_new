import 'package:icorrect/src/models/my_practice_test_model/my_practice_test_model.dart';

class MyPracticeDataModel {
  int? _currentPage;
  List<MyPracticeTestModel>? _myPracticeTests = [];
  String? _firstPageUrl;
  int? _from;
  int? _lastPage;
  String? _lastPageUrl;
  String? _nextPageUrl;
  String? _path;
  String? _perPage;
  String? _prevPageUrl;
  int? _to;
  int? _total;

  MyPracticeDataModel(
      [this._currentPage,
      this._myPracticeTests,
      this._firstPageUrl,
      this._from,
      this._lastPage,
      this._lastPageUrl,
      this._nextPageUrl,
      this._path,
      this._perPage,
      this._prevPageUrl,
      this._to,
      this._total]);

  int get currentPage => _currentPage ?? 0;

  set currentPage(value) => _currentPage = value;

  List<MyPracticeTestModel> get myPracticeTests => _myPracticeTests ?? [];

  set myPracticeTests(value) => _myPracticeTests = value;

  String get firstPageUrl => _firstPageUrl ?? "";

  set firstPageUrl(value) => _firstPageUrl = value;

  int get from => _from ?? 0;

  set from(value) => _from = value;

  int get lastPage => _lastPage ?? 0;

  set lastPage(value) => _lastPage = value;

  String get lastPageUrl => _lastPageUrl ?? "";

  set lastPageUrl(value) => _lastPageUrl = value;

  String get nextPageUrl => _nextPageUrl ?? "";

  set nextPageUrl(value) => _nextPageUrl = value;

  String get path => _path ?? "";

  set path(value) => _path = value;

  String get perPage => _perPage ?? "";

  set perPage(value) => _perPage = value;

  String get prevPageUrl => _prevPageUrl ?? "";

  set prevPageUrl(value) => _prevPageUrl = value;

  int get to => _to ?? 0;

  set to(value) => _to = value;

  int get total => _total ?? 0;

  set total(value) => _total = value;

  MyPracticeDataModel.fromJson(Map<String, dynamic> json) {
    _currentPage = json['current_page'] ?? 0;
    if (json['data'] != null) {
      json['data'].forEach((v) {
        _myPracticeTests!.add(MyPracticeTestModel.fromJson(v));
      });
    }
    _firstPageUrl = json['first_page_url'] ?? "";
    _from = json['from'] ?? 0;
    _lastPage = json['last_page'] ?? 0;
    _lastPageUrl = json['last_page_url'] ?? "";
    _nextPageUrl = json['next_page_url'] ?? "";
    _path = json['path'] ?? "";
    _perPage = json['per_page'] ?? '';
    _prevPageUrl = json['prev_page_url'] ?? '';
    _to = json['to'] ?? 0;
    _total = json['total'] ?? 0;
  }
}
