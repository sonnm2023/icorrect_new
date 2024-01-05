import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/models/my_practice_test_model/bank_topic_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/setting_model.dart';

class MyPracticeTopicsProvider extends ChangeNotifier {
  bool isDisposed = false;
  @override
  void dispose() {
    super.dispose();
    isDisposed = true;
  }

  @override
  void notifyListeners() {
    if (!isDisposed) {
      super.notifyListeners();
    }
  }

  // final List<Topic> _topics = [];
  // List<Topic> get topics => _topics;

  // void setTopicList(List<Topic> list) {
  //   clearTopicList();
  //   _topics.addAll(list);

  //   if (!isDisposed) {
  //     notifyListeners();
  //   }
  // }

  // void clearTopicList() {
  //   if (_topics.isNotEmpty) {
  //     _topics.clear();
  //   }
  // }

  // void resetExpandedStatusOfOthers(Topic topic) {
  //   if (_topics.isEmpty) return;
  //   for (Topic t in _topics) {
  //     if (t.id != topic.id) {
  //       topic.isExpanded = false;
  //     }
  //   }
  // }

  // int getTotalSelectedTopics() {
  //   int count = 0;
  //   count += _topics.where((topic) => topic.isSelected).length;
  //   return count;
  // }

  // int getTotalTopics() {
  //   return _topics.length;
  // }

  // int getTotalSelectedSubTopics() {
  //   int count = 0;
  //   for (var topic in _topics) {
  //     count += topic.subTopics!.where((subTopic) => subTopic.isSelected).length;
  //   }
  //   return count;
  // }

  // int getTotalSubTopics() {
  //   int count = 0;
  //   for (var topic in _topics) {
  //     count += topic.subTopics!.length;
  //   }
  //   return count;
  // }

  // List<SettingModel> originalSettings = [
  //   SettingModel(
  //     title: StringConstants.number_of_topics,
  //     value: 2,
  //     step: 1,
  //   ),
  //   SettingModel(
  //     title: StringConstants.number_question_of_part_1,
  //     value: 5,
  //     step: 1,
  //   ),
  //   SettingModel(
  //     title: StringConstants.number_question_of_part_2,
  //     value: 1,
  //     step: 1,
  //   ),
  //   SettingModel(
  //     title: StringConstants.cue_card_time_of_part_2,
  //     value: 60,
  //     step: 1,
  //   ),
  //   SettingModel(
  //     title: StringConstants.speed_of_first_time,
  //     value: 1,
  //     step: 0.05,
  //   ),
  //   SettingModel(
  //     title: StringConstants.speed_of_second_time,
  //     value: 0.85,
  //     step: 0.05,
  //   ),
  //   SettingModel(
  //     title: StringConstants.speed_of_third_time,
  //     value: 0.75,
  //     step: 0.05,
  //   ),
  // ];

  // final List<SettingModel> _settings = [];
  // List<SettingModel> get settings => _settings;

  // void updateSettings(int index, bool isAdd) {
  //   SettingModel item = _settings[index];
  //   if (isAdd) {
  //     item.value += item.step;
  //   } else {
  //     if (item.value > 0) {
  //       item.value -= item.step;
  //     }
  //   }

  //   if (!isDisposed) {
  //     notifyListeners();
  //   }
  // }

  // void initSettings() {
  //   for (int i = 0; i < originalSettings.length; i++) {
  //     SettingModel s = SettingModel(
  //       title: originalSettings[i].title,
  //       value: originalSettings[i].value,
  //       step: originalSettings[i].step,
  //     );
  //     _settings.add(s);
  //   }
  // }

  // void clearSettings() {
  //   if (_settings.isNotEmpty) {
  //     _settings.clear();
  //   }
  // }

  // bool _dialogShowing = false;
  // bool get dialogShowing => _dialogShowing;
  // void setDialogShowing(bool isShowing) {
  //   _dialogShowing = isShowing;

  //   notifyListeners();
  // }

  // int _permissionDeniedTime = 0;
  // int get permissionDeniedTime => _permissionDeniedTime;
  // void setPermissionDeniedTime() {
  //   _permissionDeniedTime++;
  // }

  // void resetPermissionDeniedTime() {
  //   _permissionDeniedTime = 0;
  // }
}
