import 'dart:async';

import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/models/auth_models/student_merchant_model.dart';
import 'package:icorrect_pc/src/presenters/login_presenter.dart';
import 'package:icorrect_pc/src/providers/auth_widget_provider.dart';
import 'package:icorrect_pc/src/providers/verify_provider.dart';
import 'package:icorrect_pc/src/views/screens/home/list_class_screen.dart';
import 'package:icorrect_pc/src/views/widgets/download_again_widget.dart';

import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../models/auth_models/class_merchant_model.dart';
import '../../../utils/utils.dart';
import '../../dialogs/circle_loading.dart';
import '../../dialogs/message_alert.dart';
import '../../widgets/input_field_custom.dart';

class VerifyWidget extends StatefulWidget {
  const VerifyWidget({super.key});

  @override
  State<VerifyWidget> createState() => _VerifyWidget();
}

class _VerifyWidget extends State<VerifyWidget> implements LoginViewContract {
  CircleLoading? _loading;
  late AuthWidgetProvider _provider;
  late VerifyProvider _verifyProvider;
  late LoginPresenter _presenter;
  bool _isDownloadAgain = false;
  String _messageError = '';

  final _txtLicenseController = TextEditingController();
  final _txtDeviceNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loading = CircleLoading();
    _autoVerify();
    _presenter = LoginPresenter(this);
    _provider = Provider.of<AuthWidgetProvider>(context, listen: false);
    _verifyProvider = Provider.of<VerifyProvider>(context, listen: false);
  }

  @override
  void dispose() {
    // dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !_isDownloadAgain? _buildVerifyForm() : SizedBox(
      child: DownloadAgainWidget(onClickTryAgain: () {
        _autoVerify();
      }, isOffline: false, message: _messageError, backgroundColor: Colors.transparent,),
    );
  }

  Widget _buildVerifyForm() {
    double w = MediaQuery.of(context).size.width / 2;
    double h = MediaQuery.of(context).size.height / 2;
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
            _buildKeyField(),
            const SizedBox(height: 40),
            SizedBox(
              width: w / 2,
              child: ElevatedButton(
                onPressed: () {
                  _loading?.show(context);
                  _onPressVerify();
                },
                style: ButtonStyle(
                    backgroundColor:
                    WidgetStateProperty.all<Color>(AppColors.purple),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13)))),
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                        Utils.instance().multiLanguage(StringConstants.verify_button_title),
                        style: const TextStyle(
                            fontSize: 17, color: Colors.white))),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildKeyField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(StringConstants.input_key,
            style: TextStyle(
                color: AppColors.purple,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        TextField(
          controller: _txtLicenseController,
          decoration: InputFieldCustom.init().borderGray10('Key'),
        ),
        const SizedBox(
          height: 20,
        ),
        TextField(
          controller: _txtDeviceNameController,
          decoration: InputFieldCustom.init().borderGray10('Tên máy'),
        )
      ],
    );
  }

  void _autoVerify() async {
    _loading?.show(context);
    String licenseKey = await Utils.instance().getLicenseKey() ?? '';
    String deviceName = await Utils.instance().getDeviceNameForSchool() ?? '';
    if (mounted) {
      _presenter.verify(context, licenseKey, deviceName);
    }
  }

  void _onPressVerify() async{
    String license = _txtLicenseController.text.trim();
    String deviceName = _txtDeviceNameController.text.trim();
    _presenter.verify(context, license, deviceName);
  }

  @override
  void onVerifyComplete(String merchantID) {
    // _loading?.hide();
    // _presenter.getListClass(context, merchantID);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ListClassWidget(),));
    _loading?.hide();
  }

  @override
  void onVerifyError(String message) {
    _loading?.hide();
    setState(() {
      _isDownloadAgain = true;
      _messageError = message;
    });
  }

  @override
  void onGetListClassComplete(List<ClassModel> classes) {
    _verifyProvider.setListClass(classes);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ListClassWidget(),));
    _loading?.hide();
  }

  @override
  void onGetListClassError(String message) {
    _loading?.hide();
    // message = StringConstants.verify_wrong_massage;
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(context: context, message: message);
        });
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
  void onVerifyConfigError(String message) {
    // TODO: implement onVeriftConfigError
  }

  @override
  void onVerifyConfigComplete() {
    // TODO: implement onVerifyConfigComplete
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
  void onLoginComplete() {
    // TODO: implement onLoginComplete
  }

  @override
  void onLoginError(String message) {
    // TODO: implement onLoginError
  }
}
