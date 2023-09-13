import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/presenters/test_room_presenter.dart';
import 'package:icorrect/src/provider/re_answer_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../../../../../core/app_color.dart';
import '../../../../data_sources/constants.dart';
import '../../../../data_sources/local/file_storage_helper.dart';

// ignore: must_be_immutable
class ReAnswerDialog extends Dialog {
  final BuildContext _context;
  final QuestionTopicModel _question;
  Timer? _countDown;
  int _timeRecord = 30;
  late Record _record;
  String _filePath = '';
  final TestRoomPresenter _testPresenter;
  final String _currentTestId;

  final Function(QuestionTopicModel question) _onReanswerCallBack;

  ReAnswerDialog(this._context, this._question, this._testPresenter,
      this._currentTestId, this._onReanswerCallBack,
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

    return Wrap(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Container(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Your answers are being recorded',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                const Image(
                  image: AssetImage("assets/images/img_mic.png"),
                  width: 60,
                  height: 60,
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCancelButton(),
                    _buildFinishButton(),
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildFinishButton() {
    return InkWell(
      onTap: () {
        _finishReAnswer();
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
          style: CustomTextStyle.textWhiteBold_16,
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return InkWell(
      onTap: () async {
        String path =
            '${await FileStorageHelper.getFolderPath(MediaType.audio, _currentTestId)}'
            '\\$_filePath';
        if (File(path).existsSync()) {
          await File(path).delete();
          print("DEGUG : file record exist : ${File(_filePath).existsSync()}");
        }

        _record.stop();
        _countDown!.cancel();
        // ignore: use_build_context_synchronously
        Navigator.pop(_context);
      },
      child: Container(
        width: CustomSize.size_100,
        height: CustomSize.size_40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(CustomSize.size_20),
          color: AppColor.defaultLightGrayColor,
        ),
        alignment: Alignment.center,
        child: const Text(
          'Cancel',
          style: CustomTextStyle.textWhiteBold_16,
        ),
      ),
    );
  }

  void _finishReAnswer() {
    _record.stop();
    _countDown!.cancel();
    if (_question.answers.length > 1) {
      if (_question.repeatIndex == 0) {
        _question.answers.last.url = _filePath;
      } else {
        _question.answers.elementAt(_question.repeatIndex - 1).url = _filePath;
      }
    } else {
      _question.answers.first.url = _filePath;
    }
    _question.reAnswerCount + 1;
    _onReanswerCallBack(_question);
    Navigator.pop(_context);
  }

  void _startCountDown() {
    Future.delayed(Duration.zero).then((value) {
      _countDown != null ? _countDown!.cancel() : '';
      _countDown = _countDownTimer(_context, _timeRecord, false);
      Provider.of<ReAnswerProvider>(_context, listen: false)
          .setCountDown("00:$_timeRecord");
    });
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
          .setCountDown("$minuteStr:$secondStr");

      if (count == 0 && !finishCountDown) {
        finishCountDown = true;
        _finishReAnswer();
      }
    });
  }
}
