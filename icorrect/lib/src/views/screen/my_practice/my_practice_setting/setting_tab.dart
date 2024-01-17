import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/provider/my_practice_list_provider.dart';
import 'package:provider/provider.dart';

class SettingTabScreen extends StatefulWidget {
  const SettingTabScreen({super.key});

  @override
  State<SettingTabScreen> createState() => _SettingTabScreenState();
}

class _SettingTabScreenState extends State<SettingTabScreen>
    with AutomaticKeepAliveClientMixin<SettingTabScreen> {
  // MyPracticeTopicsProvider? _myPracticeTopicsProvider;
  MyPracticeListProvider? _practiceListProvider;

  @override
  void initState() {
    super.initState();
    _practiceListProvider =
        Provider.of<MyPracticeListProvider>(context, listen: false);
    if (_practiceListProvider!.settings.isNotEmpty) {
      _practiceListProvider!.clearSettings();
    }
    _practiceListProvider!.initSettings();
  }

  @override
  void dispose() {
    _practiceListProvider!.clearSettings();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      itemCount: _practiceListProvider!.settings.length,
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
                          _practiceListProvider!.settings[index].title)!,
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
                            if (_practiceListProvider!.settings[index].value >
                                _practiceListProvider!.settings[index].step) {
                              _practiceListProvider!
                                  .updateSettings(index: index, isAdd: false);
                            }
                          } else {
                            _practiceListProvider!
                                .updateSettings(index: index, isAdd: false);
                          }
                        },
                      ),
                      Consumer<MyPracticeListProvider>(
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
                          if (index == 2) {
                            if (_practiceListProvider!.settings[index].value <
                                1) {
                              _practiceListProvider!
                                  .updateSettings(index: index, isAdd: true);
                            }
                          } else {
                            _practiceListProvider!
                                .updateSettings(index: index, isAdd: true);
                          }
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
