// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/presenters/change_password_presenter.dart';
import 'package:icorrect/src/views/widget/default_material_button.dart';
import 'package:icorrect/src/views/widget/password_input_widget.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with AutomaticKeepAliveClientMixin
    implements ChangePasswordViewContract {
  final _formKey = GlobalKey<FormState>(debugLabel: "ChangePasswordScreen");
  bool isAvailable = false;
  ChangePasswordPresenter? _changePasswordPresenter;
  // CircleLoading? _loading;
  // late AuthProvider _authProvider;
  late TextEditingController currentPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmNewPasswordController;
  final FocusNode _currentPasswordFocusNode = FocusNode();
  final FocusNode _newPasswordFocusNode = FocusNode();
  final FocusNode _confirmNewPasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _changePasswordPresenter = ChangePasswordPresenter(this);
    // _loading = CircleLoading();
    // _authProvider = Provider.of<AuthProvider>(context, listen: false);
    currentPasswordController = TextEditingController(text: '');
    newPasswordController = TextEditingController(text: '');
    confirmNewPasswordController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (kDebugMode) {
      print("DEBUG: ChangePasswordScreen - build");
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Utils.multiLanguage(StringConstants.change_password_screen_title)!,
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
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              CustomScrollView(
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
                              type: PasswordType.currentPassword,
                              focusNode: _currentPasswordFocusNode,
                            ),
                            PasswordInputWidget(
                              passwordController: newPasswordController,
                              type: PasswordType.newPassword,
                              focusNode: _newPasswordFocusNode,
                            ),
                            PasswordInputWidget(
                              passwordController: confirmNewPasswordController,
                              type: PasswordType.confirmNewPassword,
                              focusNode: _confirmNewPasswordFocusNode,
                            ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return DefaultMaterialButton(
      padding: const EdgeInsets.symmetric(vertical: 1),
      onPressed: () async {
        _hideKeyboard();

        if (newPasswordController.text.trim() ==
            currentPasswordController.text.trim()) {
          showToastMsg(
            msg: Utils.multiLanguage(
              StringConstants.old_password_equals_new_password_error_message,
            )!,
            toastState: ToastStatesType.error,
            isCenter: false,
          );
        } else if (newPasswordController.text.trim() !=
            confirmNewPasswordController.text.trim()) {
          showToastMsg(
            msg: Utils.multiLanguage(
              StringConstants.confirm_new_password_error_message,
            )!,
            toastState: ToastStatesType.error,
            isCenter: false,
          );
        } else {
          if (_formKey.currentState!.validate()) {
            // &&
            //     _authProvider.isChanging == false) {
            //   _authProvider.updateChangePasswordStatus(processing: true);
            Utils.checkInternetConnection().then(
              (isConnected) {
                if (isConnected) {
                  //Add firebase log
                  Utils.addFirebaseLog(
                    eventName: "button_click",
                    parameters: {
                      "button_name": "change password",
                    },
                  );
                  _changePasswordPresenter!.changePassword(
                    context,
                    currentPasswordController.text.trim(),
                    newPasswordController.text.trim(),
                    confirmNewPasswordController.text.trim(),
                  );
                } else {
                  _handleError();
                }
              },
            );
          }
        }
      },
      background: AppColor.defaultPurpleColor,
      text: Utils.multiLanguage(StringConstants.save_change_button_title),
      fontSize: FontsSize.fontSize_14,
      height: CustomSize.size_50,
      radius: 20,
    );
  }

  void _handleError() {
    //Show connect error here
    if (kDebugMode) {
      print("DEBUG: Connect error here!");
    }
    // _authProvider.updateChangePasswordStatus(processing: false);
    Utils.showConnectionErrorDialog(context);
    Utils.addConnectionErrorLog(context);
  }

  Widget _buildCancelButton() {
    return DefaultMaterialButton(
      padding: const EdgeInsets.symmetric(vertical: 1),
      onPressed: () {
        _hideKeyboard();

        Navigator.of(context).pop();
      },
      background: AppColor.defaultWhiteColor,
      textColor: AppColor.defaultPurpleColor,
      text: Utils.multiLanguage(StringConstants.cancel_button_title),
      fontSize: FontsSize.fontSize_14,
      height: CustomSize.size_50,
      radius: 20,
      hasBorder: true,
    );
  }

  void _hideKeyboard() {
    _currentPasswordFocusNode.unfocus();
    _newPasswordFocusNode.unfocus();
    _confirmNewPasswordFocusNode.unfocus();
  }

  @override
  void onChangePasswordSuccess(String message) {
    showToastMsg(
      msg: message,
      toastState: ToastStatesType.success,
      isCenter: false,
    );

    //Go back login screen
    Navigator.of(context).pop();
  }

  @override
  void onChangePasswordError(String message) {
    showToastMsg(
      msg: message,
      toastState: ToastStatesType.error,
      isCenter: false,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
