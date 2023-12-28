class BankModel {
  int? _id;
  String? _bankDistributeCode;
  String? _title;

  BankModel({int? id, String? bankDistributeCode, String? title}) {
    if (id != null) {
      this._id = id;
    }
    if (bankDistributeCode != null) {
      this._bankDistributeCode = bankDistributeCode;
    }
    if (title != null) {
      this._title = title;
    }
  }

  int? get id => _id;
  set id(int? id) => _id = id;
  String? get bankDistributeCode => _bankDistributeCode;
  set bankDistributeCode(String? bankDistributeCode) =>
      _bankDistributeCode = bankDistributeCode;
  String? get title => _title;
  set title(String? title) => _title = title;

  BankModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _bankDistributeCode = json['bank_distribute_code'];
    _title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['bank_distribute_code'] = this._bankDistributeCode;
    data['title'] = this._title;
    return data;
  }
}
