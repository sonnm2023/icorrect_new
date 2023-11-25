import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/models/auth_models/topic_id.dart';
import 'package:icorrect/src/provider/ielts_topics_provider.dart';
import 'package:icorrect/src/views/screen/practice/topics_list/ielts_each_part_topics.dart';
import 'package:icorrect/src/views/screen/practice/topics_list/ielts_full_part_topics.dart';
import 'package:icorrect/src/views/widget/divider.dart';
import 'package:provider/provider.dart';

import '../../../../data_sources/constant_methods.dart';
import '../../../../data_sources/utils.dart';
import '../../../../provider/auth_provider.dart';
import '../../test/simulator_test/simulator_test_screen.dart';

class IELTSTopicsScreen extends StatefulWidget {
  IELTSTopicsScreen({required this.topicTypes, super.key});
  List<String> topicTypes;

  @override
  State<IELTSTopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<IELTSTopicsScreen> {
  AuthProvider? _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    Future.delayed(Duration.zero, () {
      _authProvider!.clearTopicsId();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 50,
          title: Text(
            StringConstants.topics_screen_title,
            style: CustomTextStyle.textWithCustomInfo(
              context: context,
              color: AppColor.defaultPurpleColor,
              fontsSize: FontsSize.fontSize_18,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
          elevation: 0.0,
          iconTheme: const IconThemeData(
            color: AppColor.defaultPurpleColor,
          ),
          backgroundColor: AppColor.defaultWhiteColor,
        ),
        body: SafeArea(
            child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            widget.topicTypes == IELTSTopicType.full.get
                ? IELTSFullPartTopics()
                : ChangeNotifierProvider(
                    create: (_) => IELTSTopicsProvider(),
                    child: IELTSEachPartTopics(topicTypes: widget.topicTypes)),
            _startTestButton()
          ],
        )),
      ),
    );
  }

  Widget _startTestButton() {
    return InkWell(
      onTap: () {
        if (kDebugMode) {
          print(
              "DEBUG : topics id length: ${_authProvider!.getTopicsIdList().length}");
          for (int i = 0; i < _authProvider!.getTopicsIdList().length; i++) {
            print("DEBUG : topic id : ${_authProvider!.getTopicsIdList()[i]}");
          }
        }

        _onClickStartTest();
      },
      child: Wrap(
        children: [
          Container(
            color: AppColor.defaultWhiteColor,
            child: Column(
              children: [
                const CustomDivider(),
                const SizedBox(height: 10),
                Text(
                  Utils.multiLanguage(StringConstants.start_test_button_title),
                  style: CustomTextStyle.textWithCustomInfo(
                    context: context,
                    color: AppColor.defaultPurpleColor,
                    fontsSize: FontsSize.fontSize_16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                const CustomDivider(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future _onClickStartTest() async {
    List<TopicId> topicsId = _authProvider!.topicsId;
    if (topicsId.length >=3) {
      if (widget.topicTypes == IELTSTopicType.full.get) {
        _onTopicsIsFullTest();
      } else {
        _goToTestScreen();
      }
    } else {
      showToastMsg(
        msg: Utils.multiLanguage(StringConstants.choose_at_least_3_topics),
        toastState: ToastStatesType.warning,
      );
    }
  }

  void _onTopicsIsFullTest() {
    List<TopicId> topicsId = _authProvider!.topicsId;
    var topicsPart1 = topicsId
        .where((element) => element.testOption == IELTSTestOption.part1.get);
    var topicsPart23 = topicsId.where(
        (element) => element.testOption == IELTSTestOption.part2and3.get);
    if (topicsPart1.length < 3) {
      showToastMsg(
        msg: Utils.multiLanguage(
            StringConstants.choose_at_least_3_topics_at_part1_message),
        toastState: ToastStatesType.warning,
      );
    } else if (topicsPart23.isEmpty) {
      showToastMsg(
        msg: Utils.multiLanguage(
            StringConstants.choose_at_least_1_topics_at_part23_message),
        toastState: ToastStatesType.warning,
      );
    } else {
      _goToTestScreen();
    }
  }

  Future<void> _goToTestScreen() async {
    int testOption = Utils.getTestOption(widget.topicTypes);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SimulatorTestScreen(
          testOption: testOption,
          topicsId: _authProvider!.getTopicsIdList(),
          isPredict: IELTSPredict.normalQuestion.get,
        ),
      ),
    );
  }
}
