import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constant_strings.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/topic_model.dart';

abstract class TestRoomViewContract {
  void onPlayIntroduceFile(String fileName);
  void onNothingFileIntroduce();
  void onNothingIntroduce();
  void onPlayEndOfTakeNoteFile(String fileName);
  void onPlayEndOfTest(String fileName);
  void onNothingFileEndOfTest();
  void onNothingEndOfTest();
  void onNothingFileQuestion();
  void onNothingQuestion();
  void onSaveTopicListIntoProvider(List<TopicModel> list);
  void onCountDown(String countDownString);
  void onCountDownForCueCard(String countDownString);
  void onFinishAnswer(bool isPart2);
  void onNothingFileEndOfTakeNote();
  void onNothingEndOfTakeNote();
}

class TestRoomPresenter {
  final TestRoomViewContract? _view;

  TestRoomPresenter(this._view);

  Future<void> startPart(Queue<TopicModel> topicsQueue) async {
    TopicModel currentPart = topicsQueue.first;

    //Play introduce file of part
    _playIntroduce(currentPart);
  }

  Future<void> _playIntroduce(TopicModel topicModel) async {
    List<FileTopicModel> files = topicModel.files;
    if (files.isNotEmpty) {
      FileTopicModel file = files.first;
      bool isExist = await _isExist(file.url, MediaType.video);
      if (isExist) {
        _view!.onPlayIntroduceFile(file.url);
      } else {
        //TODO:
        //Download again
      }
    } else {
      //TODO:
      //Download again
    }
  }

  //Check file is exist using file_storage
  Future<bool> _isExist(String fileName, MediaType mediaType) async {
    bool isExist = await FileStorageHelper.checkExistFile(fileName, mediaType);
    return isExist;
  }

  Timer startCountDown({required BuildContext context, required int count, required bool isPart2}) {
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

      _view!.onCountDown("$minuteStr:$secondStr");

      if (count == 0 && !finishCountDown) {
        finishCountDown = true;
        _view!.onFinishAnswer(isPart2);
      }
    });
  }

  Timer startCountDownForCueCard({required BuildContext context, required int count, required bool isPart2}) {
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

  Future<void> playEndOfTakeNoteFile(TopicModel topic) async {
    String fileName = topic.endOfTakeNote.url;

    if (fileName.isNotEmpty) {
      bool isExist = await _isExist(fileName, MediaType.video);
      if (isExist) {
        _view!.onPlayEndOfTakeNoteFile(fileName);
      } else {
        //TODO: download again
      }
    } else {
      //TODO: download again
    }
  }

  void clickEndReAnswer(QuestionTopicModel question, String filePath) {
    //TODO:
    if (kDebugMode) print("clickEndReAnswer");
  }

  void clickSaveTheTest() {
    //TODO: Submit homework
    if (kDebugMode) print("clickSaveTheTest");
  }

  Future<void> playEndOfTestFile(TopicModel topic) async {
    String fileName = topic.fileEndOfTest.url;

    if (fileName.isNotEmpty) {
      bool isExist = await _isExist(fileName, MediaType.video);
      if (isExist) {
        _view!.onPlayEndOfTest(fileName);
      } else {
        //TODO: Download again
      }
    } else {
      //TODO: Download again
    }
  }


}
