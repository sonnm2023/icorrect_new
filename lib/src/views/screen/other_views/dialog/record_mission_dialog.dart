import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/presenters/mission_test_presenter.dart';
import 'package:icorrect/src/provider/mission_test_provider.dart';
import 'package:provider/provider.dart';

class RecordMissionDialog extends StatefulWidget {
  const RecordMissionDialog(
      {super.key,
      required this.completeButtonTap,
      required this.cancelButtonTap,
      required this.presenter,
      required this.provider});

  final MissionTestPresenter presenter;
  final MissionTestProvider provider;
  final Function() completeButtonTap;
  final Function() cancelButtonTap;

  @override
  State<RecordMissionDialog> createState() => _RecordMissionDialogState();
}

class _RecordMissionDialogState extends State<RecordMissionDialog> {
  Timer? _timerCounting;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Consumer<MissionTestProvider>(
      builder: (context, provider, child) {
        return Center(
          child: Wrap (
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                // padding: const EdgeInsets.all(15),
                width: w,
                height: w,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    const DefaultTextStyle(style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        decoration: TextDecoration.none
                    ), child: Text('Hãy nói')),
                    const SizedBox(height: 20),
                    DefaultTextStyle(style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        decoration: TextDecoration.none
                    ), child: Text(widget.provider.currentMission!.content!)),
                    const SizedBox(height: 25),
                    const Icon(Icons.mic, size: 70),
                    DefaultTextStyle(style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        decoration: TextDecoration.none
                    ), child: Text(provider.strCounting)),
                    const SizedBox(height: 10),
                    DefaultTextStyle(style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.black87,
                        decoration: TextDecoration.none
                    ), child: Text(Utils.multiLanguage(StringConstants.recording)!))
                    ,
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildButton('Huỷ bỏ', Colors.orange.shade300, _cancelButtonTap),
                        _buildButton('Hoàn thành', Colors.green.shade500, _completeButtonTap),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildButton(String buttonTitle, Color color, Function() funcTap) {
    double w = MediaQuery.of(context).size.width;
    return TextButton(
        onPressed: funcTap,
        child: Container(
          width: w/5*2,
          height: 50,
          decoration: BoxDecoration (
              color: color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 1)
          ),
          child: Center(
            child: Text(buttonTitle, style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16
            )),
          ),
        ));
  }

  void _completeButtonTap() {
    _timerCounting = widget.presenter.startCounting(context: context, count: 0);
  }

  void _cancelButtonTap() {
    _timerCounting!.cancel();
  }
}
