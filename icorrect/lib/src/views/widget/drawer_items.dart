import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/presenters/homework_presenter.dart';
import 'package:icorrect/src/provider/my_tests_list_provider.dart';
import 'package:icorrect/src/views/screen/my_tests_list/my_tests_list.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/language_selection_dialog.dart';
import 'package:icorrect/src/views/screen/video_authentication/user_auth_detail_status_widget.dart';
import 'package:provider/provider.dart';
import '../../data_sources/constants.dart';
import '../../data_sources/utils.dart';
import '../../provider/homework_provider.dart';
import '../screen/auth/change_password_screen.dart';
import '../screen/practice/practice_screen.dart';

Widget navbarItems({
  required BuildContext context,
  required HomeWorkPresenter? homeWorkPresenter,
}) {
  return ListView(
    // padding: EdgeInsets.zero,
    children: [
      Consumer<HomeWorkProvider>(
        builder: (context, homeWorkProvider, child) {
          return Utils.drawHeader(context, homeWorkProvider.currentUser);
        },
      ),
      ListTile(
        title: Text(
          Utils.multiLanguage(
            StringConstants.home_menu_item_title,
          ),
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColor.defaultGrayColor,
            fontsSize: FontsSize.fontSize_15,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: const Icon(
          Icons.home_outlined,
          color: AppColor.defaultGrayColor,
        ),
        onTap: () {
          Utils.toggleDrawer();

          /*Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomeWorkScreen(),
            ),
          );*/
        },
      ),
      //Comment for build release 20231129 - version 1.1.9 (build 1)
      /*
      ListTile(
        title: Text(
          Utils.multiLanguage(
            StringConstants.practice_menu_item_title,
          ),
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColor.defaultGrayColor,
            fontsSize: FontsSize.fontSize_15,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: const Icon(
          Icons.menu_book,
          color: AppColor.defaultGrayColor,
        ),
        onTap: () {
          Utils.toggleDrawer();

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const PracticeScreen(),
            ),
          );
        },
      ),
      ListTile(
        title: Text(
          Utils.multiLanguage(
            StringConstants.my_test_menu_item_title,
          ),
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColor.defaultGrayColor,
            fontsSize: FontsSize.fontSize_15,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: const Icon(
          Icons.list_alt,
          color: AppColor.defaultGrayColor,
        ),
        onTap: () {
          Utils.toggleDrawer();

          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider(
                    create: (_) => MyTestsListProvider(),
                    child: const MyTestsList())),
          );
        },
      ),
     */
      ListTile(
        title: Text(
          Utils.multiLanguage(
            StringConstants.change_password_menu_item_title,
          ),
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColor.defaultGrayColor,
            fontsSize: FontsSize.fontSize_15,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: const Icon(
          Icons.password_outlined,
          color: AppColor.defaultGrayColor,
        ),
        onTap: () {
          Utils.toggleDrawer();

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ChangePasswordScreen(),
            ),
          );
        },
      ),
      ListTile(
        title: Text(
          Utils.multiLanguage(
            StringConstants.video_authen_menu_item_title,
          ),
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColor.defaultGrayColor,
            fontsSize: FontsSize.fontSize_15,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: const Icon(
          Icons.video_camera_front_outlined,
          color: AppColor.defaultGrayColor,
        ),
        onTap: () {
          Utils.toggleDrawer();

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const UserAuthDetailStatus(),
            ),
          );
        },
      ),
      ListTile(
        title: Text(
          Utils.multiLanguage(
            StringConstants.multi_language,
          ),
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColor.defaultGrayColor,
            fontsSize: FontsSize.fontSize_15,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: const Icon(
          Icons.language,
          color: AppColor.defaultGrayColor,
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (builder) {
              return const LanguageSelectionDialog();
            },
          );
        },
      ),
      ListTile(
        title: Text(
          Utils.multiLanguage(
            StringConstants.logout_menu_item_title,
          ),
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColor.defaultGrayColor,
            fontsSize: FontsSize.fontSize_15,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: const Icon(
          Icons.logout_outlined,
          color: AppColor.defaultGrayColor,
        ),
        onTap: () {
          Utils.showLogoutConfirmDialog(
            context: context,
            homeWorkPresenter: homeWorkPresenter,
          );
        },
      ),
    ],
  );
}
