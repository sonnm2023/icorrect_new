import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/views/widget/divider.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: CustomDivider(),
          ),
          title: Text(
            Utils.multiLanguage(StringConstants.topics_screen_title),
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
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CustomSize.size_10,
                    ),
                    color: AppColor.defaultLightGrayColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          flex: 1,
                          child: IconButton(
                            icon: Icon(
                              Icons.check_box_outlined,
                              color: AppColor.defaultPurpleColor,
                              size: CustomSize.size_30,
                            ),
                            onPressed: null,
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            Utils.multiLanguage(StringConstants.selected_topics),
                            style: CustomTextStyle.textWithCustomInfo(
                              context: context,
                              color: AppColor.defaultBlackColor,
                              fontsSize: FontsSize.fontSize_14,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              Utils.multiLanguage(StringConstants.clear_button_title),
                              style: CustomTextStyle.textWithCustomInfo(
                                context: context,
                                color: AppColor.defaultPurpleColor,
                                fontsSize: FontsSize.fontSize_14,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: 25,
                      itemBuilder: (context, index) => _buildInTopicCard(
                        context,
                        topic: 'topic $index',
                      ),
                      separatorBuilder: (BuildContext context, int index) =>
                          const CustomDivider(),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget _buildInTopicCard(BuildContext context, {required String topic}) {
  return GestureDetector(
    onTap: () {},
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CustomSize.size_5,
      ),
      child: Card(
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              flex: 1,
              child: IconButton(
                icon: Icon(
                  Icons.check_box_outlined,
                  color: AppColor.defaultPurpleColor,
                  size: CustomSize.size_30,
                ),
                onPressed: null,
              ),
            ),
            Expanded(
              flex: 4,
              child: Text(
                topic,
                style: CustomTextStyle.textWithCustomInfo(
                  context: context,
                  color: AppColor.defaultBlackColor,
                  fontsSize: FontsSize.fontSize_14,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            const Expanded(
              flex: 1,
              child: IconButton(
                icon: Icon(
                  Icons.download_outlined,
                  color: AppColor.defaultGrayColor,
                  size: CustomSize.size_30,
                ),
                onPressed: null,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
