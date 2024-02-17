import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/my_practice_test_model/ai_option_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/setting_model.dart';
import 'package:icorrect/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';
import 'package:icorrect/src/provider/my_practice_detail_provider.dart';
import 'package:provider/provider.dart';

enum ScoringOptionType { groupScoring, allScoring }

class ScoringOrderSettingWidget extends StatefulWidget {
  final TestDetailModel myPracticeDetail;
  final List<PartInfoModel> parts;
  final List<AiOption> listAiOption;

  const ScoringOrderSettingWidget(
      {super.key,
      required this.myPracticeDetail,
      required this.parts,
      required this.listAiOption});

  @override
  State<ScoringOrderSettingWidget> createState() =>
      _ScoringOrderSettingWidgetState();
}

class _ScoringOrderSettingWidgetState extends State<ScoringOrderSettingWidget> {
  TabBar get _tabBar => TabBar(
        indicatorColor: AppColor.defaultPurpleColor,
        indicator: const BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 2, color: AppColor.defaultPurpleColor),
          ),
        ),
        tabs: [
          Tab(
            text: Utils.multiLanguage(StringConstants.ai_scoring_tab_title),
          ),
          Tab(
            text: Utils.multiLanguage(StringConstants.expert_scoring_tab_title),
          ),
        ],
      );

  late List<SettingModel> _originalSettings = [];
  late MyPracticeDetailProvider _provider;
  UserDataModel? _currentUser;
  int _maxNumberQuestionOfPart1 = 0;
  int _maxNumberQuestionOfPart2 = 0;
  int _maxNumberQuestionOfPart3 = 0;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<MyPracticeDetailProvider>(context, listen: false);
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 60.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // key: GlobalScaffoldKey.filterScaffoldKey,
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(
                bottom:
                    BorderSide(color: AppColor.defaultPurpleColor, width: 1),
              ),
            ),
            child: _tabBar,
          ),
        ),
        body: TabBarView(
          children: [
            _buildAIScoring(),
            _buildExpertScoring(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertScoring() {
    return const Center(
      child: Text("Coming soon!"),
    );
  }

  Widget _buildAIScoring() {
    return Column(
      children: [
        _buildScoringOption(),
        _buildNumberQuetions(),
        _buildPrice(),
        _buildButtons(),
      ],
    );
  }

  Widget _buildScoringOption() {
    return Consumer<MyPracticeDetailProvider>(
        builder: (context, provider, child) {
      return Column(
        children: [
          _provider.isCanGroupScoring
              ? _createScoringOption(
                  isSelected: provider.isGroupScoring,
                  type: ScoringOptionType.groupScoring,
                  selectCallBack: () {
                    bool isSelected = !provider.isGroupScoring;
                    provider.updateIsGroupScoring(value: isSelected);
                    _calculatePrice();
                  },
                  showNoteCallBack: () {
                    if (kDebugMode) {
                      print("DEBUG: show group scoring note");
                    }
                  },
                )
              : Container(),
          _createScoringOption(
            isSelected: provider.isAllScoring,
            type: ScoringOptionType.allScoring,
            selectCallBack: () {
              bool isSelected = !provider.isAllScoring;
              provider.updateIsAllScoring(
                  isSelected: isSelected,
                  value1: _maxNumberQuestionOfPart1,
                  value2: _maxNumberQuestionOfPart2,
                  value3: _maxNumberQuestionOfPart3);
              _calculatePrice();
            },
            showNoteCallBack: () {
              if (kDebugMode) {
                print("DEBUG: show all scoring note");
              }
            },
          ),
          const Divider(color: AppColor.defaultPurpleColor),
        ],
      );
    });
  }

  Widget _createScoringOption({
    required bool isSelected,
    required ScoringOptionType type,
    required Function selectCallBack,
    required Function showNoteCallBack,
  }) {
    String title = "";
    if (type == ScoringOptionType.groupScoring) {
      title = "Chấm gộp câu trả lời";
    } else if (type == ScoringOptionType.allScoring) {
      title = "Chấm tất cả câu trả lời";
    }

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              selectCallBack();
            },
            child: Row(
              children: [
                Checkbox(
                  tristate: true,
                  value: isSelected,
                  onChanged: (_) {},
                  side: const BorderSide(
                    color: AppColor.defaultGrayColor,
                    width: 2,
                  ),
                  activeColor: AppColor.defaultPurpleColor,
                ),
                const SizedBox(width: 10),
                Text(title),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            showNoteCallBack();
          },
          child: const SizedBox(
            width: 50,
            height: 50,
            child: Center(
              child: Icon(
                Icons.info,
                size: 30,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberQuetions() {
    return Column(
      children: [
        _buildItem(0),
        _buildItem(1),
        _buildItem(2),
        const Divider(color: AppColor.defaultPurpleColor),
      ],
    );
  }

  Widget _buildItem(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            Utils.multiLanguage(_originalSettings[index].title)!,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.remove_circle_outline_outlined,
                size: 30,
              ),
              onPressed: () {
                double oldValue = _provider.getNumberOfPart(index);
                if (oldValue > 0) {
                  double newValue = oldValue - 1.0;
                  _provider.setNumberQuestionOfPart(
                      index: index, value: newValue, isInitData: false);
                  _calculatePrice();
                  _updateIsAllScoring(isAdd: false);
                }
              },
            ),
            Consumer<MyPracticeDetailProvider>(
              builder: (context, provider, child) {
                int fractionDigits = 0;
                return Container(
                  width: 80,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColor.defaultPurpleColor,
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        top: 5,
                        right: 10,
                        bottom: 5,
                      ),
                      child: Text(
                        provider
                            .getNumberOfPart(index)
                            .toStringAsFixed(fractionDigits),
                      ),
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.add_circle_outline_outlined,
                size: 30,
              ),
              onPressed: () {
                double oldValue = _provider.getNumberOfPart(index);
                int max = _getMaxNumberQuestionOfPart(index);
                if (oldValue < max) {
                  double newValue = oldValue + 1.0;
                  _provider.setNumberQuestionOfPart(
                      index: index, value: newValue, isInitData: false);
                  _calculatePrice();
                  _updateIsAllScoring(isAdd: true);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrice() {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 20),
            Text("Số kim cương cần:"),
            Expanded(child: Container()),
            Consumer<MyPracticeDetailProvider>(
                builder: (context, provider, child) {
              int totalPrice = provider.totalPrice;
              return Text(
                "$totalPrice",
                style: TextStyle(fontWeight: FontWeight.bold),
              );
            }),
            const SizedBox(width: 50),
            Icon(Icons.diamond, color: Colors.blue),
            const SizedBox(width: 10),
          ],
        ),
        Row(
          children: [
            const SizedBox(width: 20),
            Text("Số kim cương hiện có:"),
            Expanded(child: Container()),
            Consumer<MyPracticeDetailProvider>(
                builder: (context, provider, child) {
              int currentUsd = provider.currentUsd;
              return Text(
                "$currentUsd",
                style: TextStyle(fontWeight: FontWeight.bold),
              );
            }),
            const SizedBox(width: 50),
            Icon(Icons.diamond, color: Colors.blue),
            const SizedBox(width: 10),
          ],
        ),
        const Divider(color: AppColor.defaultPurpleColor),
      ],
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 10),
      child: Column(
        children: [
          _createScoringRequestButton(),
          const SizedBox(height: 10),
          _createCancelButton(),
        ],
      ),
    );
  }

  Widget _createScoringRequestButton() {
    return InkWell(
      onTap: () {
        if (kDebugMode) {
          print("DEBUG: Scoring request button tapped");
        }
      },
      child: Container(
        height: 44,
        decoration: BoxDecoration(
            color: AppColor.defaultPurpleColor,
            borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Consumer<MyPracticeDetailProvider>(
              builder: (context, provider, child) {
            int totalPrice = provider.totalPrice;
            return Text(
              "Gửi chấm với $totalPrice Kim cương",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: CustomSize.size_15,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _createCancelButton() {
    return InkWell(
      onTap: () {
        if (kDebugMode) {
          print("DEBUG: Cancel button tapped");
        }
        Navigator.of(context).pop();
      },
      child: Container(
        height: 44,
        decoration: BoxDecoration(
            border: Border.all(color: AppColor.defaultPurpleColor),
            borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(
            "Để sau",
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: CustomSize.size_15,
            ),
          ),
        ),
      ),
    );
  }

  void _calculatePrice() {
    Future.delayed(Duration.zero, () {
      late AiOption option;
      int totalPrice = 0;
      int totalTime = 0;
      bool isGroupScoring = _provider.isGroupScoring;
      bool isAllScoring = _provider.isAllScoring;

      if (isGroupScoring) {
        //ELSA price
        option =
            widget.listAiOption.where((element) => element.option == 1).first;
      } else {
        //Speech super price
        option =
            widget.listAiOption.where((element) => element.option == 2).first;
      }

      if (isAllScoring) {
        for (int i = 0; i < widget.parts.length; i++) {
          PartInfoModel part = widget.parts[i];
          if (part.numberOfQuestion > 0) {
            totalTime += part.numberOfQuestion * part.timeBlockForEachQuestion;
          }
        }
      } else {
        totalTime = _provider.numberQuestionOfPart1.toInt() *
                widget.parts[0].timeBlockForEachQuestion +
            _provider.numberQuestionOfPart2.toInt() *
                widget.parts[1].timeBlockForEachQuestion +
            _provider.numberQuestionOfPart3.toInt() *
                widget.parts[2].timeBlockForEachQuestion;
      }

      totalPrice = (totalTime / option.block!).ceil();
      _provider.updateTotalPrice(totalPrice);
    });
  }

  void _initData() async {
    PartInfoModel part1 =
        widget.parts.where((element) => element.type == PartType.part1).first;
    PartInfoModel part2 =
        widget.parts.where((element) => element.type == PartType.part2).first;
    PartInfoModel part3 =
        widget.parts.where((element) => element.type == PartType.part3).first;

    _originalSettings = [
      SettingModel(
        title: StringConstants.scoring_number_question_of_part_1,
        value: part1.numberOfQuestion.toDouble(),
        step: 1,
      ),
      SettingModel(
        title: StringConstants.scoring_number_question_of_part_2,
        value: part2.numberOfQuestion.toDouble(),
        step: 1,
      ),
      SettingModel(
        title: StringConstants.scoring_number_question_of_part_3,
        value: part3.numberOfQuestion.toDouble(),
        step: 1,
      ),
    ];

    _maxNumberQuestionOfPart1 = part1.numberOfQuestion;
    _maxNumberQuestionOfPart2 = part2.numberOfQuestion;
    _maxNumberQuestionOfPart3 = part3.numberOfQuestion;

    //InitData in MyPracticeDetailProvider
    _provider.setNumberQuestionOfPart(
        index: 0, value: part1.numberOfQuestion.toDouble(), isInitData: true);
    _provider.setNumberQuestionOfPart(
        index: 1, value: part2.numberOfQuestion.toDouble(), isInitData: true);
    _provider.setNumberQuestionOfPart(
        index: 2, value: part3.numberOfQuestion.toDouble(), isInitData: true);

    _calculatePrice();

    _currentUser = await Utils.getCurrentUser();
    if (null != _currentUser) {
      _provider.updateCurrentUsd(_currentUser!.profileModel.wallet.usd);
    }
  }

  int _getMaxNumberQuestionOfPart(int index) {
    switch (index) {
      case 0:
        return _maxNumberQuestionOfPart1;
      case 1:
        return _maxNumberQuestionOfPart2;
      case 2:
        return _maxNumberQuestionOfPart3;
    }
    return 0;
  }

  void _updateIsAllScoring({required bool isAdd}) {
    if (isAdd) {
      if (_provider.numberQuestionOfPart1 != _maxNumberQuestionOfPart1) return;
      if (_provider.numberQuestionOfPart2 != _maxNumberQuestionOfPart2) return;
      if (_provider.numberQuestionOfPart3 != _maxNumberQuestionOfPart3) return;
      _provider.updateIsAllScoring(
          isSelected: true, value1: null, value2: null, value3: null);
    } else {
      _provider.updateIsAllScoring(
          isSelected: false, value1: null, value2: null, value3: null);
    }
  }
}

enum PartType { part1, part2, part3 }

class PartInfoModel {
  late PartType type;
  late int numberOfQuestion;
  late int timeBlockForEachQuestion;

  PartInfoModel(PartType partType, int number, int timeBlock) {
    type = partType;
    numberOfQuestion = number;
    timeBlockForEachQuestion = timeBlock;
  }
}
