import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/views/screen/bank_list/topics_bank_list.dart';

class BankDetailList extends StatefulWidget {
  const BankDetailList({super.key});

  @override
  State<BankDetailList> createState() => _BankDetailListState();
}

class _BankDetailListState extends State<BankDetailList> {
  double w = 0, h = 0;
  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
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
          title: _buildHeader(),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
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
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            TabBarView(
              children: _tabBarView(),
            ),
            Container(
              color: AppColor.defaultPurpleColor,
              height: 50,
              width: w,
              alignment: Alignment.center,
              child: Text(
                Utils.multiLanguage(StringConstants.start_to_pratice),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      child: Stack(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
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
              "Class 7 Global Success",
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
        insets: EdgeInsets.symmetric(
          horizontal: 100.0,
        ),
      ),
      tabs: _tabsLabel(),
    );
  }

  _tabsLabel() {
    return [
      Tab(
        height: 40,
        child: Text(
          Utils.multiLanguage(StringConstants.topic_tab_title),
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColor.defaultPurpleColor,
            fontsSize: FontsSize.fontSize_16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      Tab(
        height: 40,
        child: Text(
          Utils.multiLanguage(StringConstants.practice_setting),
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColor.defaultPurpleColor,
            fontsSize: FontsSize.fontSize_16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ];
  }

  _tabBarView() {
    return [TopicsBankList(), Container()];
  }
}
