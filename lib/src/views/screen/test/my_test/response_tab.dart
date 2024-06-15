import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/my_test_models/result_response_model.dart';
import 'package:icorrect/src/models/my_test_models/skill_problem_model.dart';
import 'package:icorrect/src/presenters/response_presenter.dart';
import 'package:icorrect/src/provider/my_test_provider.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/circle_loading.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/sample_video_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/stream_audio_dialog.dart';
import 'package:icorrect/src/views/widget/default_text.dart';
import 'package:icorrect/src/views/widget/empty_widget.dart';
import 'package:provider/provider.dart';

class ResponseTab extends StatefulWidget {
  final ActivitiesModel homeWorkModel;
  final MyTestProvider provider;

  const ResponseTab(
      {super.key, required this.homeWorkModel, required this.provider});

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
      print('DEBUG: ResponseTab ${widget.homeWorkModel.activityId.toString()}');
    }
    _loading = CircleLoading();
    _loading?.show(context: context, isViewAIResponse: false);
    if (widget.homeWorkModel.activityAnswer!.orderId.toString().isNotEmpty) {
      _presenter!.getResponse(
        context: context,
        orderId: widget.homeWorkModel.activityAnswer!.orderId.toString(),
      );
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
          return Future.delayed(
              const Duration(
                seconds: 1,
              ), () {
            _loading?.show(context: context, isViewAIResponse: false);
            _presenter!.getResponse(
              context: context,
              orderId: widget.homeWorkModel.activityAnswer!.orderId.toString(),
            );
          });
        },
        child: _buildResponseTab());
  }

  Widget _buildResponseTab() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: CustomSize.size_20,
          vertical: CustomSize.size_10,
        ),
        child: Column(
          children: [
            _buildOverview(),
            const SizedBox(height: CustomSize.size_20),
            _buildOverallScore()
          ],
        ),
      ),
    );
  }

  Widget _buildOverview() {
    return Consumer<MyTestProvider>(
      builder: (context, appState, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                Utils.multiLanguage(StringConstants.overview)!,
                style: CustomTextStyle.textWithCustomInfo(
                  context: context,
                  color: AppColor.defaultBlackColor,
                  fontsSize: FontsSize.fontSize_15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: CustomSize.size_10),
            Container(
              child: (appState.visibleOverviewComment)
                  ? Text(
                      appState.responseModel.overallComment ?? '',
                      textAlign: TextAlign.justify,
                      style: CustomTextStyle.textWithCustomInfo(
                        context: context,
                        color: AppColor.defaultBlackColor,
                        fontsSize: FontsSize.fontSize_14,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  : Text(
                      appState.responseModel.overallComment ?? '',
                      style: CustomTextStyle.textWithCustomInfo(
                        context: context,
                        color: AppColor.defaultBlackColor,
                        fontsSize: FontsSize.fontSize_14,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.justify,
                      maxLines: 4,
                    ),
            ),
            LayoutBuilder(
              builder: (context, constraint) {
                return Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: CustomSize.size_10,
                  ),
                  alignment: Alignment.centerRight,
                  width: constraint.maxWidth,
                  child: (appState.responseModel.isTooLong())
                      ? InkWell(
                          onTap: () {
                            widget.provider.setVisibleOverviewComment(
                                !appState.visibleOverviewComment);
                          },
                          child: Text(
                            (appState.visibleOverviewComment)
                                ? Utils.multiLanguage(
                                    StringConstants.show_less)!
                                : Utils.multiLanguage(
                                    StringConstants.show_more)!,
                            style: CustomTextStyle.textWithCustomInfo(
                              context: context,
                              color: AppColor.defaultBlackColor,
                              fontsSize: FontsSize.fontSize_14,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.justify,
                            maxLines: 4,
                          ),
                        )
                      : Container(),
                );
              },
            )
          ],
        );
      },
    );
  }

  Widget _buildOverallScore() {
    return Consumer<MyTestProvider>(
      builder: (context, appState, child) {
        ResultResponseModel result = appState.responseModel;
        return Column(
          children: [
            _scoreItem(
              index: 0,
              title:
                  '${Utils.multiLanguage(StringConstants.overall_score)} ${result.overallScore}',
            ),
            _scoreItem(
              index: 1,
              title:
                  '${Utils.multiLanguage(StringConstants.fluency)} ${result.fluency}',
              problems: result.fluencyProblem,
              visible: appState.visibleFluency,
            ),
            _scoreItem(
              index: 2,
              title:
                  '${Utils.multiLanguage(StringConstants.lexical_resource)} ${result.lexicalResource}',
              problems: result.lexicalResourceProblem,
              visible: appState.visibleLexical,
            ),
            _scoreItem(
              index: 3,
              title:
                  '${Utils.multiLanguage(StringConstants.grammatical)} ${result.grammatical}',
              problems: result.grammaticalProblem,
              visible: appState.visibleGramatical,
            ),
            _scoreItem(
              index: 4,
              title:
                  '${Utils.multiLanguage(StringConstants.pronunciation)} ${result.pronunciation}',
              problems: result.pronunciationProblem,
              visible: appState.visiblePronunciation,
            ),
          ],
        );
      },
    );
  }

  Widget _scoreItem({
    required int index,
    required String title,
    List<SkillProblem>? problems,
    bool? visible,
  }) {
    var radius = const Radius.circular(
      CustomSize.size_20,
    );
    var borderRadius = BorderRadius.circular(0);
    if (index == 0) {
      borderRadius = BorderRadius.only(
        topLeft: radius,
        topRight: radius,
      );
    } else if (index == 4) {
      borderRadius = !visible!
          ? BorderRadius.only(
              bottomLeft: radius,
              bottomRight: radius,
            )
          : BorderRadius.circular(0);
    }
    return (problems != null && problems.isNotEmpty)
        ? InkWell(
            onTap: () {
              _setVisibleProblem(index: index);
            },
            child: _overallScoreTitle(
                index: index,
                title: title,
                visible: visible,
                borderRadius: borderRadius))
        : _overallScoreTitle(
            index: index,
            title: title,
            visible: visible,
            borderRadius: borderRadius);
  }

  Widget _overallScoreTitle(
      {required int index,
      required String title,
      List<SkillProblem>? problems,
      bool? visible,
      var borderRadius}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: CustomSize.size_20,
            vertical: CustomSize.size_10,
          ),
          alignment: Alignment.topLeft,
          decoration: BoxDecoration(
            color: AppColor.defaultPurpleColor,
            borderRadius: borderRadius,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: CustomTextStyle.textWithCustomInfo(
                  context: context,
                  color: AppColor.defaultAppColor,
                  fontsSize: FontsSize.fontSize_15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Visibility(
                  visible: (problems != null && problems.isNotEmpty),
                  child: LayoutBuilder(builder: (_, constraint) {
                    if (index != 0) {
                      if (visible!) {
                        return const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: CustomSize.size_30,
                          color: AppColor.defaultWhiteColor,
                        );
                      } else {
                        return const Icon(
                          Icons.navigate_next_rounded,
                          size: CustomSize.size_30,
                          color: AppColor.defaultWhiteColor,
                        );
                      }
                    } else {
                      return Container();
                    }
                  })),
            ],
          ),
        ),
        index != 0 && visible! && problems != null
            ? _overallDetail(problems: problems)
            : Container()
      ],
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
      padding: const EdgeInsets.symmetric(
        horizontal: CustomSize.size_10,
        vertical: CustomSize.size_15,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColor.defaultPurpleColor,
          width: 1,
        ),
      ),
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
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_outlined,
                          color: Colors.orangeAccent,
                          size: CustomSize.size_20,
                        ),
                        const SizedBox(width: CustomSize.size_10),
                        Text(
                          Utils.multiLanguage(StringConstants.problem)!,
                          style: CustomTextStyle.textWithCustomInfo(
                            context: context,
                            color: AppColor.defaultBlackColor,
                            fontsSize: FontsSize.fontSize_14,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: CustomSize.size_5),
                    Text(
                      problemModel.problem.toString(),
                      style: CustomTextStyle.textWithCustomInfo(
                        context: context,
                        color: AppColor.defaultBlackColor,
                        fontsSize: FontsSize.fontSize_14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: CustomSize.size_15),
                    Row(
                      children: [
                        const Icon(
                          Icons.light_mode_outlined,
                          color: Colors.orangeAccent,
                          size: CustomSize.size_20,
                        ),
                        const SizedBox(width: CustomSize.size_10),
                        Text(
                          Utils.multiLanguage(StringConstants.solution)!,
                          style: CustomTextStyle.textWithCustomInfo(
                            context: context,
                            color: AppColor.defaultBlackColor,
                            fontsSize: FontsSize.fontSize_14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: CustomSize.size_10),
                        (problemModel.fileName.toString().isNotEmpty)
                            ? _viewSampleButton(
                                problemModel.fileName.toString())
                            : Container()
                      ],
                    ),
                    const SizedBox(height: CustomSize.size_5),
                    DefaultText(
                      text: problemModel.solution.toString(),
                      color: Colors.black,
                    )
                  ],
                );
              })
          : EmptyWidget.init().buildNothingWidget(
              context,
              Utils.multiLanguage(StringConstants.no_data_message)!,
              widthSize: CustomSize.size_100,
              heightSize: CustomSize.size_100,
            ),
    );
  }

  Widget _viewSampleButton(String fileName) {
    return InkWell(
      onTap: () {
        _onTapViewSample(fileName);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 3,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColor.defaultPurpleColor,
          ),
          borderRadius: BorderRadius.circular(CustomSize.size_20),
        ),
        child: Text(
          Utils.multiLanguage(StringConstants.view_sample_button_title)!,
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColor.defaultPurpleColor,
            fontsSize: FontsSize.fontSize_14,
            fontWeight: FontWeight.w600,
          ),
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
      },
    );
  }

  @override
  void onGetResponseSuccess(ResultResponseModel responseModel) {
    Utils.hideLoading(_loading);
    widget.provider.setResultResponseModel(responseModel);
    if (kDebugMode) {
      print('DEBUG: getSuccessResponse: ${responseModel.fluency.toString()}');
    }
  }

  @override
  void onGetResponseError({required String message, required bool isError}) {
    Utils.hideLoading(_loading);

    if (isError) {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        fontSize: FontsSize.fontSize_15,
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}
