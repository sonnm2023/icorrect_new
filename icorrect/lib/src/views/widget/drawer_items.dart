import 'package:flutter/material.dart';
import 'package:icorrect/src/views/screen/home/homework_screen.dart';
import 'package:provider/provider.dart';

import '../../data_sources/constants.dart';
import '../../data_sources/utils.dart';
import '../../provider/homework_provider.dart';
import '../screen/auth/change_password_screen.dart';

Widget items(BuildContext context) {
  return ListView(
    children: [
      Consumer<HomeWorkProvider>(builder: (context, homeWorkProvider, child) {
        return Utils.drawHeader(homeWorkProvider.currentUser);
      }),
      ListTile(
        title: const Text(
          "Home",
          style: CustomTextStyle.textGrey_15,
        ),
        leading: const Icon(Icons.home_outlined),
        onTap: () {
          Utils.toggleDrawer();

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const HomeWorkScreen(),
            ),
          );
        },
      ),
      ListTile(
        title: const Text(
          "Change password",
          style: CustomTextStyle.textGrey_15,
        ),
        leading: const Icon(Icons.password_outlined),
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
        leading: const Icon(Icons.logout_outlined),
        onTap: () {
          Utils.toggleDrawer();
          Utils.showLogoutConfirmDialog(context);
        },
      ),
    ],
  );
}