// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/api_urls.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/dependency_injection.dart';
import 'package:icorrect/src/data_sources/repositories/user_authen_repository.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:http/http.dart' as http;
import 'package:icorrect/src/models/log_models/log_model.dart';

abstract class VideoAuthenticationContract {
  void onCountRecording(Duration currentCount, String strCount);
  void onFinishRecording();
  void submitAuthSuccess(File savedFile, String message);
  void submitAuthFail(String message);
}

class VideoAuthenticationPresenter {
  final VideoAuthenticationContract? _view;
  UserAuthRepository? _repository;
  VideoAuthenticationPresenter(this._view) {
    _repository = Injector().getUserAuthDetailRepository();
  }

  Timer startCountRecording({required Duration durationFrom}) {
    const oneSec = Duration(seconds: 1);
    return Timer.periodic(oneSec, (timer) {
      durationFrom += const Duration(seconds: 1);

      if (durationFrom.inSeconds == 60) {
        _view!.onFinishRecording();
      } else {
        String strCount = formatDuration(durationFrom);
        _view!.onCountRecording(durationFrom, strCount);
      }
    });
  }

  String formatDuration(Duration duration) {
    int minutes = (duration.inMinutes % 60);
    int seconds = (duration.inSeconds % 60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future submitAuth({
    required File authFile,
    required isUploadVideo,
    required BuildContext context,
  }) async {
    LogModel? log;
    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.callApiSubmitAuth);
    }

    String url = submitAuthEP();
    http.MultipartRequest multiRequest =
        http.MultipartRequest(RequestMethod.post, Uri.parse(url));
    multiRequest.headers.addAll({
      StringConstants.k_content_type: 'multipart/form-data',
      StringConstants.k_authorization: 'Bearer ${await Utils.getAccessToken()}'
    });

    multiRequest.files
        .add(await http.MultipartFile.fromPath('video', authFile.path));
    try {
      _repository!.submitAuth(multiRequest).then((value) {
        Map<String, dynamic> json = jsonDecode(value) ?? {};

        if (kDebugMode) {
          print("DEBUG:form response: ${json.toString()}");
        }

        if (json[StringConstants.k_error_code] == 200 &&
            json[StringConstants.k_status] == 'success') {
          //Add log
          Utils.prepareLogData(
            log: log,
            data: jsonDecode(value),
            message: StringConstants.submit_authen_success_message,
            status: LogEvent.success,
          );

          _view!.submitAuthSuccess(
              authFile, StringConstants.submit_authen_success_message);
        } else {
          List<String> categoriesList = List<String>.from(isUploadVideo
              ? json['data']['video'] ?? []
              : json['data']['audio'] ?? []);

          _view!.submitAuthFail(StringConstants.submit_authen_fail_message);
          //Add log
          Utils.prepareLogData(
            log: log,
            data: jsonDecode(value),
            message:
                'Error : ${categoriesList.toString().replaceAll(RegExp(r'[\[\]]'), "")}',
            status: LogEvent.failed,
          );
        }
      });
    } on TimeoutException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: null,
        message: StringConstants.submit_authen_fail_timeout_message,
        status: LogEvent.failed,
      );
      _view!.submitAuthFail(StringConstants.submit_authen_fail_timeout_message);
    } on SocketException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: null,
        message: StringConstants.submit_authen_fail_socket_message,
        status: LogEvent.failed,
      );
      _view!.submitAuthFail(StringConstants.submit_authen_fail_socket_message);
    } on http.ClientException {
      //Add log
      Utils.prepareLogData(
        log: log,
        data: null,
        message: StringConstants.submit_authen_fail_client_message,
        status: LogEvent.failed,
      );
      _view!.submitAuthFail(StringConstants.submit_authen_fail_client_message);
    }
  }
}
