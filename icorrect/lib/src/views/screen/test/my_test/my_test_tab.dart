import 'package:flutter/material.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constant_strings.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/models/homework_models/homework_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect/src/models/ui_models/alert_info.dart';
import 'package:icorrect/src/provider/my_test_provider.dart';
import 'package:icorrect/src/views/screen/test/my_test/download_progressing_widget.dart';
import 'package:icorrect/src/views/widget/default_text.dart';
import 'package:provider/provider.dart';

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
  @override
  void initState() {
    super.initState();
    _loading = CircleLoading();
    _presenter = MyTestPresenter(this);
    _loading!.show(context);
    _presenter!.getMyTest(widget.homeWorkModel.testId);

    Future.delayed(Duration.zero, () {
      widget.provider.setDownloadingFile(true);
    });
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
            (widget.homeWorkModel.aiOrder != 0)
                ? Expanded(
                    flex: 1,
                    child: LayoutBuilder(builder: (_, constraint) {
                      return InkWell(
                        onTap: () {},
                        child: Container(
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
                : Container()
          ],
        );
      }
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
                InkWell(
                  onTap: () async {
                    widget.provider.setPlayAnswer(
                        !provider.playAnswer, question.id.toString());
                    if (question.answers.isNotEmpty) {
                      String audioPath = await FileStorageHelper.getFilePath(
                          question.answers.last.url.toString(), MediaType.audio);
                      print('audioPath: ${audioPath} ');
                    }
                  },
                  child: (provider.playAnswer &&
                          question.id.toString() == provider.questionId)
                      ? const Image(image: AssetImage(AppAsset.play))
                      : const Image(image: AssetImage(AppAsset.stop)),
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
                            onTap: () {},
                            child: const DefaultText(
                                text: 'View Tips',
                                color: AppColor.defaultPurpleColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 20),
                          InkWell(
                            onTap: () {},
                            child: const DefaultText(
                                text: 'Reanswer',
                                color: AppColor.defaultPurpleColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          )
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
    print('QuestionTopicModel: ${questions.length.toString()}');
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
