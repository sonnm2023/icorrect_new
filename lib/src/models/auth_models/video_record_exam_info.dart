class VideoExamRecordInfo {
  int? questionId;
  String? filePath;
  int? duration;

  int? get getQuestionId => questionId ?? 0;

  set setQuestionId(int? questionId) => this.questionId = questionId;

  get getFilePath => filePath ?? "";

  set setFilePath(filePath) => this.filePath = filePath;

  get getDuration => duration ?? 0;

  set setDuration(duration) => this.duration = duration;

  VideoExamRecordInfo({required this.questionId,required this.filePath, required this.duration});
}
