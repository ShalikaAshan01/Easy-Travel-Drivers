import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class Permissions{
  bool isAndroid(){
    return Platform.isAndroid;
  }
  void requestCameraPermission() async{
    await PermissionHandler().requestPermissions([PermissionGroup.camera]);
  }
  Future<PermissionStatus> checkCameraPermission()async{
    return PermissionHandler().checkPermissionStatus(PermissionGroup.camera);
  }
  Future<bool> checkRationaleCameraPermission()async{
    return await PermissionHandler()
        .shouldShowRequestPermissionRationale(PermissionGroup.camera);
  }
  void requestLocationPermission() async{
    await PermissionHandler().requestPermissions([PermissionGroup.location]);
  }
  Future<PermissionStatus> checkLocationPermission()async{
    return PermissionHandler().checkPermissionStatus(PermissionGroup.location);
  }
  Future<bool> checkRationaleLocationPermission()async{
    return await PermissionHandler()
        .shouldShowRequestPermissionRationale(PermissionGroup.location);
  }
}