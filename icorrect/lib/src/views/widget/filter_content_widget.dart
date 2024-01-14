import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/homework_models/activity_status_model.dart';
import 'package:icorrect/src/models/homework_models/new_api_135/new_class_model.dart';
import 'package:icorrect/src/provider/homework_provider.dart';

class FilterContentWidget extends StatefulWidget {
  const FilterContentWidget({super.key, required this.homeWorkProvider});

  final HomeWorkProvider homeWorkProvider;

  @override
  State<FilterContentWidget> createState() => _FilterContentWidgetState();
}

class _FilterContentWidgetState extends State<FilterContentWidget> {
  TabBar get _tabBar => TabBar(
        indicatorColor: AppColor.defaultPurpleColor,
        tabs: [
          Tab(
            text: Utils.multiLanguage(
                StringConstants.filter_choose_class_tab_title),
          ),
          Tab(
            text: Utils.multiLanguage(
                StringConstants.filter_choose_status_tab_title),
          ),
        ],
      );
  late List<NewClassModel> _listSelectedClass = [];
  late List<ActivityStatusModel> _listSelectedStatus = [];

  late List<NewClassModel> _originalListSelectedClass = [];
  late List<ActivityStatusModel> _originalListSelectedStatus = [];

  @override
  void initState() {
    super.initState();

    _listSelectedClass = widget.homeWorkProvider.listSelectedClassFilter;
    _listSelectedStatus = widget.homeWorkProvider.listSelectedStatusFilter;
    _originalListSelectedClass
        .addAll(widget.homeWorkProvider.listSelectedClassFilter);
    _originalListSelectedStatus
        .addAll(widget.homeWorkProvider.listSelectedStatusFilter);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: CustomSize.size_400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: _buildContent(),
          ),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: GlobalScaffoldKey.filterScaffoldKey,
        resizeToAvoidBottomInset: true,
        appBar: _tabBar,
        body: TabBarView(
          children: [
            _buildListClass(),
            _buildListStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildListClass() {
    return ListView.separated(
      itemCount: widget.homeWorkProvider.listClassForFilter.length,
      itemBuilder: (_, index) => _buildClassFilterRow(
          widget.homeWorkProvider.listClassForFilter[index]),
      separatorBuilder: (_, index) => const Divider(),
    );
  }

  Widget _buildListStatus() {
    return ListView.separated(
      itemCount: widget.homeWorkProvider.listStatusForFilter.length,
      itemBuilder: (_, index) => _buildStatusFilterRow(
          widget.homeWorkProvider.listStatusForFilter[index]),
      separatorBuilder: (_, index) => const Divider(),
    );
  }

  Widget _buildClassFilterRow(NewClassModel subject) {
    bool isSelected = _checkSelectedClass(subject);
    IconData icon =
        isSelected ? Icons.check_box_outlined : Icons.square_outlined;

    String title = subject.name;

    if (subject.name == "Select All") {
      title = Utils.convertActivityStatusToMulti(subject.name);
    }

    return ListTile(
      leading: Icon(icon, color: AppColor.defaultPurpleColor),
      title: Text(
        title,
        style: const TextStyle(color: AppColor.defaultBlackColor, fontSize: 13),
      ),
      onTap: () {
        if (subject == widget.homeWorkProvider.listClassForFilter.first) {
          if (isSelected) {
            _clearAllSelected(SelectType.classType);
          } else {
            _addAllSelected(SelectType.classType);
          }
        } else {
          if (isSelected) {
            _removeSelectedClass(subject);
          } else {
            _addSelected(subject, SelectType.classType);
          }
        }
      },
    );
  }

  Widget _buildStatusFilterRow(ActivityStatusModel subject) {
    bool isSelected = _checkSelectedStatus(subject);
    IconData icon =
        isSelected ? Icons.check_box_outlined : Icons.square_outlined;
    return ListTile(
      leading: Icon(icon, color: AppColor.defaultPurpleColor),
      title: Text(
        Utils.convertActivityStatusToMulti(subject.name),
        style: const TextStyle(color: AppColor.defaultBlackColor, fontSize: 13),
      ),
      onTap: () {
        if (subject == widget.homeWorkProvider.listStatusForFilter.first) {
          if (isSelected) {
            _clearAllSelected(SelectType.statusType);
          } else {
            _addAllSelected(SelectType.statusType);
          }
        } else {
          if (isSelected) {
            _removeSelectedStatus(subject);
          } else {
            _addSelected(subject, SelectType.statusType);
          }
        }
      },
    );
  }

  void _removeSelectedClass(NewClassModel subject) {
    //Remove select all
    bool hasSelectAll = _listSelectedClass
        .map((e) => e.id)
        .contains(widget.homeWorkProvider.listClassForFilter.first.id);
    if (hasSelectAll) {
      _listSelectedClass.removeWhere((element) =>
          element.id == widget.homeWorkProvider.listClassForFilter.first.id);
    }

    _listSelectedClass.removeWhere((element) => element.id == subject.id);
    widget.homeWorkProvider.listSelectedClassFilter.remove(subject);
    setState(() {});
  }

  void _removeSelectedStatus(ActivityStatusModel subject) {
    //Remove select all
    bool hasSelectAll = _listSelectedStatus
        .map((e) => e.id)
        .contains(widget.homeWorkProvider.listStatusForFilter.first.id);
    if (hasSelectAll) {
      _listSelectedStatus.removeWhere((element) =>
          element.id == widget.homeWorkProvider.listStatusForFilter.first.id);
    }

    _listSelectedStatus.removeWhere((element) => element.id == subject.id);
    widget.homeWorkProvider.listSelectedStatusFilter.remove(subject);
    setState(() {});
  }

  void _addSelected(dynamic subject, SelectType type) {
    if (type == SelectType.classType) {
      _listSelectedClass.add(subject);
    } else {
      _listSelectedStatus.add(subject);
    }
    setState(() {});
  }

  void _clearAllSelected(SelectType type) {
    if (type == SelectType.classType) {
      _listSelectedClass.clear();
      widget.homeWorkProvider.clearAllSelected(type);
    } else {
      _listSelectedStatus.clear();
      widget.homeWorkProvider.clearAllSelected(type);
    }
    setState(() {});
  }

  void _addAllSelected(SelectType type) {
    if (type == SelectType.classType) {
      _listSelectedClass.clear();
      _listSelectedClass.addAll(widget.homeWorkProvider.listClassForFilter);

      widget.homeWorkProvider.listSelectedClassFilter.clear();
      widget.homeWorkProvider.listSelectedClassFilter
          .addAll(widget.homeWorkProvider.listClassForFilter);
    } else {
      _listSelectedStatus.clear();
      _listSelectedStatus.addAll(widget.homeWorkProvider.listStatusForFilter);

      widget.homeWorkProvider.listSelectedStatusFilter.clear();
      widget.homeWorkProvider.listSelectedStatusFilter
          .addAll(widget.homeWorkProvider.listStatusForFilter);
    }
    setState(() {});
  }

  bool _checkSelectedClass(NewClassModel subject) {
    if (_listSelectedClass.isEmpty) return false;

    bool hasSelectAll = _listSelectedClass
        .map((e) => e.id)
        .contains(widget.homeWorkProvider.listClassForFilter.first.id);
    bool hasContain = _listSelectedClass.map((e) => e.id).contains(subject.id);
    if (hasSelectAll || hasContain) {
      return true;
    } else {
      return false;
    }
  }

  bool _checkSelectedStatus(ActivityStatusModel subject) {
    if (_listSelectedStatus.isEmpty) return false;

    bool hasSelectAll = _listSelectedStatus
        .map((e) => e.id)
        .contains(widget.homeWorkProvider.listStatusForFilter.first.id);
    bool hasContain = _listSelectedStatus.map((e) => e.id).contains(subject.id);
    if (hasSelectAll || hasContain) {
      return true;
    } else {
      return false;
    }
  }

  Widget _buildButtons() {
    double w = MediaQuery.of(context).size.width / 2;

    return Row(
      children: [
        Container(
          height: CustomSize.size_50,
          width: w,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColor.defaultGraySlightColor,
                width: 1,
              ),
              right: BorderSide(
                color: AppColor.defaultGraySlightColor,
                width: 1,
              ),
            ),
          ),
          child: InkWell(
            onTap: () {
              //Reset selected status to original data
              _resetSelectedData();
              Navigator.pop(context);
            },
            child: Center(
              child: Text(
                Utils.multiLanguage(StringConstants.close_button_title)!,
                style: CustomTextStyle.textWithCustomInfo(
                  context: context,
                  color: AppColor.defaultGrayColor,
                  fontsSize: FontsSize.fontSize_14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        Container(
          height: CustomSize.size_50,
          width: w,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColor.defaultGraySlightColor,
                width: 1,
              ),
            ),
          ),
          child: InkWell(
            onTap: () {
              bool isValid = widget.homeWorkProvider.checkFilterSelected();
              widget.homeWorkProvider.updateProcessingStatus(processing: true);
              if (isValid) {
                widget.homeWorkProvider.filterHomeWork(context);
                Navigator.pop(context);
              } else {
                widget.homeWorkProvider
                    .updateProcessingStatus(processing: false);
                widget.homeWorkProvider.updateFilterString(
                    Utils.multiLanguage(StringConstants.default_filter_title)!);
                showToastMsg(
                  msg: Utils.multiLanguage(
                      StringConstants.choose_filter_message)!,
                  toastState: ToastStatesType.warning,
                  isCenter: true,
                );
              }
            },
            child: Center(
              child: Text(
                Utils.multiLanguage(StringConstants.done_button_title)!,
                style: CustomTextStyle.textWithCustomInfo(
                  context: context,
                  color: AppColor.defaultPurpleColor,
                  fontsSize: FontsSize.fontSize_14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _resetSelectedData() {
    widget.homeWorkProvider
        .setListSelectedClassFilter(_originalListSelectedClass);
    widget.homeWorkProvider
        .setListSelectedStatusFilter(_originalListSelectedStatus);
  }
}
