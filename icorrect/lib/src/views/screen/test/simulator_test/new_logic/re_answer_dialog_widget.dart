import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/provider/re_answer_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

// ignore: must_be_immutable
class ReAnswerDialog extends Dialog {
  final BuildContext _context;
  final QuestionTopicModel _question;
  Timer? _countDown;
  int _timeRecord = 30;
  late Record _record;
  String _filePath = '';
  String _fileName = '';
  final String _currentTestId;
  final Function(QuestionTopicModel question) _finishReanswerCallback;

  ReAnswerDialog(this._context, this._question, this._currentTestId,
      this._finishReanswerCallback,
      {super.key});

  @override
  double? get elevation => 0;

  @override
  Color? get backgroundColor => Colors.white;
  @override
  ShapeBorder? get shape =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20));

  @override
  Widget? get child => _buildDialog();

  Widget _buildDialog() {
    _timeRecord = Utils.getRecordTime(_question.numPart);

    _record = Record();
    _startCountDown();
    _startRecord();

    return Container(
      width: 400,
      height: 280,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              Utils.multiLanguage(StringConstants.answer_being_recorded),
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            const Icon(
              Icons.mic,
              size: 30,
            ),
            const SizedBox(height: 10),
            Consumer<ReAnswerProvider>(
              builder: (context, reAnswerProvider, child) {
                return Text(
                  reAnswerProvider.strCount,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 38,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 20),
                Expanded(
                    child: ElevatedButton(
                  onPressed: () {
                    _cancelReAnswer();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        AppColor.defaultGrayColor),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      Utils.multiLanguage(StringConstants.cancel_button_title),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                )),
                const SizedBox(width: 20),
                Consumer<ReAnswerProvider>(
                    builder: (context, reAnswerProvider, child) {
                  return Expanded(
                      child: ElevatedButton(
                    onPressed: () {
                      _finishReAnswer(_question);
                    },
                    style: ButtonStyle(
                      backgroundColor: _canFinishReanswer()
                          ? MaterialStateProperty.all<Color>(
                              const Color.fromARGB(255, 11, 180, 16))
                          : MaterialStateProperty.all<Color>(
                              const Color.fromARGB(255, 199, 221, 200)),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        Utils.multiLanguage(
                            StringConstants.finish_button_title),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ));
                }),
                const SizedBox(width: 20),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _finishReAnswer(QuestionTopicModel question) {
    if (_canFinishReanswer()) {
      question.answers.last.url = _fileName;
      question.reAnswerCount = question.reAnswerCount + 1;
      _record.stop();
      _countDown!.cancel();
      _finishReanswerCallback(question);
      Navigator.pop(_context);
    }
  }

  bool _canFinishReanswer() {
    int timeCounting =
        Provider.of<ReAnswerProvider>(_context, listen: false).numCount;
    return _timeRecord - timeCounting >= 2;
  }

  void _cancelReAnswer() async {
    if (File(_filePath).existsSync()) {
      await File(_filePath).delete();
    }
    _record.stop();
    _countDown!.cancel();
    // ignore: use_build_context_synchronously
    Navigator.pop(_context);
  }

  void _startCountDown() {
    Future.delayed(Duration.zero).then((value) {
      _countDown != null ? _countDown!.cancel() : '';
      _countDown = _countDownTimer(_context, _timeRecord, false);
      Provider.of<ReAnswerProvider>(_context, listen: false)
          .setCountDown("00:$_timeRecord", _timeRecord);
    });
  }

  void _startRecord() async {
    _fileName = '${await Utils.generateAudioFileName()}.wav';
    _filePath =
        '${await FileStorageHelper.getFolderPath(MediaType.audio, null)}'
        '\\$_fileName';
    if (await _record.hasPermission()) {
      await _record.start(
        path: _filePath,
        encoder: Platform.isWindows ? AudioEncoder.wav : AudioEncoder.pcm16bit,
        bitRate: 128000,
        samplingRate: 44100,
      );
    }
  }

  Timer _countDownTimer(BuildContext context, int count, bool isPart2) {
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
          .setCountDown("$minuteStr:$secondStr", count);

      if (count == 0 && !finishCountDown) {
        finishCountDown = true;
        _finishReAnswer(_question);
      }
    });
  }
}
