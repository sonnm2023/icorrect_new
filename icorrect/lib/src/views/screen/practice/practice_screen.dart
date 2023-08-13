import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/views/screen/practice/topics_screen.dart';
import 'package:path/path.dart';
import '../../../../core/app_color.dart';
import '../../widget/divider.dart';
import '../../widget/drawer_items.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  @override
  Widget build(BuildContext context) {
    final drawerItems = items(context);
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: CustomDivider(),
          ),
          title: const Text(
            "Practice",
            style: TextStyle(color: AppColor.defaultPurpleColor),
          ),
          centerTitle: true,
          elevation: 0.0,
          iconTheme: const IconThemeData(color: AppColor.defaultPurpleColor),
          // bottom: PreferredSize(
          //   preferredSize: _tabBar.preferredSize,
          //   child: Material(
          //     color: defaultWhiteColor,
          //     child: _tabBar,
          //   ),
          // ),
          backgroundColor: AppColor.defaultWhiteColor,
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
                    title: 'Part I',
                    des: 'Examiner will ask general questions on familar topic',
                  ),
                  _buildInPracticeCard(
                    context,
                    title: 'Part II',
                    des:
                        'Test ability to talk about a topic, develop your ideas about a topic and relevant',
                  ),
                  _buildInPracticeCard(
                    context,
                    title: 'Part III',
                    des:
                        'Examiner will ask you talk about topics and include the point that you can cover',
                  ),
                  _buildInPracticeCard(
                    context,
                    title: 'Part II and III',
                    des:
                        'You will take test of part II and Ill with same topic',
                  ),
                  _buildInPracticeCard(
                    context,
                    title: 'Full test',
                    des:
                        'You will take a full sample test of lelts Speaking Test',
                  ),
                ],
              ),
            )
          ],
        ),
        drawer: Drawer(
          backgroundColor: AppColor.defaultWhiteColor,
          child: drawerItems,
        ),
        drawerEnableOpenDragGesture: false,
      ),
    );
  }
}

Widget _buildInPracticeCard(BuildContext context,{required String title, required String des}) {
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
                style: CustomTextStyle.textBoldBlack_14,
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
