import 'dart:convert';

import 'package:icorrect/src/models/module_lession_models/lesson_model.dart';

const String json = '''
[
{
"id": 1,
"name": "Unit 1",
"missions": [
{
"id": 1,
"name": "Mission 1",
"content": "Is there a TV?",
"files": [
{
"id": 2606054,
"url": "l3_5.mp4",
"type": 1
},
{
"id": 2745113,
"url": "ae13d26c-2f52-412a-8439-36cb1c577648.png",
"type": 4
}
],
"star": 1,
"attemp": 1,
"max_attemp": 3,
"score": 0.1
},
{
"id": 2,
"name": "Mission 2",
"content": "What is this?",
"files": [
{
"id": 2606054,
"url": "l3_5.mp4",
"type": 1
},
{
"id": 2745113,
"url": "ae13d26c-2f52-412a-8439-36cb1c577648.png",
"type": 4
}
],
"star": 0,
"attemp": 0,
"max_attemp": 3,
"score": 0.1
}
]
},
{
"id": 2,
"name": "Unit 2",
"missions": [
{
"id": 1,
"name": "Mission 1",
"content": "Is there a TV?",
"files": [
{
"id": 2606054,
"url": "l3_5.mp4",
"type": 1
},
{
"id": 2745113,
"url": "ae13d26c-2f52-412a-8439-36cb1c577648.png",
"type": 4
}
],
"star": 1,
"attemp": 1,
"max_attemp": 3,
"score": 1
},
{
"id": 2,
"name": "Mission 2",
"content": "What is this?",
"files": [
{
"id": 2606054,
"url": "l3_5.mp4",
"type": 1
},
{
"id": 2745113,
"url": "ae13d26c-2f52-412a-8439-36cb1c577648.png",
"type": 4
}
],
"star": 0,
"attemp": 0,
"max_attemp": 3,
"score": 1
}
]
}
]
''';
abstract class ListLessonViewContract {
  void onGetListLessonComplete(List<LessonModel> list);
  void onGetListLessonError();
}

class ListLessonPresenter {

  ListLessonViewContract? _view;

  ListLessonPresenter(this._view) {

  }

  void getListLesson() async {
    // ListLessonModel model = ListLessonModel.fromJson(jsonDecode(json));
    List value = jsonDecode(json);
    List<LessonModel> list = value.map((e) => LessonModel.fromJson(e)).toList();
    _view!.onGetListLessonComplete(list);
  }

}