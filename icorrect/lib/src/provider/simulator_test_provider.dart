import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/models/auth_models/video_record_exam_info.dart';
import 'package:icorrect/src/models/my_test_models/student_result_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
// import 'package:video_compress/video_compress.dart';

class SimulatorTestProvider with ChangeNotifier {
  bool isDisposed = false;

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!isDisposed) {
      super.notifyListeners();
    }
  }

  int _timeRecordCounting = 0;
  int get timeRecordCounting => _timeRecordCounting;
  void setTimeRecordCounting(int count) {
    _timeRecordCounting = count;
  }

  bool _visibleCameraLive = true;
  bool get visibleCameraLive => _visibleCameraLive;
  void setVisibleCameraLive(bool visible) {
    _visibleCameraLive = visible;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  File _savedVideoFile = File("");
  File get savedVideoFile => _savedVideoFile;
  void setVideoFile(File file) {
    _savedVideoFile = file;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _canRecordVideo = false;
  bool get canRecordVideo => _canRecordVideo;
  void setRecordVideo(bool canRecord) {
    _canRecordVideo = canRecord;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  List<VideoExamRecordInfo> _videosSaved = [];
  List<VideoExamRecordInfo> get videosSaved => _videosSaved;
  void setVideosSaved(List<VideoExamRecordInfo> videos) {
    if (_videosSaved.isNotEmpty) {
      _videosSaved.clear();
    }
    _videosSaved.addAll(videos);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void addVideoRecorded(VideoExamRecordInfo video) {
    _videosSaved.add(video);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearVideosSaved() {
    if (_videosSaved.isNotEmpty) {
      _videosSaved.clear();
    }
    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _currentCountRecordingVideo = 0;
  int get currentCountRecordingVideo => _currentCountRecordingVideo;
  void setCurrentCountRecordingVideo(int count) {
    _currentCountRecordingVideo = count;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isGettingTestDetail = true;
  bool get isGettingTestDetail => _isGettingTestDetail;
  void setGettingTestDetailStatus(bool isProcessing) {
    _isGettingTestDetail = isProcessing;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isShowConfirmSaveTest = false;
  bool get isShowConfirmSaveTest => _isShowConfirmSaveTest;
  void setShowConfirmSaveTest(bool isShow) {
    _isShowConfirmSaveTest = isShow;
  }

  bool _isDownloadProgressing = false;
  bool get isDownloadProgressing => _isDownloadProgressing;
  void setDownloadProgressingStatus(bool isDownloading) {
    _isDownloadProgressing = isDownloading;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _startNowAvailable = false;
  bool get startNowAvailable => _startNowAvailable;
  void setStartNowStatus(bool available) {
    _startNowAvailable = available;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _total = 0;
  int get total => _total;
  void setTotal(int total) {
    _total = total;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _downloadingIndex = 0;
  int get downloadingIndex => _downloadingIndex;
  void updateDownloadingIndex(int index) {
    _downloadingIndex = index;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  double _downloadingPercent = 0.0;
  double get downloadingPercent => _downloadingPercent;
  void updateDownloadingPercent(double percent) {
    _downloadingPercent = percent;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _permissionDeniedTime = 0;
  int get permissionDeniedTime => _permissionDeniedTime;
  void setPermissionDeniedTime() {
    _permissionDeniedTime++;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  //Status of doing the test
  DoingStatus _doingStatus = DoingStatus.none;
  DoingStatus get doingStatus => _doingStatus;
  void updateDoingStatus(DoingStatus status) {
    _doingStatus = status;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  String _activityType = '';
  String get activityType => _activityType;
  void setActivityType(String type) {
    _activityType = type;
  }

  SubmitStatus _submitStatus = SubmitStatus.none;
  SubmitStatus get submitStatus => _submitStatus;
  void updateSubmitStatus(SubmitStatus status) {
    _submitStatus = status;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  TestDetailModel _currentTestDetail = TestDetailModel();
  TestDetailModel get currentTestDetail => _currentTestDetail;
  void setCurrentTestDetail(TestDetailModel testDetailModel) {
    _currentTestDetail = testDetailModel;
  }

  final List<String> _answerList = [];
  List<String> get answerList => _answerList;
  void setAnswerList(List<String> list) {
    _answerList.clear();
    _answerList.addAll(list);
  }

  bool _isLoadingVideo = false;
  bool get isLoadingVideo => _isLoadingVideo;
  void setIsLoadingVideo(bool isLoading) {
    _isLoadingVideo = isLoading;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _needDownloadAgain = false;
  bool get needDownloadAgain => _needDownloadAgain;
  void setNeedDownloadAgain(bool need) {
    _needDownloadAgain = need;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _visibleCueCard = false;
  bool get visibleCueCard => _visibleCueCard;
  void setVisibleCueCard(bool visible) {
    _visibleCueCard = visible;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _visibleRepeat = true;
  bool get visibleRepeat => _visibleRepeat;
  void setVisibleRepeat(bool visible) {
    _visibleRepeat = visible;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _countRepeat = 0;
  int get countRepeat => _countRepeat;
  void setCountRepeat(int countRepeat) {
    _countRepeat = countRepeat;
  }

  bool _isVisibleSave = false;
  bool get isVisibleSaveTheTest => _isVisibleSave;
  void setVisibleSaveTheTest(bool visible) {
    _isVisibleSave = visible;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _reviewingCurrentIndex = 0;
  int get reviewingCurrentIndex => _reviewingCurrentIndex;
  void updateReviewingCurrentIndex(int index) {
    _reviewingCurrentIndex = index;
  }

  final List<QuestionTopicModel> _questionList = [];
  List<QuestionTopicModel> get questionList => _questionList;
  void addCurrentQuestionIntoList({
    required QuestionTopicModel questionTopic,
    required int repeatIndex,
    required bool isRepeat,
  }) {
    QuestionTopicModel temp = QuestionTopicModel().copyWith(
        id: questionTopic.id,
        content: questionTopic.content,
        type: questionTopic.type,
        topicId: questionTopic.topicId,
        tips: questionTopic.tips,
        tipType: questionTopic.tipType,
        isFollowUp: questionTopic.isFollowUp,
        cueCard: questionTopic.cueCard,
        reAnswerCount: questionTopic.reAnswerCount,
        answers: questionTopic.answers,
        numPart: questionTopic.numPart,
        repeatIndex: questionTopic.repeatIndex,
        files: questionTopic.files);
    if (isRepeat) {
      temp.content = StringConstants.repeat_question;
    }
    temp.repeatIndex = repeatIndex;
    _questionList.add(temp);

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void setQuestionList(List<QuestionTopicModel> list) {
    _questionList.clear();
    _questionList.addAll(list);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearQuestionList() {
    _questionList.clear();
  }

  QuestionTopicModel _currentQuestion = QuestionTopicModel();
  QuestionTopicModel get currentQuestion => _currentQuestion;
  void setCurrentQuestion(QuestionTopicModel question) {
    _currentQuestion = question;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  ReviewingStatus _reviewingStatus = ReviewingStatus.none;
  ReviewingStatus get reviewingStatus => _reviewingStatus;
  void updateReviewingStatus(ReviewingStatus status) {
    if (kDebugMode) {
      print("DEBUG: Current status of Reviewing = $_reviewingStatus");
      print("DEBUG: Next status of Reviewing = $status");
    }
    _reviewingStatus = status;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _indexOfHeaderPart2 = 0;
  int get indexOfHeaderPart2 => _indexOfHeaderPart2;
  void setIndexOfHeaderPart2(int i) {
    _indexOfHeaderPart2 = i;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _indexOfHeaderPart3 = 0;
  int get indexOfHeaderPart3 => _indexOfHeaderPart3;
  void setIndexOfHeaderPart3(int i) {
    _indexOfHeaderPart3 = i;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _indexOfCurrentQuestion = 0;
  int get indexOfCurrentQuestion => _indexOfCurrentQuestion;
  void setIndexOfCurrentQuestion(int i) {
    _indexOfCurrentQuestion = i;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void resetIndexOfCurrentQuestion() {
    _indexOfCurrentQuestion = 0;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _finishPlayFollowUp = false;
  bool get finishPlayFollowUp => _finishPlayFollowUp;
  void setFinishPlayFollowUp(bool isFinish) {
    _finishPlayFollowUp = isFinish;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _visibleRecord = false;
  bool get visibleRecord => _visibleRecord;
  void setVisibleRecord(bool isVisible) {
    _visibleRecord = isVisible;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isLessThan2Second = true;
  bool get isLessThan2Second => _isLessThan2Second;
  void setIsLessThan2Second(bool isLess) {
    _isLessThan2Second = isLess;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _timeRecord = 0;
  int get timeRecord => _timeRecord;
  void setTimeRecord(int seconds) {
    _timeRecord = seconds;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _enableRepeatButton = true;
  bool get enableRepeatButton => _enableRepeatButton;
  void setEnableRepeatButton(bool enable) {
    _enableRepeatButton = enable;
  }

  String? _strCountCueCard;
  String get strCountCueCard => _strCountCueCard ?? '00:00';
  void setCountDownCueCard(
      {required String strCount, required bool needToNotify}) {
    _strCountCueCard = strCount;

    if (needToNotify) {
      notifyListeners();
    }
  }

  bool _isReviewingPlayAnswer = false;
  bool get isReviewingPlayAnswer => _isReviewingPlayAnswer;
  void setIsReviewingPlayAnswer(bool isReviewingPlayAnswer) {
    _isReviewingPlayAnswer = isReviewingPlayAnswer;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  final List<QuestionTopicModel> _listVideoSource = [];
  List<QuestionTopicModel> get listVideoSource => _listVideoSource;
  void setListVideoSource(List<QuestionTopicModel> list) {
    _listVideoSource.clear();
    _listVideoSource.addAll(list);
  }

  void addVideoSource(QuestionTopicModel q) {
    _listVideoSource.add(q);
  }

  void clearListVideoSource() {
    _listVideoSource.clear();
  }

  bool _questionHasImage = false;
  bool get questionHasImage => _questionHasImage;
  void setQuestionHasImageStatus(bool hasImage) {
    _questionHasImage = hasImage;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  String _questionImageUrl = '';
  String get questionImageUrl => _questionImageUrl;
  void setQuestionImageUrl(String url) {
    _questionImageUrl = url;
  }

  void resetQuestionImageUrl() {
    _questionImageUrl = '';
  }

  String _questionImageUrlFromLocal = '';
  String get questionImageUrlFromLocal => _questionImageUrlFromLocal;
  void setQuestionImageUrlFromLocal(String url) {
    _questionImageUrlFromLocal = url;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void resetQuestionImageUrlFromLocal() {
    _questionImageUrlFromLocal = '';
  }

  List<StudentResultModel> _highLightHomeWorks = [];
  List<StudentResultModel> get highLightHomeworks => _highLightHomeWorks;
  void setHighLightHomeworks(List<StudentResultModel> homeworks) {
    _highLightHomeWorks = homeworks;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  List<StudentResultModel> _otherLightHomeWorks = [];
  List<StudentResultModel> get otherLightHomeWorks => _otherLightHomeWorks;
  void setOtherLightHomeWorks(List<StudentResultModel> homeworks) {
    _otherLightHomeWorks = homeworks;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _needUpdateReanswer = false;
  bool get needUpdateReanswer => _needUpdateReanswer;
  void setNeedUpdateReanswerStatus(bool isNeed) {
    _needUpdateReanswer = isNeed;
  }

  void resetNeedUpdateReanswerStatus() {
    _needUpdateReanswer = false;
  }

  bool _showFullImage = false;
  bool get showFullImage => _showFullImage;
  void setShowFullImage(bool show) {
    _showFullImage = show;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  String _selectedQuestionImageUrl = '';
  String get selectedQuestionImageUrl => _selectedQuestionImageUrl;
  void setSelectedQuestionImageUrl(String url) {
    _selectedQuestionImageUrl = url;
  }

  void resetSelectedQuestionImageUrl() {
    _selectedQuestionImageUrl = '';
  }

  bool _isReDownload = false;
  bool get isReDownload => _isReDownload;
  void setIsReDownload(bool reDownload) {
    _isReDownload = reDownload;
  }

  int _playingIndexWhenReDownload = 0;
  int get playingIndexWhenReDownload => _playingIndexWhenReDownload;
  void setPlayingIndexWhenReDownload(int index) {
    _playingIndexWhenReDownload = index;
  }

  final List<Map<String, dynamic>> _logActions = [];
  List<Map<String, dynamic>> get logActions => _logActions;
  void addLogActions(Map<String, dynamic> log) {
    _logActions.add(log);
  }

  void resetLogActions() {
    _logActions.clear();
  }

  bool _enabledFinish = true;
  bool get enabledFinish => _enabledFinish;
  void setEnabledFinish(bool enabled) {
    _enabledFinish = enabled;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _hasOrder = false;
  bool get hasOrder => _hasOrder;
  void setHasOrderStatus(bool hasOrder) {
    _hasOrder = hasOrder;
  }

  bool _needRefreshActivityList = false;
  bool get needRefreshActivityList => _needRefreshActivityList;
  void setNeedRefreshActivityList(bool needRefresh) {
    _needRefreshActivityList = needRefresh;
  }

  int _totalDuration = 0;
  int get totalDuration => _totalDuration;
  void updateTotalDuration(int total) {
    _totalDuration = total;
  }

  void addDuration(int duration) {
    _totalDuration += duration;
    if (kDebugMode) {
      print("DEBUG: Total duration = $_totalDuration");
    }
  }

  void resetTotalDuration() {
    _totalDuration = 0;
  }

  List<QuestionTopicModel> _errorQuestionList = [];
  List<QuestionTopicModel> get errorQuestionList => _errorQuestionList;
  void addErrorQuestion(QuestionTopicModel q) {
    _errorQuestionList.add(q);
  }

  void resetErrorQuestionList() {
    _errorQuestionList.clear();
  }

  void removeErrorQuestion(QuestionTopicModel q) {
    if (errorQuestionList.isEmpty) return;
    if (errorQuestionList.contains(q)) {
      _errorQuestionList.remove(q);
    }
  }

  void updateQuestionStatus(QuestionTopicModel q) {
    int index = questionList.indexWhere((question) => question.id == q.id);
    if (index != -1) {
      questionList[index] = q;
      notifyListeners();
    }
  }

  bool _isReAnswer = false;
  bool get isReAnswer => _isReAnswer;
  void setIsReAnswer() {
    _isReAnswer = true;
  }

  void resetIsReAnswer() {
    _isReAnswer = false;
  }

  void resetAll() {
    _isReAnswer = false;
    _errorQuestionList = [];
    _totalDuration = 0;
    _needRefreshActivityList = false;
    _hasOrder = false;
    _enabledFinish = true;
    resetLogActions();
    _videosSaved = [];
    _timeRecordCounting = 0;
    _playingIndexWhenReDownload = 0;
    _isReDownload = false;
    _isShowConfirmSaveTest = false;
    _isLessThan2Second = true;
    _visibleCameraLive = true;
    _savedVideoFile = File("");
    _currentCountRecordingVideo = 0;
    _needDownloadAgain = false;
    _isLoadingVideo = false;
    _answerList.clear();
    _currentTestDetail = TestDetailModel();
    _doingStatus = DoingStatus.none;
    _submitStatus = SubmitStatus.none;
    _activityType = '';
    _permissionDeniedTime = 0;
    _isGettingTestDetail = true;
    _isDownloadProgressing = false;
    _startNowAvailable = false;
    _total = 0;
    _downloadingIndex = 0;
    _downloadingPercent = 0.0;
    _isReviewingPlayAnswer = false;
    _strCountCueCard = null;
    _enableRepeatButton = true;
    _visibleRecord = false;
    _indexOfHeaderPart2 = 0;
    _indexOfHeaderPart3 = 0;
    _visibleCueCard = false;
    _visibleRepeat = true;
    _isVisibleSave = false;
    _countRepeat = 0;
    _currentQuestion = QuestionTopicModel();
    _indexOfCurrentQuestion = 0;
    _reviewingStatus = ReviewingStatus.none;
    clearQuestionList();
    clearListVideoSource();
    resetNeedUpdateReanswerStatus();
    resetSelectedQuestionImageUrl();
    resetQuestionImageUrl();
    resetQuestionImageUrlFromLocal();
  }
}
