import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:icorrect/src/models/module_lession_models/ai_response_model.dart';
import 'package:icorrect/src/presenters/ai_response_presenter.dart';
import 'package:icorrect/src/provider/ai_response_provider.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_color.dart';

class AiResponseScreen extends StatefulWidget {
  const AiResponseScreen({super.key});

  @override
  State<AiResponseScreen> createState() => _AiResponseScreenState();
}

class _AiResponseScreenState extends State<AiResponseScreen> implements AiResponseViewContract{
  AiResponsePresenter? _presenter;

  List<List<Phoneme>> listText = [];
  AiResponseProvider? _provider;

  @override
  void initState() {
    super.initState();
    _presenter = AiResponsePresenter(this);
    _provider = Provider.of<AiResponseProvider>(context, listen: false);
    _presenter!.getAiResponseScore();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _provider!.setIsMissionFinished(true);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _provider!.isMissionFinished? Colors.green.shade300 : Colors.redAccent.shade100,
        automaticallyImplyLeading: true,
        title: Center(
          child: Text(_provider!.isMissionFinished ? 'Nhiệm vụ thành công' : 'Nhiệm vụ thất bại',
            style: const TextStyle(
                color: AppColor.defaultAppColor,
                fontWeight: FontWeight.w500,
                fontSize: 23
            ),),
        ),
      ),
      backgroundColor: _provider!.isMissionFinished? Colors.green.shade300 : Colors.redAccent.shade100,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _buildScore(),
          const SizedBox(height: 20),
          Text(_provider!.isMissionFinished? 'Chúc mừng bạn đã hoàn thành nhiệm vụ':'Bạn cần đạt tối thiểu 50% để hoàn thành nhiệm vụ',
              textAlign: TextAlign.center,
              style: const TextStyle (
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white
              )),
          _buildTextResponse(),
          const SizedBox(height: 40),
          _buildTryAgainButton(),
          const SizedBox(height: 20),
          _buildSkipButton()
        ],
      ),
    );
  }

  Widget _buildScore() {
    double w = MediaQuery.of(context).size.width;
    return Center(
      child: Column(
        children: [
          Stack (
            alignment: Alignment.center,
            children: [
              Container(
                width: w / 3 + 20,
                height: w / 3 + 20,
                decoration: BoxDecoration (
                    borderRadius: BorderRadius.circular(w/6 + 10),
                    color: _provider!.isMissionFinished? Colors.green : Colors.red
                ),
              ),
              Container(
                width: w / 3,
                height: w / 3,
                decoration: BoxDecoration (
                    borderRadius: BorderRadius.circular(w/6),
                    color: Colors.white
                ),
              ),
              Text((_provider!.aiResponseModel!.score*100).toStringAsFixed(0), style: TextStyle(
                  color: _provider!.isMissionFinished? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                  fontSize: 26
              ))
            ],
          ),
          _provider!.isMissionFinished?const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rate_rounded, size: 40, color: Colors.orange,),
              Icon(Icons.star_rate_rounded, size: 40, color: Colors.grey,),
              Icon(Icons.star_rate_rounded, size: 40, color: Colors.grey,),
            ],
          ) : const SizedBox()
        ],
      ),
    );
  }

  Widget _buildTextResponse() {
    double w = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.all(10),
      color: Colors.white,
      height: w/2,
      child: Container(
        padding: const EdgeInsets.all(5),
        child: Column (
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.headphones, size: 28),
                SizedBox(width: 5),
                Icon(Icons.volume_down, size: 28)
              ],
            ),
            const SizedBox(height: 5),
            Container(
              margin: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  for(var i in listText)
                    _buildWords(i)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTryAgainButton() {
    return InkWell(
      onTap: () {

      },
      child: Container (
        margin: const EdgeInsets.symmetric(horizontal: 20),
        width: MediaQuery.of(context).size.width,
        height: 50,
        decoration: BoxDecoration (
            color: _provider!.isMissionFinished? Colors.blue : Colors.green.shade400,
            borderRadius: BorderRadius.circular(10)
        ),
        child: Center(
            child: Text(
              _provider!.isMissionFinished? 'Làm lại nhiệm vụ' : 'Thử nói lại',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
            )),
      ),
    );
  }

  Widget _buildSkipButton() {
    return InkWell(
      onTap: () {

      },
      child: Container (
        margin: const EdgeInsets.symmetric(horizontal: 20),
        width: MediaQuery.of(context).size.width,
        height: 50,
        decoration: BoxDecoration (
            color: Colors.yellow.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10)
        ),
        child: Center(
            child: Text(
              _provider!.isMissionFinished? 'Nhiệm vụ tiếp theo' : 'Bỏ qua và tiếp tục nhiệm vụ khác',
              style: const TextStyle(
                  color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 17),
            )),
      ),
    );
  }

  Widget _buildWords(List<Phoneme> list) {
    return InkWell(
      onTap: () {
        String text = '';
        for (var i in list) {
          text += i.text!;
        }
        _showTextDetail(list, text);
      },
      child: Row (
        children: [
          for(var i in list)
            _buildRichText(i.text!, i.score!),
          const Text(' ')
        ],
      ),
    );
  }

  Widget _buildRichText(String text, double score) {
    return Text(text, style: TextStyle(
        color: setColorText(score),
        fontWeight: FontWeight.w400,
        fontSize: 20,
        decoration: TextDecoration.none
    ));
  }

  void _showTextDetail(List<Phoneme> phoneme, String text) {
    showDialog(context: context, builder: (context) {
      return Center(
        child: Wrap(
          children: [
            Container(
              margin: const EdgeInsets.all(15),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/1.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Container(
                margin: const EdgeInsets.all(5),
                child: Column (
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(text, style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            decoration: TextDecoration.none
                        ),),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.mic_rounded, size: 28),
                            SizedBox(width: 5),
                            Icon(Icons.volume_down, size: 28)
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const Text('/', style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            decoration: TextDecoration.none
                        )),
                        for(var i in phoneme)
                          _buildRichText(i.ipa!, i.score!),
                        const Text('/',style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            decoration: TextDecoration.none
                        )),
                      ],
                    ),
                    const SizedBox(height: 20),
                    DataTable(
                        columns: const [
                          DataColumn(label: Text('Sound')),
                          DataColumn(label: Text('Native score')),
                          DataColumn(label: Text('You said'))
                        ],
                        rows: [
                          for(var i in phoneme)
                            DataRow(cells: [
                              DataCell(Text('/${i.text}/')),
                              DataCell(Text((i.score!*100).toStringAsFixed(1))),
                              DataCell(Text(i.decision!, style: TextStyle(color: setColorText(i.score!))))
                            ])
                        ]),
                    const Spacer(),
                    TextButton(
                        onPressed: () {},
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 70),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.orange.shade600),
                            child: const Text(
                                'Đóng',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16
                                )))),
                    const SizedBox(height: 10)
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Color setColorText(double score) {
    if (score > 0.0 && score < 0.5) {
      return Colors.red;
    } else if (score >= 0.5 && score < 0.8) {
      return Colors.yellow;
    } else if (score >=0.8 && score <= 1) {
      return Colors.green;
    } else {
      return Colors.white;
    }
  }

  void getText(Data data) {
    for (Word word in data.words) {
      listText.add(word.phonemes);
    }
  }

  @override
  void getAiResponseScoreComplete(AiResponseModel model) {
    _provider!.setAiResponseModel(model);
    if (model.score >= 0.5) {
      _provider!.setIsMissionFinished(true);
    } else {
      _provider!.setIsMissionFinished(false);
    }
    setState(() {
      getText(model.data);
    });
  }

  @override
  void getAiResponseScoreError() {
    // TODO: implement getAiResponseScoreError
  }

  @override
  void onCounting(String strCount, int count) {
    // TODO: implement onCounting
  }
}