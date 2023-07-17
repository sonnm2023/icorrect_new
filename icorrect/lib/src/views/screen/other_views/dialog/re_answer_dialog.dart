import 'dart:async';

import 'package:flutter/material.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/presenters/test_presenter.dart';
import 'package:icorrect/src/provider/test_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

// ignore: must_be_immutable
class ReAnswerDialog extends Dialog {
  final BuildContext _context;
  final QuestionTopicModel _question;
  Timer? _countDown;
  final _timeRecord = 30;
  late Record _record;
  final String _filePath = '';
  final TestPresenter _testPresenter;

  ReAnswerDialog(this._context, this._question, this._testPresenter, {super.key});

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
    _record = Record();
    _startCountDown();
    _startRecord();
    return Container(
      width: 400,
      height: 350,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 50,
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                _countDown!.cancel();
                Navigator.pop(_context);
              },
              child: const Icon(Icons.cancel_outlined),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.only(top: 20),
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
                const Image(image: AssetImage("assets/images/img_mic.png")),
                const SizedBox(height: 10),
                Consumer<TestProvider>(
                  builder: (context, testProvider, child) {
                    return Text(
                      testProvider.strCount,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 38,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _record.stop();
                    _countDown!.cancel();
                    Navigator.pop(_context);
                    _testPresenter.clickEndReAnswer(_question, _filePath);
                  },
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.green),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: const Text("Finish"),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void onSkip() {
    _record.stop();
    _countDown!.cancel();
    Navigator.pop(_context);
    _testPresenter.clickEndReAnswer(_question, _filePath);
  }

  void _startCountDown() {
    //TODO
    // Future.delayed(Duration.zero).then((value) {
    //   _countDown != null ? _countDown!.cancel() : '';
    //   _countDown = _testPresenter.startCountDown(_context, _timeRecord);
    //   Provider.of<TestProvider>(_context, listen: false)
    //       .setCountDown("00:$_timeRecord");
    // });
  }

  void _startRecord() async {
    // DateTime dateTime = DateTime.now();
    // String timeNow =
    //     '${dateTime.year}${dateTime.month}${dateTime.day}_${dateTime.hour}${dateTime.minute}';
    // _filePath =
    // '${await StorageHelper.init().rootPath()}\\${StringClass.AUDIO}\\${_question.id}_reanswer_$timeNow';
    //
    // if (await _record.hasPermission()) {
    //   await _record.start(
    //     path: _filePath,
    //     encoder: AudioEncoder.wav,
    //     bitRate: 128000,
    //     samplingRate: 44100,
    //   );
    // }
  }

  void onCountDown(String strCount) {
    //TODO
    // Provider.of<VariableProvider>(_context, listen: false)
    //     .setCountDown(strCount);
  }
}