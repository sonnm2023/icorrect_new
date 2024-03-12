// import 'package:flutter/material.dart';
//
// import '../models/practice_model/ielts_topic_model.dart';
//
// class IELTSIndividualPartScreenProvider extends ChangeNotifier {
//   bool isDisposed = false;
//   @override
//   void dispose() {
//     super.dispose();
//     isDisposed = true;
//   }
//
//   @override
//   void notifyListeners() {
//     if (!isDisposed) {
//       super.notifyListeners();
//     }
//   }
//
//   List<IELTSTopicModel> _topicsList = [];
//   List<IELTSTopicModel> get topicsList => _topicsList;
//   void setIELTSTopics(List<IELTSTopicModel> topics) {
//     if (_topicsList.isNotEmpty) {
//       _topicsList.clear();
//     }
//     _topicsList.addAll(topics);
//     if (!isDisposed) {
//       notifyListeners();
//     }
//   }
//
//   List<int> _topicsId = [];
//   List<int> get topicsId => _topicsId;
//   void setTopicSelection(int id) {
//     _topicsId.add(id);
//     if (!isDisposed) {
//       notifyListeners();
//     }
//   }
//
//   void removeTopicId(int id) {
//     _topicsId.removeWhere((item) => item == id);
//     if (!isDisposed) {
//       notifyListeners();
//     }
//   }
//
//   void clearTopicSelection() {
//     _topicsId.clear();
//     if (!isDisposed) {
//       notifyListeners();
//     }
//   }
//
//   void addAllTopics() {
//     if (_topicsId.isNotEmpty) {
//       _topicsId.clear();
//     }
//     for (int i = 0; i < _topicsList.length; i++) {
//       _topicsId.add(_topicsList[i].id);
//     }
//     if (!isDisposed) {
//       notifyListeners();
//     }
//   }
// }
