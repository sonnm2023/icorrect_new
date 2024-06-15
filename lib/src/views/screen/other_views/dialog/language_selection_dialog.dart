import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/provider/homework_provider.dart';
import 'package:icorrect/src/provider/my_practice_list_provider.dart';
import 'package:provider/provider.dart';

class LanguageSelectionDialog extends StatefulWidget {
  const LanguageSelectionDialog({super.key});

  @override
  State<LanguageSelectionDialog> createState() =>
      _LanguageSelectionDialogState();
}

class _LanguageSelectionDialogState extends State<LanguageSelectionDialog> {
  double w = 0, h = 0;
  final FlutterLocalization localization = FlutterLocalization.instance;
  HomeWorkProvider? homeWorkProvider;
  MyPracticeListProvider? myPracticeListProvider;

  @override
  void initState() {
    homeWorkProvider = Provider.of<HomeWorkProvider>(context, listen: false);
    myPracticeListProvider =
        Provider.of<MyPracticeListProvider>(context, listen: false);
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
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.g_translate,
                      color: AppColor.defaultPurpleColor, size: 35),
                  const SizedBox(height: 10),
                  Text(
                    Utils.multiLanguage(
                        StringConstants.select_your_language_title)!,
                    style: const TextStyle(
                      color: AppColor.defaultPurpleColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _languageItem(false),
                  _languageItem(true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageItem(bool isEnglish) {
    return InkWell(
      splashColor: AppColor.defaultPurpleColor,
      onTap: () {
        localization.translate(isEnglish ? 'en' : 'vi');
        if (null != homeWorkProvider) {
          homeWorkProvider!.prepareToUpdateFilterString();
        }
        if (null != myPracticeListProvider) {
          myPracticeListProvider!.refreshList(true);
        }
        Navigator.of(context).pop();
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image(
                  image: AssetImage(
                      isEnglish ? AppAsset.imgEnglish : AppAsset.imgVietName),
                  width: 30,
                  height: 30,
                ),
                const SizedBox(width: 20),
                Text(
                  Utils.multiLanguage(
                      isEnglish ? StringConstants.ens : StringConstants.vn)!,
                  style: const TextStyle(
                    color: AppColor.defaultPurpleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
            const Icon(
              Icons.navigate_next,
              size: 30,
              color: AppColor.defaultPurpleColor,
            )
          ],
        ),
      ),
    );
  }
}
