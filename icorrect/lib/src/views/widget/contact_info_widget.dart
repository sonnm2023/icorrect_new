import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ContactInfoWidget extends StatefulWidget {
  const ContactInfoWidget({super.key});

  @override
  State<ContactInfoWidget> createState() => _ContactInfoWidgetState();
}

class _ContactInfoWidgetState extends State<ContactInfoWidget> {
  PackageInfo _packageInfo = PackageInfo(
    appName: StringConstants.unknown,
    packageName: StringConstants.unknown,
    version: StringConstants.unknown,
    buildNumber: StringConstants.unknown,
    buildSignature: StringConstants.unknown,
    installerStore: StringConstants.unknown,
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;

      //Save app version into local
      Utils.setAppVersion(info.version);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${_packageInfo.appName} version ${_packageInfo.version}',
            style: CustomTextStyle.textWithCustomInfo(
              context: context,
              color: AppColor.defaultGrayColor,
              fontsSize: FontsSize.fontSize_14,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            Utils.multiLanguage(
              StringConstants.contact,
            )!,
            style: CustomTextStyle.textWithCustomInfo(
              context: context,
              color: AppColor.defaultGrayColor,
              fontsSize: FontsSize.fontSize_14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            StringConstants.csupporter,
            style: CustomTextStyle.textWithCustomInfo(
              context: context,
              color: AppColor.defaultBlackColor,
              fontsSize: FontsSize.fontSize_13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
