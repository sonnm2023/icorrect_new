import 'package:flutter/foundation.dart';
import 'package:icorrect/src/models/my_practice_test_model/bank_topic_model.dart';

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
}
