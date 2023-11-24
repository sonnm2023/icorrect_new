import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/provider/homework_provider.dart';

class HomeWorkWidget extends StatelessWidget {
  const HomeWorkWidget(
      {super.key,
      required this.homeWorkModel,
      required this.callBack,
      required this.homeWorkProvider});

  // final HomeWorkModel homeWorkModel;
  final ActivitiesModel homeWorkModel;
  final Function callBack;
  final HomeWorkProvider homeWorkProvider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CustomSize.size_10,
        // vertical: CustomSize.size_5,
      ),
      child: Card(
        elevation: 0,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(CustomSize.size_10),
              border: Border.all(
                color: AppColor.defaultPurpleColor,
                width: 0.5,
                style: BorderStyle.solid,
              )),
          child: ListTile(
            onTap: () {
              callBack(homeWorkModel);
            },
            contentPadding: const EdgeInsets.symmetric(
              horizontal: CustomSize.size_10,
              vertical: CustomSize.size_5,
            ),
            leading: Container(
              width: CustomSize.size_50,
              height: CustomSize.size_50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1.0,
                  color: AppColor.defaultPurpleColor,
                ),
                borderRadius: BorderRadius.circular(CustomSize.size_100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    StringConstants.part,
                    textAlign: TextAlign.center,
                    style: CustomTextStyle.textWithCustomInfo(
                      context: context,
                      color: AppColor.defaultPurpleColor,
                      fontsSize: FontsSize.fontSize_14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    Utils.getPartOfTestWithString(
                        homeWorkModel.activityTestOption),
                    style: CustomTextStyle.textWithCustomInfo(
                      context: context,
                      color: AppColor.defaultPurpleColor,
                      fontsSize: FontsSize.fontSize_14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: _activityNameWidget(context),
                ),
                const SizedBox(height: CustomSize.size_5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        (homeWorkModel.activityEndTime.isNotEmpty)
                            ? homeWorkModel.activityEndTime
                            : '0000-00-00 00:00',
                        style: CustomTextStyle.textWithCustomInfo(
                          context: context,
                          color: AppColor.defaultGrayColor,
                          fontsSize: FontsSize.fontSize_14,
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.clip,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: CustomSize.size_20,
                        ),
                        child: Text(
                          _statusOfActivity(context),
                          textAlign: TextAlign.right,
                          style: CustomTextStyle.textWithCustomInfo(
                            context: context,
                            color: _getColor(context),
                            fontsSize: FontsSize.fontSize_14,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _activityNameWidget(context) {
    return homeWorkModel.activityType == ActivityType.test.name ||
            homeWorkModel.activityType == ActivityType.exam.name
        ? Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "TEST: ",
                maxLines: 2,
                style: CustomTextStyle.textWithCustomInfo(
                  context: context,
                  color: AppColor.defaultBlackColor,
                  fontsSize: FontsSize.fontSize_15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.7,
                child: Text(
                  homeWorkModel.activityName,
                  maxLines: 2,
                  overflow: TextOverflow.clip,
                  style: CustomTextStyle.textWithCustomInfo(
                    context: context,
                    color: AppColor.defaultBlackColor,
                    fontsSize: FontsSize.fontSize_15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              )
            ],
          )
        : Text(
            homeWorkModel.activityName,
            maxLines: 2,
            style: CustomTextStyle.textWithCustomInfo(
              context: context,
              color: AppColor.defaultBlackColor,
              fontsSize: FontsSize.fontSize_15,
              fontWeight: FontWeight.w400,
            ),
          );
  }

  String _statusOfActivity(BuildContext context) {
    String status = Utils.getHomeWorkStatus(
        homeWorkModel, homeWorkProvider.serverCurrentTime)['title'];
    String aiStatus = Utils.haveAiResponse(homeWorkModel);
    if (aiStatus.isNotEmpty) {
      return "${status == StringConstants.activity_status_corrected ? '${Utils.multiLanguage(status)} &' : ''}"
          "${Utils.multiLanguage(aiStatus)}";
    } else {
      return Utils.multiLanguage(status);
    }
  }

  Color _getColor(BuildContext context) {
    String aiStatus = Utils.haveAiResponse(homeWorkModel);
    if (aiStatus.isNotEmpty) {
      return const Color.fromARGB(255, 12, 201, 110);
    } else {
      return Utils.getHomeWorkStatus(
          homeWorkModel, homeWorkProvider.serverCurrentTime)['color'];
    }
  }
}
