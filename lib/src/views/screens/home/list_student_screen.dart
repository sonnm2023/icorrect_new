import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/models/auth_models/class_merchant_model.dart';
import 'package:icorrect_pc/src/models/auth_models/student_merchant_model.dart';
import 'package:icorrect_pc/src/providers/main_widget_provider.dart';
import 'package:icorrect_pc/src/providers/verify_provider.dart';
import 'package:icorrect_pc/src/views/dialogs/circle_loading.dart';
import 'package:icorrect_pc/src/views/screens/home/home_screen.dart';
import 'package:icorrect_pc/src/views/screens/home/list_class_screen.dart';
import 'package:icorrect_pc/src/views/widgets/download_again_widget.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_assets.dart';
import '../../../../core/app_colors.dart';
import '../../../data_source/constants.dart';
import '../../../presenters/login_presenter.dart';
import '../../../utils/Navigations.dart';
import '../../../utils/utils.dart';
import '../../dialogs/custom_alert_dialog.dart';

class ListStudentWidget extends StatefulWidget {
  const ListStudentWidget({super.key});

  @override
  State<ListStudentWidget> createState() => _ListStudentWidgetState();
}

class _ListStudentWidgetState extends State<ListStudentWidget> implements LoginViewContract {
  CircleLoading? _loading;
  late MainWidgetProvider _provider;
  late VerifyProvider _verifyProvider;
  late LoginPresenter _presenter;
  List<StudentModel> _listFilter = [];
  String username = '';
  int userID = 0;
  final _scrollController = ScrollController();
  bool _isDownloadAgain = false;
  String _messageError = '';

  @override
  void initState() {
    _loading = CircleLoading();
    super.initState();
    _provider = Provider.of<MainWidgetProvider>(context, listen: false);
    _verifyProvider = Provider.of<VerifyProvider>(context, listen: false);

    _presenter = LoginPresenter(this);
    _loading!.show(context);
    _presenter.getListStudent(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _provider.setTitleMain(_verifyProvider.currentClass!.name!);
      });
    },);
  }

  @override
  void dispose() {
    _verifyProvider.clearAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(AppAssets.bg_main), fit: BoxFit.fill),
          ),
          child: _mainItem(),
        ),
      ),
    );
  }

  Widget _mainItem() {
    return Padding(
        padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
        child:
        Column(
          children: [_mainHeader(), _body()],
        ));
  }

  Widget _mainHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 170,
                child: IconButton(
                    onPressed: () {
                      _provider.setVisibleSearch(true);
                      _verifyProvider.clearAll();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ListClassWidget(),
                          ));
                    },
                    icon: const Icon(
                      Icons.arrow_back_outlined,
                      size: 35,
                    )),
              ),
              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Visibility(visible: _provider.visibleSearch, child: _buildSearch()),
                      Visibility(visible: !_provider.visibleSearch, child: _buildTitle())
                    ],
                  ),
                  const SizedBox(width: 10,),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _provider.setVisibleSearch(!_provider.visibleSearch);
                        _listFilter = _verifyProvider.currentListStudent;
                      });
                    },
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Icon(
                          !_provider.visibleSearch? Icons.search : Icons.cancel_outlined,
                          size: 40,
                          color: AppColors.purple,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const Image(width: 170, image: AssetImage(AppAssets.img_logo_app)),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: const Divider(
            height: 1,
            thickness: 1,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return Container(
      width: MediaQuery.of(context).size.width / 3,
      decoration: BoxDecoration (
          border: Border.all(color: AppColors.purple, width: 1.5),
          borderRadius: BorderRadius.circular(15)
      ),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        decoration: const InputDecoration (
            label: Center(child: Text('Tìm kiếm học sinh ... ')),
            border: InputBorder.none
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text('Lớp: ${_provider.titleMain}', style: const TextStyle(
        color: AppColors.purple,
        fontWeight: FontWeight.bold,
        fontSize: 24));
  }

  Widget _body() {
    return Consumer<MainWidgetProvider>(
        builder: (context, appState, child) =>
            Expanded(child: !_isDownloadAgain ? _buildListStudent() : DownloadAgainWidget(onClickTryAgain: () {
              _loading!.show(context);
              _presenter.getListStudent(context);
            }, isOffline: false, message: _messageError, backgroundColor: Colors.transparent)));
  }

  Widget _buildListStudent() {
    double w = MediaQuery.of(context).size.width;
    return Container(
      width: w,
      margin: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
      child: Consumer(builder: (context, value, child) {
        return DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(25),
            dashPattern: [6, 3, 6, 3],
            strokeWidth: 2,
            color: AppColors.defaultPurpleColor,
            child: _listStudent());
      },),
    );
  }

  Widget _listStudent() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 80),
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: _listFilter.length,
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 3,
            crossAxisCount: 3,
            crossAxisSpacing:80,
            mainAxisSpacing: 20
        ),
        itemBuilder: (context, index) {
            return InkWell(
                onTap: () {
                  username = _listFilter[index].name!;
                  userID = _listFilter[index].apiId!;
                  _onPressLogin('${_listFilter[index].apiId}',
                      _verifyProvider.currentClass!.classId!);
                },
                child: _studentItem(index));
        },
      ),
    );
  }

  Widget _studentItem(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration (
          border: Border.all(
            color: AppColors.purple, width: 1.2,
          ),
          borderRadius: BorderRadius.circular(12)
      ),
      child: Wrap (
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Column (
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_listFilter[index].name!, style: const TextStyle(
                      color: AppColors.purple,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                Text(
                  'Biệt danh: ${_listFilter[index].nickName ?? 'không có'}',
                  style: const TextStyle(
                      color: AppColors.purple,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                Text(
                  'Bài đã làm: ${_listFilter[index].answersOfStudentCount}',
                  style: const TextStyle(
                      color: AppColors.purple,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onPressLogin(String userId, String classId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: Utils.instance().multiLanguage(StringConstants.dialog_title),
          richText: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: <TextSpan>[
                const TextSpan(text: 'Bạn có muốn đăng nhập với tài khoản là: ', style: TextStyle(fontSize: FontsSize.fontSize_16, color: Colors.black)),
                TextSpan(text: username, style: const TextStyle(fontSize: FontsSize.fontSize_16, fontWeight: FontWeight.bold, color: Colors.black)),
                // TextSpan(text: _mainWidgetProvider!.titleMain, style: const TextStyle(fontSize: FontsSize.fontSize_16, fontWeight: FontWeight.bold, color: Colors.black)),
                const TextSpan(text: ' không?', style: TextStyle(fontSize: FontsSize.fontSize_16, color: Colors.black))
              ]
            ),
          ),
          description: '',
          okButtonTitle: StringConstants.ok_button_title,
          cancelButtonTitle: Utils.instance().multiLanguage(StringConstants.cancel_button_title),
          borderRadius: 8,
          hasCloseButton: false,
          okButtonTapped: () async {
            LoginPresenter presenter = LoginPresenter(this);
            _loading!.show(context);
            presenter.loginWithClassID(context, userId, classId);
          },
          cancelButtonTapped: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _runFilter(String enterKeyword) {
    List<StudentModel> results = [];
    if (enterKeyword.isEmpty) {
      results = _verifyProvider.currentListStudent;
    } else {
      results = _verifyProvider.currentListStudent
          .where((student) => student.name!.toLowerCase().contains(enterKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _listFilter = results;
    });
  }

  @override
  void onLoginComplete() {
    _loading?.hide();
    _provider.setTitleMain('Học sinh: $username');
    _provider.setLastScreen(const ListStudentWidget());
    _provider.setCurrentScreen(const HomeWorksWidget());
    Navigations.instance().goToMainWidget(context);
  }

  @override
  void onLoginError(String message) {
    _loading?.hide();
    if (message == StringConstants.login_wrong_message) {
      message =
          Utils.instance().multiLanguage(StringConstants.login_wrong_message);
    }
    setState(() {
      _messageError = message;
      _isDownloadAgain = true;
    });
  }


  @override
  void onGetListStudentComplete(List<StudentModel> list) {
    _verifyProvider.setCurrentListStudent([]);
    _verifyProvider.setCurrentListStudent(list);
    setState(() {
      _isDownloadAgain = false;
      _listFilter = _verifyProvider.currentListStudent;
    });
    _loading!.hide();
  }

  @override
  void onGetListStudentError(String message) {
    _loading?.hide();
    setState(() {
      _isDownloadAgain = true;
      _messageError = message;
    });
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
}
