import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';

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

  bool _isChamGop = false;
  bool _isChamAll = false;

  void _changeChamGopValue(bool value) {
    _isChamGop = value;
  }

  void _changeChamAllValue(bool value) {
    _isChamAll = value;
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
        Row(
          children: [
            Checkbox(
              tristate: true,
              value: _isChamGop,
              onChanged: (value) {
                _changeChamGopValue(value!);
              },
              side: const BorderSide(
                color: AppColor.defaultGrayColor,
                width: 2,
              ),
              activeColor: AppColor.defaultPurpleColor,
            ),
            const SizedBox(width: 10),
            Text("Chấm gộp câu trả lời"),
            const SizedBox(width: 10),
            InkWell(
              onTap: () {
                if (kDebugMode) {
                  print("DEBUG: Cham gop tapped");
                }
              },
              child: SizedBox(
                width: 50,
                height: 50,
                child: Center(
                  child: Icon(
                    Icons.info,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
