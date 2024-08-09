import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:icorrect_pc/src/models/auth_models/class_merchant_model.dart';
import 'package:icorrect_pc/src/models/auth_models/student_merchant_model.dart';
import 'package:icorrect_pc/src/presenters/login_presenter.dart';
import 'package:icorrect_pc/src/providers/main_widget_provider.dart';
import 'package:icorrect_pc/src/providers/window_manager_provider.dart';
import 'package:icorrect_pc/src/views/dialogs/circle_loading.dart';
import 'package:icorrect_pc/src/views/screens/home/list_student_screen.dart';
import 'package:icorrect_pc/src/views/widgets/download_again_widget.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../../../core/app_assets.dart';
import '../../../../core/app_colors.dart';
import '../../../data_source/constants.dart';
import '../../../data_source/local/app_shared_preferences_keys.dart';
import '../../../data_source/local/app_shared_references.dart';
import '../../../providers/verify_provider.dart';
import '../../../utils/Navigations.dart';
import '../../../utils/utils.dart';
import '../../dialogs/custom_alert_dialog.dart';
import '../../dialogs/enter_text_dialog.dart';
import '../../dialogs/language_selection_dialog.dart';
import '../../dialogs/message_alert.dart';
import 'list_syllabus_screen.dart';

class ListClassWidget extends StatefulWidget {
  const ListClassWidget({super.key});

  @override
  State<ListClassWidget> createState() => _ListClassWidgetState();
}

class _ListClassWidgetState extends State<ListClassWidget> implements LoginViewContract {

  CircleLoading? _loading;
  late List<ClassModel> _listFilter = [];
  late MainWidgetProvider _provider;
  late VerifyProvider _verifyProvider;
  late LoginPresenter _presenter;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _verifyConfigController = TextEditingController();
  final _deviceNameController = TextEditingController();
  final _scrollController = ScrollController();
  int currentIndex = 0;
  bool _isDownloadAgain = false;
  String messageError = '';
  int page = 1;
  int totalClass = 0;

  @override
  void initState() {
    _loading = CircleLoading();
    super.initState();
    _presenter = LoginPresenter(this);
    _provider = Provider.of<MainWidgetProvider>(context, listen: false);
    _verifyProvider = Provider.of<VerifyProvider>(context, listen: false);
    _loading!.show(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verifyProvider.clearListClass();
    },);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        page += 1;
        _presenter.getListClass(context, page);
      }
    });
    _presenter.getListClass(context, page);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(AppAssets.bg_main), fit: BoxFit.fill),
          ),
          child: _mainItem(),
        ),
        endDrawer: Drawer (
          backgroundColor: AppColors.defaultWhiteColor,
          child: navbarItems(),
        )
      ),
    );
  }

  Widget navbarItems() {
    return ListView(
      // padding: EdgeInsets.zero,
      children: [
        ListTile(
          title: Text(
            Utils.instance().multiLanguage(StringConstants.multi_language_title),
            style: CustomTextStyle.textWithCustomInfo(
              context: context,
              color: AppColors.defaultGrayColor,
              fontsSize: FontsSize.fontSize_15,
              fontWeight: FontWeight.w400,
            ),
          ),
          leading: Container(
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.defaultPurpleColor),
                borderRadius: BorderRadius.circular(100)),
            child: Image(
              image: AssetImage(Utils.instance().getLanguageImg()),
              width: 25,
            ),
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (builder) {
                return const LanguageSelectionDialog();
              },
            ).then((value) => Navigator.pop(context));
          },
        ),
        ListTile(
          title: Text(
            Utils.instance().multiLanguage(StringConstants.syllabus_list),
            style: CustomTextStyle.textWithCustomInfo(
              context: context,
              color: AppColors.defaultGrayColor,
              fontsSize: FontsSize.fontSize_15,
              fontWeight: FontWeight.w400,
            ),
          ),
          leading: const Icon(
            Icons.menu_book,
            color: AppColors.defaultGrayColor,
          ),
          onTap: () {
            Navigator.pop(context);
            _provider.setLastScreen(const ListClassWidget());
            _provider.setCurrentScreen(const ListSyllabusWidget());
            _provider.setTitleMain(Utils.instance().multiLanguage(StringConstants.syllabus_list));
            Navigations.instance().goToMainWidget(context);
          },
        ),
        ListTile(
          title: Text(
            'Đổi tên máy',
            style: CustomTextStyle.textWithCustomInfo(
              context: context,
              color: AppColors.defaultGrayColor,
              fontsSize: FontsSize.fontSize_15,
              fontWeight: FontWeight.w400,
            ),
          ),
          leading: const Icon(
            Icons.drive_file_rename_outline,
            color: AppColors.defaultGrayColor,
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return EnterTextDialog(
                    title: 'Thông báo',
                    description: 'Bạn hãy nhập tên máy mới',
                    hintText: 'Ví dụ: Máy 01 ...',
                    controller: _deviceNameController,
                    okButtonTitle: 'Xác nhận',
                    cancelButtonTitle: 'Huỷ bỏ',
                    borderRadius: 20,
                    hasCloseButton: true,
                    okButtonTapped: () {
                      _loading!.show(context);
                      _presenter.changeDeviceName(context, _deviceNameController.text.trim());
                    },
                    cancelButtonTapped: () {
                      Navigator.of(context).pop();
                    }, isObscureText: false,);
              },
            );
          },
        ),
      ],
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
              const Image(width: 170, image: AssetImage(AppAssets.img_logo_app)),
              // Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Visibility(visible: _provider.visibleSearch, child: _buildSearch()),
              //     Visibility(visible: !_provider.visibleSearch, child: _buildTitle())
              //   ],
              // ),
              _buildTitle(),
              SizedBox(
                  width: 170,
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return EnterTextDialog(
                                  title: 'Cảnh báo!',
                                  description: 'Hãy nhập mã xác thực',
                                  hintText: 'Mã xác thực',
                                  controller: _verifyConfigController,
                                  okButtonTitle: 'Xác nhận',
                                  cancelButtonTitle: 'Huỷ bỏ',
                                  borderRadius: 20,
                                  hasCloseButton: true,
                                  isObscureText: true,
                                  okButtonTapped: () {
                                    _loading!.show(context);
                                    _presenter.verifyConfig(context, _verifyConfigController.text.trim());
                                  },
                                  cancelButtonTapped: () {
                                    Navigator.of(context).pop();
                                  });
                            },
                          );
                        },
                        icon: const Icon(
                          Icons.settings,
                          size: 45,
                          color: AppColors.purple,
                        ),
                      ),
                    ],
                  )),
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
      child: const TextField(
        decoration: InputDecoration (
            label: Center(child: Text('Tìm kiếm lớp ... ')),
            border: InputBorder.none
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text('Danh Sách lớp', style: TextStyle(
        color: AppColors.purple,
        fontWeight: FontWeight.bold,
        fontSize: 24));
  }

  Widget _body() {
    return Consumer<MainWidgetProvider>(
        builder: (context, appState, child) =>
            Expanded(child: !_isDownloadAgain? _buildListClass() : DownloadAgainWidget(onClickTryAgain: () {
              _loading!.show(context);
              _presenter.getListClass(context, page);
            }, isOffline: false, message: messageError, backgroundColor: Colors.transparent)));
  }

  Widget _buildListClass() {
    double w = MediaQuery.of(context).size.width;
    return Container(
      width: w,
      margin: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
      child: Consumer(builder: (context, value, child) {
        return DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(25),
          dashPattern: const [6, 3, 6, 3],
          strokeWidth: 2,
          color: AppColors.defaultPurpleColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              InkWell(
                  onTap: () {
                    _loading?.show(context);
                    page = 1;
                    _verifyProvider.clearListClass();
                    _presenter.getListClass(context, page);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    width: 120,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(Icons.refresh_rounded),
                          const SizedBox(width: 5),
                          Text(
                              Utils.instance().multiLanguage(
                                  StringConstants.refresh_data),
                              style: const TextStyle(
                                color: AppColors.purple,
                                fontSize: 16,
                              )),
                        ]),
                  )),
              _listFilter.isEmpty? Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(AppAssets.img_empty),
                  const Text('Danh sách lớp đang trống!')
                ],
              )) : Expanded(child: _listClass()),
            ],
          ),
          );
      },),
    );
  }

  Widget _listClass() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 80),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: GridView.builder(
          shrinkWrap: true,
          itemCount: _listFilter.length + 1,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 3.5,
            crossAxisCount: 3,
            crossAxisSpacing:80,
            mainAxisSpacing: 20
          ),
          itemBuilder: (context, index) {
            if (index == _listFilter.length) {
              if (_listFilter.length == totalClass) {
                return SizedBox();
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            } else {
              return InkWell(
                  onTap: () {
                    goToListStudentWidget(index);
                  },
                  child: _classItem(index));
            }
          },
        ),
      ),
    );
  }

  Widget _classItem(int index) {
    return Container(
          decoration: BoxDecoration (
              border: Border.all(
                  color: AppColors.purple, width: 1.2,
              ),
              borderRadius: BorderRadius.circular(12)
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Column (
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_listFilter[index].name!, style: const TextStyle(
                color: AppColors.purple,
                fontWeight: FontWeight.bold,
                fontSize: 18),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Học sinh: ${_listFilter[index].studentCount}', style: const TextStyle(
                        color: AppColors.purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                    Text('Bài tập: ${_listFilter[index].activitiesCount}', style: const TextStyle(
                        color: AppColors.purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 15))
                  ],
                )
              ],
            ),
          ),
        );
  }

  void goToListStudentWidget(int index) {
    _verifyProvider.setCurrentClass(_verifyProvider.listClass[index]);
    AppSharedPref.instance()
        .putString(key: AppSharedKeys.classID, value: _verifyProvider.listClass[index].id.toString());
    _provider.setVisibleSearch(false);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ListStudentWidget()));
  }


  @override
  void onVerifyConfigError(String message) {
    _loading!.hide();
    _verifyConfigController.clear();
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(context: context, message: message);
        });
  }

  @override
  void onVerifyConfigComplete() {
    _loading!.hide();
    _scaffoldKey.currentState!.openEndDrawer();
    Navigator.of(context).pop();
    _verifyConfigController.clear();
  }

  @override
  void onChangeDeviceNameComplete(String msg) {
    _loading!.hide();
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(context: context, message: msg);
        });
  }

  @override
  void onChangeDeviceNameError(String msg) {
    _loading!.hide();
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(context: context, message: msg);
        });
  }

  @override
  void onLoginComplete() {
    // TODO: implement onLoginComplete
  }

  @override
  void onLoginError(String message) {
    // TODO: implement onLoginError
  }


  @override
  void onGetListStudentComplete(List<StudentModel> list) {
  }

  @override
  void onGetListStudentError(String message) {
  }

  @override
  void onGetListClassComplete(List<ClassModel> list, int lastPage, int total) {
    totalClass = total;
    _verifyProvider.setListClass(list);
    if (page % 2 == 0 || page == lastPage) {
      setState(() {
        _isDownloadAgain = false;
        _listFilter = _verifyProvider.listClass;
      });
      _loading!.hide();
    } else {
      page += 1;
      _presenter.getListClass(context, page);
    }
  }

  @override
  void onGetListClassError(String message) {
    _loading?.hide();
    setState(() {
      _isDownloadAgain = true;
      messageError = message;
    });
  }

  @override
  void onVerifyComplete(String merchantID) {
    // TODO: implement onVerifyComplete
  }

  @override
  void onVerifyError(String message) {
    // TODO: implement onVerifyError
  }
}
