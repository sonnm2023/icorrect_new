class SyllabusMerchantModel {
  int? errorCode;
  String? status;
  Data? data;

  SyllabusMerchantModel({
    this.errorCode,
    this.status,
    this.data,
  });

  factory SyllabusMerchantModel.fromJson(Map<String, dynamic> json) => SyllabusMerchantModel(
    errorCode: json["error_code"],
    status: json["status"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "error_code": errorCode,
    "status": status,
    "data": data!.toJson(),
  };
}

class Data {
  String? message;
  bool? status;
  int? errorCode;
  DataData? data;

  Data({
    this.message,
    this.status,
    this.errorCode,
    this.data,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    message: json["message"],
    status: json["status"],
    errorCode: json["error_code"],
    data: DataData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "error_code": errorCode,
    "data": data!.toJson(),
  };
}

class DataData {
  int? currentPage;
  List<Syllabus>? data;
  int? from;
  int? lastPage;
  int? perPage;
  int? total;

  DataData({
    this.currentPage,
    this.data,
    this.from,
    this.lastPage,
    this.perPage,
    this.total,
  });

  factory DataData.fromJson(Map<String, dynamic> json) => DataData(
    currentPage: json["current_page"],
    data: json["data"] == null? [] : List<Syllabus>.from(json["data"].map((x) => Syllabus.fromJson(x))),
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

class Syllabus {
  int? id;
  String? name;
  String? slug;
  dynamic mota;
  int? createdBy;
  int? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? level;
  int? centerId;
  int? sharedByIcorrect;

  Syllabus({
    this.id,
    this.name,
    this.slug,
    this.mota,
    this.createdBy,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.level,
    this.centerId,
    this.sharedByIcorrect,
  });

  factory Syllabus.fromJson(Map<String, dynamic> json) => Syllabus(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    mota: json["mota"],
    createdBy: json["created_by"],
    status: json["status"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    level: json["level"],
    centerId: json["center_id"],
    sharedByIcorrect: json["shared_by_icorrect"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "mota": mota,
    "created_by": createdBy,
    "status": status,
    "created_at": createdAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
    "level": level,
    "center_id": centerId,
    "shared_by_icorrect": sharedByIcorrect,
  };
}
