import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/my_practice_test_model/bank_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/bank_topic_model.dart';
import 'package:icorrect/src/presenters/my_practice_topic_list_presenter.dart';
import 'package:icorrect/src/provider/my_practice_list_provider.dart';
import 'package:icorrect/src/provider/my_practice_topics_provider.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/circle_loading.dart';
import 'package:provider/provider.dart';

class TopicListTabScreen extends StatefulWidget {
  const TopicListTabScreen({super.key, required this.selectedBank});

  final BankModel selectedBank;

  @override
  State<TopicListTabScreen> createState() => _TopicListTabScreenState();
}

class _TopicListTabScreenState extends State<TopicListTabScreen>
    with AutomaticKeepAliveClientMixin<TopicListTabScreen>
    implements MyPracticeTopicListViewContract {
  MyPracticeTopicListPresenter? _presenter;
  CircleLoading? _loading;
  // MyPracticeTopicsProvider? _myPracticeTopicsProvider;
  MyPracticeListProvider? _practiceListProvider;

  @override
  void initState() {
    super.initState();
    _presenter = MyPracticeTopicListPresenter(this);
    _loading = CircleLoading();
    // _myPracticeTopicsProvider =
    //     Provider.of<MyPracticeTopicsProvider>(context, listen: false);
    _practiceListProvider =
        Provider.of<MyPracticeListProvider>(context, listen: false);
    _getTopicList();
  }

  @override
  void dispose() {
    _practiceListProvider!.clearTopicList();
    super.dispose();
  }

  void _getTopicList() {
    _loading!.show(context: context, isViewAIResponse: false);
    _presenter!
        .getListTopicOfBank(context, widget.selectedBank.bankDistributeCode!);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        _buildSelectionInfo(),
        _buildTopicList(),
      ],
    );
  }

  Widget _buildSelectionInfo() {
    return Consumer<MyPracticeListProvider>(
      builder: (buildContext, provider, child) {
        int selectedTopics = provider.getTotalSelectedTopics();
        int totalTopics = provider.getTotalTopics();
        int selectedSubTopics = provider.getTotalSelectedSubTopics();
        int totalSubTopics = provider.getTotalSubTopics();

        return Container(
          color: AppColor.defaultGraySlightColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                width: 60,
                child: Checkbox(
                  value: selectedTopics > 0,
                  onChanged: (value) {
                    _selectAllTopics(value!, provider.topics);
                  },
                  activeColor: AppColor.defaultPurpleColor,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "($selectedTopics/$totalTopics)${Utils.multiLanguage(StringConstants.my_pratice_selected_topics)}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "($selectedSubTopics/$totalSubTopics)${Utils.multiLanguage(StringConstants.my_pratice_selected_subtopics)}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 60),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectAllTopics(bool isSelected, List<Topic> topics) {
    setState(() {
      for (int i = 0; i < topics.length; i++) {
        topics[i].isSelected = isSelected;
        if (topics[i].subTopics != null) {
          for (int j = 0; j < topics[i].subTopics!.length; j++) {
            topics[i].subTopics![j].isSelected = isSelected;
          }
        }
      }
    });
  }

  Widget _buildTopicList() {
    return Consumer<MyPracticeListProvider>(
      builder: (context, provider, child) {
        return Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: provider.topics.length,
            itemBuilder: (context, index) {
              return _buildTopicItem(provider.topics[index]);
            },
          ),
        );
      },
    );
  }

  bool _hasSubTopic(Topic topic) {
    if (topic.subTopics == null) return false;
    if (topic.subTopics!.isEmpty) return false;
    return true;
  }

  void _topicTapped(Topic topic) {
    setState(() {
      final bool newValue =
          !topic.subTopics!.any((subTopic) => subTopic.isSelected);
      for (int i = 0; i < topic.subTopics!.length; i++) {
        topic.subTopics![i].isSelected = newValue;
      }
    });
  }

  void _subTopicTapped(Topic topic, SubTopics subTopic) {
    setState(() {
      subTopic.isSelected = !subTopic.isSelected;
      topic.subTopics!.every(
        (subTopic) => subTopic.isSelected,
      )
          ? topic.isSelected = true
          : topic.isSelected = false;
    });
  }

  Widget _buildTopicItem(Topic topic) {
    bool hasSubTopic = _hasSubTopic(topic);
    String selectedSubTopicsInfo = "";
    if (hasSubTopic) {
      int temp = _practiceListProvider!
          .getTotalSelectedSubTopicsWithTopicId(topic.id!);
      if (temp > 0) {
        selectedSubTopicsInfo = " ($temp/${topic.subTopics!.length})";
      }
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    _topicTapped(topic);
                  },
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        Checkbox(
                          value: topic.subTopics!
                              .any((subTopic) => subTopic.isSelected),
                          onChanged: (value) {
                            _topicTapped(topic);
                          },
                          fillColor: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return AppColor.defaultPurpleColor;
                            }
                            return Colors.grey;
                          }),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            "${topic.title!}$selectedSubTopicsInfo",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              hasSubTopic
                  ? InkWell(
                      onTap: () {
                        if (kDebugMode) {
                          print("DEBUG: Expand sub topic");
                        }
                        setState(
                          () {
                            // _myPracticeTopicsProvider!
                            //     .resetExpandedStatusOfOthers(topic);
                            topic.isExpanded = !topic.isExpanded;
                          },
                        );
                      },
                      child: SizedBox(
                        width: 60,
                        height: 50,
                        child: Center(
                          child: topic.isExpanded
                              ? const Icon(
                                  Icons.expand_more_outlined,
                                  size: 30,
                                )
                              : const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 20,
                                ),
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
        const SizedBox(height: 5),
        const Divider(
          thickness: 1,
          height: 1,
          color: AppColor.defaultPurpleColor,
        ),
        if (topic.isExpanded)
          ...topic.subTopics!.map((subTopic) {
            return _buildSubTopicItem(topic, subTopic);
          }).toList(),
      ],
    );
  }

  Widget _buildSubTopicItem(Topic topic, SubTopics subTopic) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    _subTopicTapped(topic, subTopic);
                  },
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        Checkbox(
                          value: subTopic.isSelected,
                          onChanged: (value) {
                            _subTopicTapped(topic, subTopic);
                          },
                          fillColor: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return AppColor.defaultPurpleColor;
                            }
                            return Colors.grey;
                          }),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          subTopic.title!,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        const Divider(
          thickness: 1,
          height: 1,
          color: AppColor.defaultPurpleColor,
        ),
      ],
    );
  }

  @override
  void onGetListTopicOfBankError(String message) {
    _loading!.hide();
    if (kDebugMode) {
      print("DEBUG: implement onGetListTopicOfBankFail");
    }
  }

  @override
  void onGetListTopicOfBankSuccess(List<Topic> topics) {
    _loading!.hide();
    if (kDebugMode) {
      print("DEBUG: implement onGetListTopicOfBankSuccess");
    }
    _practiceListProvider!.setTopicList(topics);
  }

  @override
  bool get wantKeepAlive => true;
}
