import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constant_strings.dart';
import 'package:icorrect/src/models/homework_models/homework_model.dart';
import 'package:icorrect/src/models/my_test_models/result_response_model.dart';
import 'package:icorrect/src/models/my_test_models/student_result_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/user_data_models/student_model.dart';

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

  bool _playAnswer = false;
  String _questionId = '';
  String get questionId => _questionId;

  bool get playAnswer => _playAnswer;
  void setPlayAnswer(bool visible, String questionId) {
    _playAnswer = visible;
    _questionId = questionId;
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
}
