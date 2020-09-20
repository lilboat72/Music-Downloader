/** 
 * Before adding new permissions. Don't forget to first add it in:
 *   android/app/src/main/AndroidManifest.xml
 */

import 'package:permission_handler/permission_handler.dart';

class AskPermission{
  PermissionStatus status;

  // Make sure all permissions in this class are called here
  Future askAll() async{
    await notification();
    await storage();
  }

  Future notification() async{
    this.status = await Permission.notification.request();
    if(this.status.isUndetermined){
      await openAppSettings();
    }
    if(this.status.isDenied){
      await notification();
    }
    if(this.status.isPermanentlyDenied){
      await openAppSettings();
    }
  }
  
  Future storage() async{
    this.status = await Permission.storage.request();
    if(this.status.isUndetermined){
      await openAppSettings();
    }
    if(this.status.isDenied){
      await notification();
    }
    if(this.status.isPermanentlyDenied){
      await openAppSettings();
    }
  }
}