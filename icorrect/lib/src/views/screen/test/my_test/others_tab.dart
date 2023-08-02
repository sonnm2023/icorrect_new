import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect/src/models/my_test_models/student_result_model.dart';
import 'package:provider/provider.dart';

import '../../../../../core/app_asset.dart';
import '../../../../../core/app_color.dart';
import '../../../../data_sources/constant_strings.dart';
import '../../../../data_sources/utils.dart';
import '../../../../models/user_data_models/user_data_model.dart';
import '../../../../presenters/special_homeworks_presenter.dart';
import '../../../../provider/my_test_provider.dart';
import '../../../widget/default_text.dart';
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
              return _othersItem(provider.otherLightHomeWorks.elementAt(index));
            });
      } else {
        return EmptyWidget.init().buildNothingWidget(
            'Nothing other homeworks in here',
            widthSize: 100,
            heightSize: 100);
      }
    });
  }

  Widget _othersItem(StudentResultModel resultModel) {
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
          ),
          DefaultText(
            text: resultModel.overallScore.toString(),
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
    _loading?.hide();
    widget.provider.setOtherLightHomeWorks(studentsResults);
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
