/** 
 * On the frontend side of things, only this file may read or modify json files
 * 
 * json objects format: [{url:name}]
 */

//TODO: change this file name to something more 'understandable'

import 'dart:io';
import 'dart:convert';
import 'package:Myapp/Backend/Download.dart' as Download;
import 'package:Myapp/Backend/Email_service.dart' as Email;
import 'package:path_provider/path_provider.dart' as Storage;
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mutex/mutex.dart';

String appStorage;
Directory audiosFile;
String frontendFile = 'assets/frontendFile.json';
String backendFile = 'assets/backendFile.json';
String idSingles = 'Singles';
String idPlaylists = 'Playlists';
String idSpecificSingles = 'SpecificSingles';
String idSpecificPlaylists = 'SpecificPlaylists';
String idQueue = 'Queue';
SharedPreferences prefs;
Mutex fileLock = Mutex(); // Prevents reads or writes

/// Represents useable values in [perfs].
/// Extremely important that its up to date with [perfs].
/// 
/// **ABSENT
/// 
/// NEW_USER - it shouldn't be modified 
enum Setting{
  Dark_Mode,
  Auto_Downloads,
  Storage_Location,
  Internal_External,
}

Future readJson(String fileName) async{
  await fileLock.acquire();

  List section = fileName.split('/');
  String data = await File(appStorage + '/${section[1]}').readAsString();

  fileLock.release();
  return json.decode(data);
}

Future writeJson(String fileName, Object contents) async{
  await fileLock.acquire(); // Attempts to acquire any lock (read or write) will be blocked until this write lock is released.

  List section = fileName.split('/');
  File file = File(appStorage + '/${section[1]}');
  if(contents is Map){
    await file.writeAsString(json.encode(contents));
  }else{
    await file.writeAsString('$contents'); 
  }

  fileLock.release();
}

/// Startup is true by default
/// 
/// This function's purpose is to configure necessary values that usually require awaiting
/// before other functions and classes use them.
Future config() async{
  print('Initializing Startup');
  prefs = await SharedPreferences.getInstance();
  appStorage = (await Storage.getApplicationDocumentsDirectory()).path;

  if (prefs.containsKey('NEW_USER') == false){
    // app has been run for the very first time
    // Time to initialize our values
    await prefs.setBool('NEW_USER', false);
    await prefs.setBool('${Setting.Dark_Mode}', false);
    await prefs.setBool('${Setting.Auto_Downloads}', false);
    await prefs.setString('${Setting.Storage_Location}', (await Storage.getExternalStorageDirectory()).path); //TODO: Problem with this is that when app gets deleted, so does the folder
    await prefs.setString('${Setting.Internal_External}', 'Internal');
    
    /// Create asset files into directory
    String makefrontendFile = await rootBundle.loadString(frontendFile);
    String makebackendFile = await rootBundle.loadString(backendFile);
    await writeJson(frontendFile, makefrontendFile);
    await writeJson(backendFile, makebackendFile);
  }

  audiosFile = await Directory(prefs.getString('${Setting.Storage_Location}') + '/BoatAudios').create();
  print(audiosFile);
}

Future downloadSingle({bool specific = false}) async{
  print('Entering API single function');
  Map newLinks = await readJson(frontendFile);
  print('Done reading frontendFile');
  
  if(specific == false){ 
    // all downloads 
    if(newLinks[idSingles].isNotEmpty){
      newLinks[idQueue].add( {idSingles : Map.of(newLinks[idSingles])} );
      newLinks[idSingles].clear();
      await writeJson(frontendFile, newLinks);
      print('After writing: $newLinks');
      print('Done writing');
    }
  }
  else{ 
    // specific downloads
    if(newLinks[idSpecificSingles].isNotEmpty){
      newLinks[idQueue].add( {idSingles : Map.of(newLinks[idSpecificSingles])} );
      newLinks[idSpecificSingles].clear();
      await writeJson(frontendFile, newLinks);
      print('After writing: $newLinks');
      print('Done writing');
    }
  }
}

Future downloadPlaylist({bool specific = false}) async{
  print('Entering API playlist function');
  Map newLinks = await readJson(frontendFile);
  print('Done reading frontendFile');
  
  if(specific == false){
    // all downloads 
    if(newLinks[idPlaylists].isNotEmpty){
      newLinks[idQueue].add( {idPlaylists : Map.of(newLinks[idPlaylists])} );
      newLinks[idPlaylists].clear();
      await writeJson(frontendFile, newLinks);
      print('After writing: $newLinks');
      print('Done writing');
    }
  }
  else{
    // specific downloads
    if(newLinks[idSpecificPlaylists].isNotEmpty){
      newLinks[idQueue].add( {idPlaylists : Map.of(newLinks[idSpecificPlaylists])} );
      newLinks[idSpecificPlaylists].clear();
      await writeJson(frontendFile, newLinks);
      print('After writing: $newLinks');
      print('Done writing');
    }
  }
}

/// Type:
/// 
///         Critical
///         Feedback
Future mail(String subject, String body, String type) async{
  Email.sendIt(subject, body, type);
}

/// TODO: Needs to run as a background process even when app is fully closed
Future queue() async{
  /** 
  * [frontendFile] "queue" syntax e.g: [{'Singles':{url:name, url:name, url:name}}, {'Playlists':{url:name}}, {'Playlists':{url:name, url:name}}]
  * NB 'Specifics' are either seen as 'Singles' or 'Playlists'
  */
  Map nextUp = await readJson(frontendFile); // Gets iterated through

  // Active checks
  while(true){
    for(Map map in nextUp[idQueue]){
      for(MapEntry item in map.entries){
        if(map[item.key] == {}){
          print(map[item.key]);
          break;
        }
        if(item.key == idSingles){
          print('calling singles handler...');
          await Download.handler(Download.singles, item.value);
        }
        if(item.key == idPlaylists){
          print('calling playlists handler...');
          await Download.handler(Download.playlist, item.value);
        }
      }
    }
    await Future.delayed(Duration(seconds: 10));
    Map nextUp2 = await readJson(frontendFile); // new updated [frontendFile] "queue"
    print('nextUp: ${nextUp[idQueue]}');
    print('-----');
    print('nextUp2: ${nextUp2[idQueue]}');
    if (nextUp2[idQueue].length != nextUp[idQueue].length){
      // Something new has been added to [frontendFile] "queue"
      nextUp[idQueue] = nextUp2[idQueue].sublist(nextUp[idQueue].length);
    }else{
      //Nothing has changed in [frontendFile] "queue"
      nextUp[idQueue].clear();
      nextUp2[idQueue].clear();
      print('NEW JSON TO BE ADDED: $nextUp2');
      await writeJson(frontendFile, nextUp2);
    }
  }
}
