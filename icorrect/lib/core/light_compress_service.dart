import 'package:light_compressor/light_compressor.dart';
import 'package:flutter/foundation.dart';

class LightCompressVideo {
  static LightCompressor getLightCompress() {
    return LightCompressor();
  }

  static Future<Result> getLightCompressVideo(
      String path, String videoName, LightCompressor lightCompressor) async {
    return await lightCompressor.compressVideo(
      path: path,
      videoQuality: VideoQuality.medium,
      isMinBitrateCheckEnabled: false,
      video: Video(videoName: videoName),
      android: AndroidConfig(isSharedStorage: true, saveAt: SaveAt.Movies),
      ios: IOSConfig(saveInGallery: true),
    );
  }

  static void getResponseLightCompress(
      Result result,
      Function(String outputFile) outputResponse,
      Function(String message) onFailure,
      Function(String message) onCancelled) {
    if (result is OnSuccess) {
      final String outputFile = result.destinationPath;
      outputResponse(outputFile);
    } else if (result is OnFailure) {
      if (kDebugMode) {
        print('DEBUG: Error light compress video message: ${result.message}');
      }
      onFailure('Error light compress video message: ${result.message}');
    } else if (result is OnCancelled) {
      if (kDebugMode) {
        print(
            'DEBUG: Error light compress video cancelled: ${result.isCancelled}');
      }
      onCancelled(
          'Error light compress video cancelled: ${result.isCancelled}');
    }
  }
}
