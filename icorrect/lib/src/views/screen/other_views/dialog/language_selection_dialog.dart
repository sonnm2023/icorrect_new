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
    if (null != localization.currentLocale) {
      if (localization.currentLocale!.languageCode == "vn") {
        _character = LanguageSelector.vietnamese;
      } else if (localization.currentLocale!.languageCode == "en") {
        _character = LanguageSelector.english;
      }
    }
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
                vertical: 10,
                horizontal: 10,
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      _buildItem(LanguageSelector.english),
                      _buildItem(LanguageSelector.vietnamese),
                    ],
                  ),
                  Positioned(
                    top: -10,
                    right: -10,
                    child: InkWell(
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: Image(
                            image: AssetImage("assets/images/ic_close_black.png"),
                            width: 20,
                            height: 20,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                      onTap: () {
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

  String _getLanguageCode(LanguageSelector languageSelector) {
    String code = '';
    switch (languageSelector) {
      case LanguageSelector.vietnamese:
        {
          code = 'vn';
          break;
        }
      case LanguageSelector.english:
        {
          code = 'en';
          break;
        }
    }

    return code;
  }

  String _getLanguageName(LanguageSelector languageSelector) {
    String name = '';
    switch (languageSelector) {
      case LanguageSelector.vietnamese:
        {
          name = StringConstants.vn;
          break;
        }
      case LanguageSelector.english:
        {
          name = StringConstants.ens;
          break;
        }
    }

    return name;
  }

  Widget _buildItem(LanguageSelector languageSelector) {
    String languageName = _getLanguageName(languageSelector);
    String code = _getLanguageCode(languageSelector);

    return ListTile(
      title: InkWell(
        onTap: () {
          bool isChanged = localization.currentLocale!.languageCode != code;
          if (isChanged) {
            _changeLanguage(code, languageSelector);
          }
        },
        child: Text(
          Utils.multiLanguage(languageName),
        ),
      ),
      leading: Radio<LanguageSelector>(
        value: languageSelector,
        groupValue: _character,
        onChanged: (LanguageSelector? value) {
          bool isChanged = localization.currentLocale!.languageCode != code;
          if (isChanged) {
            _changeLanguage(code, value!);
          }
        },
      ),
    );
  }

  void _changeLanguage(String code, LanguageSelector languageSelector) {
    setState(() {
      _character = languageSelector;
    });

    localization.translate(code);
    if (null != homeWorkProvider) {
      homeWorkProvider!.prepareToUpdateFilterString();
    }
  }
}
