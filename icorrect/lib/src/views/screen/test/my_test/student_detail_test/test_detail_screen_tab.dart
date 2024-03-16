// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/my_test_models/student_result_model.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect/src/models/ui_models/alert_info.dart';
import 'package:icorrect/src/presenters/other_student_test_presenter.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/provider/student_test_detail_provider.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/circle_loading.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/custom_alert_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/tip_question_dialog.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/full_image_widget.dart';
import 'package:icorrect/src/views/widget/simulator_test_widget/load_local_image_widget.dart';
import 'package:provider/provider.dart';
import 'download_again_widget.dart';
import 'download_progressing_widget.dart';

class TestDetailScreen extends StatefulWidget {
  StudentTestProvider provider;
  StudentResultModel studentResultModel;

  TestDetailScreen(
      {super.key, required this.provider, required this.studentResultModel});

  @override
  State<TestDetailScreen> createState() => _TestDetailScreenState();
}

class _TestDetailScreenState extends State<TestDetailScreen>
    with AutomaticKeepAliveClientMixin<TestDetailScreen>, WidgetsBindingObserver
    implements OtherStudentTestContract {
  CircleLoading? _loading;
  OtherStudentTestPresenter? _presenter;
  AudioPlayer? _player;

  bool isOffline = false;
  StreamSubscription? connection;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    connection = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // when every connection status is changed.
      if (result == ConnectivityResult.none) {
        isOffline = true;
      } else if (result == ConnectivityResult.mobile) {
        isOffline = false;
      } else if (result == ConnectivityResult.wifi) {
        isOffline = false;
      } else if (result == ConnectivityResult.ethernet) {
        isOffline = false;
      } else if (result == ConnectivityResult.bluetooth) {
        isOffline = false;
      }

      if (kDebugMode) {
        print("DEBUG: NO INTERNET === $isOffline");
      }
    });
    _loading = CircleLoading();
    _presenter = OtherStudentTestPresenter(this);
    _player = AudioPlayer();
    _loading!.show(context: context, isViewAIResponse: false);

    _getData();
    Future.delayed(Duration.zero, () {
      widget.provider.setDownloadingFile(true);
    });
  }

  void _getData() async {
    await _presenter!.initializeData();
    Utils.checkInternetConnection().then(
      (isConnected) async {
        if (isConnected) {
          _presenter!.getMyTest(
              context: context,
              testId: widget.studentResultModel.testId.toString());
        } else {
          //Show connect error here
          if (kDebugMode) {
            print("DEBUG: Connect error here!");
          }
          Utils.showConnectionErrorDialog(context);

          Utils.addConnectionErrorLog(context);
        }
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _onAppActive();
        break;
      case AppLifecycleState.paused:
        if (kDebugMode) {
          print('DEBUG: App paused');
        }
        break;
      case AppLifecycleState.inactive:
        _onAppInBackground();
        break;
      case AppLifecycleState.detached:
        if (kDebugMode) {
          print('DEBUG:App detached');
        }
        break;
      case AppLifecycleState.hidden:
        if (kDebugMode) {
          print('DEBUG:App hidden');
        }
        break;
    }
  }

  Future _onAppInBackground() async {
    if (_player!.state == PlayerState.playing) {
      QuestionTopicModel q = widget.provider.currentQuestion;
      widget.provider.setPlayAnswer(false, q.id.toString());
      _stopAudio();
    }
  }

  Future _onAppActive() async {
    if (widget.provider.visibleRecord) {
      widget.provider.setVisibleRecord(false);
      _player!.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _player!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildMyTest();
  }

  Widget _buildMyTest() {
    return Consumer<StudentTestProvider>(
      builder: (context, provider, child) {
        if (provider.isDownloading) {
          return const DownloadProgressingWidget();
        } else {
          return Stack(
            children: [
              Column(
                children: [
                  // Expanded(flex: 5, child: VideoMyTest()),
                  Expanded(
                    flex: 9,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: provider.myAnswerOfQuestions.length,
                      itemBuilder: (context, index) {
                        return _questionItem(
                            provider.myAnswerOfQuestions[index]);
                      },
                    ),
                  ),
                ],
              ),
              provider.needDownloadAgain
                  ? DownloadAgainWidget(
                      simulatorTestPresenter: null,
                      otherStudentTestPresenter: _presenter,
                    )
                  : const SizedBox(),
              _buildFullImageView(),
            ],
          );
        }
      },
    );
  }

  Widget _buildFullImageView() {
    return Consumer<StudentTestProvider>(
      builder: (context, provider, child) {
        if (provider.showFullImage) {
          return FullImageWidget(
            imageUrl: provider.selectedQuestionImageUrl,
            provider: provider,
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _questionItem(QuestionTopicModel question) {
    bool hasImage = Utils.checkHasImage(question: question);
    String fileName = question.files.last.url;

    return Consumer<StudentTestProvider>(
      builder: (context, provider, child) {
        return Card(
          elevation: 2,
          child: LayoutBuilder(builder: (_, constraint) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: CustomSize.size_10,
                vertical: CustomSize.size_10,
              ),
              margin: const EdgeInsets.only(
                top: CustomSize.size_10,
              ),
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
                          child: const Image(
                            image: AssetImage(AppAsset.play),
                            width: CustomSize.size_50,
                            height: CustomSize.size_50,
                          ),
                        )
                      : InkWell(
                          onTap: () async {
                            _onClickPlayAnswer(question);
                          },
                          child: const Image(
                            image: AssetImage(AppAsset.stop),
                            width: CustomSize.size_50,
                            height: CustomSize.size_50,
                          ),
                        ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(
                        left: CustomSize.size_10,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.content.toString(),
                            style: CustomTextStyle.textWithCustomInfo(
                              context: context,
                              color: AppColor.defaultBlackColor,
                              fontsSize: FontsSize.fontSize_14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: CustomSize.size_10),
                          InkWell(
                            onTap: () {
                              _showTips(question);
                            },
                            child: (question.tips.isNotEmpty)
                                ? Text(
                                    Utils.multiLanguage(StringConstants
                                        .view_tips_button_title)!,
                                    style: CustomTextStyle.textWithCustomInfo(
                                      context: context,
                                      color: AppColor.defaultPurpleColor,
                                      fontsSize: FontsSize.fontSize_14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                : Container(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  hasImage
                      ? InkWell(
                          onTap: () {
                            _showFullImage(fileName: fileName);
                          },
                          child: LoadLocalImageWidget(
                            imageUrl: fileName,
                            isInRow: true,
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  void _showFullImage({required String fileName}) {
    if (kDebugMode) {
      print("DEBUG: _showFullImage");
    }

    //For test
    // widget.simulatorTestProvider.setSelectedQuestionImageUrl(fileName);
    // widget.simulatorTestProvider.setShowFullImage(true);

    widget.provider.setSelectedQuestionImageUrl(fileName);
    widget.provider.setShowFullImage(true);
  }

  Future _onClickPlayAnswer(QuestionTopicModel question) async {
    if (question.answers.isNotEmpty) {
      widget.provider.setPlayAnswer(true, question.id.toString());
      _preparePlayAudio(
          fileName: Utils.convertFileName(question.answers.last.url.toString()),
          questionId: question.id.toString());
    } else {
      Fluttertoast.showToast(
        msg: Utils.multiLanguage(StringConstants.no_answer_message)!,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  Future _preparePlayAudio(
      {required String fileName, required String questionId}) async {
    String path = await FileStorageHelper.getFilePath(
        fileName, MediaType.audio, widget.studentResultModel.testId.toString());
    _playAudio(path, questionId);
  }

  Future<void> _playAudio(String audioPath, String questionId) async {
    try {
      await _player!.play(DeviceFileSource(audioPath));
      await _player!.setVolume(2.5);
      _player!.onPlayerComplete.listen((event) {
        widget.provider.setPlayAnswer(false, questionId);
      });
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("DEBUG:  _playAudio $e");
      }
    }
  }

  Future<void> _stopAudio() async {
    await _player!.stop();
  }

  _showTips(QuestionTopicModel questionTopicModel) {
    Provider.of<AuthProvider>(context, listen: false)
        .setShowDialogWithGlobalScaffoldKey(
            true, GlobalScaffoldKey.showTipScaffoldKey);

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
        return TipQuestionDialog.tipQuestionDialog(context, questionTopicModel);
      },
    );
  }

  @override
  void onDownloadFilesFail(AlertInfo alertInfo) {
    _loading!.hide();
    Fluttertoast.showToast(
      msg: alertInfo.description,
      backgroundColor: AppColor.defaultGrayColor,
      textColor: Colors.black,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
    );
  }

  @override
  void onDownloadFilesSuccess(TestDetailModel testDetail, String nameFile,
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
  void onReDownload() {
    widget.provider.setDownloadingFile(false);
    widget.provider.setNeedDownloadAgain(true);
  }

  @override
  void onTryAgainToDownload() {
    if (isOffline) {
      _showCheckNetworkDialog();
    } else {
      if (null != _presenter!.testDetail && null != _presenter!.filesTopic) {
        updateStatusForReDownload();
        if (null == _presenter!.dio) {
          _presenter!.initializeData();
        }
        _presenter!.reDownloadFiles();
      }
    }
  }

  void updateStatusForReDownload() {
    widget.provider.setDownloadingFile(true);
    widget.provider.setNeedDownloadAgain(false);
  }

  void _showCheckNetworkDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: Utils.multiLanguage(StringConstants.dialog_title)!,
          description:
              Utils.multiLanguage(StringConstants.network_error_message)!,
          okButtonTitle: Utils.multiLanguage(StringConstants.ok_button_title),
          cancelButtonTitle: null,
          borderRadius: 8,
          hasCloseButton: false,
          okButtonTapped: () {
            Navigator.of(context).pop();
          },
          cancelButtonTapped: null,
        );
      },
    );
  }

  @override
  void onGetMyTestFail(AlertInfo alertInfo) {
    _loading!.hide();

    Fluttertoast.showToast(
        msg: alertInfo.description,
        backgroundColor: AppColor.defaultGrayColor,
        textColor: Colors.black,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER);
    if (kDebugMode) {
      print('DEBUG: getMyTestFail: ${alertInfo.description.toString()}');
    }
  }

  @override
  void onGetMyTestSuccess(List<QuestionTopicModel> questions) {
    _loading!.hide();
    widget.provider.setAnswerOfQuestions(questions);
  }

  @override
  bool get wantKeepAlive => true;
}
