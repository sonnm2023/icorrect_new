import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/models/practice_model/ielts_topic_model.dart';

class IELTSPartListScreenProvider extends ChangeNotifier {
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

  final List<IELTSTopicModel> _selectedTopicList = [];
  List<IELTSTopicModel> get selectedTopicIdList => _selectedTopicList;

  void addSelectedTopic(IELTSTopicModel topic) {
    _selectedTopicList.add(topic);

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void removeSelectedTopic(IELTSTopicModel topic) {
    _selectedTopicList.removeWhere((element) => element.id == topic.id);
    // _selectedTopicIdList.removeWhere((element) =>
    // element.id == topic.id && element.testOption == topicId.testOption);

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void addAllSelectedTopicList(List<IELTSTopicModel> list) {
    _selectedTopicList.clear();
    _selectedTopicList.addAll(list);

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void removeAllSelectedTopicList() {
    _selectedTopicList.clear();

    if (!isDisposed) {
      notifyListeners();
    }
  }

  //Case: FULL PART
  //SUB 1: Part 1 Topic Selected List
  final List<IELTSTopicModel> _fullPartPart1SelectedTopicList = [];
  List<IELTSTopicModel> get fullPartPart1SelectedTopicList => _fullPartPart1SelectedTopicList;

  void addTopicFullPartPart1SelectedTopicList(IELTSTopicModel topic) {
    _fullPartPart1SelectedTopicList.add(topic);

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void removeTopicFullPartPart1SelectedTopicList(IELTSTopicModel topic) {
    _fullPartPart1SelectedTopicList.removeWhere((element) => element.id == topic.id);

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void addAllFullPartPart1SelectedTopicList(List<IELTSTopicModel> list) {
    _fullPartPart1SelectedTopicList.clear();
    _fullPartPart1SelectedTopicList.addAll(list);

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void removeAllFullPartPart1SelectedTopicList() {
    _fullPartPart1SelectedTopicList.clear();

    if (!isDisposed) {
      notifyListeners();
    }
  }

  //Case: FULL PART
  //SUB 1: Part 23 Topic Selected List
  final List<IELTSTopicModel> _fullPartPart23SelectedTopicList = [];
  List<IELTSTopicModel> get fullPartPart23SelectedTopicList => _fullPartPart23SelectedTopicList;

  void addTopicFullPartPart23SelectedTopicList(IELTSTopicModel topic) {
    _fullPartPart23SelectedTopicList.add(topic);

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void removeTopicFullPartPart23SelectedTopicList(IELTSTopicModel topic) {
    _fullPartPart23SelectedTopicList.removeWhere((element) => element.id == topic.id);

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void addAllFullPartPart23SelectedTopicList(List<IELTSTopicModel> list) {
    _fullPartPart23SelectedTopicList.clear();
    _fullPartPart23SelectedTopicList.addAll(list);

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void removeAllFullPartPart23SelectedTopicList() {
    _fullPartPart23SelectedTopicList.clear();

    if (!isDisposed) {
      notifyListeners();
    }
  }

  //Original topic id list of part 1
  final List<IELTSTopicModel> _originalPart1TopicList = [];
  List<IELTSTopicModel> get originalPart1TopicList =>
      _originalPart1TopicList;

  //Original topic id list of part 2
  final List<IELTSTopicModel> _originalPart2TopicList = [];
  List<IELTSTopicModel> get originalTopicIdListPart2 =>
      _originalPart2TopicList;

  //Original topic id list of part 3
  final List<IELTSTopicModel> _originalPart3TopicList = [];
  List<IELTSTopicModel> get originalTopicIdListPart3 =>
      _originalPart3TopicList;

  //Original topic id list of part 2,3
  final List<IELTSTopicModel> _originalPart23TopicList = [];
  List<IELTSTopicModel> get originalTopicIdListPart23 =>
      _originalPart23TopicList;

  //Original Part 1 topic list of FULL PART
  final List<IELTSTopicModel> _originalFullPartPart1TopicList = [];
  List<IELTSTopicModel> get originalFullPartPart1TopicList =>
      _originalFullPartPart1TopicList;

  //Original Part 2,3 topic list of FULL PART
  final List<IELTSTopicModel> _originalFullPartPart23TopicList = [];
  List<IELTSTopicModel> get originalFullPartPart23TopicList =>
      _originalFullPartPart23TopicList;

  void setupDataWithPartType(
      //For first time after get list topic of part
      IELTSPartType partType,
      List<IELTSTopicModel> list) {
    switch (partType) {
      case IELTSPartType.part1:
        {
          _originalPart1TopicList.clear();
          _originalPart1TopicList.addAll(list);

          //For selected topic list
          _selectedTopicList.clear();
          _selectedTopicList.addAll(list);
          break;
        }

      case IELTSPartType.part2:
        {
          _originalPart2TopicList.clear();
          _originalPart2TopicList.addAll(list);

          //For selected topic list
          _selectedTopicList.clear();
          _selectedTopicList.addAll(list);
          break;
        }

      case IELTSPartType.part3:
        {
          _originalPart3TopicList.clear();
          _originalPart3TopicList.addAll(list);

          //For selected topic list
          _selectedTopicList.clear();
          _selectedTopicList.addAll(list);
          break;
        }

      case IELTSPartType.part2and3:
        {
          _originalPart23TopicList.clear();
          _originalPart23TopicList.addAll(list);

          //For selected topic list
          _selectedTopicList.clear();
          _selectedTopicList.addAll(list);
          break;
        }

      case IELTSPartType.full:
        {
          _initDataForFullPart(list);
          break;
        }
    }
  }

  void _initDataForFullPart(List<IELTSTopicModel> list) {
    List<IELTSTopicModel> part1 = list.where((element) => element.topicType.toString() == IELTSPartType.part1.get.first).toList();
    _originalFullPartPart1TopicList.addAll(part1);
    _originalFullPartPart23TopicList.addAll(list.where((element) => !part1.contains(element)));
    if(kDebugMode) {
      print("Part 1 - length = ${_originalFullPartPart1TopicList.length}");
      print("Part 2,3 - length = ${_originalFullPartPart23TopicList.length}");
    }
  }

  void removeOriginalTopicListWithPartType(IELTSPartType partType) {
    switch (partType) {
      case IELTSPartType.part1:
        {
          _originalPart1TopicList.clear();
          break;
        }

      case IELTSPartType.part2:
        {
          _originalPart2TopicList.clear();
          break;
        }

      case IELTSPartType.part3:
        {
          _originalPart3TopicList.clear();
          break;
        }

      case IELTSPartType.part2and3:
        {
          _originalPart23TopicList.clear();
          break;
        }

      case IELTSPartType.full:
        {
          _originalFullPartPart1TopicList.clear();
          _originalFullPartPart23TopicList.clear();
          break;
        }
    }
  }

  void resetData() {
    _selectedTopicList.clear();
    _originalPart1TopicList.clear();
    _originalPart2TopicList.clear();
    _originalPart3TopicList.clear();
    _originalPart23TopicList.clear();
  }

  /*
  final List<TopicId> _topicsId = [];
  List<TopicId> get topicsId => _topicsId;

  void setTopicsId(List<TopicId> list, int testOption) {
    _topicsId.removeWhere((element) => element.testOption == testOption);

    _topicsId.addAll(list);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void removeTopicId(TopicId topic) {
    _topicsId.removeWhere(
        (item) => item.id == topic.id && item.testOption == topic.testOption);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void addTopicId(TopicId id) {
    _topicsId.add(id);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearTopicsId() {
    if (_topicsId.isNotEmpty) {
      _topicsId.clear();
    }
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearTopicsByTestOption(int testOption) {
    _topicsId.removeWhere((element) => element.testOption == testOption);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  List<int> getTopicsIdList() {
    List<int> topicsIdList = [];
    for (int i = 0; i < _topicsId.length; i++) {
      topicsIdList.add(_topicsId[i].id ?? 0);
    }
    return topicsIdList;
  }
   */

  bool _isShowSearchBar = false;
  bool get isShowSearchBar => _isShowSearchBar;
  void setShowSearchBar(bool isShow) {
    _isShowSearchBar = isShow;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  String _queryChanged = '';
  String get queryChanged => _queryChanged;
  void setQueryChanged(String query) {
    _queryChanged = query;
    if (!isDisposed) {
      notifyListeners();
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
}
