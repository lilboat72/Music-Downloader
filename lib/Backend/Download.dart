/** 
 * [MyApi.backendFile]["failedDownloads"] syntax: { 'urlhere': {'Songname': 'MoBamba', 'type': 'Singles','reason': 'Internet connection lost', 'solution': 'just retry'}, 'urlhere2': {'Songname': 'MoBamba', 'playlistName': 'MUDBOY','type': 'Playlist','reason': 'Internet connection lost', 'solution': 'just retry'} }
 * [MyApi.backendFile]["finishedDownloads"] syntax: //TODO
 */

import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:io';
import 'package:http/http.dart';
import 'package:Myapp/API.dart' as MyApi;

/// Downloads thumbanail straight into [directory]
Future<void> _downloadThumbnail(String url, Directory directory) async{
  print('Downloading thumbnail $url');
  Response response = await get(url);
  File image = File('${directory.path}/COVER_IMAGE');
  image.writeAsBytesSync(response.bodyBytes);
}

//${MyApi.cfg.getString("Storage_Location")}
Future singles(YoutubeExplode yt, MapEntry userMusic) async{
  String id = YoutubeExplode.parseVideoId(userMusic.key);
  print('ID: --------------- $id');
  id == null ? print('Failed to extract id. id: $id'):null;
  MediaStreamInfoSet mediaStreams = await yt.getVideoMediaStream(id);
  Video title = mediaStreams.videoDetails;
  AudioStreamInfo audio = mediaStreams.audio.last; // Highest bitrate
  print(audio.audioEncoding);
  File location = File('${MyApi.audiosFile.path}/${userMusic.value}.m4a');
  print(location);

  // Open the file
  IOSink output = location.openWrite(mode: FileMode.writeOnlyAppend);
  print('TITLE: -------------- ${title.title}');

  // Listen for data received and add to [output]
  await for(List<int> data in audio.downloadStream()){
    output.add(data);
  }

  // close file
  await output.close();
}

/// Playlist links MUST look like this: https://www.youtube.com/playlist?list=blah1blah2blah3
Future playlist(YoutubeExplode yt, MapEntry userMusic) async{
  bool getThumb = true; // Once the first thumbnail has been downloaded, set this to false
  String id = YoutubeExplode.parsePlaylistId(userMusic.key);
  print('ID: --------------- $id');
  id == null ? 'Failed to extract id. id: $id':null;
  Playlist playlist = await yt.getPlaylist(id);
  print(playlist.title);
  Directory album = await Directory('${MyApi.audiosFile.path}/${userMusic.value}').create();

  for(Video item in playlist.videos){
    MediaStreamInfoSet mediaStreams = await yt.getVideoMediaStream(item.id);
    AudioStreamInfo audio = mediaStreams.audio.last; // Highest bitrate
    Video title = mediaStreams.videoDetails; // Video title
    File location = File('${album.path}/${item.title}.m4a'); // Currently the name cannot be changed

    // Download thumbnail. Only required to get the first one in the playlist 
    if(getThumb){
      ThumbnailSet thumbnail = ThumbnailSet(item.id); // Get thumbnail info
      await _downloadThumbnail(thumbnail.highResUrl, album);
      getThumb = false;
    }

    // Open the file
    IOSink output = location.openWrite(mode: FileMode.writeOnlyAppend);
    print('TITLE: -------------- ${title.title}');
    
    // Download as stream and add to [output]
    await for(List<int> data in audio.downloadStream()){
      output.add(data);
    }

    // close file
    await output.close();
  }
}

/// Never call [singles] and [playlists] individually. Rather use this handler.
/// 
/// Handles the finished and failed downloads in Function -singles and playlists- and then reports that to [MyAPI.backendFile]
/// in either "finishedDownloads" or "failedDownloads"
Future handler(Function func, Map music) async{
  YoutubeExplode yt = YoutubeExplode();

  for(MapEntry userMusic in music.entries){
    try{
      await func(yt, userMusic);
    }
    ///TODO: add the link that caught these exeptions into [MyAPI.backendFile]["finishedDownloads"]
    
    // YoutubeExplode errors
    on VideoRequiresPurchaseException catch(e){
      String reason = 'The owner of this video requires a purchase to access this video';
      String solution = 'Unless your youtube account has purchased this video, it cannot be downloaded';
      print(e);
    }
    on VideoStreamUnavailableException catch(e){
      String reason = 'Stream unavailable';
      String solution = '';
      print(e);
    }
    on VideoUnavailableException catch(e){
      String reason = 'Video unavailabe, deleted or is private';
      String solution = 'Avoid passing in links from unavailable videos';
      print(e);
    }
    on VideoUnplayableException catch(e){
      String reason = 'Video might be blocked in your region or requires purchase';
      String solution = 'Avoid passing in links from unavailable videos';
      print(e);
    }
    on UnrecognizedStructureException catch(e){
      String reason = 'Seems like youtube has changed their url naming conventions :(';
      String solution = 'NO NEED TO WORRY:) OUR DEVS HAVE BEEN NOTIFIED, AND WILL TRY TO PUSH AN UPDATE ASAP';// TODO: Notify me 
      print(e);
      break;
    }
  }

  yt.close();
}

// main(List<String> args) async{
//   //singles('https://www.youtube.com/watch?v=RIuk23XHYj0', 'Gang Gang');
//   //playlist('https://www.youtube.com/playlist?list=PLwJPVqdDa7fQJxJGe9KHMEIxLcTB0sJgO', 'Mudboy');

//   await handler(playlist, {'https://www.youtube.com/playlist?list=PLwJPVqdDa7fQJxJGe9KHMEIxLcTB0sJgO':'MUDBOY'});
// }