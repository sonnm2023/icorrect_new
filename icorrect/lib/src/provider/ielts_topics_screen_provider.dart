import 'package:flutter/foundation.dart';

import '../models/auth_models/topic_id.dart';

class IELTSTopicsScreenProvider extends ChangeNotifier {
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

  List<TopicId> _topicsId = [];
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
}
