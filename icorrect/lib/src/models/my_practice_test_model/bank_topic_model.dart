class Topic {
  int? _id;
  String? _title;
  List<SubTopics>? _subTopics;
  bool _isExpanded = false;
  bool _isSelected = false;

  Topic({
    int? id,
    String? title,
    List<SubTopics>? subTopics,
    required bool isExpanded,
    required bool isSelected,
  }) {
    if (id != null) {
      this._id = id;
    }
    if (title != null) {
      this._title = title;
    }
    if (subTopics != null) {
      this._subTopics = subTopics;
    }
    this._isExpanded = isExpanded;
    this._isSelected = isSelected;
  }

  int? get id => _id;
  set id(int? id) => _id = id;
  String? get title => _title;
  set title(String? title) => _title = title;
  List<SubTopics>? get subTopics => _subTopics;
  set subTopics(List<SubTopics>? subTopics) => _subTopics = subTopics;
  bool get isExpanded => _isExpanded;
  set isExpanded(bool isExpanded) => _isExpanded = isExpanded;
  bool get isSelected => _isSelected;
  set isSelected(bool isSelected) => _isSelected = isSelected;

  Topic.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _title = json['title'];
    if (json['sub_topics'] != null) {
      _subTopics = <SubTopics>[];
      json['sub_topics'].forEach((v) {
        _subTopics!.add(SubTopics.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['title'] = this._title;
    if (this._subTopics != null) {
      data['sub_topics'] = this._subTopics!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SubTopics {
  int? _id;
  String? _title;
  bool _isSelected = false;

  SubTopics({int? id, String? title, required bool isSelected}) {
    if (id != null) {
      this._id = id;
    }
    if (title != null) {
      this._title = title;
    }
    this._isSelected = isSelected;
  }

  int? get id => _id;
  set id(int? id) => _id = id;
  String? get title => _title;
  set title(String? title) => _title = title;
  bool get isSelected => _isSelected;
  set isSelected(bool isSelected) => _isSelected = isSelected;

  SubTopics.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['title'] = this._title;
    return data;
  }
}