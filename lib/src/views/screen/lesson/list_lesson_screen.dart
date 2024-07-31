
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/module_lession_models/lesson_model.dart';
import 'package:icorrect/src/presenters/list_lesson_presenter.dart';
import 'package:icorrect/src/provider/lesson_provider.dart';
import 'package:icorrect/src/provider/mission_test_provider.dart';
import 'package:icorrect/src/views/screen/lesson/mission_test_screen.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/circle_loading.dart';
import 'package:provider/provider.dart';

class ListLessonScreen extends StatefulWidget {
  const ListLessonScreen({super.key});

  @override
  State<ListLessonScreen> createState() => _ListLessonScreenState();
}

class _ListLessonScreenState extends State<ListLessonScreen> implements ListLessonViewContract {

  final double rad = 80;
  final double height = 40;

  ListLessonPresenter? _presenter;
  LessonProvider? _provider;
  MissionTestProvider? _missionTestProvider;
  CircleLoading? _loading;

  List<bool> isOpenList = [];

  @override
  void initState() {
    // TODO: implement initState
    _loading = CircleLoading();
    _loading!.show(context: context, isViewAIResponse: false);
    super.initState();
    _presenter = ListLessonPresenter(this);
    _provider = Provider.of<LessonProvider>(context, listen: false);
    _missionTestProvider = Provider.of<MissionTestProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _presenter!.getListLesson();
    },);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.defaultLightPurple02Color,
      appBar: _buildAppBar(),
      body: _buildBody(),
      drawer: Drawer(),
    );
  }

  void toggleOverlay(int index) {
    setState(() {
      isOpenList[index] = !isOpenList[index];
    });
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColor.defaultPurple02Color,
      title: const Text('Nhiệm vụ hiện tại', style: TextStyle(
        color: Colors.white,
        fontSize: 21,
        fontWeight: FontWeight.bold
      )),
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white, size: 30),
      actions: [
        InkWell(onTap: () {

        }, child: const Icon(Icons.search, size: 30, color: AppColor.defaultAppColor)),
        InkWell(onTap: () {

        }, child: Container(
          margin: const EdgeInsets.only(right: 10),
            child: const Icon(Icons.filter_alt_outlined, size: 30, color: AppColor.defaultAppColor)))
      ],
    );
  }

  // Widget _buildAppBar() {
  //   return Container(
  //
  //   );
  // }

  Widget _buildBody() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        // child: Row (
        //   mainAxisAlignment: MainAxisAlignment.start,
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     _buildProcessColor(), _buildListMission()
        //   ],
        // ),
        child: Stack(
          children: [
            Positioned(
              left: rad/2,
              top: 50,
              bottom: 0,
              child: Container(
                color: Colors.white,
                width: 1,
              ),
            ),
            _buildListAnswer(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswer(bool isAnswer,LessonModel lesson, Mission mission) {
    double percentComplete = 0;
    int quantityComplete = 0;
    int totalMission = lesson.missions!.length;
    for (var i in lesson.missions!) {
      percentComplete += i.score!;
      if (i.score! >= 0.5) {
        quantityComplete += 1;
      }
    }
    percentComplete = percentComplete / totalMission;
    return isAnswer?
    Container(
      margin: EdgeInsets.only(left: rad/4 + 5),
      child: Text(mission.content!, style: const TextStyle(
       color: Colors.white,
       fontWeight: FontWeight.bold,
       fontSize: 18
      )),
    ) : Expanded(
      child: Container(
        margin: const EdgeInsets.only(left: 5, right: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lesson.name ?? '',style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18
            )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nhiệm vụ:$quantityComplete/$totalMission',style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                )),
                Text('Hoàn thành:${percentComplete*100}%',style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                ))
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Thành tích: Xuất sắc',style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('12/15', style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                    )),
                    Icon(Icons.star_rate, color: Colors.orange)
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCircleColor({required Color color, required bool isAnswer, String? imageUrl}) {
    double rad1 = isAnswer? rad/4 : rad/2;
    return Container(
      margin: EdgeInsets.only(left: rad1 == rad/4 ? rad1 : 0),
      child: CircleAvatar(
          radius: rad1,
          backgroundColor: isAnswer ? color : Colors.white,
          child: isAnswer
              ? Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(rad1),
                      border: Border.all(color: Colors.white, width: 1)))
              : Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(rad1),
                      border: Border.all(color: Colors.white, width: 1)),
                  child: ClipOval(
                      child: imageUrl == null ?Image.asset(AppAsset.gold, fit: BoxFit.cover)
                          : Image.network(imageUrl)
                  ),
                )),
    );
  }

  Widget _buildListAnswer() {
      return Column(
          children: List.generate(_provider!.listLesson.length, (index) {
            List<Mission> missions = _provider!.listLesson[index].missions!;
            int missionIndex = 0;
            return Column(
              children: [
                if (isOpenList[index])
                  Column(
                    children: List.generate(_provider!.listLesson[index].missions!.length, (innerIndex) {
                      missionIndex = missions.length - 1 - innerIndex;
                      return _buildAnswerItem(
                    isAnswer: true,
                    lesson: _provider!.listLesson[index],
                    mission: missions[missionIndex],
                    color: Utils.setColorScore(missions[missionIndex].score!),
                    index: innerIndex);
              }),
            ),
          _buildAnswerItem(
              isAnswer: false,
              lesson: _provider!.listLesson[index],
              mission: missions[missionIndex],
              color: Colors.green,
              index: index)
        ],
      );
          })
      );
  }
  
  Widget _buildAnswerItem(
      {required bool isAnswer,
        required LessonModel lesson,
        required Mission mission,
        required Color color,
        required int index}) {
    double scoreArg = 0.0;
    for (var i in lesson.missions!) {
      scoreArg += i.score!;
    }
    scoreArg = scoreArg/lesson.missions!.length;
    return InkWell(
      onTap: () {
        if (!isAnswer) {
          toggleOverlay(index);
        } else {
          _missionTestProvider!.setCurrentMission(mission);
          _missionTestProvider!.setListFileVideo(mission.files!.first);
          _missionTestProvider!.setListFileImage(mission.files!.elementAt(1));
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MissionTestScreen()));
        }
      },
      child: Container(
        margin: EdgeInsets.only(top: height),
        child: Row(
          children: [
            _buildCircleColor(color: color, isAnswer: isAnswer),
            _buildAnswer(isAnswer, lesson, mission)
          ],
        ),
      ),
    );
  }

  @override
  void onGetListLessonComplete(list) {
    setState(() {
      isOpenList = List.generate(list.length, (index) => false);
    });
    _provider!.setListLesson(list);
    print('list.length: ${list.length}');
    setState(() {
      _loading!.hide();
    });
  }

  @override
  void onGetListLessonError() {
  }
}
