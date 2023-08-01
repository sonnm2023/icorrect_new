import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constant_strings.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/homework_models/homework_model.dart';
import 'package:icorrect/src/models/my_test_models/result_response_model.dart';
import 'package:icorrect/src/models/my_test_models/skill_problem_model.dart';
import 'package:icorrect/src/presenters/response_presenter.dart';
import 'package:icorrect/src/provider/my_test_provider.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/sample_video_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/stream_audio_dialog.dart';
import 'package:icorrect/src/views/widget/default_text.dart';
import 'package:icorrect/src/views/widget/empty_widget.dart';
import 'package:provider/provider.dart';

import '../../other_views/dialog/circle_loading.dart';

class ResponseTab extends StatefulWidget {
  HomeWorkModel homeWorkModel;
  MyTestProvider provider;
  ResponseTab({super.key, required this.homeWorkModel, required this.provider});

  @override
  State<ResponseTab> createState() => _ResponseTabState();
}

class _ResponseTabState extends State<ResponseTab>
    with AutomaticKeepAliveClientMixin<ResponseTab>
    implements ResponseContracts {
  CircleLoading? _loading;
  ResponsePresenter? _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = ResponsePresenter(this);
    if (kDebugMode) {
      print('meomeo: ${widget.homeWorkModel.activityId.toString()}');
    }
    _loading = CircleLoading();
    _loading?.show(context);
    if (widget.homeWorkModel.orderId.isNotEmpty) {
      _presenter!.getResponse(widget.homeWorkModel.orderId);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
        color: AppColor.defaultPurpleColor,
        onRefresh: () {
          return Future.delayed(const Duration(seconds: 1), () {
            _loading?.show(context);
            _presenter!.getResponse(widget.homeWorkModel.orderId.toString());
          });
        },
        child: _buildResponseTab());
  }

  Widget _buildResponseTab() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            _buildOverview(),
            const SizedBox(height: 20),
            _buildOverallScore()
          ],
        ),
      ),
    );
  }

  Widget _buildOverview() {
    return Consumer<MyTestProvider>(builder: (context, appState, child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: const DefaultText(
              text: 'Overview',
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            child: (appState.visibleOverviewComment)
                ? Text(
                    appState.responseModel.overallComment ?? '',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  )
                : DefaultText(
                    text: appState.responseModel.overallComment ?? '',
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    maxLines: 4,
                  ),
          ),
          LayoutBuilder(builder: (context, constraint) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.centerRight,
              width: constraint.maxWidth,
              child: (appState.responseModel.overallComment !=
                          'Nothing overall comment in here' &&
                      appState.responseModel.overallComment
                          .toString()
                          .isNotEmpty)
                  ? InkWell(
                      onTap: () {
                        widget.provider.setVisibleOverviewComment(
                            !appState.visibleOverviewComment);
                      },
                      child: DefaultText(
                          text: (appState.visibleOverviewComment)
                              ? 'Show less'
                              : 'Show more',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          maxLines: 4),
                    )
                  : Container(),
            );
          })
        ],
      );
    });
  }

  Widget _buildOverallScore() {
    return Consumer<MyTestProvider>(builder: (context, appState, child) {
      ResultResponseModel result = appState.responseModel;
      return Column(
        children: [
          _scoreItem(index: 0, title: 'Overall score: ${result.overallScore}'),
          _scoreItem(
              index: 1,
              title: 'Fluency : ${result.fluency}',
              problems: result.fluencyProblem,
              visible: appState.visibleFluency),
          _scoreItem(
              index: 2,
              title: 'Lexical Resource : ${result.lexicalResource}',
              problems: result.lexicalResourceProblem,
              visible: appState.visibleLexical),
          _scoreItem(
              index: 3,
              title: 'Grammatical : ${result.grammatical}',
              problems: result.grammaticalProblem,
              visible: appState.visibleGramatical),
          _scoreItem(
              index: 4,
              title: 'Pronunciation : ${result.pronunciation}',
              problems: result.pronunciationProblem,
              visible: appState.visiblePronunciation),
        ],
      );
    });
  }

  Widget _scoreItem(
      {required int index,
      required String title,
      List<SkillProblem>? problems,
      bool? visible}) {
    var radius = const Radius.circular(20);
    var borderRadius = BorderRadius.circular(0);
    if (index == 0) {
      borderRadius = BorderRadius.only(topLeft: radius, topRight: radius);
    } else if (index == 4) {
      borderRadius = !visible!
          ? BorderRadius.only(bottomLeft: radius, bottomRight: radius)
          : BorderRadius.circular(0);
    }
    return InkWell(
      onTap: () {
        _setVisibleProblem(index: index);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            alignment: Alignment.topLeft,
            decoration: BoxDecoration(
                color: AppColor.defaultPurpleColor, borderRadius: borderRadius),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DefaultText(
                  text: title,
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                LayoutBuilder(builder: (_, constraint) {
                  if (index != 0) {
                    if (visible!) {
                      return const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 30,
                        color: Colors.white,
                      );
                    } else {
                      return const Icon(
                        Icons.navigate_next_rounded,
                        size: 30,
                        color: Colors.white,
                      );
                    }
                  } else {
                    return Container();
                  }
                }),
              ],
            ),
          ),
          index != 0 && visible!
              ? _overallDetail(problems: problems!)
              : Container()
        ],
      ),
    );
  }

  void _setVisibleProblem({required int index}) {
    switch (index) {
      case 1:
        return widget.provider
            .setVisibleFluency(!widget.provider.visibleFluency);
      case 2:
        return widget.provider
            .setVisibleLexical(!widget.provider.visibleLexical);
      case 3:
        return widget.provider
            .setVisibleGramatical(!widget.provider.visibleGramatical);
      case 4:
        return widget.provider
            .setVisiblePronunciation(!widget.provider.visiblePronunciation);
    }
  }

  Widget _overallDetail({required List<SkillProblem> problems}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
          border: Border.all(color: AppColor.defaultPurpleColor, width: 1)),
      child: (problems.isNotEmpty)
          ? ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: problems.length,
              itemBuilder: (_, item) {
                SkillProblem problemModel = problems.elementAt(item);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning_amber_outlined,
                            color: Colors.orangeAccent, size: 20),
                        SizedBox(width: 10),
                        DefaultText(
                          text: 'Problem',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )
                      ],
                    ),
                    const SizedBox(height: 5),
                    DefaultText(
                      text: problemModel.problem.toString(),
                      color: Colors.black,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Icon(Icons.light_mode_outlined,
                            color: Colors.orangeAccent, size: 20),
                        const SizedBox(width: 10),
                        const DefaultText(
                          text: 'Solution',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        const SizedBox(width: 10),
                        (problemModel.fileName.toString().isNotEmpty)
                            ? _viewSampleButton(
                                problemModel.fileName.toString())
                            : Container()
                      ],
                    ),
                    const SizedBox(height: 5),
                    DefaultText(
                      text: problemModel.solution.toString(),
                      color: Colors.black,
                    )
                  ],
                );
              })
          : EmptyWidget.init().buildNothingWidget('Nothing Problem in here',
              widthSize: 100, heightSize: 100),
    );
  }

  Widget _viewSampleButton(String fileName) {
    return InkWell(
      onTap: () {
        _onTapViewSample(fileName);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
            border: Border.all(color: AppColor.defaultPurpleColor),
            borderRadius: BorderRadius.circular(20)),
        child: const DefaultText(
          text: 'View Sample',
          color: AppColor.defaultPurpleColor,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  void _onTapViewSample(String fileName) {
    String url = fileEP(fileName);
    String typeFile = Utils.fileType(fileName);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (builder) {
          return (typeFile == StringClass.audio)
              ? SliderAudio(url: url)
              : SampleVideo(url: url);
        });
  }

  @override
  void getSuccessResponse(ResultResponseModel responseModel) {
    _loading!.hide();
    widget.provider.setResultResponseModel(responseModel);
    if (kDebugMode) {
      print('responseModel: ${responseModel.fluency.toString()}');
    }
  }

  @override
  void getErrorResponse(String message) {
    _loading!.hide();
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0);
  }

  @override
  bool get wantKeepAlive => true;
}
