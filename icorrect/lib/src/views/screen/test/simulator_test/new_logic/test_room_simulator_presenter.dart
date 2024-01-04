import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/data_sources/repositories/simulator_test_repository.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/auth_models/video_record_exam_info.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';
import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect/src/models/ui_models/alert_info.dart';
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';
import 'package:icorrect/src/views/screen/test/simulator_test/new_logic/playlist_model.dart';

enum PlayListType { introduce, endOfTakeNote, endOfTest, question }

abstract class TestRoomSimulatorContract {
  void playFileVideo(File normalFile, File slowFile);
  void onFileNotFound();
  void onCountDown(String strCount, int count);
  void onFinishAnswer(bool isPart2);
  void onCountDownForCueCard(String strCount);
  void submitAnswersSuccess(AlertInfo alertInfo);
  void submitAnswerFail(AlertInfo alertInfo);
}

class TestRoomSimulatorPresenter {
  final TestRoomSimulatorContract? _view;
  SimulatorTestRepository? _repository;

  TestRoomSimulatorPresenter(this._view) {
    _repository = Injector().getTestRepository();
  }

  List<TopicModel> getListTopicModel(TestDetailModel testDetailModel) {
    List<TopicModel> topicsList = [];

    if (testDetailModel.introduce.id != 0) {
      topicsList.add(testDetailModel.introduce);
    }

    if (testDetailModel.part1.isNotEmpty) {
      topicsList.addAll(testDetailModel.part1);
    }

    if (testDetailModel.part2 != TopicModel()) {
      topicsList.add(testDetailModel.part2);
    }

    if (testDetailModel.part3 != TopicModel()) {
      topicsList.add(testDetailModel.part3);
    }

    topicsList.sort((a, b) => a.numPart.compareTo(b.numPart));

    return topicsList;
  }

  List<PlayListModel> getPlayList(TestDetailModel testDetailModel) {
    List<PlayListModel> playList = [];
    List<TopicModel> topicsList = getListTopicModel(testDetailModel);

    for (int i = 0; i < topicsList.length; i++) {
      TopicModel topic = topicsList.elementAt(i);

      List<QuestionTopicModel> questions = getAllQuestionsTopic(topic);

      if (topic.files.isNotEmpty && topic.questionList.isNotEmpty) {
        PlayListModel playListIntro =
            _setPlayListModel(topic, PlayListType.introduce);

        playList.add(playListIntro);
      }

      for (int j = 0; j < questions.length; j++) {
        QuestionTopicModel questionModel = questions.elementAt(j);
        questionModel.numPart = topic.numPart;

        PlayListModel playListModel = _setPlayListModel(
            topic, PlayListType.question,
            question: questionModel, testDetailModel: testDetailModel);

        playList.add(playListModel);
      }

      if (topic.endOfTakeNote.url.isNotEmpty && topic.questionList.isNotEmpty) {
        PlayListModel playListEndOfTakeNote = _setPlayListModel(
            topic, PlayListType.endOfTakeNote,
            testDetailModel: testDetailModel);

        playList.add(playListEndOfTakeNote);
      }

      if (topic.fileEndOfTest.url.isNotEmpty) {
        PlayListModel playListEndOfTest =
            _setPlayListModel(topic, PlayListType.endOfTest);
        playList.add(playListEndOfTest);
      }
    }

    playList.sort((a, b) => a.numPart.compareTo(b.numPart));

    return playList;
  }

  PlayListModel _setPlayListModel(TopicModel topic, PlayListType playListType,
      {QuestionTopicModel? question, TestDetailModel? testDetailModel}) {
    PlayListModel playListModel = PlayListModel();
    if (testDetailModel != null) {
      playListModel.firstRepeatSpeed = testDetailModel.firstRepeatSpeed;
      playListModel.secondRepeatSpeed = testDetailModel.secondRepeatSpeed;
      playListModel.normalSpeed = testDetailModel.normalSpeed;
      playListModel.part1Time = testDetailModel.part1Time;
      playListModel.part2Time = testDetailModel.part2Time;
      playListModel.part3Time = testDetailModel.part3Time;
      playListModel.takeNoteTime = testDetailModel.takeNoteTime;
    }
    if (playListType == PlayListType.introduce) {
      playListModel.numPart = topic.numPart;
      playListModel.questionContent = PlayListType.introduce.name;
      playListModel.fileIntro =
          topic.files.isNotEmpty ? topic.files.first.url : "";
    } else if (playListType == PlayListType.endOfTakeNote) {
      playListModel.numPart = PartOfTest.part2.get;
      playListModel.endOfTakeNote = topic.endOfTakeNote.url;
      playListModel.questionContent = PlayListType.endOfTakeNote.name;
    } else if (playListType == PlayListType.endOfTest) {
      playListModel.endOfTest = topic.fileEndOfTest.url;
      playListModel.numPart = PartOfTest.part3.get;
      playListModel.questionContent = PlayListType.endOfTest.name;
    } else {
      playListModel.numPart = topic.numPart;
      playListModel.endOfTakeNote = topic.endOfTakeNote.url;
      playListModel.endOfTest = topic.fileEndOfTest.url;
      playListModel.questionContent = question != null ? question.content : '';
      playListModel.cueCard = question != null ? question.cueCard : '';
      playListModel.questionId = question!.id;
      playListModel.isFollowUp =
          question != null ? question.isFollowUpQuestion() : false;
      List<FileTopicModel> files = question != null ? question.files : [];
      playListModel.questionTopicModel = question;
      if (kDebugMode) {
        print(
            'question length: ${playListModel.questionTopicModel.answers.length}');
        for (int i = 0;
            i < playListModel.questionTopicModel.answers.length;
            i++) {
          print('answers: ${playListModel.questionTopicModel.answers[i].url}');
        }
      }
      playListModel.fileQuestionNormal = files.first.url;
      playListModel.fileQuestionSlow =
          files.length > 1 ? files.last.url : playListModel.fileQuestionNormal;
      List<FileTopicModel> filesImage = _getFilesImage(files);
      playListModel.fileImage =
          filesImage.isNotEmpty ? filesImage.first.url : '';
    }

    return playListModel;
  }

  List<FileTopicModel> _getFilesImage(List<FileTopicModel> files) {
    return files
        .where((element) => Utils.fileType(element.url) == "image")
        .toList();
  }

  List<QuestionTopicModel> getAllQuestionsTopic(TopicModel topicModel) {
    List<QuestionTopicModel> questions = [];
    if (topicModel.followUp.isNotEmpty) {
      questions.addAll(topicModel.followUp);
    }
    questions.addAll(topicModel.questionList);
    return questions;
  }

  int getQuestionLength(TestDetailModel testDetailModel) {
    List<TopicModel> topics = getListTopicModel(testDetailModel);
    List<QuestionTopicModel> questions = [];
    for (int i = 0; i < topics.length; i++) {
      questions.addAll(getAllQuestionsTopic(topics[i]));
    }
    return questions.length;
  }

  Future playingIntroduce(String file) async {
    assert(_view != null && _repository != null);
    bool isExist =
        await FileStorageHelper.checkExistFile(file, MediaType.video, null);
    if (isExist) {
      String filePath =
          await FileStorageHelper.getFilePath(file, MediaType.video, null);
      _view!.playFileVideo(File(filePath), File(""));
    } else {
      //Handle have not file introduce
      if (kDebugMode) {
        print("DEBUG: Handle have not file introduce 1");
      }
      _view!.onFileNotFound();
    }
  }

  Future playingQuestion(String fileNormal, String fileSlow) async {
    assert(_view != null && _repository != null);
    bool isExistFileNormal = await FileStorageHelper.checkExistFile(
        fileNormal, MediaType.video, null);
    bool isExistFileSlow =
        await FileStorageHelper.checkExistFile(fileSlow, MediaType.video, null);

    if (isExistFileNormal) {
      String normalPath = await FileStorageHelper.getFilePath(
          fileNormal, MediaType.video, null);

      String slowPath = isExistFileSlow
          ? await FileStorageHelper.getFilePath(fileSlow, MediaType.video, null)
          : normalPath;
      _view!.playFileVideo(File(normalPath), File(slowPath));
    } else {
      //Handle have not file question
      if (kDebugMode) {
        print("DEBUG: Handle have not file question");
      }
      _view!.onFileNotFound();
    }
  }

  Future playingEndOfTakeNote(String file) async {
    assert(_view != null && _repository != null);
    bool isExist =
        await FileStorageHelper.checkExistFile(file, MediaType.video, null);
    if (isExist) {
      String filePath =
          await FileStorageHelper.getFilePath(file, MediaType.video, null);
      _view!.playFileVideo(File(filePath), File(""));
    } else {
      //Handle have not file introduce
      if (kDebugMode) {
        print("Handle have not file playingEndOfTakeNote");
      }
      _view!.onFileNotFound();
    }
  }

  Future playingEndOfTest(String file) async {
    assert(_view != null && _repository != null);
    bool isExist =
        await FileStorageHelper.checkExistFile(file, MediaType.video, null);
    if (isExist) {
      String filePath =
          await FileStorageHelper.getFilePath(file, MediaType.video, null);
      _view!.playFileVideo(File(filePath), File(""));
    } else {
      //Handle have not file introduce
      if (kDebugMode) {
        print("Handle have not file playingEndOfTest");
      }
      _view!.onFileNotFound();
    }
  }

  Timer startCountDown(
      {required BuildContext context,
      required int count,
      required bool isPart2}) {
    assert(_view != null && _repository != null);
    bool finishCountDown = false;
    const oneSec = Duration(seconds: 1);
    return Timer.periodic(oneSec, (Timer timer) {
      if (count < 1) {
        timer.cancel();
      } else {
        count = count - 1;
      }

      dynamic minutes = count ~/ 60;
      dynamic seconds = count % 60;

      dynamic minuteStr = minutes.toString().padLeft(2, '0');
      dynamic secondStr = seconds.toString().padLeft(2, '0');

      _view!.onCountDown("$minuteStr:$secondStr", count);

      if (count == 0 && !finishCountDown) {
        finishCountDown = true;
        _view!.onFinishAnswer(isPart2);
      }
    });
  }

  Timer startCountDownForCueCard(
      {required BuildContext context,
      required int count,
      required bool isPart2}) {
    bool finishCountDown = false;
    const oneSec = Duration(seconds: 1);
    return Timer.periodic(oneSec, (Timer timer) {
      if (count < 1) {
        timer.cancel();
      } else {
        count = count - 1;
      }

      dynamic minutes = count ~/ 60;
      dynamic seconds = count % 60;

      dynamic minuteStr = minutes.toString().padLeft(2, '0');
      dynamic secondStr = seconds.toString().padLeft(2, '0');

      _view!.onCountDownForCueCard("$minuteStr:$secondStr");

      if (count == 0 && !finishCountDown) {
        finishCountDown = true;
        _view!.onFinishAnswer(isPart2);
      }
    });
  }

  String randomVideoRecordExam(List<VideoExamRecordInfo> videosSaved) {
    if (videosSaved.length > 1) {
      List<VideoExamRecordInfo> prepareVideoForRandom = [];
      for (int i = 0; i < videosSaved.length; i++) {
        if (videosSaved[i].duration! >= 7) {
          prepareVideoForRandom.add(videosSaved[i]);
        }
      }
      if (prepareVideoForRandom.isEmpty) {
        return _getMaxDurationVideo(videosSaved);
      } else {
        Random random = Random();
        int elementRandom = random.nextInt(prepareVideoForRandom.length);
        return prepareVideoForRandom[elementRandom].filePath ?? "";
      }
    } else {
      return _getMaxDurationVideo(videosSaved);
    }
  }

  String _getMaxDurationVideo(List<VideoExamRecordInfo> videosSaved) {
    if (videosSaved.isNotEmpty) {
      videosSaved.sort(((a, b) => a.duration!.compareTo(b.duration!)));
      VideoExamRecordInfo maxValue = videosSaved.last;
      return maxValue.filePath ?? '';
    }
    return '';
  }

  Future submitMyTest(
      {required BuildContext context,
      required String testId,
      required String activityId,
      required List<QuestionTopicModel> questionsList,
      File? videoConfirmFile,
      List<Map<String, dynamic>>? logAction,
      required bool isUpdate,
      required bool isExam}) async {
    assert(_view != null && _repository != null);

    //Add log
    LogModel? log;
    Map<String, dynamic> dataLog = {};

    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiSubmitTest);
    }

    http.MultipartRequest multiRequest = await Utils.formDataRequestSubmit(
        testId: testId,
        activityId: activityId,
        questions: questionsList,
        isExam: isExam,
        isUpdate: isUpdate,
        videoConfirmFile: videoConfirmFile,
        logAction: logAction);
    try {
      _repository!.submitTest(multiRequest).then((value) {
        if (kDebugMode) {
          print('VALUE : response : $value');
        }
        Map<String, dynamic> json = jsonDecode(value) ?? {};
        if (kDebugMode) {
          print("DEBUG: error form: ${json.toString()}");
        }
        if (json['error_code'] == 200) {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: dataLog,
            message: null,
            status: LogEvent.success,
          );
          _view!.submitAnswersSuccess(AlertClass.submitTestSuccess);
        } else {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: dataLog,
            message: StringConstants.submit_test_error_message,
            status: LogEvent.failed,
          );
          _view!.submitAnswerFail(AlertClass.failToSubmitAndContactAdmin);
        }
      }).catchError((onError) {
        if (kDebugMode) {
          print('catchError updateAnswerFail ${onError.toString()}');
        }
        //Add log
        Utils.prepareLogData(
          log: log,
          data: dataLog,
          message: onError.toString(),
          status: LogEvent.failed,
        );

        // ignore: invalid_return_type_for_catch_error
        _view!.submitAnswerFail(AlertClass.failToSubmitAndContactAdmin);
      });
    } on TimeoutException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: StringConstants.submit_test_error_timeout,
        status: LogEvent.failed,
      );
      _view!.submitAnswerFail(AlertClass.networkFailToSubmit);
    } on SocketException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: StringConstants.submit_test_error_socket,
        status: LogEvent.failed,
      );

      _view!.submitAnswerFail(AlertClass.networkFailToSubmit);
    } on http.ClientException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: dataLog,
        message: StringConstants.submit_test_error_client,
        status: LogEvent.failed,
      );
      _view!.submitAnswerFail(AlertClass.networkFailToSubmit);
    }
  }

  void callTestPositionApi(
    BuildContext context, {
    required String activityId,
    required int questionIndex,
  }) async {
    UserDataModel? currentUser = await Utils.getCurrentUser();
    if (null == currentUser) return;

    if (kDebugMode) {
      print(
          "DEBUG: callTestPositionApi: activityId $activityId - questionIndex $questionIndex");
    }

    assert(_view != null && _repository != null);

    LogModel? log;
    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiTestPosition);
    }

    String email = currentUser.userInfoModel.email;

    _repository!
        .callTestPosition(
            email: email,
            activityId: activityId,
            questionIndex: questionIndex,
            user: testPositionUser,
            pass: testPositionPass)
        .then((value) async {
      if (kDebugMode) {
        print("DEBUG: callTestPosition $value");
      }

      //Add information into log
      log!.addData(key: StringConstants.k_email, value: email);
      log.addData(key: StringConstants.k_activity_id, value: activityId);
      log.addData(key: "question_index", value: questionIndex);

      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap[StringConstants.k_error_code] == 200) {
        if (kDebugMode) {
          print("DEBUG: callTestPosition SUCCESS");
        }
        //Add log
        Utils.prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: dataMap[StringConstants.k_message],
          status: LogEvent.success,
        );
      } else {
        if (kDebugMode) {
          print("DEBUG: callTestPosition FAIL");
        }
        //Add log
        Utils.prepareLogData(
          log: log,
          data: null,
          message:
              "CallTestPositionApi error: ${dataMap[StringConstants.k_error_code]}${dataMap[StringConstants.k_status]}",
          status: LogEvent.failed,
        );
      }
    }).catchError((onError) {
      String message = '';
      if (onError is http.ClientException || onError is SocketException) {
        message = StringConstants.network_error_message;
      } else {
        message = StringConstants.common_error_message;
      }
      //Add log
      Utils.prepareLogData(
        log: log,
        data: null,
        message: message,
        status: LogEvent.failed,
      );
    });
  }
}
