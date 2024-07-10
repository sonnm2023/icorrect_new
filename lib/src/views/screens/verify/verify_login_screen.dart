
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/data_source/local/app_shared_preferences_keys.dart';
import 'package:icorrect_pc/src/data_source/local/app_shared_references.dart';
import 'package:icorrect_pc/src/models/auth_models/student_merchant_model.dart';
import 'package:icorrect_pc/src/presenters/login_presenter.dart';
import 'package:icorrect_pc/src/presenters/verify_presenter.dart';
import 'package:icorrect_pc/src/providers/auth_widget_provider.dart';
import 'package:icorrect_pc/src/providers/verify_provider.dart';
import 'package:icorrect_pc/src/views/screens/verify/verify_screen.dart';

import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../models/auth_models/class_merchant_model.dart';
import '../../../utils/Navigations.dart';
import '../../../utils/utils.dart';
import '../../dialogs/circle_loading.dart';
import '../../dialogs/message_alert.dart';
import '../../widgets/input_field_custom.dart';

class LoginVerifyWidget extends StatefulWidget {
  const LoginVerifyWidget({super.key});

  @override
  State<LoginVerifyWidget> createState() => _LoginVerifyState();
}

class _LoginVerifyState extends State<LoginVerifyWidget> implements LoginViewContract {
  CircleLoading? _loading;
  late AuthWidgetProvider _provider;
  VerifyProvider? _verifyProvider;
  LoginPresenter? _loginPresenter;
  List<ClassModel> classes = [];
  String classID = '';

  final _txtUsernameController = TextEditingController();
  final _txtClassIDController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loading = CircleLoading();
    _loginPresenter = LoginPresenter(this);
    _provider = Provider.of<AuthWidgetProvider>(context, listen: false);
    _verifyProvider = Provider.of<VerifyProvider>(context, listen: false);
    classes = _verifyProvider!.listClass;
  }

  @override
  void dispose() {
    // dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildLoginForm();
  }

  Widget _buildLoginForm() {
    double w = MediaQuery.of(context).size.width / 2;
    double h = MediaQuery.of(context).size.height / 1.8;
    return Center(
      child: Container(
        width: w,
        height: h,
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 30),
        margin: const EdgeInsets.only(bottom: 100),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: AppColors.gray),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildUsernameField(),
            const SizedBox(height: 15),
            _buildClassIDMenu(),
            const SizedBox(height: 40),
            SizedBox(
              width: w/4*3,
              child: ElevatedButton(
                onPressed: () {
                  _loading?.show(context);
                  _onPressLogin();
                },
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all<Color>(AppColors.purple),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13))),
                ),
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                        Utils.instance().multiLanguage(
                            StringConstants.sign_in_button_title),
                        style: const TextStyle(
                            fontSize: 17, color: Colors.white))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(StringConstants.username,
            style: TextStyle(
                color: AppColors.purple,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextField(
          controller: _txtUsernameController,
          decoration:
          InputFieldCustom.init().borderGray10('VD: hocvien01'),
        )
      ],
    );
  }

  Widget _buildClassIDMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(StringConstants.select_class,
            style: TextStyle(
                color: AppColors.purple,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
            decoration: BoxDecoration (
                borderRadius: BorderRadius.circular(13),
                color: Colors.grey[200]
            ),
            child: ScrollbarTheme (
              data: const ScrollbarThemeData (),
              child: DropdownMenu(
                controller: _txtClassIDController,
                enableSearch: true,
                expandedInsets: const EdgeInsets.symmetric(horizontal: 0),
                inputDecorationTheme: InputDecorationTheme (
                  border: OutlineInputBorder (
                      borderRadius: BorderRadius.circular(13)
                  ),
                ),
                dropdownMenuEntries: [
                  for (var value in classes)
                    DropdownMenuEntry(value: value.classId, label: value.name!)
                ],
                onSelected: (value) {
                  // classID = value!;
                },
                hintText: StringConstants.select_class,
                menuHeight: MediaQuery.of(context).size.height/4,
                // width: MediaQuery.of(context).size.width,
              ),
            )
        ),
      ],
    );
  }

  void _onPressLogin() {
    String username = _txtUsernameController.text.trim();
    LoginPresenter presenter = LoginPresenter(this);
    presenter.loginWithClassID(context, username, classID);
  }

  void _onExitVerify() async {
    Utils.instance().setLicenseKey('');
    Utils.instance().setMerchantID('');
    _verifyProvider!.resetListClass();
    _provider.setCurrentScreen(const VerifyWidget());
  }

  @override
  void onLoginComplete() {
    _loading?.hide();
    Navigations.instance().goToMainWidget(context);
  }

  @override
  void onLoginError(String message) {
    _loading?.hide();
    if (message == StringConstants.login_wrong_message) {
      message =
          Utils.instance().multiLanguage(StringConstants.login_wrong_message);
    }
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(context: context, message: message);
        });
  }

  @override
  void onChangeDeviceNameComplete(String msg) {
    // TODO: implement onChangeDeviceNameComplete
  }

  @override
  void onChangeDeviceNameError(String msg) {
    // TODO: implement onChangeDeviceNameError
  }

  @override
  void onGetListClassComplete(List<ClassModel> list) {
    // TODO: implement onGetListClassComplete
  }

  @override
  void onGetListClassError(String message) {
    // TODO: implement onGetListClassError
  }

  @override
  void onGetListStudentComplete(List<StudentModel> list) {
    // TODO: implement onGetListStudentComplete
  }

  @override
  void onGetListStudentError(String message) {
    // TODO: implement onGetListStudentError
  }

  @override
  void onVerifyComplete(String merchantID) {
    // TODO: implement onVerifyComplete
  }

  @override
  void onVerifyConfigComplete() {
    // TODO: implement onVerifyConfigComplete
  }

  @override
  void onVerifyConfigError(String message) {
    // TODO: implement onVerifyConfigError
  }

  @override
  void onVerifyError(String message) {
    // TODO: implement onVerifyError
  }
}
