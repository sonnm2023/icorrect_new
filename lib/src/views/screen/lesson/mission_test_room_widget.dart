import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/presenters/mission_test_presenter.dart';
import 'package:icorrect/src/provider/mission_test_provider.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/record_mission_dialog.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/back_button_widget.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/app_asset.dart';

class MissionTestRoomWidget extends StatefulWidget {
  const MissionTestRoomWidget(
      {super.key,
      required this.missionTestProvider,
      required this.missionTestPresenter});

  final MissionTestProvider missionTestProvider;
  final MissionTestPresenter missionTestPresenter;

  @override
  State<MissionTestRoomWidget> createState() => _MissionTestRoomWidgetState();
}

class _MissionTestRoomWidgetState extends State<MissionTestRoomWidget> {

  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _videoPlayerController = VideoPlayerController.file(File('/data/user/0/com.icorrect.vn/files\\videos\\gretting.mp4'));
    // _videoPlayerController!.initialize();
    // _initVideoController();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {

      },
      child: Scaffold(
        backgroundColor: Colors.blue.withOpacity(1),
        body: _buildBody(),
    ));
  }

  Widget _buildBody() {
    double w = MediaQuery.of(context).size.width;
    return Consumer(builder: (context, value, child) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // _initVideoController();
      });
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            children: [
              _buildVideoPlayer(),
              BackButtonWidget(backButtonTapped: (){

              })
            ],
          ),
          const SizedBox(height: 20),
          Text(widget.missionTestProvider.currentMission!.content!, style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24
          )),
          _buildImageQuestion(),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildButton('Nghe cô giáo đọc', Colors.orange.shade300, () {
                _initVideoController();
              },),
              _buildButton('Luyện tập', Colors.green.shade500, () {
                showDialog(context: context, builder: (context) {
                  return RecordMissionDialog(
                    provider: widget.missionTestProvider,
                    presenter: widget.missionTestPresenter,
                    completeButtonTap: () {},
                    cancelButtonTap: () {},
                        );
                      });
              },),
            ],
          )
        ],
      );
    });
  }

  Widget _buildVideoPlayer() {
    double w = MediaQuery.of(context).size.width;
    double h = 240;
    return Container(
      color: Colors.white,
      width: w,
      height: h,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: _videoPlayerController!.value.isInitialized
            ? VideoPlayer(_videoPlayerController!)
            : const Image(image: AssetImage(AppAsset.img_video_play_holder)),
      ),
    );
  }

  Widget _buildImageQuestion() {
    double w = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: w,
      height: w,
      color: Colors.white,
      child: Image.asset(AppAsset.gold),
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

  void _initVideoController() async {
    _videoPlayerController!.initialize().then((value) {
      setState(() {
        _videoPlayerController!.value.isPlaying? _videoPlayerController!.pause() : _videoPlayerController!.play();
      });
    });
  }

  Future<String> getFilePath(String fileName) async {
    return await FileStorageHelper.getFilePath(fileName, MediaType.video, null);
  }
}
