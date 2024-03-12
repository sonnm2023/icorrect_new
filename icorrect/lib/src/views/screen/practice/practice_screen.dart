import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/provider/ielts_part_list_screen_provider.dart';
import 'package:icorrect/src/views/screen/practice/topics_list/ielts_part_list_screen.dart';
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
    Future.delayed(Duration.zero, () {
      _authProvider.setGlobalScaffoldKey(
        GlobalScaffoldKey.practiceScreenScaffoldKey,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Utils.multiLanguage(StringConstants.practice_screen_title)!,
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
                const SizedBox(height: 20),
                _buildInPracticeCard(
                  context,
                  title: Utils.multiLanguage(
                      StringConstants.practice_card_part_1_title)!,
                  des: Utils.multiLanguage(
                      StringConstants.practice_card_part_1_description)!,
                  partType: IELTSPartType.part1,
                ),
                _buildInPracticeCard(
                  context,
                  title: Utils.multiLanguage(
                      StringConstants.practice_card_part_2_title)!,
                  des: Utils.multiLanguage(
                      StringConstants.practice_card_part_2_description)!,
                  partType: IELTSPartType.part2,
                ),
                _buildInPracticeCard(
                  context,
                  title: Utils.multiLanguage(
                      StringConstants.practice_card_part_3_title)!,
                  des: Utils.multiLanguage(
                      StringConstants.practice_card_part_3_description)!,
                  partType: IELTSPartType.part3,
                ),
                _buildInPracticeCard(
                  context,
                  title: Utils.multiLanguage(
                      StringConstants.practice_card_part_2_3_title)!,
                  des: Utils.multiLanguage(
                      StringConstants.practice_card_part_2_3_description)!,
                  partType: IELTSPartType.part2and3,
                ),
                _buildInPracticeCard(
                  context,
                  title: Utils.multiLanguage(
                      StringConstants.practice_card_full_test_title)!,
                  des: Utils.multiLanguage(
                      StringConstants.practice_card_full_test_description)!,
                  partType: IELTSPartType.full,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

Widget _buildInPracticeCard(BuildContext context,
    {required String title,
    required String des,
    required IELTSPartType partType}) {
  return GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => IELTSPartListScreenProvider(),
          child: IELTSPartListScreen(partType: partType),
        ),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CustomSize.size_10,
        vertical: CustomSize.size_5,
      ),
      child: Card(
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: CustomSize.size_5,
            vertical: CustomSize.size_10,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColor.defaultGraySlightColor,
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
                style: CustomTextStyle.textWithCustomInfo(
                  context: context,
                  color: AppColor.defaultBlackColor,
                  fontsSize: FontsSize.fontSize_16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                des,
                style: CustomTextStyle.textWithCustomInfo(
                  context: context,
                  color: AppColor.defaultGrayColor,
                  fontsSize: FontsSize.fontSize_15,
                  fontWeight: FontWeight.w400,
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}
