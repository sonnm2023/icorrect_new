import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/auth_models/topic_id.dart';
import 'package:icorrect/src/models/practice_model/ielts_topic_model.dart';
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';
import 'package:icorrect/src/presenters/ielts_topics_list_presenter.dart';
import 'package:icorrect/src/provider/ielts_individual_part_screen_provider.dart';
import 'package:icorrect/src/provider/ielts_part_list_screen_provider.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/circle_loading.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/custom_alert_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/message_dialog.dart';
import 'package:icorrect/src/views/widget/divider.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class IELTSIndividualPartScreen extends StatefulWidget {
  IELTSIndividualPartScreen({required this.partType, super.key});
  IELTSPartType partType;

  @override
  State<IELTSIndividualPartScreen> createState() => _IELTSIndividualPartScreenState();
}

class _IELTSIndividualPartScreenState extends State<IELTSIndividualPartScreen>
    with AutomaticKeepAliveClientMixin<IELTSIndividualPartScreen>
    implements IELTSTopicsListConstract {
  double w = 0, h = 0;
  // IELTSIndividualPartScreenProvider? _ieltsTopicsProvider;
  CircleLoading? _loading;
  IELTSTopicsListPresenter? _presenter;
  IELTSPartListScreenProvider? _provider;

  @override
  void initState() {
    super.initState();
    _loading = CircleLoading();
    _presenter = IELTSTopicsListPresenter(this);
    // _ieltsTopicsProvider =
    //     Provider.of<IELTSIndividualPartScreenProvider>(context, listen: false);
    _provider = Provider.of<IELTSPartListScreenProvider>(context, listen: false);

    _loading!.show(context: context, isViewAIResponse: false);
    _getTopicsList();
  }

  Future<void> _getTopicsList() async {
    UserDataModel? currentUser = await Utils.getCurrentUser();
    if (currentUser != null) {
      String status = "";
      if (widget.topicTypes == IELTSPartType.full.get) {
        widget.topicTypes = [];
        status = IELTSStatus.fullPart.get;
      }
      _presenter!.getIELTSTopicList(widget.topicTypes, status);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (FocusManager.instance.primaryFocus != null) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Consumer<IELTSIndividualPartScreenProvider>(
      builder: (context, provider, child) {
        int testOption = Utils.getTestOption(widget.topicTypes);
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: w,
              padding: const EdgeInsets.symmetric(
                horizontal: CustomPadding.padding_11,
              ),
              color: AppColor.defaultLight01GrayColor,
              child: Stack(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // mainAxisSize: MainAxisSize.max,
                // crossAxisAlignment: CrossAxisAlignment.center,
                alignment: Alignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    alignment: Alignment.centerLeft,
                    child: Checkbox(
                      tristate: true,
                      activeColor: AppColor.defaultPurpleColor,
                      value: provider.topicsId.length ==
                          provider.topicsList.length,
                      onChanged: (bool? value) {
                        if (value ?? false) {
                          _addAllTopics();
                        } else {
                          provider.clearTopicSelection();
                          _provider!.clearTopicsByTestOption(testOption);
                        }
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      context.formatString(StringConstants.selected_topics, [
                        provider.topicsId.length,
                        provider.topicsList.length
                      ]),
                      style: CustomTextStyle.textWithCustomInfo(
                        context: context,
                        color: AppColor.defaultBlackColor,
                        fontsSize: FontsSize.fontSize_15,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        provider.clearTopicSelection();
                        _provider!.clearTopicsByTestOption(testOption);
                      },
                      child: Text(
                        Utils.multiLanguage(
                            StringConstants.clear_button_title)!,
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
            Consumer<IELTSPartListScreenProvider>(
              builder: (context, parentScreenProvider, child) {
                var listSearched = provider.topicsList.where((element) =>
                    element.title.toLowerCase().contains(
                        parentScreenProvider.queryChanged.toLowerCase()));
                return Expanded(
                  child: ListView.separated(
                    itemCount: listSearched.length,
                    itemBuilder: (context, index) {
                      IELTSTopicModel topicModel =
                          listSearched.elementAt(index);
                      return _buildInTopicCard(
                        context,
                        ieltsTopicModel: topicModel,
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const CustomDivider(),
                  ),
                );
              },
            )
          ],
        );
      },
    );
  }

  Widget _buildInTopicCard(BuildContext context,
      {required IELTSTopicModel ieltsTopicModel}) {
    int option = Utils.getTestOption(widget.topicTypes);
    return Consumer<IELTSIndividualPartScreenProvider>(builder: (context, provider, child) {
      bool isChecked = provider.topicsId.contains(ieltsTopicModel.id);
      return InkWell(
        onTap: () {
          if (isChecked) {
            provider.removeTopicId(ieltsTopicModel.id);
            _provider!.removeTopicId(
                TopicId(id: ieltsTopicModel.id, testOption: option));
          } else {
            provider.setTopicSelection(ieltsTopicModel.id);
            _provider!.addTopicId(
                TopicId(id: ieltsTopicModel.id, testOption: option));
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 0,
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
                        _provider!.addTopicId(TopicId(
                            id: ieltsTopicModel.id, testOption: option));
                      } else {
                        provider.removeTopicId(ieltsTopicModel.id);
                        _provider!.removeTopicId(TopicId(
                            id: ieltsTopicModel.id, testOption: option));
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
  void onGetIELTSTopicsFail(String message) async {
    _loading!.hide();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: Utils.multiLanguage(StringConstants.dialog_title)!,
          description: message,
          okButtonTitle: Utils.multiLanguage(StringConstants.ok_button_title),
          cancelButtonTitle: null,
          borderRadius: 8,
          hasCloseButton: false,
          okButtonTapped: () {
            Navigator.of(context).pop();
          },
          cancelButtonTapped: null,
        );
      },
    );
  }

  @override
  void onGetIELTSTopicsSuccess(List<IELTSTopicModel> topicsList) {
    _loading!.hide();
    _ieltsTopicsProvider!.setIELTSTopics(topicsList);

    _addAllTopics();
  }

  void _addAllTopics() {
    int testOption = Utils.getTestOption(widget.topicTypes);
    _ieltsTopicsProvider!.addAllTopics();
    List<TopicId> topicsId = [];
    for (int i = 0; i < _ieltsTopicsProvider!.topicsId.length; i++) {
      topicsId.add(TopicId(
          id: _ieltsTopicsProvider!.topicsId[i], testOption: testOption));
    }
    _provider!.setTopicsId(topicsId, testOption);
  }

  @override
  bool get wantKeepAlive => true;
}
