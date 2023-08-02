import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/src/data_sources/constant_strings.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/homework_models/homework_model.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/my_test_models/student_result_model.dart';
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';
import 'package:icorrect/src/presenters/special_homeworks_presenter.dart';
import 'package:icorrect/src/provider/my_test_provider.dart';
import 'package:icorrect/src/views/screen/test/my_test/student_detail_test/student_test_screen.dart';
import 'package:icorrect/src/views/widget/default_text.dart';
import 'package:icorrect/src/views/widget/empty_widget.dart';
import 'package:provider/provider.dart';

import '../../../../../core/app_color.dart';
import '../../other_views/dialog/circle_loading.dart';

class HighLightTab extends StatefulWidget {
  MyTestProvider provider;
  ActivitiesModel homeWorkModel;
  HighLightTab(
      {super.key, required this.provider, required this.homeWorkModel});

  @override
  State<HighLightTab> createState() => _HighLightTabState();
}

class _HighLightTabState extends State<HighLightTab>
    implements SpecialHomeworksContracts {
  SpecialHomeworksPresenter? _presenter;
  CircleLoading? _loading;

  @override
  void initState() {
    super.initState();
    _presenter = SpecialHomeworksPresenter(this);
    _loading = CircleLoading();
    _getHighLightHomeWork();
    _loading?.show(context);
  }

  void _getHighLightHomeWork() async {
    UserDataModel userDataModel =
        await Utils.getCurrentUser() ?? UserDataModel();
    if (kDebugMode) {
      print(
          "DEBUG: _getHighLightHomeWork ${widget.homeWorkModel.activityId.toString()}");
    }
    _presenter!.getSpecialHomeWorks(
        email: userDataModel.userInfoModel.email.toString(),
        activityId: widget.homeWorkModel.activityId.toString(),
        status: Status.allHomework.get,
        example: Status.highLight.get);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        color: AppColor.defaultPurpleColor,
        onRefresh: () {
          return Future.delayed(const Duration(seconds: 1), () {
            _loading!.show(context);
            _getHighLightHomeWork();
          });
        },
        child: _buildHighLightList());
  }

  Widget _buildHighLightList() {
    return Consumer<MyTestProvider>(builder: (context, provider, child) {
      if (provider.highLightHomeworks.isNotEmpty) {
        return ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            itemCount: provider.highLightHomeworks.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  StudentResultModel resultModel =
                      provider.highLightHomeworks.elementAt(index);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StudentTestDetail(
                              studentResultModel: resultModel)));
                },
                child: _highlightItem(
                    provider.highLightHomeworks.elementAt(index)),
              );
            });
      } else {
        return EmptyWidget.init().buildNothingWidget(
            'Nothing HighLight Homeworks in here',
            widthSize: 100,
            heightSize: 100);
      }
    });
  }

  Widget _highlightItem(StudentResultModel resultModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              blurRadius: 0.3,
              spreadRadius: 0.3,
            )
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                foregroundImage: AssetImage(AppAsset.defaultAvt),
                radius: 30,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultText(
                      text: resultModel.students!.name.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 10),
                    DefaultText(
                      text: resultModel.createdAt.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color: AppColor.defaultGrayColor,
                    )
                  ],
                ),
              )
            ],
          ),
          DefaultText(
            text: resultModel.aiScore.toString().isNotEmpty
                ? resultModel.aiScore.toString()
                : resultModel.overallScore.toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Colors.green,
          )
        ],
      ),
    );
  }

  @override
  void getSpecialHomeWork(List<StudentResultModel> studentsResults) {
    if (kDebugMode) {
      print('DEBUG: getSpecialHomeWork ${studentsResults.length}');
    }
    _loading?.hide();
    widget.provider.setHighLightHomeworks(studentsResults);
  }

  @override
  void getSpecialHomeWorksFail(String message) {
    _loading?.hide();
    Fluttertoast.showToast(
        msg: message,
        backgroundColor: AppColor.defaultGrayColor,
        textColor: Colors.black);
  }
}
