import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/provider/homework_provider.dart';
import 'package:provider/provider.dart';

class LanguageSelectionDialog extends StatefulWidget {
  const LanguageSelectionDialog({super.key});

  @override
  State<LanguageSelectionDialog> createState() =>
      _LanguageSelectionDialogState();
}

class _LanguageSelectionDialogState extends State<LanguageSelectionDialog> {
  double w = 0, h = 0;
  LanguageSelector? _character;
  final FlutterLocalization localization = FlutterLocalization.instance;
  HomeWorkProvider? homeWorkProvider;

  @override
  void initState() {
    homeWorkProvider = Provider.of<HomeWorkProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Center(
      child: Wrap(
        children: [
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 10,
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      Utils.multiLanguage(StringConstants.ens),
                    ),
                    leading: Radio<LanguageSelector>(
                      value: LanguageSelector.english,
                      groupValue: _character,
                      onChanged: (LanguageSelector? value) {
                        setState(() {
                          _character = value;
                        });
                        localization.translate('en');
                        if (null != homeWorkProvider) {
                          homeWorkProvider!.prepareToUpdateFilterString();
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(
                      Utils.multiLanguage(StringConstants.vn),
                    ),
                    leading: Radio<LanguageSelector>(
                      value: LanguageSelector.vietnamese,
                      groupValue: _character,
                      onChanged: (LanguageSelector? value) {
                        setState(() {
                          _character = value;
                        });
                        localization.translate('vn');
                        if (null != homeWorkProvider) {
                          homeWorkProvider!.prepareToUpdateFilterString();
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
