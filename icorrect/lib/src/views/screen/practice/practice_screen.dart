import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/views/screen/practice/topics_screen.dart';
import 'package:icorrect/src/views/widget/divider.dart';
import 'package:provider/provider.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_authProvider.isShowDialog) {
          GlobalKey<ScaffoldState> key = _authProvider.globalScaffoldKey;
          _authProvider.setShowDialogWithGlobalScaffoldKey(false, key);

          Navigator.of(key.currentState!.context).pop();
        } else {
          Queue<GlobalKey<ScaffoldState>> scaffoldKeys =
              _authProvider.scaffoldKeys;
          GlobalKey<ScaffoldState> key = scaffoldKeys.first;
          if (key == GlobalScaffoldKey.homeScreenScaffoldKey) {
            Utils.showLogoutConfirmDialog(
                context: context, homeWorkPresenter: null);
          } else {
            Navigator.of(key.currentState!.context).pop();
            scaffoldKeys.removeFirst();
          }
        }

        return false;
      },
      child: DefaultTabController(
        length: 1,
        child: Scaffold(
          key: GlobalScaffoldKey.practiceScreenScaffoldKey,
          appBar: AppBar(
            title: const Text(
              StringConstants.practice_screen_title,
              style: CustomTextStyle.appbarTitle,
            ),
            centerTitle: true,
            elevation: 0.0,
            iconTheme: const IconThemeData(
              color: AppColor.defaultPurpleColor,
            ),
            backgroundColor: AppColor.defaultWhiteColor,
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: CustomDivider(),
            ),
          ),
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildInPracticeCard(
                      context,
                      title: StringConstants.practice_card_part_1_title,
                      des: StringConstants.practice_card_part_1_description,
                    ),
                    _buildInPracticeCard(
                      context,
                      title: StringConstants.practice_card_part_2_title,
                      des: StringConstants.practice_card_part_2_description,
                    ),
                    _buildInPracticeCard(
                      context,
                      title: StringConstants.practice_card_part_3_title,
                      des: StringConstants.practice_card_part_3_description,
                    ),
                    _buildInPracticeCard(
                      context,
                      title: StringConstants.practice_card_part_2_3_title,
                      des: StringConstants.practice_card_part_2_3_description,
                    ),
                    _buildInPracticeCard(
                      context,
                      title: StringConstants.practice_card_full_test_title,
                      des: StringConstants.practice_card_full_test_description,
                    ),
                  ],
                ),
              )
            ],
          ),
          drawer: Utils.navbar(context: context, homeWorkPresenter: null),
          drawerEnableOpenDragGesture: false,
        ),
      ),
    );
  }
}

Widget _buildInPracticeCard(
  BuildContext context, {
  required String title,
  required String des,
}) {
  return GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TopicsScreen(),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: CustomSize.size_10, vertical: CustomSize.size_5),
      child: Card(
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: CustomSize.size_5,
            vertical: CustomSize.size_10,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColor.defaultPurpleColor,
              style: BorderStyle.solid,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(CustomSize.size_10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: CustomTextStyle.textBoldBlack_14(context),
              ),
              Text(
                des,
                style: CustomTextStyle.textGrey_14,
              )
            ],
          ),
        ),
      ),
    ),
  );
}
