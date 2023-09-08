import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences_keys.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/presenters/login_presenter.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/views/screen/home/homework_screen.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/circle_loading.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/message_dialog.dart';
import 'package:icorrect/src/views/widget/contact_info_widget.dart';
import 'package:icorrect/src/views/widget/default_material_button.dart';
import 'package:icorrect/src/views/widget/default_text.dart';
import 'package:icorrect/src/views/widget/default_text_button.dart';
import 'package:icorrect/src/views/widget/email_input_widget.dart';
import 'package:icorrect/src/views/widget/logo_text_widget.dart';
import 'package:icorrect/src/views/widget/logo_widget.dart';
import 'package:icorrect/src/views/widget/password_input_widget.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    implements LoginViewContract {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  LoginPresenter? _loginPresenter;
  late AuthProvider _authProvider;
  CircleLoading? _loading;

  @override
  void initState() {
    super.initState();
    _loading = CircleLoading();
    _loginPresenter = LoginPresenter(this);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);

    //TODO: For test
    // emailController.text = "hocvien02@nguyenhuytuong.com";
    // passwordController.text = "123456";

    _getAppConfigInfo();
  }

  void _getAppConfigInfo() async {
    String appConfigInfo =
        await AppSharedPref.instance().getString(key: AppSharedKeys.secretkey);
    if (appConfigInfo.isEmpty) {
      _loginPresenter!.getAppConfigInfo();
    } else {
      _autoLogin();
    }
  }

  void _autoLogin() async {
    String token = await Utils.getAccessToken();

    if (token.isNotEmpty) {
      _authProvider.updateProcessingStatus();

      //Has login
      Timer(const Duration(milliseconds: 2000), () async {
        _authProvider.updateProcessingStatus();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const HomeWorkScreen(),
          ),
          ModalRoute.withName('/'),
        );
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _authProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: CustomSize.size_40,
                          ),
                          const LogoWidget(),
                          const LogoTextWidget(),
                          const SizedBox(
                            height: CustomSize.size_60,
                          ),
                          EmailInputWidget(
                            emailController: emailController,
                          ),
                          PasswordInputWidget(
                            passwordController: passwordController,
                            type: PasswordType.password,
                          ),
                          _buildSignInButton(),
                          // _buildSignUpButton(),
                          // _buildForgotPasswordButton(),
                          Expanded(
                            child: Container(),
                          ),
                          const ContactInfoWidget(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.isProcessing) {
                  _loading!.show(context);
                } else {
                  _loading!.hide();
                }
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return DefaultMaterialButton(
      padding: const EdgeInsets.symmetric(vertical: 1),
      onPressed: () {
        FocusManager.instance.primaryFocus?.unfocus();
        if (_formKey.currentState!.validate() &&
            _authProvider.isProcessing == false) {
          _authProvider.updateProcessingStatus();

          _loginPresenter!.login(
            emailController.text.trim(),
            passwordController.text.trim(),
          );
        }
      },
      text: 'Sign In',
      background: AppColor.defaultPurpleColor,
      fontSize: FontsSize.fontSize_14,
      height: CustomSize.size_50,
    );
  }

  Widget _buildSignUpButton() {
    return Align(
      alignment: Alignment.center,
      child: DefaultTextButton(
        onPressed: () {
          if (_authProvider.isProcessing == false) {
            if (kDebugMode) {
              print("DEBUG: Goto Sign up screen");
            }
          }
        },
        child: const DefaultText(
          text: 'Sign up',
          color: Colors.black,
          textStyle: TextStyle(
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.center,
      child: DefaultTextButton(
        onPressed: () {
          if (_authProvider.isProcessing == false) {
            if (kDebugMode) {
              print("DEBUG: Goto Forgot password screen");
            }
          }
        },
        child: const DefaultText(
          text: 'Forgot password?',
          color: Colors.black,
          textStyle: TextStyle(
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void onLoginComplete() {
    _authProvider.updateProcessingStatus();

    //Reset textfield controllers
    emailController.text = "";
    passwordController.text = "";

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const HomeWorkScreen()),
    );
  }

  @override
  void onLoginError(String message) {
    _authProvider.updateProcessingStatus();

    showDialog(
        context: context,
        builder: (builder) {
          return MessageDialog.alertDialog(context, message);
        });
  }

  @override
  void onGetAppConfigInfoFail(String message) {
    if (kDebugMode) {
      print("DEBUG: onGetAppConfigInfoFail $message");
    }
    //Show get app config info error
    showToastMsg(
        msg: "Has an error when getting app config information!",
        toastState: ToastStatesType.error);
  }

  @override
  void onGetAppConfigInfoSuccess() {
    if (kDebugMode) {
      print("DEBUG: onGetAppConfigInfoSuccess");
    }
    _autoLogin();
  }
}
