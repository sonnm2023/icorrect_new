class VerifyModel {
  int? errorCode;
  String? status;
  Data? data;
  String? messages;

  VerifyModel({
    this.errorCode,
    this.status,
    this.data,
    this.messages,
  });

  factory VerifyModel.fromJson(Map<String, dynamic> json) => VerifyModel(
    errorCode: json["error_code"],
    status: json["status"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    messages: json["messages"] ?? json['message'],
  );

  Map<String, dynamic> toJson() => {
    "error_code": errorCode,
    "status": status,
    "data": data?.toJson(),
    "messages": messages,
  };
}

class Data {
  String expireTime;
  String merchantId;
  int configKey;

  Data({
    required this.expireTime,
    required this.merchantId,
    required this.configKey
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    expireTime: json["expire_time"],
    merchantId: json["merchant_id"],
    configKey: json['config_key']
  );

  Map<String, dynamic> toJson() => {
    "expire_time": expireTime,
    "merchant_id": merchantId,
    'config_key': configKey
  };
}