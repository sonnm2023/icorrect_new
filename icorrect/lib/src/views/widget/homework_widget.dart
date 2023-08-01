import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';

class HomeWorkWidget extends StatelessWidget {
  const HomeWorkWidget({super.key, required this.homeWorkModel, required this.callBack});

  // final HomeWorkModel homeWorkModel;
  final ActivitiesModel homeWorkModel;
  final Function callBack;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        child: ListTile(
          onTap: () {
            callBack(homeWorkModel);
          },
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          leading: Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: AppColor.defaultPurpleColor),
              borderRadius: const BorderRadius.all(
                Radius.circular(100),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Part",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColor.defaultPurpleColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 8,
                  ),
                ),
                Text(
                  // Utils.getPartOfTest(homeWorkModel.testOption), //TODO
                  "PART",
                  style: const TextStyle(
                    color: AppColor.defaultPurpleColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                child: Text(
                  // homeWorkModel.name,
                  homeWorkModel.activityName,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    (homeWorkModel.activityEndTime.isNotEmpty)
                        ? homeWorkModel.activityEndTime
                        : '0000-00-00 00:00',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    (Utils.getHomeWorkStatus(homeWorkModel).isNotEmpty)
                        ? '${Utils.getHomeWorkStatus(homeWorkModel)['title']} ${Utils.haveAiResponse(homeWorkModel)}'
                        : '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: (Utils.getHomeWorkStatus(homeWorkModel)
                              .isNotEmpty)
                          ? Utils.getHomeWorkStatus(
                              homeWorkModel)['color']
                          : AppColor.defaultPurpleColor,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
