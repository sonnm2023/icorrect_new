import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constant_strings.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/homework_models/homework_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect/src/models/ui_models/alert_info.dart';
import 'package:icorrect/src/provider/my_test_provider.dart';
import 'package:icorrect/src/views/screen/auth/ai_response_webview.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/tip_question_dialog.dart';
import 'package:icorrect/src/views/screen/test/my_test/download_progressing_widget.dart';
import 'package:icorrect/src/views/screen/test/my_test/test_record_widget.dart';
import 'package:icorrect/src/views/widget/default_text.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../../../../presenters/my_test_presenter.dart';
import '../../other_views/dialog/circle_loading.dart';

class MyTestTab extends StatefulWidget {
  HomeWorkModel homeWorkModel;
  MyTestProvider provider;
  MyTestTab({super.key, required this.homeWorkModel, required this.provider});

  @override
  State<MyTestTab> createState() => _MyTestTabState();
}

class _MyTestTabState extends State<MyTestTab>
    with AutomaticKeepAliveClientMixin<MyTestTab>
    implements MyTestConstract {
  MyTestPresenter? _presenter;
  CircleLoading? _loading;

  AudioPlayer? _player;
  final Record _record = Record();

  @override
  void initState() {
    super.initState();
    _loading = CircleLoading();
    _presenter = MyTestPresenter(this);
    _player = AudioPlayer();
    _loading!.show(context);
    _presenter!.getMyTest(widget.homeWorkModel.testId);

    Future.delayed(Duration.zero, () {
      widget.provider.setDownloadingFile(true);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _player!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildMyTest();
  }

  Widget _buildMyTest() {
    return Consumer<MyTestProvider>(builder: (context, provider, child) {
      if (provider.isDownloading) {
        return const DownloadProgressingWidget();
      } else {
        return Column(
          children: [
            Expanded(
                flex: 4,
                child: Container(
                  color: AppColor.defaultAppColor,
                )),
            Expanded(
                flex: 9,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: provider.myAnswerOfQuestions.length,
                    itemBuilder: (context, index) {
                      return _questionItem(provider.myAnswerOfQuestions[index]);
                    })),
            Stack(
              children: [
                (widget.homeWorkModel.aiOrder != 0)
                    ? Expanded(child: LayoutBuilder(builder: (_, constraint) {
                        return InkWell(
                          onTap: () {
                            _showAiResposne();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            color: Colors.green,
                            width: constraint.maxWidth,
                            child: const Center(
                              child: Text(
                                'View AI Response',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 19),
                              ),
                            ),
                          ),
                        );
                      }))
                    : Container(),
                Expanded(
                    child: TestRecordWidget(finishAnswer: (currentQuestion) {}))
              ],
            )
          ],
        );
      }
    });
  }

  _showAiResposne() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        enableDrag: false,
        barrierColor: AppColor.defaultGrayColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 20),
        builder: (_) {
          return FutureBuilder(
              future: AiResponseEP(widget.homeWorkModel.aiOrder.toString()),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                  return Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColor.defaultGrayColor,
                          size: 35,
                        ),
                      ),
                      AIResponse(url: snapshot.data.toString())
                    ],
                  );
                }
                return Container(
                  height: 400,
                  color: Colors.white,
                  child: const Center(
                    child: Text('Nothing in here',
                        style: TextStyle(
                            color: AppColor.defaultGrayColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w400)),
                  ),
                );
              });
        });
  }

  Widget _questionItem(QuestionTopicModel question) {
    return Consumer<MyTestProvider>(builder: (context, provider, child) {
      return Card(
        elevation: 2,
        child: LayoutBuilder(builder: (_, constraint) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            margin: const EdgeInsets.only(top: 10),
            width: constraint.maxWidth,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                (provider.playAnswer &&
                        question.id.toString() == provider.questionId)
                    ? InkWell(
                        onTap: () async {
                          widget.provider
                              .setPlayAnswer(false, question.id.toString());
                          _stopAudio();
                        },
                        child: const Image(image: AssetImage(AppAsset.play)),
                      )
                    : InkWell(
                        onTap: () async {
                          widget.provider
                              .setPlayAnswer(true, question.id.toString());

                          if (question.answers.isNotEmpty) {
                            _preparePlayAudio(
                                fileName: Utils.convertFileName(
                                    question.answers.last.url.toString()),
                                questionId: question.id.toString());
                          }
                        },
                        child: const Image(image: AssetImage(AppAsset.stop)),
                      ),
                Container(
                  margin: const EdgeInsets.only(left: 20),
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(0),
                        width: 280,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question.content.toString(),
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              _showTips(question);
                            },
                            child: const DefaultText(
                                text: 'View Tips',
                                color: AppColor.defaultPurpleColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 20),
                          (widget.homeWorkModel.canReanswer())
                              ? InkWell(
                                  onTap: () {},
                                  child: const DefaultText(
                                      text: 'Reanswer',
                                      color: AppColor.defaultPurpleColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                )
                              : Container()
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        }),
      );
    });
  }

  _showTips(QuestionTopicModel questionTopicModel) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        enableDrag: false,
        barrierColor: AppColor.defaultGrayColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 20),
        builder: (_) {
          return TipQuestionDialog.tipQuestionDialog(
              context, questionTopicModel);
        });
  }

  Future _recordReanswer(bool visibleRecord) async {
    if (visibleRecord) {
      if (await _record.hasPermission()) {
        await _record.start(
          path: await Utils.generateAudioFileName(),
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          samplingRate: 44100,
        );
      }
    } else {
      _record.stop();
    }
  }

  Future _preparePlayAudio(
      {required String fileName, required String questionId}) async {
    Utils.prepareAudioFile(fileName).then((value) {
      _playAudio(value.path.toString(), questionId);
    });
  }

  Future<void> _playAudio(String audioPath, String questionId) async {
    try {
      await _player!.play(DeviceFileSource(audioPath));
      await _player!.setVolume(2.5);
      _player!.onPlayerComplete.listen((event) {
        widget.provider.setPlayAnswer(false, questionId);
      });
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future<void> _stopAudio() async {
    await _player!.stop();
  }

  @override
  void downloadFilesSuccess(TestDetailModel testDetail, String nameFile,
      double percent, int index, int total) {
    widget.provider.setTotal(total);
    widget.provider.updateDownloadingPercent(percent);
    widget.provider.updateDownloadingIndex(index);
    if (index == total) {
      widget.provider.setDownloadingFile(false);
      widget.provider.setTotal(0);
      widget.provider.updateDownloadingPercent(0.0);
      widget.provider.updateDownloadingIndex(0);
    }
  }

  @override
  void getMyTestSuccess(List<QuestionTopicModel> questions) {
    _loading!.hide();
    widget.provider.setAnswerOfQuestions(questions);
  }

  @override
  void downloadFilesFail(AlertInfo alertInfo) {
    _loading!.hide();
    print('downloadFilesFail: ${alertInfo.description.toString()}');
  }

  @override
  void getMyTestFail(AlertInfo alertInfo) {
    _loading!.hide();
    print('getMyTestFail: ${alertInfo.description.toString()}');
  }

  @override
  bool get wantKeepAlive => true;
}
