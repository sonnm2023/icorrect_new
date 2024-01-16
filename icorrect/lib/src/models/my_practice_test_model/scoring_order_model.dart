class ScoringOrderModel {
  int? id;
  int? cost;
  int? status;
  String? createdAt;
  int? scoreBy;
  int? score;

  ScoringOrderModel({
    this.id,
    this.cost,
    this.status,
    this.createdAt,
    this.scoreBy,
    this.score,
  });

  ScoringOrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cost = json['cost'];
    status = json['status'];
    createdAt = json['created_at'];
    scoreBy = json['score_by'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['cost'] = cost;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['score_by'] = scoreBy;
    data['score'] = score;
    return data;
  }
}
