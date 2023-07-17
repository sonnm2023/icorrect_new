import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/presenters/test_presenter.dart';
import 'package:icorrect/src/provider/test_provider.dart';
import 'package:provider/provider.dart';

class SaveTheTestWidget extends StatelessWidget {
  const SaveTheTestWidget({super.key, required this.testPresenter});

  final TestPresenter testPresenter;

  @override
  Widget build(BuildContext context) {
    return Consumer<TestProvider>(
      builder: (context, testProvider, child) {
        return Visibility(
          visible: testProvider.isVisibleSaveTheTest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage('assets/images/ic_completed.png'),
                width: 100,
              ),
              const Text(
                'Congratulations',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'You finished a speaking test',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColor.defaultGrayColor,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 250,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    //TODO
                    testPresenter.clickSaveTheTest();
                  },
                  child: const Text("Save the test"),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
