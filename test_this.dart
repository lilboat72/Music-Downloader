List music = [];

class FailedListItem<T>{
  bool isSelected = false;// Selection property to highlight or not
  T data;
  FailedListItem(this.data);
}

Future main() async{
  Future populatedata() async{
    Map jsonObjects = { 'Singles': {'Songname': 'MoBamba', 'url': 'youtube.com/mobamba','reason': 'Internet connection lost', 'solution': 'just retry'}, 'Playlist': {'Songname': 'MoBamba', 'playlistName': 'MUDBOY','url': 'youtube.com/playlist','reason': 'Internet connection lost', 'solution': 'just retry'} };
    print(jsonObjects.keys.toList()[0]);
    for(MapEntry item in jsonObjects.entries){
      music.add(FailedListItem<Map>({item.key: item.value}));
    }
    print('MUSIC LIST: $music');
    print('MUSIC DATA: ${music[0].data}'); // returns MAP
    print('MUSIC DATA: ${music[1].data}'); // returns MAP
    //return music;   
  }
  await populatedata();
}
