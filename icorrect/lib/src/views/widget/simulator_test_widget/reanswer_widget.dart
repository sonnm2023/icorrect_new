import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_asset.dart';
import '../../../../core/app_color.dart';
import '../../../data_sources/constants.dart';
import '../../../data_sources/local/file_storage_helper.dart';
import '../../../data_sources/utils.dart';
import '../../../models/simulator_test_models/question_topic_model.dart';
import '../../../presenters/test_room_presenter.dart';
import '../../../provider/re_answer_provider.dart';
import '../../../provider/simulator_test_provider.dart';
import 'package:record/record.dart';

class ReanswerWidget extends StatelessWidget {
  final BuildContext _context;
  Timer? _countDown;
  int _timeRecord = 30;
  late Record _record;
  String _filePath = '';
  final String _currentTestId;
  final Function(int index, QuestionTopicModel question) _onReanswerCallBack;

  ReanswerWidget(this._context, this._currentTestId, this._onReanswerCallBack,
      {super.key});

  String get fileReanswerPath => _filePath;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    _record = Record();

    return Consumer<SimulatorTestProvider>(
        builder: (context, simulatorTestProvider, child) {
      if (simulatorTestProvider.visibleReanswer &&
          simulatorTestProvider.questionReanswer.id != 0) {
        _timeRecord =
            Utils.getRecordTime(simulatorTestProvider.questionReanswer.numPart);
        _startCountDown(simulatorTestProvider.indexReanswerQuestion,
            simulatorTestProvider.questionReanswer);
        _startRecord();
      }
      return Visibility(
        visible: simulatorTestProvider.visibleReanswer,
        child: Container(
          width: w,
          height: h / 3,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: w,
                    height: CustomSize.size_200,
                    alignment: Alignment.center,
                    color: AppColor.defaultGraySlightColor,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: CustomSize.size_20,
                        ),
                        const Text('Your answer is being recorded'),
                        const SizedBox(
                          height: CustomSize.size_20,
                        ),
                        Image.asset(
                          AppAsset.record,
                          width: CustomSize.size_25,
                          height: CustomSize.size_25,
                        ),
                        const SizedBox(
                          height: CustomSize.size_5,
                        ),
                        Consumer<ReAnswerProvider>(
                          builder: (context, reAnswerProvider, child) {
                            return Text(
                              reAnswerProvider.strCount,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: CustomSize.size_20),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: CustomSize.size_40,
                          ),
                          child: _buildFinishButton(
                              simulatorTestProvider.indexReanswerQuestion,
                              simulatorTestProvider.currentQuestion),
                        ),
                        const SizedBox(height: CustomSize.size_20),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.all(10),
                child: _buildCancelButton(simulatorTestProvider),
              )
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFinishButton(int index, QuestionTopicModel question) {
    return InkWell(
      onTap: () {
        _finishReAnswer(index, question);
      },
      child: Container(
        width: CustomSize.size_100,
        height: CustomSize.size_40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(CustomSize.size_20),
          color: Colors.green,
        ),
        alignment: Alignment.center,
        child: const Text(
          'Finish',
          style: CustomTextStyle.textWhiteBold_15,
        ),
      ),
    );
  }

  Widget _buildCancelButton(SimulatorTestProvider provider) {
    return InkWell(
      onTap: () async {
        String path =
            '${await FileStorageHelper.getFolderPath(MediaType.audio, _currentTestId)}'
            '\\$_filePath';
        if (File(path).existsSync()) {
          await File(path).delete();
          if (kDebugMode) {
            print("DEGUG : file record exist : ${File(path).existsSync()}");
          }
        }

        _record.stop();
        _countDown!.cancel();
        provider.setReanswerAction(false, -1, QuestionTopicModel());
      },
      child: const Icon(Icons.cancel_outlined),
    );
  }

  Future<void> stopReanswer() async {
    _record.stop();
    _countDown != null ? _countDown!.cancel() : '';
    String path =
        '${await FileStorageHelper.getFolderPath(MediaType.audio, _currentTestId)}'
        '\\$_filePath';
    if (File(path).existsSync()) {
      await File(path).delete();
      if (kDebugMode) {
        print("DEGUG : file record exist : ${File(path).existsSync()}");
      }
    }
  }

  void _startCountDown(int index, QuestionTopicModel question) {
    Future.delayed(Duration.zero).then((value) {
      _countDown != null ? _countDown!.cancel() : '';
      _countDown =
          _countDownTimer(_context, index, _timeRecord, false, question);
      Provider.of<ReAnswerProvider>(_context, listen: false)
          .setCountDown("00:$_timeRecord");
    });
  }

  void _finishReAnswer(int index, QuestionTopicModel question) {
    _record.stop();
    _countDown!.cancel();
    if (question.answers.length > 1) {
      if (question.repeatIndex == 0) {
        question.answers.last.url = _filePath;
      } else {
        question.answers.elementAt(question.repeatIndex - 1).url = _filePath;
      }
    } else {
      question.answers.first.url = _filePath;
    }
    question.reAnswerCount + 1;
    _onReanswerCallBack(index, question);
  }

  void _startRecord() async {
    _filePath = '${await Utils.generateAudioFileName()}.wav';

    if (await _record.hasPermission()) {
      await _record.start(
        path:
            '${await FileStorageHelper.getFolderPath(MediaType.audio, _currentTestId)}'
            '\\$_filePath',
        encoder: Platform.isAndroid ? AudioEncoder.wav : AudioEncoder.pcm16bit,
        bitRate: 128000,
        samplingRate: 44100,
      );
    }
  }

  Timer _countDownTimer(BuildContext context, int index, int count,
      bool isPart2, QuestionTopicModel question) {
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

      Provider.of<ReAnswerProvider>(_context, listen: false)
          .setCountDown("$minuteStr:$secondStr");

      if (count == 0 && !finishCountDown) {
        finishCountDown = true;
        _finishReAnswer(index, question);
      }
    });
  }
}
