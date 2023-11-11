// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/core/connectivity_service.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/presenters/change_password_presenter.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/views/widget/default_material_button.dart';
import 'package:icorrect/src/views/widget/password_input_widget.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    implements ChangePasswordViewContract {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController currentPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmNewPasswordController;
  bool isAvailable = false;
  ChangePasswordPresenter? _changePasswordPresenter;
  late AuthProvider _authProvider;
  final connectivityService = ConnectivityService();

  @override
  void initState() {
    currentPasswordController = TextEditingController(text: '');
    newPasswordController = TextEditingController(text: '');
    confirmNewPasswordController = TextEditingController(text: '');

    _changePasswordPresenter = ChangePasswordPresenter(this);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);

    /*
    confirmNewPasswordController.addListener(() {
    if (confirmNewPasswordController.text.trim() != newPasswordController.text.trim()) {
        showToastMsg(
          msg: "Confirm new password must be equal new password!",
          toastState: ToastStates.error,
        );

        setState(() {
          isAvailable = true;
        });
      }
    });
    */
    super.initState();
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    // _authProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          StringConstants.change_password_screen_title,
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColor.defaultPurpleColor,
            fontsSize: FontsSize.fontSize_18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        leading: const BackButton(color: AppColor.defaultPurpleColor),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Divider(
            color: AppColor.defaultPurpleColor,
            thickness: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(CustomSize.size_30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PasswordInputWidget(
                          passwordController: currentPasswordController,
                          type: PasswordType.currentPassword),
                      PasswordInputWidget(
                          passwordController: newPasswordController,
                          type: PasswordType.newPassword),
                      PasswordInputWidget(
                          passwordController: confirmNewPasswordController,
                          type: PasswordType.confirmNewPassword),
                      const SizedBox(height: 20),
                      _buildSaveButton(),
                      const SizedBox(height: 10),
                      _buildCancelButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return DefaultMaterialButton(
      padding: const EdgeInsets.symmetric(vertical: 1),
      onPressed: () async {
        if (newPasswordController.text.trim() !=
            confirmNewPasswordController.text.trim()) {
          showToastMsg(
            msg: StringConstants.confirm_new_password_error_message,
            toastState: ToastStatesType.error,
          );
        } else {
          if (_formKey.currentState!.validate() &&
              _authProvider.isProcessing == false) {
            _authProvider.updateProcessingStatus(isProcessing: true);

            _changePasswordPresenter!.changePassword(
              context,
              currentPasswordController.text.trim(),
              newPasswordController.text.trim(),
              confirmNewPasswordController.text.trim(),
            );
            // var connectivity = await connectivityService.checkConnectivity();
            // if (connectivity.name != StringConstants.connectivity_name_none) {
            //   _authProvider.updateProcessingStatus(isProcessing: true);

            //   _changePasswordPresenter!.changePassword(
            //     context,
            //     currentPasswordController.text.trim(),
            //     newPasswordController.text.trim(),
            //     confirmNewPasswordController.text.trim(),
            //   );
            // } else {
            //   //Show connect error here
            //   if (kDebugMode) {
            //     print("DEBUG: Connect error here!");
            //   }
            //   Utils.showConnectionErrorDialog(context);

            //   Utils.addConnectionErrorLog(context);
            // }
          }
        }
      },
      background: AppColor.defaultPurpleColor,
      text: StringConstants.save_change_button_title,
      fontSize: FontsSize.fontSize_14,
      height: CustomSize.size_50,
      radius: 20,
    );
  }

  Widget _buildCancelButton() {
    return DefaultMaterialButton(
      padding: const EdgeInsets.symmetric(vertical: 1),
      onPressed: () {
        Navigator.of(context).pop();
      },
      background: AppColor.defaultWhiteColor,
      textColor: AppColor.defaultPurpleColor,
      text: StringConstants.cancel_button_title,
      fontSize: FontsSize.fontSize_14,
      height: CustomSize.size_50,
      radius: 20,
      hasBorder: true,
    );
  }

  @override
  void onChangePasswordComplete() {
    _authProvider.updateProcessingStatus(isProcessing: false);

    //Go back login screen
    Navigator.of(context).pop();
  }

  @override
  void onChangePasswordError(String message) {
    _authProvider.updateProcessingStatus(isProcessing: false);

    //Show error message
    showToastMsg(
      msg: message,
      toastState: ToastStatesType.error,
    );
  }
}
