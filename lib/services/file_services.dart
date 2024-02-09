//import 'dart:convert';
import 'dart:io';
//import 'dart:math';

//import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
//import 'package:flutter/foundation.dart';
//import 'package:hive/hive.dart';
//import 'package:path/path.dart' as p;
//import 'package:path_provider/path_provider.dart' as path;
//import 'package:path_provider/path_provider.dart';

//import 'package:rabbit_clipboard/models/file_model.dart';
//import 'package:rabbit_clipboard/models/sender_model.dart';

class FileMethods {
  //todo implement separate file picker for android to avoid caching
  static Future<List<String?>> pickFiles() async {
    FilePickerResult? files = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.any, withData: false);
    if (files == null) {
      return [];
    } else {
      return files.paths;
    }
  }

  ///This typically relates to cached files that are stored in the cache directory
  ///Works only for android and ios
  static clearCache() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await FilePicker.platform.clearTemporaryFiles();
    }
  }
}
