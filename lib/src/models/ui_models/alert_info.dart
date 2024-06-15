// ignore_for_file: unnecessary_getters_setters, prefer_typing_uninitialized_variables

import 'package:icorrect/src/data_sources/utils.dart';

class AlertInfo {
  var _title;
  var _description;
  var _typeAlert;

  AlertInfo([this._title, this._description, this._typeAlert]);

  get title => _title;

  set title(var value) => _title = value;

  get description => _description;

  set description(value) => _description = value;

  get typeAlert => _typeAlert;

  set typeAlert(value) => _typeAlert = value;
}
