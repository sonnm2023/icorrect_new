import 'dart:async';

import 'package:flutter/material.dart';
import 'package:icorrect/src/models/my_test_models/result_response_model.dart';
import 'package:icorrect/src/models/my_test_models/student_result_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';

class MyTestProvider extends ChangeNotifier {
  bool isDisposed = false;
  @override
  void dispose() {
    dispose();
    super.dispose();
    isDisposed = true;
  }

  void clearData() {
    setVisibleOverviewComment(false);
    setResultResponseModel(ResultResponseModel());
    setOtherLightHomeWorks([]);
    setHighLightHomeworks([]);
    setDownloadingFile(false);
    setTotal(0);
    updateDownloadingIndex(0);
    updateDownloadingPercent(0);
    setAnswerOfQuestions([]);
    setTimerCount('00:00');
    _requestions = [];
    setCountDownTimer(null);
    setCurrentQuestion(QuestionTopicModel());
    setVisibleRecord(false);

    setTotal(0);
    updateDownloadingPercent(0.0);
    updateDownloadingIndex(0);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  ///////////////My Test Screen/////////////////////////////////////////////////

  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  void setDownloadingFile(bool downloading) {
    _isDownloading = downloading;
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

  int _downloadingIndex = 1;
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

  List<QuestionTopicModel> _questions = [];
  List<QuestionTopicModel> get myAnswerOfQuestions => _questions;
  void setAnswerOfQuestions(List<QuestionTopicModel> questions) {
    _questions = questions;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  List<QuestionTopicModel> _requestions = [];
  List<QuestionTopicModel> get reAnswerOfQuestions => _requestions;
  void setReAnswerOfQuestions(QuestionTopicModel question) {
    _requestions.add(question);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearReAnswerOfQuestions() {
    _requestions = [];
    if (!isDisposed) {
      notifyListeners();
    }
  }

  String _pathRecorded = '';
  String get pathRecorded => _pathRecorded;
  void setPathRecord(String path) {
    _pathRecorded = path;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _playAnswer = false;
  int _questionIndex = 0;
  int get questionIndex => _questionIndex;

  bool get playAnswer => _playAnswer;
  void setPlayAnswer(bool visible, int questionIndex) {
    _playAnswer = visible;
    _questionIndex = questionIndex;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  QuestionTopicModel _currentQuestion = QuestionTopicModel();
  QuestionTopicModel get currentQuestion => _currentQuestion;
  void setCurrentQuestion(QuestionTopicModel question) {
    _currentQuestion = question;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _visibleRecord = false;
  bool get visibleRecord => _visibleRecord;
  void setVisibleRecord(bool visible) {
    _visibleRecord = visible;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  String _timerCount = '00:00';
  String get timerCount => _timerCount;
  void setTimerCount(String time) {
    _timerCount = time;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  Timer? _countDownTimer;
  Timer? get countDownTimer => _countDownTimer;
  void setCountDownTimer(Timer? timer) {
    _countDownTimer = timer;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  /////////////Response screen //////////////////////////////////////////////

  bool _visibleOverViewComment = false;
  bool get visibleOverviewComment => _visibleOverViewComment;
  void setVisibleOverviewComment(bool visible) {
    _visibleOverViewComment = visible;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _visibleFluency = false;
  bool get visibleFluency => _visibleFluency;

  void setVisibleFluency(bool visible) {
    _visibleFluency = visible;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _visibleLexical = false;
  bool get visibleLexical => _visibleLexical;

  void setVisibleLexical(bool visible) {
    _visibleLexical = visible;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _visibleGramatical = false;
  bool get visibleGramatical => _visibleGramatical;

  void setVisibleGramatical(bool visible) {
    _visibleGramatical = visible;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _visiblePronunciation = false;
  bool get visiblePronunciation => _visiblePronunciation;

  void setVisiblePronunciation(bool visible) {
    _visiblePronunciation = visible;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  ResultResponseModel _responseModel = ResultResponseModel();
  ResultResponseModel get responseModel => _responseModel;
  void setResultResponseModel(ResultResponseModel responseModel) {
    _responseModel = responseModel;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearSampleAudioCache() {
    _isSamplePlaying = false;
    _durationSampleAudio = Duration.zero;
    _positionSampleAudio = Duration.zero;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isSamplePlaying = false;
  bool get isSamplePlaying => _isSamplePlaying;
  void setSampleAudioPlaying(bool playing) {
    _isSamplePlaying = playing;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  Duration _durationSampleAudio = Duration.zero;
  Duration get durationAudioSample => _durationSampleAudio;
  void setDurationAudioSample(Duration duration) {
    _durationSampleAudio = duration;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  Duration _positionSampleAudio = Duration.zero;
  Duration get positionAudioSample => _positionSampleAudio;
  void setPositionAudioSample(Duration duration) {
    _positionSampleAudio = duration;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  /////////////Hightligh home work screen/////////////////////////////////

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

  bool _needDownloadAgain = false;
  bool get needDownloadAgain => _needDownloadAgain;
  void setNeedDownloadAgain(bool need) {
    _needDownloadAgain = need;

    if (!isDisposed) {
      notifyListeners();
    }
  }
}
