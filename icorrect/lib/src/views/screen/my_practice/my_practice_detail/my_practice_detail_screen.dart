import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect/src/provider/my_test_provider.dart';
import 'package:icorrect/src/views/other/confirm_dialog.dart';
import 'package:icorrect/src/views/screen/test/my_test/my_test_tab.dart';
import 'package:icorrect/src/views/widget/divider.dart';
import 'package:provider/provider.dart';

class MyPracticeDetailScreen extends StatefulWidget {
  final String testId;
  const MyPracticeDetailScreen({required this.testId, super.key});

  @override
  State<MyPracticeDetailScreen> createState() => _MyPracticeDetailScreenState();
}

class _MyPracticeDetailScreenState extends State<MyPracticeDetailScreen> {
  double w = 0, h = 0;
  MyTestProvider? _myTestProvider;

  @override
  void initState() {
    super.initState();
    _myTestProvider = Provider.of<MyTestProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          left: true,
          top: true,
          right: true,
          bottom: true,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(10),
                  child: Stack(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () {
                            if (_myTestProvider!
                                .reAnswerOfQuestions.isNotEmpty) {
                              _showDialogConfirmToOutScreen(
                                  provider: _myTestProvider!);
                            } else {
                              _myTestProvider!.clearData();
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Icon(
                            Icons.arrow_back_outlined,
                            color: AppColor.defaultPurpleColor,
                            size: 25,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          Utils.multiLanguage(
                              StringConstants.test_detail_tab_title)!,
                          style: CustomTextStyle.textWithCustomInfo(
                            context: context,
                            color: AppColor.defaultPurpleColor,
                            fontsSize: FontsSize.fontSize_18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const CustomDivider(),
                Container(
                  height: h - 60,
                  padding: const EdgeInsets.only(bottom: 30),
                  child: MyTestTab(
                    homeWorkModel: null,
                    practiceTestId: widget.testId,
                    provider: _myTestProvider!,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      onWillPop: () async {
        if (_myTestProvider!.reAnswerOfQuestions.isNotEmpty) {
          _showDialogConfirmToOutScreen(provider: _myTestProvider!);
        } else {
          _myTestProvider!.clearData();
          Navigator.of(context).pop();
        }
        return false;
      },
    );
  }

  void _showDialogConfirmToOutScreen({required MyTestProvider provider}) {
    showDialog(
      context: context,
      builder: (builder) {
        return ConfirmDialogWidget(
          title: Utils.multiLanguage(StringConstants.confirm_to_go_out_screen)!,
          message: Utils.multiLanguage(
              StringConstants.re_answer_not_be_save_message)!,
          cancelButtonTitle:
              Utils.multiLanguage(StringConstants.cancel_button_title)!,
          okButtonTitle:
              Utils.multiLanguage(StringConstants.back_button_title)!,
          cancelButtonTapped: () {},
          okButtonTapped: () {
            deleteFileAnswers(provider.reAnswerOfQuestions);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Future deleteFileAnswers(List<QuestionTopicModel> questions) async {
    for (var q in questions) {
      if (q.answers.isNotEmpty) {
        String fileName = q.answers.last.url.toString();
        FileStorageHelper.deleteFile(fileName, MediaType.audio, null);
      }
    }
  }
}
