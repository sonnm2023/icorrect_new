class ClassMerchantModel {
  int? errorCode;
  String? status;
  Data? data;
  String? message;

  ClassMerchantModel({
    this.errorCode,
    this.status,
    this.data,
    this.message
  });

  factory ClassMerchantModel.fromJson(Map<String, dynamic> json) => ClassMerchantModel(
    errorCode: json["error_code"],
    status: json["status"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    message: json['message']
  );

  Map<String, dynamic> toJson() => {
    "error_code": errorCode,
    "status": status,
    "data": data?.toJson(),
    'messages': message
  };
}

class Data {
  int? currentPage;
  List<ClassModel>? data;
  int? from;
  int? lastPage;
  int? perPage;
  int? total;

  Data({
    this.currentPage,
    this.data,
    this.from,
    this.lastPage,
    this.perPage,
    this.total,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    currentPage: json["current_page"],
    data: json['data'] == null ? null : List<ClassModel>.from(json["data"].map((x) => ClassModel.fromJson(x))),
    from: json["from"],
    lastPage: json["last_page"],
    perPage: json["per_page"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "data": List<dynamic>.from(data!.map((x) => x.toJson())),
    "from": from,
    "last_page": lastPage,
    "per_page": perPage,
    "total": total,
  };
}

class ClassModel {
  int? id;
  String? name;
  DateTime? createdAt;
  String? classId;
  int? studentCount;
  int? activitiesCount;

  ClassModel({
    this.id,
    this.name,
    this.createdAt,
    this.classId,
    this.studentCount,
    this.activitiesCount,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) => ClassModel(
    id: json["id"],
    name: json["name"],
    createdAt: DateTime.parse(json["created_at"]),
    classId: json["class_id"],
    studentCount: json["student_count"],
    activitiesCount: json["activities_count"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "created_at": createdAt!.toIso8601String(),
    "class_id": classId,
    "student_count": studentCount,
    "activities_count": activitiesCount,
  };
}