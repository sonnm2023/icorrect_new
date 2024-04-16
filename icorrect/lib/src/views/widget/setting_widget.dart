import 'dart:io';

import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool setting;
  bool isLoading = false; // Trạng thái loading

  @override
  void initState() {
    super.initState();
    _loadSetting();
  }

  Future<void> _loadSetting() async {
    setState(() {
      isLoading = true; // Bắt đầu quá trình tải
    });
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      setting = prefs.getBool('use_video_player_lib') ?? true;
      isLoading = false; // Kết thúc quá trình tải
    });
  }

  Future<void> _saveSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_video_player_lib', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: isLoading // Kiểm tra trạng thái loading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Hiển thị loading indicator nếu đang tải
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSwitchVideoLib(),
                  const Divider(),
                  _buildShareLog(),
                  const Divider(),
                ],
              ),
            ),
    );
  }

  Widget _buildSwitchVideoLib() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Using video player library'),
        Switch(
          value: setting,
          onChanged: (value) async {
            await _saveSetting(value);
            setState(() {
              setting = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildShareLog() {
    return InkWell(
      onTap: () {
        showShareBottomSheet(context);
      },
      child: const Row(
        children: [
          SizedBox(
            height: 44,
            child: Center(child: Text('Share log')),
          )
        ],
      ),
    );
  }

  void showShareBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.facebook),
              title: const Text('Share via Facebook'),
              onTap: () {
                shareFileViaFacebook();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share via Zalo'),
              onTap: () {
                shareFileViaZalo();
              },
            ),
          ],
        );
      },
    );
  }

  void shareFileViaFacebook() async {
    String folderPath = await FileStorageHelper.getExternalDocumentPath();
    String filePath = "$folderPath/flutter_logs.txt";
    File file = File(filePath);
    if (await file.exists()) {
      XFile xFile = XFile(filePath);
      Share.shareXFiles([xFile],
              text: 'Check out this file!',
              sharePositionOrigin: const Rect.fromLTRB(0.0, 0.0, 100.0, 100.0))
          .then((value) => print('File shared via Facebook'))
          .catchError((error) => print('Error sharing file: $error'));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hiện không có file để share. Làm ơn quay lại sau!'),
        ),
      );
    }
  }

  void shareFileViaZalo() async {
    String folderPath = await FileStorageHelper.getExternalDocumentPath();
    String filePath = "$folderPath/flutter_logs.txt";
    File file = File(filePath);
    if (await file.exists()) {
      XFile xFile = XFile(filePath);
      Share.shareXFiles([xFile],
              text: 'Check out this file!',
              sharePositionOrigin: const Rect.fromLTRB(0.0, 0.0, 100.0, 100.0))
          .then((value) => print('File shared via Zalo'))
          .catchError((error) => print('Error sharing file: $error'));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hiện không có file để share. Làm ơn quay lại sau!'),
        ),
      );
    }
  }
}
