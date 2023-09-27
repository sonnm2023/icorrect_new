import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/my_test_models/student_result_model.dart';
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';
import 'package:icorrect/src/presenters/special_homeworks_presenter.dart';
import 'package:icorrect/src/provider/simulator_test_provider.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/circle_loading.dart';
import 'package:icorrect/src/views/screen/test/my_test/student_detail_test/student_test_screen.dart';
import 'package:icorrect/src/views/widget/empty_widget.dart';
import 'package:provider/provider.dart';

class HighLightTab extends StatefulWidget {
  final SimulatorTestProvider provider;
  final ActivitiesModel homeWorkModel;

  const HighLightTab(
      {super.key, required this.provider, required this.homeWorkModel});

  @override
  State<HighLightTab> createState() => _HighLightTabState();
}

class _HighLightTabState extends State<HighLightTab>
    with AutomaticKeepAliveClientMixin<HighLightTab>
    implements SpecialHomeworksContracts {
  SpecialHomeworksPresenter? _presenter;
  CircleLoading? _loading;

  @override
  void initState() {
    super.initState();
    _presenter = SpecialHomeworksPresenter(this);
    _loading = CircleLoading();
    _getHighLightHomeWork();
  }

  void _getHighLightHomeWork() async {
    UserDataModel userDataModel =
        await Utils.getCurrentUser() ?? UserDataModel();
    if (kDebugMode) {
      print(
          "DEBUG: _getHighLightHomeWork ${widget.homeWorkModel.activityId.toString()}");
    }

    Future.delayed(
      Duration.zero,
      () {
        List<StudentResultModel> homeWorks = widget.provider.highLightHomeworks;
        if (homeWorks.isEmpty) {
          _loading?.show(context);
          _presenter!.getSpecialHomeWorks(
            context: context,
            email: userDataModel.userInfoModel.email.toString(),
            activityId: widget.homeWorkModel.activityId.toString(),
            status: Status.highLight.get,
            example: Status.highLight.get,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
        color: AppColor.defaultPurpleColor,
        onRefresh: () {
          return Future.delayed(
            const Duration(seconds: 1),
            () {
              _getHighLightHomeWork();
            },
          );
        },
        child: _buildHighLightList());
  }

  Widget _buildHighLightList() {
    return Consumer<SimulatorTestProvider>(
      builder: (context, provider, child) {
        if (provider.highLightHomeworks.isNotEmpty) {
          return ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(CustomSize.size_5),
            itemCount: provider.highLightHomeworks.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  StudentResultModel resultModel =
                      provider.highLightHomeworks.elementAt(index);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StudentTestDetail(studentResultModel: resultModel),
                    ),
                  );
                },
                child: _highlightItem(
                  provider.highLightHomeworks.elementAt(index),
                ),
              );
            },
          );
        } else {
          return EmptyWidget.init().buildNothingWidget(
            'No data, please come back later!',
            widthSize: CustomSize.size_100,
            heightSize: CustomSize.size_100,
          );
        }
      },
    );
  }

  Widget _highlightItem(StudentResultModel resultModel) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CustomSize.size_5,
        vertical: CustomSize.size_5,
      ),
      margin: const EdgeInsets.only(
        top: CustomSize.size_20,
        left: CustomSize.size_10,
        right: CustomSize.size_10,
      ),
      decoration: BoxDecoration(
          color: AppColor.defaultWhiteColor,
          borderRadius: BorderRadius.circular(CustomSize.size_10),
          border: Border.all(
            color: AppColor.defaultPurpleColor,
            style: BorderStyle.solid,
            width: 0.5,
          )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const SizedBox(
                height: CustomSize.size_50,
                child: CircleAvatar(
                  foregroundImage: AssetImage(AppAsset.defaultAvt),
                  radius: CustomSize.size_30,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: CustomSize.size_5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resultModel.students!.name.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyle.textBoldBlack_14,
                    ),
                    const SizedBox(height: CustomSize.size_5),
                    Text(
                      resultModel.createdAt.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyle.textGrey_14,
                    )
                  ],
                ),
              )
            ],
          ),
          Text(
            Utils.scoreReponse(resultModel)['score'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Utils.scoreReponse(resultModel)['color'],
                fontSize: 15,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  void getSpecialHomeWork(List<StudentResultModel> studentsResults) {
    if (kDebugMode) {
      print('DEBUG: getSpecialHomeWork ${studentsResults.length}');
    }
    widget.provider.setHighLightHomeworks(studentsResults);
    _loading?.hide();
  }

  @override
  void getSpecialHomeWorksFail(String message) {
    _loading?.hide();
    Fluttertoast.showToast(
        msg: message,
        backgroundColor: AppColor.defaultGrayColor,
        textColor: Colors.black);
  }

  @override
  bool get wantKeepAlive => true;
}
