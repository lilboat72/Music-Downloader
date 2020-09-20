import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:io';
import 'package:http/http.dart';

/// Downloads thumbanail straight into [directory]
Future<void> downloadThumbnail(String url, Directory directory) async{
  print('Downloading thumbnail $url');
  Response response = await get(url);
  File image = File('${directory.path}/COVER_IMAGE');
  image.writeAsBytesSync(response.bodyBytes);
}

Future singles(String myId, String userDefinedName) async{
  // Intializing
  YoutubeExplode yt = YoutubeExplode();
  String id = YoutubeExplode.parseVideoId(myId);
  print('ID: --------------- $id');
  if(id == null){
    return print('id cannot be extracted');
  }
  Video title = await yt.getVideo(id);
  MediaStreamInfoSet mediaStreams = await yt.getVideoMediaStream(id);
  AudioStreamInfo audio = mediaStreams.audio.last; // Highest bitrate
  print(audio.audioEncoding);
  File location = File('../Audios/$userDefinedName.m4a'); // TODO: rootbundle should be used here
  
  // Open the file
  IOSink output = location.openWrite(mode: FileMode.writeOnlyAppend);
  print('TITLE: -------------- ${title.title}');

  // Listen for data received and add to [output]
  await for(List<int> data in audio.downloadStream()){
    output.add(data);
  }

  // Close [output] and connection
  await output.close();
  yt.close();
}

/// Playlist links MUST look like this: https://www.youtube.com/playlist?list=blah1blah2blah3
Future playlist(String myId, String userDefinedName) async{
  // Initializing
  YoutubeExplode yt = YoutubeExplode();
  bool getThumb = true; // Once the first thumbnail has been downloaded, set this to false
  String id = YoutubeExplode.parsePlaylistId(myId);
  print('ID: --------------- $id');
  id == null ? 'Failed to extract id. id: $id':null;
  Playlist playlist = await yt.getPlaylist(id);
  print(playlist.title);
  Directory album = await Directory('../Audios/$userDefinedName').create(); // TODO: remove hardcode

  for(Video item in playlist.videos){
    MediaStreamInfoSet mediaStreams = await yt.getVideoMediaStream(item.id);
    AudioStreamInfo audio = mediaStreams.audio.last; // Highest bitrate
    Video title = mediaStreams.videoDetails; // Video title
    File location = File('${album.path}/${item.title}.m4a'); // TODO: rootbundle should be used here;

    // Download thumbnail. Only required to get the first one in the playlist 
    if(getThumb){
      ThumbnailSet thumbnail = ThumbnailSet(item.id); // Get thumbnail info
      await downloadThumbnail(thumbnail.highResUrl, album);
      getThumb = false;
    }

    // Open the file
    IOSink output = location.openWrite(mode: FileMode.writeOnlyAppend);
    print('TITLE: -------------- ${title.title}');
    
    // Download as stream and add to [output]
    await for(List<int> data in audio.downloadStream()){
      output.add(data);
    }
    await output.close();
  }

  yt.close();
}

main(List<String> args) {
  //singles('https://www.youtube.com/watch?v=RIuk23XHYj0', 'Gang Gang');
  playlist('https://www.youtube.com/playlist?list=PLwJPVqdDa7fQJxJGe9KHMEIxLcTB0sJgO', 'Mudboy');
}