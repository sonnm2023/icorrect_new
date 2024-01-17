import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/my_practice_test_model/setting_model.dart';
import 'package:provider/provider.dart';

enum ScoringOptionType { groupScoring, allScoring }

class ScoringOrderSettingWidget extends StatefulWidget {
  const ScoringOrderSettingWidget({super.key});

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

  bool _isGroupScoring = false;
  bool _isAllScoring = false;
  late List<SettingModel> _originalSettings = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    _originalSettings = [
      SettingModel(
        title: StringConstants.number_question_of_part_1,
        value: 1,
        step: 1,
      ),
      SettingModel(
        title: StringConstants.number_question_of_part_2,
        value: 1,
        step: 1,
      ),
      SettingModel(
        title: StringConstants.number_question_of_part_3,
        value: 1,
        step: 1,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 60.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
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
    return Column(
      children: [
        _createScoringOption(
          isSelected: _isGroupScoring,
          type: ScoringOptionType.groupScoring,
          selectCallBack: () {
            bool isSelected = !_isGroupScoring;
            _changeGroupScoringStatus(isSelected);
          },
          showNoteCallBack: () {
            if (kDebugMode) {
              print("DEBUG: show group scoring note");
            }
          },
        ),
        _createScoringOption(
          isSelected: _isAllScoring,
          type: ScoringOptionType.allScoring,
          selectCallBack: () {
            bool isSelected = !_isAllScoring;
            _changeAllScoringStatus(isSelected);
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
              onPressed: () {},
            ),
            Consumer(builder: (context, provider, child) {
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
                      _originalSettings[index]
                          .value
                          .toStringAsFixed(fractionDigits),
                    ),
                  ),
                ),
              );
            }),
            IconButton(
              icon: const Icon(
                Icons.add_circle_outline_outlined,
                size: 30,
              ),
              onPressed: () {},
            ),
          ],
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

  Widget _buildPrice() {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 20),
            Text("Số kim cương cần:"),
            Expanded(child: Container()),
            Text("100"),
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
            Text("100"),
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
          child: Text(
            "Gửi chấm với 10 Kim cương",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: CustomSize.size_15,
            ),
          ),
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

  void _changeGroupScoringStatus(bool value) {
    setState(() {
      _isGroupScoring = value;
    });
  }

  void _changeAllScoringStatus(bool value) {
    setState(() {
      _isAllScoring = value;
    });
  }
}
