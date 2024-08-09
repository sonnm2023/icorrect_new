import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/data_source/local/database_helper.dart';
import 'package:icorrect_pc/src/data_source/local/file_storage_helper.dart';
import 'package:icorrect_pc/src/models/homework_models/syllabusDB_model.dart';
import 'package:icorrect_pc/src/models/homework_models/syllabus_merchant_model.dart';
import 'package:icorrect_pc/src/presenters/syllabus_presenter.dart';
import 'package:icorrect_pc/src/providers/main_widget_provider.dart';
import 'package:icorrect_pc/src/providers/syllabus_provider.dart';
import 'package:icorrect_pc/src/utils/utils.dart';
import 'package:icorrect_pc/src/views/dialogs/circle_loading.dart';
import 'package:icorrect_pc/src/views/dialogs/confirm_dialog.dart';
import 'package:icorrect_pc/src/views/widgets/simulator_test_widgets/download_progressing_widget.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_assets.dart';
import '../../../../core/app_colors.dart';
import '../../../models/ui_models/download_info.dart';
import '../../dialogs/message_alert.dart';

class ListSyllabusWidget extends StatefulWidget {
  const ListSyllabusWidget({super.key});

  @override
  State<ListSyllabusWidget> createState() => _ListSyllabusWidgetState();
}

class _ListSyllabusWidgetState extends State<ListSyllabusWidget> implements SyllabusViewContract {

  CircleLoading? _loading;
  SyllabusPresenter? _presenter;
  SyllabusProvider? _provider;
  MainWidgetProvider? _mainWidgetProvider;
  int syllabus_id = 0;
  String syllabusName = '';
  int page = 1;
  int pageListSyllabus = 1;
  int totalSyllabus = 0;
  final _sc = ScrollController();

  @override
  void initState() {
    _loading = CircleLoading();
    // TODO: implement initState
    super.initState();
    _presenter = SyllabusPresenter(this);
    _provider = Provider.of<SyllabusProvider>(context, listen: false);
    _mainWidgetProvider = Provider.of<MainWidgetProvider>(context, listen: false);
    getListSyllabus();
    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        pageListSyllabus += 1;
        _presenter!.getListSyllabusMerchant(context, pageListSyllabus);
      }
    });
  }

  void getListSyllabus() {
    _loading!.show(context);
    _presenter!.getListSyllabusMerchant(context, pageListSyllabus);
  }

  @override
  Widget build(BuildContext context) {
    return _buildListSyllabus();
  }

  Widget _buildDownloadProgressing() {
    return Consumer<SyllabusProvider>(builder: (context, provider, child) {
      if (kDebugMode) {
        print("DEBUG: SimulatorTest --- build -- buildBody");
      }
      DownloadInfo downloadInfo = DownloadInfo(provider.currentIndex,
          provider.currentIndex / provider.total, provider.total);
      return Visibility(
        visible: provider.isDownloadProgressing,
        child: Center(
              child: DownloadProgressingWidget(downloadInfo,
                  reDownload: () {}, visible: provider.isDownloadProgressing, isSyllabus: true,),
            ),
      );
    });
  }

  Widget _buildListSyllabus() {
    double w = MediaQuery.of(context).size.width;
    return Consumer<SyllabusProvider>(
      builder: (context, provider, child) {
        if (provider.isDownloadProgressing) {
          return _buildDownloadProgressing();
        } else {
          return Visibility(
            visible: !provider.isDownloadProgressing,
            child: Container(
              width: w,
              margin: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
              child: Consumer(
                builder: (context, value, child) {
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
                                pageListSyllabus = 1;
                                _presenter!.getListSyllabusMerchant(context, pageListSyllabus);
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
                          provider.listSyllabusDB.isEmpty ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(AppAssets.img_empty),
                                const Text('Danh sách giáo trình đang trống!')
                              ],
                            ),
                          ) : _listSyllabus(),
                        ],
                      ),
                      );
                },
              ),
            ),
          );
        }
      },
    );
  }

  Widget _listSyllabus() {
    return Consumer<SyllabusProvider>(builder: (context, provider, child) {
      return SingleChildScrollView(
        controller: _sc,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: provider.listSyllabusDB.length + 1,
          itemBuilder: (context, index) {
            if (index == provider.listSyllabusDB.length) {
              if (index >= totalSyllabus) {
                return const SizedBox();
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            } else {
              return _syllabusItem(provider.listSyllabusDB, index);
            }
        },),
      );
    },);
  }

  Widget _syllabusItem(List<SyllabusDBModel> list, int index) {
    SyllabusDBModel syllabus = list[index];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
      height: 100,
      decoration: BoxDecoration (
        border: Border.all(color: AppColors.purple, width: 1.2),
        borderRadius: BorderRadius.circular(20)
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row (
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Giáo trình: ${syllabus.syllabusName}', style: const TextStyle (
                  color: AppColors.purple,
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),),
                Text('Trạng thái: ${statusDownload(syllabus.statusDownload)}', style: const TextStyle (
                    color: AppColors.purple,
                    fontWeight: FontWeight.w500,
                    fontSize: 15
                )),
                Text('Ngày tải: ${syllabus.downloadAt ?? 'chưa tải'}', style: const TextStyle (
                    color: AppColors.purple,
                    fontWeight: FontWeight.w500,
                    fontSize: 15
                ))
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text('Số file: ${syllabus.totalDownloaded}', style: const TextStyle (
                        color: AppColors.purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                    )),
                    const SizedBox(width: 5,),
                    InkWell(
                      onTap: () async {
                        _loading!.show(context);
                        await _presenter!.initializeData();
                        syllabus_id = syllabus.syllabusID;
                        syllabusName = syllabus.syllabusName;
                        if (mounted) {
                          _presenter!.getListFileSyllabus(
                              context, syllabus.syllabusID, page, syllabusName);
                        }
                      },
                      child: const Icon(Icons.download, color: AppColors.purple, size: 35),
                    ),
                    const SizedBox(width: 10,),
                    InkWell(
                      onTap: () {
                        showDialog(context: context, builder: (context) {
                          return ConfirmDialogWidget(title: 'Thông báo!',
                              message: 'Bạn có chắc muốn xoá giáo trình khỏi bộ nhớ không?',
                              cancelButtonTitle: 'Không',
                              okButtonTitle: 'Xác nhận',
                              cancelButtonTapped: () {},
                              okButtonTapped: () async {
                                _loading!.show(context);
                                _presenter!.deleteSyllabus(syllabus.syllabusName);
                                await FileStorageHelper.deleteFolder(syllabus.syllabusName);
                              });
                        },);
                      },
                      child: const Icon(Icons.delete, color: AppColors.purple, size: 35),
                    ),
                  ],
                ),
                Text('Dung lượng: ${formatCapacity(syllabus.capacity)}', style: const TextStyle (
                    color: AppColors.purple,
                    fontWeight: FontWeight.w500,
                    fontSize: 15
                )),
                Text('Ngày update: ${syllabus.updateAt}', style: const TextStyle (
                    color: AppColors.purple,
                    fontWeight: FontWeight.w500,
                    fontSize: 15
                ))
              ],
            )
          ],
        ),
      ),
    );
  }

  String formatCapacity(double capacity) {
    if (capacity > 100) {
      return '${(capacity / 1024).toStringAsFixed(2)} GB';
    } else {
      return '${capacity.toStringAsFixed(2)} MB';
    }
  }
  
  String statusDownload(int status) {
    if (status == 0) {
      return 'Chưa tải';
    } else {
      return 'Đã tải';
    }
  }

  @override
  void onGetListSyllabusComplete(List<Syllabus> syllabus, int total) {
    totalSyllabus = total;
    _provider!.setListSyllabus(syllabus);
    // _loading!.hide();
    _presenter!.insertListSyllabusToDB(syllabus);
  }

  @override
  void onGetListSyllabusError(String message) {
    _loading!.hide();
    showDialog(context: context, builder: (context) {
      return MessageDialog(context: context, message: message);
    });
  }

  @override
  void onDownloadError(String msg) {
    print(msg);
  }

  @override
  void onDownloadSuccess(int index,int to, int total, int totalCapacity) async {
    _provider!.setCurrentIndex(index + 1);
    double capacity = await FileStorageHelper.getSizeFolder(syllabusName);
    DatabaseHelper.updateDownloadAtSyllabus(DateTime.now().toIso8601String(), syllabusName);
    DatabaseHelper.updateTotalDownloadedSyllabus(index + 1, syllabusName);
    DatabaseHelper.updateStatusDownloadSyllabus(1, syllabusName);
    DatabaseHelper.updateCapacitySyllabus(capacity / 1024 / 1024, syllabusName);
    if (index + 1 == total) {
      _provider!.setStatusDownloadProgressing(false);
      _mainWidgetProvider!.setTitleMain(Utils.instance().multiLanguage(StringConstants.syllabus_list));
      page = 1;
      _presenter!.getAllSyllabusInDB();
    } else {
      if (index == to - 1) {
        page ++;
        _presenter!.getListFileSyllabus(context, syllabus_id, page, syllabusName);
      }
    }
  }

  @override
  void onGetListFileComplete(int total) {
    _provider!.setTotal(total);
    _provider!.setStatusDownloadProgressing(true);
    _mainWidgetProvider!.setTitleMain(syllabusName);
    _loading!.hide();
  }

  @override
  void onGetListFileError(String msg) {
    _loading!.hide();
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(context: context, message: msg);
        });
  }

  @override
  void onInsertSyllabusToDBComplete() {
    _presenter!.getAllSyllabusInDB();
  }

  @override
  void onInsertSyllabusToDBError(String msg) {
    _loading!.hide();
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(context: context, message: msg);
        });
  }

  @override
  void onGetListSyllabusDBComplete(List<SyllabusDBModel> list) {
    _provider!.setListSyllabusDB([]);
    _provider!.setListSyllabusDB(list);
    _loading!.hide();
  }

  @override
  void onGetListSyllabusDBError(String msg) {
    _loading!.hide();
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(context: context, message: msg);
        });
  }
}
