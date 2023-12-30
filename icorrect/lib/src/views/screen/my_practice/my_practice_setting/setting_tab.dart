import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/provider/my_practice_topics_provider.dart';
import 'package:provider/provider.dart';

class SettingTabScreen extends StatefulWidget {
  const SettingTabScreen({super.key});

  @override
  State<SettingTabScreen> createState() => _SettingTabScreenState();
}

class _SettingTabScreenState extends State<SettingTabScreen>
    with AutomaticKeepAliveClientMixin<SettingTabScreen> {
  MyPracticeTopicsProvider? _myPracticeTopicsProvider;

  @override
  void initState() {
    super.initState();
    _myPracticeTopicsProvider =
        Provider.of<MyPracticeTopicsProvider>(context, listen: false);
    _myPracticeTopicsProvider!.initSettings();
  }

  @override
  void dispose() {
    _myPracticeTopicsProvider!.clearSettings();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      itemCount: _myPracticeTopicsProvider!.settings.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      Utils.multiLanguage(
                          _myPracticeTopicsProvider!.settings[index].title),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline_outlined,
                          size: 30,
                        ),
                        onPressed: () {
                          if (index > 3) {
                            if (_myPracticeTopicsProvider!
                                    .settings[index].value >
                                _myPracticeTopicsProvider!
                                    .settings[index].step) {
                              _myPracticeTopicsProvider!
                                  .updateSettings(index, false);
                            }
                          } else {
                            _myPracticeTopicsProvider!
                                .updateSettings(index, false);
                          }
                        },
                      ),
                      Consumer<MyPracticeTopicsProvider>(
                          builder: (context, provider, child) {
                        int fractionDigits = 0;
                        if (index > 3) fractionDigits = 2;
                        return Container(
                          width: 80,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColor.defaultPurpleColor,
                              width: 1.0,
                            ),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                top: 5,
                                right: 10,
                                bottom: 5,
                              ),
                              child: Text(
                                provider.settings[index].value
                                    .toStringAsFixed(fractionDigits),
                              ),
                            ),
                          ),
                        );
                      }),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle_outline_outlined,
                          size: 30,
                        ),
                        onPressed: () {
                          _myPracticeTopicsProvider!
                              .updateSettings(index, true);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(
                color: AppColor.defaultGrayColor,
              )
            ],
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
