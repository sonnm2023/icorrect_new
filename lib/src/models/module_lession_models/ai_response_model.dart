// To parse this JSON data, do
//
//     final aiResponseModel = aiResponseModelFromJson(jsonString);

import 'dart:convert';
import 'dart:ui';

AiResponseModel aiResponseModelFromJson(String str) => AiResponseModel.fromJson(json.decode(str));

String aiResponseModelToJson(AiResponseModel data) => json.encode(data.toJson());

class AiResponseModel {
  double pronunciationScore;
  Data data;
  int fluencyScore;
  int intonationScore;
  double score;
  bool status;
  String sentence;
  double duration;
  String requestId;
  String userId;
  String profileId;
  double createdAt;
  String audioPath;
  String msg;
  String serverVersion;

  AiResponseModel({
    required this.pronunciationScore,
    required this.data,
    required this.fluencyScore,
    required this.intonationScore,
    required this.score,
    required this.status,
    required this.sentence,
    required this.duration,
    required this.requestId,
    required this.userId,
    required this.profileId,
    required this.createdAt,
    required this.audioPath,
    required this.msg,
    required this.serverVersion,
  });

  factory AiResponseModel.fromJson(Map<String, dynamic> json) => AiResponseModel(
    pronunciationScore: json["pronunciation_score"]?.toDouble(),
    data: Data.fromJson(json["data"]),
    fluencyScore: json["fluency_score"],
    intonationScore: json["intonation_score"],
    score: json["score"]?.toDouble(),
    status: json["status"],
    sentence: json["sentence"],
    duration: json["duration"]?.toDouble(),
    requestId: json["request_id"],
    userId: json["user_id"],
    profileId: json["profile_id"],
    createdAt: json["created_at"]?.toDouble(),
    audioPath: json["audio_path"],
    msg: json["msg"],
    serverVersion: json["server_version"],
  );

  Map<String, dynamic> toJson() => {
    "pronunciation_score": pronunciationScore,
    "data": data.toJson(),
    "fluency_score": fluencyScore,
    "intonation_score": intonationScore,
    "score": score,
    "status": status,
    "sentence": sentence,
    "duration": duration,
    "request_id": requestId,
    "user_id": userId,
    "profile_id": profileId,
    "created_at": createdAt,
    "audio_path": audioPath,
    "msg": msg,
    "server_version": serverVersion,
  };
}

class Data {
  List<Word> words;

  Data({
    required this.words,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    words: List<Word>.from(json["words"].map((x) => Word.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "words": List<dynamic>.from(words.map((x) => x.toJson())),
  };
}

class Word {
  String text;
  List<String> ipa;
  List<Phoneme> phonemes;
  String decision;
  double score;

  Word({
    required this.text,
    required this.ipa,
    required this.phonemes,
    required this.decision,
    required this.score,
  });

  factory Word.fromJson(Map<String, dynamic> json) => Word(
    text: json["text"],
    ipa: List<String>.from(json["ipa"].map((x) => x)),
    phonemes: List<Phoneme>.from(json["phonemes"].map((x) => Phoneme.fromJson(x))),
    decision: json["decision"],
    score: json["score"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "text": text,
    "ipa": List<dynamic>.from(ipa.map((x) => x)),
    "phonemes": List<dynamic>.from(phonemes.map((x) => x.toJson())),
    "decision": decision,
    "score": score,
  };
}

class Phoneme {
  int? startIndex;
  int? endIndex;
  String? text;
  String? ipa;
  double? score;
  String? phonemeError;
  String? decision;

  Phoneme({
    this.startIndex,
    this.endIndex,
    this.text,
    this.ipa,
    this.score,
    this.phonemeError,
    this.decision,
  });

  factory Phoneme.fromJson(Map<String, dynamic> json) => Phoneme(
    startIndex: json["start_index"],
    endIndex: json["end_index"],
    text: json["text"],
    ipa: json["ipa"],
    score: json["score"]?.toDouble(),
    phonemeError: json["phoneme_error"],
    decision: json["decision"],
  );

  Map<String, dynamic> toJson() => {
    "start_index": startIndex,
    "end_index": endIndex,
    "text": text,
    "ipa": ipa,
    "score": score,
    "phoneme_error": phonemeError,
    "decision": decision,
  };
}

class TextResponseColor {
  String text;
  Color color;

  TextResponseColor({
    required this.text,
    required this.color
  });
}