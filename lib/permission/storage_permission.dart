import 'package:permission_handler/permission_handler.dart';

class PermissionStorage {
  static Future<bool> getPermissionStorage() async {
    var storageStatus = await Permission.storage.request();
    if (!storageStatus.isGranted) {
      await Permission.storage.request();
      if (!storageStatus.isGranted) {
        return false;
      }
    } else {
      true;
    }
    return true;
  }
}
