import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/app_color.dart';
import '../../../../data_sources/constants.dart';
import '../../../../data_sources/utils.dart';
import '../../../../provider/ielts_topics_provider.dart';
import 'ielts_each_part_topics.dart';

class IELTSFullPartTopics extends StatefulWidget {
  IELTSFullPartTopics({super.key});

  @override
  State<IELTSFullPartTopics> createState() => _IELTSFullPartTopicsState();
}

class _IELTSFullPartTopicsState extends State<IELTSFullPartTopics> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          iconTheme: const IconThemeData(
            color: AppColor.defaultPurpleColor,
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColor.defaultPurpleColor,
                  ),
                ),
              ),
              child: _tabBar,
            ),
          ),
          backgroundColor: AppColor.defaultWhiteColor,
        ),
        body: TabBarView(
          children: _tabBarView(),
        ),
      ),
    );
  }

  TabBar get _tabBar {
    return TabBar(
      physics: const BouncingScrollPhysics(),
      isScrollable: false,
      indicatorPadding: const EdgeInsets.only(top: 10),
      indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            width: 3.0,
            color: AppColor.defaultPurpleColor,
          ),
          insets: EdgeInsets.symmetric(horizontal: 100.0)),
      tabs: _tabsLabel(),
    );
  }

  _tabsLabel() {
    return [
      Tab(
        height: 40,
        child: Text(
          Utils.multiLanguage(StringConstants.practice_card_part_1_title),
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColor.defaultBlackColor,
            fontsSize: FontsSize.fontSize_16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      Tab(
        height: 40,
        child: Text(
          Utils.multiLanguage(StringConstants.practice_card_part_2_3_title),
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColor.defaultBlackColor,
            fontsSize: FontsSize.fontSize_16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ];
  }

  _tabBarView() {
    return [
      ChangeNotifierProvider(
          create: (_) => IELTSTopicsProvider(),
          child: IELTSEachPartTopics(topicTypes: IELTSTopicType.part1.get)),
      ChangeNotifierProvider(
          create: (_) => IELTSTopicsProvider(),
          child: IELTSEachPartTopics(topicTypes: IELTSTopicType.part2and3.get))
    ];
  }
}
