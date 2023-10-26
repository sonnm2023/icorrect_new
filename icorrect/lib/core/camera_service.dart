import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  CameraController? get cameraController => _cameraController;

  Future<void> initialize(Function refreshState) async {
    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras![1],
      ResolutionPreset.high,
      enableAudio: true,
    );

    await _cameraController!.initialize().then((value) {
      refreshState();
    }).catchError((e) {
      if (kDebugMode) {
        print(e);
      }
    });
  }

  void startCameraRecording() async {
    if (_cameraController != null) {
      _cameraController!.startVideoRecording();
    }
  }

  void saveVideoDoingTest(Function(File savedFile) saveVideoCallBack) {
    try {
      _cameraController!.stopVideoRecording().then((value) async {
        saveVideoCallBack(File(value.path));
        if (kDebugMode) {
          int length = (await value.readAsBytes()).lengthInBytes;
          print(
              "RECORDING_VIDEO : Video Recording saved to ${value.path}, size : ${length / 1024}kb, size ${(length / 1024) / 1024}mb");
        }
      });
    } on CameraException catch (e) {
      if (kDebugMode) {
        print(
            "RECORDING_VIDEO : ERROR WHEN SAVE RECORDING VIDEO : ${e.toString()}");
      }
    }
  }

  dispose() async {
    if (_cameraController != null) {
      await _cameraController?.dispose();
      _cameraController = null;
    }
  }
}
