import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constant_strings.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/presenters/login_presenter.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/provider/homework_provider.dart';
import 'package:icorrect/src/views/screen/home/homework_screen.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/circle_loading.dart';
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
    emailController.text = "hocsinh03@testing.com";
    passwordController.text = "123456";

    _autoLogin();
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
            builder: (_) => ChangeNotifierProvider<HomeWorkProvider>(
              create: (_) => HomeWorkProvider(),
              child: const HomeWorkScreen(),
            ),
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
                    padding: const EdgeInsets.all(15),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          const LogoWidget(),
                          const LogoTextWidget(),
                          const SizedBox(height: 60),
                          EmailInputWidget(emailController: emailController),
                          PasswordInputWidget(
                            passwordController: passwordController,
                            type: PasswordType.password,
                          ),
                          _buildSignInButton(),
                          _buildSignUpButton(),
                          _buildForgotPasswordButton(),
                          Expanded(child: Container(),),
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
        if (_formKey.currentState!.validate() &&
            _authProvider.isProcessing == false) {
          _authProvider.updateProcessingStatus();

          _loginPresenter!.login(
            emailController.text.trim(),
            passwordController.text.trim(),
          );
        }
      },
      background: AppColor.defaultPurpleColor,
      text: 'Sign In',
      fontSize: 15,
      height: 60,
    );
  }

  Widget _buildSignUpButton() {
    return Align(
      alignment: Alignment.center,
      child: DefaultTextButton(
        onPressed: () {
          if (_authProvider.isProcessing == false) {
            //TODO
            if (kDebugMode) {
              print("DEBUG: Goto Sign up screen");
            }

            //TODO
            // Navigator.of(context).pushNamedAndRemoveUntil(signupRoute, (route) => false);
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
            //TODO
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
    Navigator.of(context).push(
      // MaterialPageRoute(builder: (context) => const HomeWorkScreen()),
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<HomeWorkProvider>(
          create: (_) => HomeWorkProvider(),
          child: const HomeWorkScreen(),
        ),
      ),
    );
  }

  @override
  void onLoginError(String message) {
    _authProvider.updateProcessingStatus();

    //Show error message
    showToastMsg(
      msg: message,
      toastState: ToastStatesType.error,
    );
  }
}
