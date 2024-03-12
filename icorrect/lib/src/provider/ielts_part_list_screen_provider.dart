import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/models/auth_models/topic_id.dart';


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

  final List<TopicId> _selectedTopicIdList = [];
  List<TopicId> get selectedTopicIdList => _selectedTopicIdList;

  void addSelectedTopicId(TopicId topicId) {
    _selectedTopicIdList.add(topicId);

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void removeSelectedTopicId(TopicId topicId) {
    _selectedTopicIdList.removeWhere((element) => element.id == topicId.id && element.testOption == topicId.testOption);

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void addAllSelectedTopicIdList(List<TopicId> list) {
    _selectedTopicIdList.clear();
    _selectedTopicIdList.addAll(list);

    if (!isDisposed) {
      notifyListeners();
    }
  }

  void removeAllSelectedTopicIdList() {
    _selectedTopicIdList.clear();

    if (!isDisposed) {
      notifyListeners();
    }
  }

  //Original topic id list of part 1
  final List<TopicId> _originalTopicIdListPart1 = [];
  List<TopicId> get originalTopicIdListPart1 => _originalTopicIdListPart1;

  //Original topic id list of part 2
  final List<TopicId> _originalTopicIdListPart2 = [];
  List<TopicId> get originalTopicIdListPart2 => _originalTopicIdListPart2;

  //Original topic id list of part 3
  final List<TopicId> _originalTopicIdListPart3 = [];
  List<TopicId> get originalTopicIdListPart3 => _originalTopicIdListPart3;

  //Original topic id list of part 2,3
  final List<TopicId> _originalTopicIdListPart23 = [];
  List<TopicId> get originalTopicIdListPart23 => _originalTopicIdListPart23;

  //Original topic id list of full part
  final List<TopicId> _originalTopicIdListFullPart = [];
  List<TopicId> get originalTopicIdListFullPart => _originalTopicIdListFullPart;

  void setOriginalTopicListWithPartType(IELTSPartType partType, List<TopicId> list) {
    switch(partType) {
      case IELTSPartType.part1: {
        _originalTopicIdListPart1.clear();
        _originalTopicIdListPart1.addAll(list);
        break;
      }

      case IELTSPartType.part2: {
        _originalTopicIdListPart2.clear();
        _originalTopicIdListPart2.addAll(list);
        break;
      }

      case IELTSPartType.part3: {
        _originalTopicIdListPart3.clear();
        _originalTopicIdListPart3.addAll(list);
        break;
      }

      case IELTSPartType.part2and3: {
        _originalTopicIdListPart23.clear();
        _originalTopicIdListPart23.addAll(list);
        break;
      }

      case IELTSPartType.full: {
        _originalTopicIdListFullPart.clear();
        _originalTopicIdListFullPart.addAll(list);
        break;
      }
    }
  }

  void removeOriginalTopicListWithPartType(IELTSPartType partType) {
    switch(partType) {
      case IELTSPartType.part1: {
        _originalTopicIdListPart1.clear();
        break;
      }

      case IELTSPartType.part2: {
        _originalTopicIdListPart2.clear();
        break;
      }

      case IELTSPartType.part3: {
        _originalTopicIdListPart3.clear();
        break;
      }

      case IELTSPartType.part2and3: {
        _originalTopicIdListPart23.clear();
        break;
      }

      case IELTSPartType.full: {
        _originalTopicIdListFullPart.clear();
        break;
      }
    }
  }



  void resetData() {
    _selectedTopicIdList.clear();
    _originalTopicIdListPart1.clear();
    _originalTopicIdListPart2.clear();
    _originalTopicIdListPart3.clear();
    _originalTopicIdListPart23.clear();
    _originalTopicIdListFullPart.clear();
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
