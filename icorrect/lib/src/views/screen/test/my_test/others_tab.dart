import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/my_test_models/student_result_model.dart';
import 'package:icorrect/src/views/screen/test/my_test/student_detail_test/student_test_screen.dart';
import 'package:provider/provider.dart';

import '../../../../../core/app_asset.dart';
import '../../../../../core/app_color.dart';
import '../../../../data_sources/constants.dart';
import '../../../../data_sources/utils.dart';
import '../../../../models/user_data_models/user_data_model.dart';
import '../../../../presenters/special_homeworks_presenter.dart';
import '../../../../provider/my_test_provider.dart';
import '../../../widget/empty_widget.dart';
import '../../other_views/dialog/circle_loading.dart';

class OtherTab extends StatefulWidget {
  MyTestProvider provider;
  ActivitiesModel homeWorkModel;

  OtherTab({super.key, required this.provider, required this.homeWorkModel});

  @override
  State<OtherTab> createState() => _OtherTabState();
}

class _OtherTabState extends State<OtherTab>
    with AutomaticKeepAliveClientMixin<OtherTab>
    implements SpecialHomeworksContracts {
  SpecialHomeworksPresenter? _presenter;
  CircleLoading? _loading;

  @override
  void initState() {
    super.initState();
    _presenter = SpecialHomeworksPresenter(this);
    _loading = CircleLoading();
    _getOthersHomeWork();
    _loading?.show(context);
  }

  void _getOthersHomeWork() async {
    UserDataModel userDataModel =
        await Utils.getCurrentUser() ?? UserDataModel();
    _presenter!.getSpecialHomeWorks(
        email: userDataModel.userInfoModel.email.toString(),
        activityId: widget.homeWorkModel.activityId.toString(),
        status: Status.allHomework.get,
        example: Status.others.get);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
        color: AppColor.defaultPurpleColor,
        onRefresh: () {
          return Future.delayed(const Duration(seconds: 1), () {
            _loading!.show(context);
            _getOthersHomeWork();
          });
        },
        child: _buildOthersHomeWorksList());
  }

  Widget _buildOthersHomeWorksList() {
    return Consumer<MyTestProvider>(builder: (context, provider, child) {
      if (provider.otherLightHomeWorks.isNotEmpty) {
        return ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            itemCount: provider.otherLightHomeWorks.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  StudentResultModel resultModel =
                      provider.otherLightHomeWorks.elementAt(index);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StudentTestDetail(
                              studentResultModel: resultModel)));
                },
                child:
                    _othersItem(provider.otherLightHomeWorks.elementAt(index)),
              );
            });
      } else {
        return EmptyWidget.init().buildNothingWidget(
            'Nothing other homeworks in here',
            widthSize: CustomSize.size_100,
            heightSize: CustomSize.size_100);
      }
    });
  }

  Widget _othersItem(StudentResultModel resultModel) {
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
                    const SizedBox(
                      height: CustomSize.size_5
                    ),
                    Text(
                      resultModel.createdAt.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyle.textGrey_14,
                    )
                  ],
                ),
              ),
            ],
          ),
          Text(
            resultModel.aiScore.toString().isNotEmpty
                ? resultModel.aiScore.toString()
                : resultModel.overallScore.toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CustomTextStyle.textBoldGreen_15,
          ),
        ],
      ),
    );
  }

  @override
  void getSpecialHomeWork(List<StudentResultModel> studentsResults) {
    _loading?.hide();
    widget.provider.setOtherLightHomeWorks(studentsResults);
  }

  @override
  void getSpecialHomeWorksFail(String message) {
    _loading?.hide();
    Fluttertoast.showToast(
        msg: message,
        backgroundColor: AppColor.defaultGrayColor,
        textColor: Colors.black,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM);
  }

  @override
  bool get wantKeepAlive => true;
}
