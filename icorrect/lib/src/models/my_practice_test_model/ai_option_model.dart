class AiOption {
  int? block;
  int? option;
  int? diamond;
  String? name;

  AiOption({this.block, this.option, this.diamond, this.name});

  AiOption.fromJson(Map<String, dynamic> json) {
    block = json['block'];
    option = json['option'];
    diamond = json['diamond'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['block'] = block;
    data['option'] = option;
    data['diamond'] = diamond;
    data['name'] = name;
    return data;
  }
}
