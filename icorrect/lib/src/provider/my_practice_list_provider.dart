import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences_keys.dart';
import 'package:icorrect/src/models/my_practice_test_model/bank_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/bank_topic_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/my_practice_response_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/my_practice_test_model.dart';
import 'package:icorrect/src/models/my_practice_test_model/setting_model.dart';

class MyPracticeListProvider extends ChangeNotifier {
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

  MyPracticeResponseModel _myPracticeResponseModel = MyPracticeResponseModel();
  MyPracticeResponseModel get myPracticeResponseModel =>
      _myPracticeResponseModel;
  void setMyPracticeResponseModel(MyPracticeResponseModel model) {
    _myPracticeResponseModel = model;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  final List<MyPracticeTestModel> _myTestsList = [];
  List<MyPracticeTestModel> get myTestsList => _myTestsList;
  void setMyTestsList(List<MyPracticeTestModel> list) {
    if (_myTestsList.isNotEmpty) {
      _myTestsList.clear();
    }
    _myTestsList.addAll(list);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearOldDataMyTestsList() {
    if (_myTestsList.isNotEmpty) {
      _myTestsList.clear();
    }
  }

  void removeTestAt(int indexDeleted) {
    _myTestsList.removeAt(indexDeleted);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void addMyTestsList(List<MyPracticeTestModel> list) {
    _myTestsList.addAll(list);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearMyTestsList() {
    _myTestsList.clear();
    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _pageNum = 0;
  int get pageNum => _pageNum;
  void setPageNum(int page) {
    _pageNum = page;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _showLoadingBottom = false;
  bool get showLoadingBottom => _showLoadingBottom;
  void setShowLoadingBottom(bool isShow) {
    _showLoadingBottom = isShow;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  final List<BankModel> _banks = [];
  List<BankModel> get banks => _banks;

  void setBankList(List<BankModel> list) {
    clearBankList();
    _banks.addAll(list);

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearBankList() {
    if (_banks.isNotEmpty) {
      _banks.clear();
    }
  }

  bool _showBankListButton = false;
  bool get showBankListButton => _showBankListButton;

  void updateStatusShowBankListButton({required bool isShow}) {
    _showBankListButton = isShow;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;
  void setIsProcessing(bool isProcessing) {
    _isProcessing = isProcessing;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  final List<Topic> _topics = [];
  List<Topic> get topics => _topics;

  void setTopicList(List<Topic> list) {
    clearTopicList();
    _topics.addAll(list);

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearTopicList() {
    if (_topics.isNotEmpty) {
      _topics.clear();
    }
  }

  void resetExpandedStatusOfOthers(Topic topic) {
    if (_topics.isEmpty) return;
    for (Topic t in _topics) {
      if (t.id != topic.id) {
        topic.isExpanded = false;
      }
    }
  }

  int getTotalSelectedTopics() {
    int count = 0;
    count += _topics
        .where((topic) =>
            topic.isSelected ||
            topic.subTopics!.any((subTopic) => subTopic.isSelected))
        .length;
    return count;
  }

  int getTotalTopics() {
    return _topics.length;
  }

  int getTotalSelectedSubTopics() {
    int count = 0;
    for (var topic in _topics) {
      count += topic.subTopics!.where((subTopic) => subTopic.isSelected).length;
    }
    return count;
  }

  int getTotalSelectedSubTopicsWithTopicId(int id) {
    int count = 0;
    Topic t = _topics.where((element) => element.id == id).first;
    count += t.subTopics!.where((element) => element.isSelected).length;
    return count;
  }

  int getTotalSubTopics() {
    int count = 0;
    for (var topic in _topics) {
      count += topic.subTopics!.length;
    }
    return count;
  }

  void saveSettingList(List<SettingModel> list) {
    final String encodedData = SettingModel.encode(list);
    AppSharedPref.instance()
        .putString(key: AppSharedKeys.myPracticeSetting, value: encodedData);
  }

  Future<List<SettingModel>?> getSettingList() async {
    // Fetch and decode data
    final String dataString = await AppSharedPref.instance()
        .getString(key: AppSharedKeys.myPracticeSetting);

    if (dataString.isEmpty) return null;

    final List<SettingModel> settings = SettingModel.decode(dataString);
    return settings;
  }

  List<SettingModel> originalSettings = [
    SettingModel(
      title: StringConstants.number_of_topics,
      value: 2,
      step: 1,
    ),
    SettingModel(
      title: StringConstants.number_question_of_part_1,
      value: 5,
      step: 1,
    ),
    SettingModel(
      title: StringConstants.number_question_of_part_2,
      value: 1,
      step: 1,
    ),
    SettingModel(
      title: StringConstants.cue_card_time_of_part_2,
      value: 60,
      step: 15,
    ),
    // SettingModel(
    //   title: StringConstants.speed_of_first_time,
    //   value: 1,
    //   step: 0.05,
    // ),
    // SettingModel(
    //   title: StringConstants.speed_of_second_time,
    //   value: 0.85,
    //   step: 0.05,
    // ),
    // SettingModel(
    //   title: StringConstants.speed_of_third_time,
    //   value: 0.75,
    //   step: 0.05,
    // ),
  ];

  final List<SettingModel> _settings = [];
  List<SettingModel> get settings => _settings;

  void updateSettings({required int index, required bool isAdd}) {
    SettingModel item = _settings[index];
    if (isAdd) {
      item.value += item.step;
    } else {
      if (item.value > 0) {
        item.value -= item.step;
      }
    }

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void initSettings() async {
    //Check has setting in local first
    List<SettingModel>? settingList = await getSettingList();
    if (null != settingList) {
      for (int i = 0; i < settingList.length; i++) {
        SettingModel s = SettingModel(
          title: settingList[i].title,
          value: settingList[i].value,
          step: settingList[i].step,
        );
        _settings.add(s);
      }
    } else {
      for (int i = 0; i < originalSettings.length; i++) {
        SettingModel s = SettingModel(
          title: originalSettings[i].title,
          value: originalSettings[i].value,
          step: originalSettings[i].step,
        );
        _settings.add(s);
      }
    }

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearSettings() {
    if (_settings.isNotEmpty) {
      _settings.clear();
    }
  }

  bool _dialogShowing = false;
  bool get dialogShowing => _dialogShowing;
  void setDialogShowing(bool isShowing) {
    _dialogShowing = isShowing;

    notifyListeners();
  }

  int _permissionDeniedTime = 0;
  int get permissionDeniedTime => _permissionDeniedTime;
  void setPermissionDeniedTime() {
    _permissionDeniedTime++;
  }

  void resetPermissionDeniedTime() {
    _permissionDeniedTime = 0;
  }

  bool _isRefreshList = false;
  bool get isRefreshList => _isRefreshList;
  void refreshList(bool isRefresh) {
    _isRefreshList = isRefresh;

    if (isRefresh && !isDisposed) {
      notifyListeners();
    }
  }

  bool _isTestDetailLoading = false;
  bool get isTestDetailLoading => _isTestDetailLoading;
  void setIsTestDetailLoading(bool isLoading) {
    _isTestDetailLoading = isLoading;
    if (!isDisposed) {
      notifyListeners();
    }
  }
}
