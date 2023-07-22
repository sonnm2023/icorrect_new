import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:icorrect/src/data_sources/constant_strings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileStorageHelper {
  static Future<String> getExternalDocumentPath() async {
    var status = await Permission.storage.status; 
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    Directory directory = Directory('');
    directory = await getApplicationDocumentsDirectory();

    final exPath = directory.path;
    if (kDebugMode) print("Saved Path: $exPath");
    await Directory(exPath).create(recursive: true);
    return exPath;
  }

  static Future<String> get _getRootPath async {
    // final directory = await getExternalDocumentPath();
    // return directory;

    final directory = await getApplicationSupportDirectory();
    return directory.path;
  }

  static Future<String> getFolderPath(MediaType mediaType) async {
    final path = await _getRootPath;

    String folder = '';
    if (mediaType == MediaType.video) {
      folder = StringClass.video;
    } else {
      folder = StringClass.audio;
    }

    String filePath = '$path\\$folder';
    Directory hideDirectory = Directory(filePath);
    return hideDirectory.path;
  }

  static Future<File> writeVideo(
      String bytes, String name, MediaType mediaType) async {
    final path = await getFolderPath(mediaType);
    File file = File('$path\\$name');
    if (kDebugMode) print('Save file: $path\\$name');
    return file.writeAsString(bytes);
  }

  static Future<String> readVideoFromFile(
      String fileName, MediaType mediaType) async {
    try {
      final path = await getFolderPath(mediaType);
      File file = File('$path\\$fileName');
      final content = file.readAsStringSync();
      return content;
    } catch (e) {
      return '';
    }
  }

  static Future<bool> checkExistFile(
      String fileName, MediaType mediaType) async {
    final path = await getFolderPath(mediaType);
    String filePath = '$path\\$fileName';
    bool result = await File(filePath).exists();
    return result;
  }

  static Future<String> getFilePath(
      String fileName, MediaType mediaType) async {
    final path = await getFolderPath(mediaType);
    String filePath = '$path\\$fileName';
    return filePath;
  }
}
