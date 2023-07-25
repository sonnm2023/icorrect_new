import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/presenters/test_room_presenter.dart';
import 'package:icorrect/src/provider/test_provider.dart';
import 'package:provider/provider.dart';

class SaveTheTestWidget extends StatelessWidget {
  const SaveTheTestWidget({super.key, required this.testRoomPresenter});

  final TestRoomPresenter testRoomPresenter;

  @override
  Widget build(BuildContext context) {
    return Consumer<TestProvider>(
      builder: (context, testProvider, child) {
        return Visibility(
          visible: testProvider.isVisibleSaveTheTest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(child: SizedBox()),
              Container(
                width: double.infinity,
                height: 60,
                color: Colors.blueAccent,
                child: ElevatedButton(
                  onPressed: () {
                    testRoomPresenter.clickSaveTheTest();
                  },
                  child: const Text(
                    "SAVE THE TEST",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
