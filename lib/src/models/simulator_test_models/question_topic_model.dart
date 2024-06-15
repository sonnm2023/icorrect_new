import 'dart:convert';

import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';

QuestionTopicModel questionTopicModelFromJson(String str) =>
    QuestionTopicModel.fromJson(json.decode(str));
String questionTopicModelToJson(QuestionTopicModel data) =>
    json.encode(data.toJson());

class QuestionTopicModel {
  int? _id;
  String? _content;
  int? _type;
  int? _topicId;
  String? _tips;
  int? _tipType;
  int? _isFollowUp;
  String? _cueCard;
  int? _reAnswerCount = 0;
  List<FileTopicModel>? _answers;
  int? _numPart;
  //0 - first answer  1 - second answer(repeat 1)  2 - third answer (repeat 2)
  int? _repeatIndex = 0;
  List<FileTopicModel>? _files;
  bool _isError = false;

  QuestionTopicModel({
    int? id,
    String? content,
    int? type,
    int? topicId,
    String? tips,
    int? tipType,
    int? isFollowUp,
    String? cueCard,
    int? reAnswerCount,
    List<FileTopicModel>? answers,
    int? numPart,
    int? repeatIndex,
    List<FileTopicModel>? files,
    bool isError = false,
  }) {
    _id = id;
    _content = content;
    _type = type;
    _topicId = topicId;
    _tips = tips;
    _tipType = tipType;
    _isFollowUp = isFollowUp;
    _cueCard = cueCard;
    _reAnswerCount = reAnswerCount;
    _answers = answers;
    _numPart = numPart;
    _repeatIndex = repeatIndex;
    _files = files;
    _isError = isError;
  }

  int get id => _id ?? 0;
  set id(int id) => _id = id;
  String get content => _content ?? "";
  set content(String content) => _content = content;
  int get type => _type ?? 0;
  set type(int type) => _type = type;
  int get topicId => _topicId ?? 0;
  set topicId(int topicId) => _topicId = topicId;
  String get tips => _tips ?? "";
  set tips(String tips) => _tips = tips;
  int get tipType => _tipType ?? 0;
  set tipType(int tipType) => _tipType = tipType;

  int get isFollowUp => _isFollowUp ?? 0;
  set isFollowUp(int isFollowUp) => _isFollowUp = isFollowUp;
  String get cueCard => _cueCard ?? "";
  set cueCard(String cueCard) => _cueCard = cueCard;
  int get reAnswerCount => _reAnswerCount ?? 0;
  set reAnswerCount(int reAnswerCount) => _reAnswerCount = reAnswerCount;
  List<FileTopicModel> get answers => _answers ?? [];
  set answers(List<FileTopicModel> answers) => _answers = answers;
  int get numPart => _numPart ?? 0;
  set numPart(int numPart) => _numPart = numPart;
  int get repeatIndex => _repeatIndex ?? 0;
  set repeatIndex(int repeatIndex) => _repeatIndex = repeatIndex;
  bool get isError => _isError;
  set isError(bool value) => _isError = value;

  List<FileTopicModel> get files => _files ?? [];
  set files(List<FileTopicModel> files) => _files = files;

  bool isFollowUpQuestion() {
    return isFollowUp == 1;
  }

  QuestionTopicModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _content = json['content'];
    _type = json['type'];
    _topicId = json['topic_id'];
    _tips = json['tips'];
    _tipType = json['tip_type'];
    _isFollowUp = json['is_follow_up'];
    _cueCard = json['cue_card'];
    _reAnswerCount = json['reanswer'];
    _numPart = json['num_part'];

    if (json['answer'] != null) {
      _answers = <FileTopicModel>[];
      json['answer'].forEach((v) {
        _answers!.add(FileTopicModel.fromAnswerJson(v));
      });
    }

    if (json['files'] != null) {
      _files = <FileTopicModel>[];
      json['files'].forEach((v) {
        _files!.add(FileTopicModel.fromJson(v));
      });
    }
  }

  String contentQuestion() {
    if (_answers!.isNotEmpty) {
      if ((_answers!.length == 2 && _repeatIndex == 0) ||
          (_answers!.length == 3 && (_repeatIndex == 0 || _repeatIndex == 1))) {
        return "Ask for repeat question";
      }
    }
    return _content!;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['content'] = _content;
    data['type'] = _type;
    data['topic_id'] = _topicId;
    data['tips'] = _tips;
    data['tip_type'] = _tipType;
    if (_files != null) {
      data['files'] = _files!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  // QuestionTopicModel copyWith({
  //   required QuestionTopicModel questionTopicModel,
  // })
  QuestionTopicModel copyWith({
    int? id,
    String? content,
    int? type,
    int? topicId,
    String? tips,
    int? tipType,
    int? isFollowUp,
    String? cueCard,
    int? reAnswerCount,
    List<FileTopicModel>? answers,
    int? numPart,
    int? repeatIndex,
    List<FileTopicModel>? files,
    bool? isError,
  }) =>
      QuestionTopicModel(
        id: id ?? this.id,
        content: content ?? this.content,
        type: type ?? this.type,
        topicId: topicId ?? this.topicId,
        tips: tips ?? this.tips,
        tipType: tipType ?? this.tipType,
        isFollowUp: isFollowUp ?? this.isFollowUp,
        cueCard: cueCard ?? this.cueCard,
        reAnswerCount: reAnswerCount ?? this.reAnswerCount,
        answers: answers ?? this.answers,
        numPart: numPart ?? this.numPart,
        repeatIndex: repeatIndex ?? this.repeatIndex,
        files: files ?? this.files,
        isError: isError ?? this.isError,
      );
}
