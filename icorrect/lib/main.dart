import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constant_methods.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences.dart';
import 'package:icorrect/src/data_sources/local/app_shared_preferences_keys.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/data_sources/multi_language.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/provider/homework_provider.dart';
import 'package:icorrect/src/provider/my_practice_list_provider.dart';
import 'package:icorrect/src/provider/my_practice_topics_provider.dart';
import 'package:icorrect/src/provider/play_answer_provider.dart';
import 'package:icorrect/src/provider/rating_provider.dart';
import 'package:icorrect/src/provider/re_answer_provider.dart';
import 'package:icorrect/src/provider/simulator_test_provider.dart';
import 'package:icorrect/src/provider/timer_provider.dart';
import 'package:icorrect/src/provider/user_auth_detail_provider.dart';
import 'package:icorrect/src/provider/video_authentication_provider.dart';
import 'package:icorrect/src/views/screen/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import 'src/provider/my_test_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  //Init task run on background
  Workmanager().initialize(callbackDispatcher);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(const MyApp()));

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterLocalization _localization = FlutterLocalization.instance;
  StreamSubscription? connection;

  @override
  void initState() {
    _localization.init(
      mapLocales: [
        const MapLocale('en', MultiLanguage.EN),
        const MapLocale('vi', MultiLanguage.VN),
      ],
      initLanguageCode: 'vi',
    );
    _localization.onTranslatedLanguage = _onTranslatedLanguage;

    connection = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        //Show toast for disconnected
        showToastMsg(
          msg: Utils.multiLanguage(StringConstants.network_error_message)!,
          toastState: ToastStatesType.warning,
          isCenter: false,
        );
      }
    });

    super.initState();
  }

  void _onTranslatedLanguage(Locale? locale) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MyTestProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => PlayAnswerProvider()),
        ChangeNotifierProvider(create: (_) => ReAnswerProvider()),
        ChangeNotifierProvider(create: (_) => SimulatorTestProvider()),
        ChangeNotifierProvider(create: (_) => HomeWorkProvider()),
        ChangeNotifierProvider(create: (_) => VideoAuthProvider()),
        ChangeNotifierProvider(create: (_) => UserAuthDetailProvider()),
        ChangeNotifierProvider(create: (_) => RatingProvider()),
        ChangeNotifierProvider(create: (_) => MyPracticeListProvider()),
        ChangeNotifierProvider(create: (_) => MyPracticeTopicsProvider()),
      ],
      child: MaterialApp(
        supportedLocales: _localization.supportedLocales,
        localizationsDelegates: _localization.localizationsDelegates,
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

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
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
      print("DEBUG-SENDLOG: HAS NOT LOG FILE");
      return Future.value(false);
    }

    //For test
    File(path).readAsString().then((String contents) {
      print("DEBUG-SENDLOG: LOG CONTENT: $contents");
    });

    //Get log api info
    String logApiUrl =
        await AppSharedPref.instance().getString(key: AppSharedKeys.logApiUrl);
    String secretkey =
        await AppSharedPref.instance().getString(key: AppSharedKeys.secretkey);

    if (logApiUrl.isEmpty || secretkey.isEmpty) {
      if (kDebugMode) {
        print("DEBUG: Not have log url or secretkey");
      }
      print("DEBUG-SENDLOG: HAS NOT LOG URL OR SECRETKEY");
      return Future.value(false);
    }

    print("DEBUG-SENDLOG: URL: $logApiUrl");

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
        print("DEBUG: send log success kDebugMode");
      }
      print("DEBUG-SENDLOG: SUCCESS");
      // Utils.deleteLogFile();
    } else {
      if (kDebugMode) {
        print("DEBUG: send log failed  - kDebugMode");
      }
      print("DEBUG-SENDLOG: ERROR: ${res.toString()}");
    }

    return Future.value(true);
  });
}
