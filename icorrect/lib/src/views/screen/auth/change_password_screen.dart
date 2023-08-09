import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constants.dart';
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
        title: const Text(
          'Change password',
          style: TextStyle(color: AppColor.defaultPurpleColor),
        ),
        centerTitle: true,
        leading: const BackButton(color: AppColor.defaultPurpleColor),
        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(4.0),
            child: Divider(
              color: AppColor.defaultPurpleColor,
              thickness: 1,
            )),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(15),
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
      onPressed: () {
        if (newPasswordController.text.trim() !=
            confirmNewPasswordController.text.trim()) {
          showToastMsg(
            msg: "Confirm new password must be equal new password!",
            toastState: ToastStatesType.error,
          );
        } else {
          if (_formKey.currentState!.validate() &&
              _authProvider.isProcessing == false) {
            _authProvider.updateProcessingStatus();

            _changePasswordPresenter!.changePassword(
              currentPasswordController.text.trim(),
              newPasswordController.text.trim(),
              confirmNewPasswordController.text.trim(),
            );
          }
        }
      },
      background: AppColor.defaultPurpleColor,
      text: 'Save change',
      fontSize: 17,
      height: 50,
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
      text: 'Cancel',
      fontSize: 17,
      height: 50,
      radius: 20,
      hasBorder: true,
    );
  }

  @override
  void onChangePasswordComplete() {
    _authProvider.updateProcessingStatus();

    //Go back login screen
    Navigator.of(context).pop();
  }

  @override
  void onChangePasswordError(String message) {
    _authProvider.updateProcessingStatus();

    //Show error message
    showToastMsg(
      msg: message,
      toastState: ToastStatesType.error,
    );
  }
}
