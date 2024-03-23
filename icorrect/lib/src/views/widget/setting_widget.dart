import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
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
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: isLoading // Kiểm tra trạng thái loading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Hiển thị loading indicator nếu đang tải
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Using video player library'),
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
              ),
            ),
    );
  }
}
