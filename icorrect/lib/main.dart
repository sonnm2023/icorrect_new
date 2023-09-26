import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences_keys.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/provider/homework_provider.dart';
import 'package:icorrect/src/provider/play_answer_provider.dart';
import 'package:icorrect/src/provider/re_answer_provider.dart';
import 'package:icorrect/src/provider/simulator_test_provider.dart';
import 'package:icorrect/src/provider/timer_provider.dart';
import 'package:icorrect/src/views/screen/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import 'src/provider/my_test_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Init task run on background
  Workmanager().initialize(callbackDispatcher);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(const MyApp()));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MyTestProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => TimerProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PlayAnswerProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReAnswerProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SimulatorTestProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeWorkProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(seedColor: AppColor.defaultWhiteColor),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const LoginScreen(),
      ),
    );
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    // your code that you want to run in background
    if (kDebugMode) {
      print('DEBUG: Task executed: $taskName');
    }

    //Check logs file is exist
    String folderPath = await FileStorageHelper.getExternalDocumentPath();
    String path = "$folderPath/flutter_logs.txt";
    if (kDebugMode) {
      print("DEBUG: log file path = $path");
    }

    bool isExistFile = await File(path).exists();

    if (!isExistFile) {
      if (kDebugMode) {
        print("DEBUG: Not have logs at moment");
      }
      return Future.value(false);
    }

    //Get log api info
    String logApiUrl =
        await AppSharedPref.instance().getString(key: AppSharedKeys.logApiUrl);
    String secretkey =
        await AppSharedPref.instance().getString(key: AppSharedKeys.secretkey);

    if (logApiUrl.isEmpty || secretkey.isEmpty) {
      if (kDebugMode) {
        print("DEBUG: Not have logs at moment");
      }
      return Future.value(false);
    }

    http.MultipartRequest request =
        http.MultipartRequest(RequestMethod.post, Uri.parse(logApiUrl));

    Map<String, String> formData = {};
    formData.addEntries([MapEntry("secretkey", secretkey)]);
    formData.addEntries([const MapEntry("file", "flutter_logs.txt")]);
    request.fields.addAll(formData);
    request.files.add(
      http.MultipartFile(
        "file",
        File(path).readAsBytes().asStream(),
        File(path).lengthSync(),
        filename: 'flutter_logs.txt',
      ),
    );

    var res = await request.send();
    if (res.statusCode == 200) {
      if (kDebugMode) {
        print("DEBUG: send log success");
      }
      //TODO: Delete log file
      Utils.deleteLogFile();
    } else {
      if (kDebugMode) {
        print("DEBUG: send log failed");
      }
    }

    return Future.value(true);
  });
}
