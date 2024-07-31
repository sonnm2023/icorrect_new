class LessonModel {
  int? id;
  String? name;
  List<Mission>? missions;

  LessonModel({
    this.id,
    this.name,
    this.missions,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) => LessonModel(
    id: json["id"],
    name: json["name"],
    missions: json["missions"] == null? [] : List<Mission>.from(json["missions"].map((x) => Mission.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "missions": List<dynamic>.from(missions!.map((x) => x.toJson())),
  };
}

class Mission {
  int? id;
  String? name;
  String? content;
  List<FileElement>? files;
  int? star;
  int? attemp;
  int? maxAttemp;
  double? score;

  Mission({
    this.id,
    this.name,
    this.content,
    this.files,
    this.star,
    this.attemp,
    this.maxAttemp,
    this.score,
  });

  factory Mission.fromJson(Map<String, dynamic> json) => Mission(
    id: json["id"],
    name: json["name"],
    content: json["content"],
    files: json["files"] == null? [] : List<FileElement>.from(json["files"].map((x) => FileElement.fromJson(x))),
    star: json["star"],
    attemp: json["attemp"],
    maxAttemp: json["max_attemp"],
    score: json["score"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "content": content,
    "files": List<dynamic>.from(files!.map((x) => x.toJson())),
    "star": star,
    "attemp": attemp,
    "max_attemp": maxAttemp,
    "score": score,
  };
}

class FileElement {
  int? id;
  String? url;
  int? type;

  FileElement({
    this.id,
    this.url,
    this.type,
  });

  factory FileElement.fromJson(Map<String, dynamic> json) => FileElement(
    id: json["id"],
    url: json["url"],
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "url": url,
    "type": type,
  };
}