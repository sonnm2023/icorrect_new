// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/core/connectivity_service.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences_keys.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/user_data_models/user_data_model.dart';
import 'package:icorrect/src/presenters/login_presenter.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/views/screen/home/homework_screen.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/alert_dialog.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/circle_loading.dart';
import 'package:icorrect/src/views/screen/other_views/dialog/message_dialog.dart';
import 'package:icorrect/src/views/widget/contact_info_widget.dart';
import 'package:icorrect/src/views/widget/default_material_button.dart';
import 'package:icorrect/src/views/widget/email_input_widget.dart';
import 'package:icorrect/src/views/widget/logo_text_widget.dart';
import 'package:icorrect/src/views/widget/logo_widget.dart';
import 'package:icorrect/src/views/widget/password_input_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    implements LoginViewContract, ActionAlertListener {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  LoginPresenter? _loginPresenter;
  late AuthProvider _authProvider;
  CircleLoading? _loading;
  Permission? _writeFilePermission;
  PermissionStatus _writeFilePermissionStatus = PermissionStatus.denied;
  final connectivityService = ConnectivityService();

  @override
  void initState() {
    super.initState();
    _loading = CircleLoading();
    _loginPresenter = LoginPresenter(this);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);

    //For debug
    // emailController.text = "testkhaothi01@testing.com";
    // passwordController.text = "123456";

    _checkPermission();
  }

  void _checkPermission() async {
    await _initializePermission();

    if (mounted && _writeFilePermission != null) {
      _requestPermission(_writeFilePermission!, context);
    } else {
      _getAppConfigInfo();
    }
  }

  Future<void> _requestPermission(
      Permission permission, BuildContext context) async {
    _authProvider.setPermissionDeniedTime();
    // ignore: unused_local_variable
    final status = await permission.request();
    _listenForPermissionStatus(context);
  }

  Future<void> _initializePermission() async {
    _writeFilePermission = Permission.storage;
    if (Platform.isAndroid) {
      AndroidDeviceInfo android = await DeviceInfoPlugin().androidInfo;
      int sdk = android.version.sdkInt;

      if (sdk >= 33) {
        _writeFilePermission = null;
      }
    }
  }

  void _listenForPermissionStatus(BuildContext context) async {
    if (_writeFilePermission != null) {
      _writeFilePermissionStatus = await _writeFilePermission!.status;

      if (_writeFilePermissionStatus == PermissionStatus.denied) {
        if (_authProvider.permissionDeniedTime > 2) {
          _showConfirmDialog();
        }
      } else if (_writeFilePermissionStatus ==
          PermissionStatus.permanentlyDenied) {
        openAppSettings();
      } else {
        _getAppConfigInfo();
      }
    }
  }

  void _showConfirmDialog() {
    if (false == _authProvider.dialogShowing) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertsDialog.init().showDialog(
            context,
            AlertClass.storagePermissionAlert,
            this,
            keyInfo: StringClass.permissionDenied,
          );
        },
      );
      _authProvider.setDialogShowing(true);
    }
  }

  void _getAppConfigInfo() async {
    var connectivity = await connectivityService.checkConnectivity();
    if (connectivity.name != StringConstants.connectivity_name_none) {
      String appConfigInfo = await AppSharedPref.instance()
          .getString(key: AppSharedKeys.secretkey);
      if (appConfigInfo.isEmpty) {
        _loginPresenter!.getAppConfigInfo(context);
      } else {
        _autoLogin();
      }
    } else {
      //Show connect error here
      if (kDebugMode) {
        print("DEBUG: Connect error here!");
      }
      Utils.showConnectionErrorDialog(context);

      Utils.addConnectionErrorLog(context);
    }
  }

  void _autoLogin() async {
    String token = await Utils.getAccessToken();

    if (token.isNotEmpty) {
      _authProvider.updateProcessingStatus(isProcessing: true);

      UserDataModel? currentUser = await Utils.getCurrentUser();
      if (null == currentUser) {
        return;
      }

      _loginPresenter!
          .setUserInformation(currentUser.userInfoModel.id.toString());

      //Has login
      Timer(const Duration(milliseconds: 2000), () async {
        _authProvider.updateProcessingStatus(isProcessing: false);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => HomeWorkScreen(),
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
                  _loading!.show(context: context, isViewAIResponse: false);
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
      onPressed: () async {
        FocusManager.instance.primaryFocus?.unfocus();
        if (_formKey.currentState!.validate() &&
            _authProvider.isProcessing == false) {
          var connectivity = await connectivityService.checkConnectivity();
          if (connectivity.name != StringConstants.connectivity_name_none) {
            _authProvider.updateProcessingStatus(isProcessing: true);

            //Add firebase log
            Utils.addFirebaseLog(
              eventName: "button_click",
              parameters: {
                "button_name": "login",
              },
            );

            _loginPresenter!.login(
              emailController.text.trim(),
              passwordController.text.trim(),
              context,
            );
          } else {
            //Show connect error here
            if (kDebugMode) {
              print("DEBUG: Connect error here!");
            }
            Utils.showConnectionErrorDialog(context);

            Utils.addConnectionErrorLog(context);
          }
        }
      },
      text: StringConstants.sign_in_button_title,
      background: AppColor.defaultPurpleColor,
      fontSize: FontsSize.fontSize_14,
      height: CustomSize.size_50,
    );
  }

  //TODO: Next phase
  /*
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
          text: StringConstants.sign_up_button_title,
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
          text: StringConstants.forgot_password_button_title,
          color: Colors.black,
          textStyle: TextStyle(
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  */

  void _resetTextFieldControllers() {
    emailController.text = "";
    passwordController.text = "";
  }

  @override
  void onLoginComplete() {
    _authProvider.updateProcessingStatus(isProcessing: false);

    _resetTextFieldControllers();

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => HomeWorkScreen()),
    );
  }

  @override
  void onLoginError(String message) {
    _authProvider.updateProcessingStatus(isProcessing: false);

    showDialog(
      context: context,
      builder: (builder) {
        return MessageDialog.alertDialog(context, message);
      },
    );
  }

  @override
  void onGetAppConfigInfoFail(String message) {
    if (kDebugMode) {
      print("DEBUG: onGetAppConfigInfoFail $message");
    }
    //Show get app config info error
    showToastMsg(
      msg: message,
      toastState: ToastStatesType.error,
    );
  }

  @override
  void onGetAppConfigInfoSuccess() {
    _autoLogin();
  }

  @override
  void onAlertExit(String keyInfo) {
    // TODO: implement onAlertExit
  }

  @override
  void onAlertNextStep(String keyInfo) {
    // TODO: implement onAlertNextStep
  }
}
