import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';

class TopicsBankList extends StatefulWidget {
  const TopicsBankList({super.key});

  @override
  State<TopicsBankList> createState() => _TopicsBankListState();
}

class _TopicsBankListState extends State<TopicsBankList> {
  double w = 0, h = 0;
  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Column(
      children: [
        _buildSelectionInfo(),
        Container(
          height: h - 200,
          padding: const EdgeInsets.only(bottom: 50),
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: 100,
              itemBuilder: (context, index) {
                return _buildTopicItem();
              }),
        )
      ],
    );
  }

  Widget _buildSelectionInfo() {
    return Container(
      color: AppColor.defaultGraySlightColor,
      padding: const EdgeInsets.all(10),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Icon(Icons.check_box, color: AppColor.defaultPurpleColor),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              "Selected (4/6)",
              style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTopicItem() {
    return InkWell(
      onTap: () {},
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.check_box, color: AppColor.defaultPurpleColor),
                const SizedBox(width: 10),
                Text(
                  "Unit 1: Family Life",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 5),
          const Divider(
            thickness: 1,
            height: 1,
            color: AppColor.defaultPurpleColor,
          )
        ],
      ),
    );
  }
}
