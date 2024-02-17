class ScoringOrderConfigInfo {
  int? scoringEachQuest;
  List<AiOption>? aiOption;

  ScoringOrderConfigInfo({this.scoringEachQuest, this.aiOption});

  ScoringOrderConfigInfo.fromJson(Map<String, dynamic> json) {
    // scoringEachQuest = 0; //For test: disable scoring by group
    scoringEachQuest = json['scoring_each_quest'];
    if (json['ai_option'] != null) {
      aiOption = <AiOption>[];
      json['ai_option'].forEach((v) {
        aiOption!.add(AiOption.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['scoring_each_quest'] = scoringEachQuest;
    if (aiOption != null) {
      data['ai_option'] = aiOption!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

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
