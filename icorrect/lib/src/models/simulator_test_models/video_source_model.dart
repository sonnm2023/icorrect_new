import 'package:native_video_player/native_video_player.dart';

class VideoSourceModel {
  final String path;
  final VideoSourceType type;

  VideoSourceModel({
    required this.path,
    required this.type,
  });
}