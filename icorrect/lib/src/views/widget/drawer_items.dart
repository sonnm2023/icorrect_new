import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/presenters/homework_presenter.dart';
import 'package:provider/provider.dart';
import '../../data_sources/constants.dart';
import '../../data_sources/utils.dart';
import '../../provider/homework_provider.dart';
import '../screen/auth/change_password_screen.dart';

Widget navbarItems({
  required BuildContext context,
  required HomeWorkPresenter? homeWorkPresenter,
}) {
  return ListView(
    // padding: EdgeInsets.zero,
    children: [
      Consumer<HomeWorkProvider>(
        builder: (context, homeWorkProvider, child) {
          return Utils.drawHeader(homeWorkProvider.currentUser);
        },
      ),
      ListTile(
        title: const Text(
          "Home",
          style: CustomTextStyle.textGrey_15,
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
      //TODO: PHRASE 2
      /*ListTile(
        title: const Text(
          "Practice",
          style: CustomTextStyle.textGrey_15,
        ),
        leading: const Icon(
          Icons.menu_book_outlined,
          color: AppColor.defaultGrayColor,
        ),
        onTap: () {
          Utils.toggleDrawer();

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const PracticeScreen(),
            ),
          );
        },
      ),*/
      ListTile(
        title: const Text(
          "Change password",
          style: CustomTextStyle.textGrey_15,
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
        title: const Text(
          "Logout",
          style: CustomTextStyle.textGrey_15,
        ),
        leading: const Icon(
          Icons.logout_outlined,
          color: AppColor.defaultGrayColor,
        ),
        onTap: () {
          Utils.showLogoutConfirmDialog(context: context, homeWorkPresenter: homeWorkPresenter);
        },
      ),
    ],
  );
}
