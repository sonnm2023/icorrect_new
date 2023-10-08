<<<<<<< HEAD
// import 'package:camera/camera.dart';
// import 'package:flutter/foundation.dart';
//
// class CameraService {
//   CameraController? _cameraController;
//   List<CameraDescription>? _cameras;
//   CameraController? get cameraController => _cameraController;
//
//   Future<void> initialize(Function refreshState) async {
//     _cameras = await availableCameras();
//
//     _cameraController = CameraController(
//       _cameras![1],
//       ResolutionPreset.low,
//       enableAudio: true,
//     );
//
//     await _cameraController!.initialize().then((value) {
//       refreshState();
//     }).catchError((e) {
//       print(e);
//     });
//   }
//
//   void startCameraRecording() {
//     if (_cameraController != null) {
//       _cameraController!.startVideoRecording();
//     }
//   }
//
//   void saveVideoDoingTest() {
//     _cameraController!.stopVideoRecording().then((value) async {
//       if (value != null) {
//         if (kDebugMode) {
//           int length = (await value.readAsBytes()).lengthInBytes;
//           print(
//               "DEBUG : Video Recording saved to ${value.path}, size : ${length / 1024}kb, size ${(length / 1024) / 1024}mb");
//         }
//       }
//     });
//   }
//
//   dispose() async {
//     await _cameraController?.dispose();
//     _cameraController = null;
//   }
// }
=======
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

  void startCameraRecording() {
    if (_cameraController != null) {
      _cameraController!.startVideoRecording();
    }
  }

  void saveVideoDoingTest(Function(File savedFile) saveVideoCallBack) {
    try {
      _cameraController!.stopVideoRecording().then((value) async {
        if (value != null) {
          saveVideoCallBack(File(value.path));
          if (kDebugMode) {
            int length = (await value.readAsBytes()).lengthInBytes;
            print(
                "DEBUG : Video Recording saved to ${value.path}, size : ${length / 1024}kb, size ${(length / 1024) / 1024}mb");
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("DEBUG : ERROR WHEN SAVE RECORDING VIDEO : ${e.toString()}");
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
>>>>>>> build/update_exam_logic
