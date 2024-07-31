import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/models/ui_models/alert_info.dart';
import 'package:icorrect/src/presenters/mission_test_presenter.dart';
import 'package:icorrect/src/provider/mission_test_provider.dart';
import 'package:icorrect/src/views/screen/lesson/mission_test_room_widget.dart';
import 'package:icorrect/src/views/widget/mission_test_widget/download_progressing_widget.dart';
import 'package:provider/provider.dart';

import '../../../data_sources/utils.dart';
import '../other_views/dialog/record_mission_dialog.dart';

class MissionTestScreen extends StatefulWidget {
  const MissionTestScreen({super.key});

  @override
  State<MissionTestScreen> createState() => _MissionTestScreenState();
}

class _MissionTestScreenState extends State<MissionTestScreen> implements MissionTestViewContract{

  MissionTestProvider? _provider;
  MissionTestPresenter? _presenter;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _presenter = MissionTestPresenter(this);
    _provider = Provider.of<MissionTestProvider>(context, listen: false);
    _presenter!.prepareDataForDownload(
        context: context,
        activityId: null,
        fileVideo: _provider!.fileVideo!,
        fileImage: _provider!.fileImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade300,
      // body: _buildMission()
      body: Container(
        color: AppColor.defaultOrangeColor, child: const DownloadProgressingWidget()),
    );
  }

  Widget _buildMission() {
    double w = MediaQuery.of(context).size.width/7*6;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column (
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 15),
          Center(child: Image.asset('assets/images/ic_list.png', height: 120)),
          Text(_provider!.currentMission!.name!, style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white
          )),
          const SizedBox(height: 15),
          const Text('Câu hỏi', style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white
          )),
          const SizedBox(height: 5),
          Text(_provider!.currentMission!.content!, style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white
          )),
          const Text('Đây là cái gì', style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white
          )),
          Container(
            color: Colors.white,
              width: w,
              height: w,
              child: Image.asset(AppAsset.gold, width: w, height: w)),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildButton('Nghe cô giáo đọc', Colors.orange.shade300, () {
                Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MissionTestRoomWidget(
                              missionTestProvider: _provider!,
                              missionTestPresenter: _presenter!)));
                },
              ),
              _buildButton('Luyện tập', Colors.green.shade500, () {
                _provider!.setCurrentCount(0);
                String timeFormat = Utils.getTimeRecordString(0);
                _provider!.setStrCounting(timeFormat);
                showDialog(context: context, builder: (context) {
                  return RecordMissionDialog(
                    presenter: _presenter!,
                    provider: _provider!,
                    completeButtonTap: () {},
                    cancelButtonTap: () {},
                  );
                });
              },),
            ],
          )
        ],
      ),
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

  @override
  void onCounting(String strCount, int count) {
    _provider!.setCurrentCount(count);
    _provider!.setStrCounting(strCount);
  }

  @override
  void onDownloadError(AlertInfo info) {
    // TODO: implement onDownloadError
  }

  @override
  void onDownloadSuccess(String nameFile, double percent, int index, int total) {
    _provider!.updateDownloadingIndex(index);
    _provider!.updateDownloadingPercent(percent);
    _provider!.setTotal(total);
    if (index == total) {

    }
  }

  @override
  void onReDownload() {
    // TODO: implement onReDownload
  }

  @override
  void onTryAgainToDownload() {
    // TODO: implement onTryAgainToDownload
  }
}
