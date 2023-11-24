import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:icorrect/src/models/auth_models/topic_id.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/provider/ielts_topics_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../core/app_color.dart';
import '../../../../data_sources/constants.dart';
import '../../../../data_sources/utils.dart';
import '../../../../models/practice_model/ielts_topic_model.dart';
import '../../../../models/user_data_models/user_data_model.dart';
import '../../../../presenters/ielts_topics_list_presenter.dart';
import '../../../widget/divider.dart';
import '../../other_views/dialog/circle_loading.dart';
import '../../other_views/dialog/message_dialog.dart';

class IELTSEachPartTopics extends StatefulWidget {
  List<String> topicTypes;
  IELTSEachPartTopics({required this.topicTypes, super.key});

  @override
  State<IELTSEachPartTopics> createState() => _IELTSEachPartTopicsState();
}

class _IELTSEachPartTopicsState extends State<IELTSEachPartTopics>
    with AutomaticKeepAliveClientMixin<IELTSEachPartTopics>
    implements IELTSTopicsListConstract {
  IELTSTopicsProvider? _ieltsTopicsProvider;
  CircleLoading? _loading;
  IELTSTopicsListPresenter? _presenter;
  AuthProvider? _authProvider;

  @override
  void initState() {
    super.initState();
    _loading = CircleLoading();
    _presenter = IELTSTopicsListPresenter(this);
    _ieltsTopicsProvider =
        Provider.of<IELTSTopicsProvider>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);

    _loading!.show(context: context, isViewAIResponse: false);
    _getTopicsList();
  }

  Future<void> _getTopicsList() async {
    UserDataModel? currentUser = await Utils.getCurrentUser();
    if (currentUser != null) {
      String status = "";
      if (widget.topicTypes == IELTSTopicType.full.get) {
        widget.topicTypes = [];
        status = IELTSStatus.fullPart.get;
      }
      _presenter!.getIELTSTopicsList(widget.topicTypes, status);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<IELTSTopicsProvider>(builder: (context, provider, child) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: CustomSize.size_10,
            ),
            color: AppColor.defaultLight01GrayColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Checkbox(
                    tristate: true,
                    activeColor: AppColor.defaultPurpleColor,
                    value:
                        provider.topicsId.length == provider.topicsList.length,
                    onChanged: (bool? value) {
                      if (value ?? false) {
                        provider.addAllTopics();
                      } else {
                        provider.clearTopicSelection();
                      }
                    },
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    context.formatString(StringConstants.selected_topics,
                        [provider.topicsId.length, provider.topicsList.length]),
                    style: CustomTextStyle.textWithCustomInfo(
                      context: context,
                      color: AppColor.defaultBlackColor,
                      fontsSize: FontsSize.fontSize_15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: TextButton(
                    onPressed: () {
                      provider.clearTopicSelection();
                    },
                    child: Text(
                      StringConstants.clear_button_title,
                      style: CustomTextStyle.textWithCustomInfo(
                        context: context,
                        color: AppColor.defaultPurpleColor,
                        fontsSize: FontsSize.fontSize_15,
                        fontWeight: FontWeight.bold,
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
            itemCount: provider.topicsList.length,
            itemBuilder: (context, index) {
              IELTSTopicModel topicModel = provider.topicsList[index];
              return _buildInTopicCard(
                context,
                ieltsTopicModel: topicModel,
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const CustomDivider(),
          )),
        ],
      );
    });
  }

  Widget _buildInTopicCard(BuildContext context,
      {required IELTSTopicModel ieltsTopicModel}) {
    return Consumer<IELTSTopicsProvider>(builder: (context, provider, child) {
      bool isChecked = provider.topicsId.contains(ieltsTopicModel.id);
      return InkWell(
        onTap: () {
          int option = Utils.getTestOption(widget.topicTypes);
          if (isChecked) {
            provider.removeTopicId(ieltsTopicModel.id);
            _authProvider!.removeTopicId(
                TopicId(id: ieltsTopicModel.id, testOption: option));
          } else {
            provider.setTopicSelection(ieltsTopicModel.id);
            _authProvider!.addTopicId(
                TopicId(id: ieltsTopicModel.id, testOption: option));
          }
        },
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
                Expanded(
                  flex: 1,
                  child: Checkbox(
                    tristate: true,
                    activeColor: AppColor.defaultPurpleColor,
                    value: isChecked,
                    onChanged: (bool? value) {
                      if (value ?? false) {
                        provider.setTopicSelection(ieltsTopicModel.id);
                      } else {
                        provider.removeTopicId(ieltsTopicModel.id);
                      }
                    },
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    ieltsTopicModel.title.toUpperCase(),
                    style: CustomTextStyle.textWithCustomInfo(
                      context: context,
                      color: AppColor.defaultBlackColor,
                      fontsSize: FontsSize.fontSize_14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                // const Expanded(
                //   flex: 1,
                //   child: IconButton(
                //     icon: Icon(
                //       Icons.download,
                //       color: AppColor.defaultBlackColor,
                //       size: CustomSize.size_30,
                //     ),
                //     onPressed: null,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  void getIELTSTopicsFail(String message) {
    _loading!.hide();
    showDialog(
      context: context,
      builder: (builder) {
        return MessageDialog.alertDialog(context, message);
      },
    );
  }

  @override
  void getIELTSTopicsSuccess(List<IELTSTopicModel> topicsList) {
    _loading!.hide();
    _ieltsTopicsProvider!.setIELTSTopics(topicsList);
  }

  @override
  bool get wantKeepAlive => true;
}
