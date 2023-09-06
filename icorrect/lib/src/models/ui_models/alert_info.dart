class AlertInfo {
  var _title;
  var _description;
  var _typeAlert;

  AlertInfo([this._title, this._description, this._typeAlert]);

  get title => this._title;

  set title(var value) => this._title = value;

  get description => this._description;

  set description(value) => this._description = value;

  get typeAlert => this._typeAlert;

  set typeAlert(value) => this._typeAlert = value;
}