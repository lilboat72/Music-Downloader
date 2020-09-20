import 'package:flutter/material.dart';
import 'package:Myapp/API.dart' as MyApi;

/// Holds the options for appBar
class Option {
  //Color iconColor = Colors.white;
  double buttonWidth = 50;
  buildOption({String tooltipMsg, IconData icon, Function function}){
    return ButtonTheme(
      minWidth: buttonWidth,
      child: Tooltip(
        message: tooltipMsg,
        child: FlatButton(
          onPressed: (){function();},
          child: Icon(icon),
        ),
      ),
    );
  }
}  

// ---------------------------------------------------------------
// Thinking of streams

class CurrentlyListItem<T>{
  bool isSelected = false;// Selection property to highlight or not
  T data;
  CurrentlyListItem(this.data);
}

class CurrentlyDownloading extends StatefulWidget{
  @override
  _CurrentlyDownloading createState() => _CurrentlyDownloading();
}

class _CurrentlyDownloading extends State<CurrentlyDownloading>{
  @override
  Widget build(BuildContext context){
    return null;
  } 
}

// ----------------------------------------------------------------

class FailedListItem<T>{
  bool isSelected = false;// Selection property to highlight or not
  T data;
  FailedListItem(this.data);
}

class Failed extends StatefulWidget{
  @override
  _Failed createState() => _Failed();
}

class _Failed extends State<Failed>{
  bool options = false; // Display options or not
  bool countAfterLongPress = true; // increment or decrement [selectedCount] after a longtap
  int selectedCount = 0; // How many ListView items are selected
  List music = []; // Undownloaded music contains 'instance of...'
  List<Map> selectedMusic = []; // Indexes of selected items
  Future myFuture;

  /// Resets vars at the top of DownloadPageState to default
  void resetVars({bool all = false, bool c_options = false, bool c_countAfterLongPress = false,
    bool c_selectedCount = false, bool c_music = false, bool c_selectedMusic = false}){
    if(all){
      options = false;
      countAfterLongPress = true;
      selectedCount = 0;
      music = []; 
      selectedMusic = []; 
    }else{
      c_options ? options = false: null;
      c_countAfterLongPress ? countAfterLongPress = true:null;
      c_selectedCount ? selectedCount = 0:null;
      c_music ? music = []:null;
      c_selectedMusic ? selectedMusic = []:null;
    }
  }

  void back(){
    setState(() {
      for(var item in music){
        item.isSelected = false;
      }
      resetVars(c_selectedCount: true, c_countAfterLongPress: true, c_options: true);
    });
  }

  Future delete() async{ //TODO: Fix this
    Map file = await MyApi.readJson(MyApi.backendFile);
    for(Map map in selectedMusic){
      for(MapEntry item in map.entries){
        file["failedDownloads"].remove(item.key);
      }
    }
    MyApi.writeJson(MyApi.frontendFile, file);
    await populatedata();
    setState(() {
      if(music.isNotEmpty){
       resetVars(c_selectedMusic: true,c_selectedCount: true); 
      }else{
        resetVars(all: true);
      }
    });
  }

  void selectAll(){
    setState(() {
      for(var item in music){
        item.isSelected = true;
      }
      for(var item in music){
        item.isSelected = true;
        selectedMusic.add(item.data);
      }
      selectedCount = music.length;
    });
  }

  Future downloadSelected() async{
    Map frontend = await MyApi.readJson(MyApi.frontendFile);
    Map backend = await MyApi.readJson(MyApi.backendFile);
    String objectPlace;
    Function func;

    // { 'urlhere': {'Songname': 'MoBamba', 'Type': 'Singles', 'Reason': 'Internet connection lost', 'Solution': 'just retry'}, 'urlhere2': {'Songname': 'MoBamba', 'PlaylistName': 'MUDBOY','Type': 'Playlist', 'Reason': 'Internet connection lost', 'Solution': 'just retry'} }
    // Figure out which 'objectPlace' to place into in frontendFile
    for(Map map in selectedMusic){
      String objectPlace;
      Function func;
      for(MapEntry item in map.entries){
        objectPlace = item.value['Type'];
        if(item.key == MyApi.idSingles){
          func = MyApi.downloadSingle;
        }
        if(item.key == MyApi.idPlaylists){
          func = MyApi.downloadPlaylist;
        }
        backend["failedDownloads"].remove(item.key); // Remove from backend
        frontend[objectPlace][item.key] = item.value['Songname']; // Add to frontend
      }
    }

    await MyApi.writeJson(MyApi.frontendFile, frontend);
    await MyApi.writeJson(MyApi.backendFile, MyApi.backendFile);
    func(specific: true);
    await populatedata();
    setState(() {
      if(music.isNotEmpty){
        resetVars(c_selectedCount: true, c_selectedMusic: true);
      }
      else{
        resetVars(all: true);
      }
    });
  }

  getAppbar(options){
    if(options){
      return AppBar(
        title: Text('$selectedCount'),
        backgroundColor: Colors.red,
        elevation: 10,
        titleSpacing: 20,
        leading: Option().buildOption(tooltipMsg: 'Back', icon: Icons.arrow_back, function: back),
        actions: <Widget>[
          Option().buildOption(tooltipMsg: 'Delete', icon: Icons.delete, function: delete),
          Option().buildOption(tooltipMsg: 'Select all', icon: Icons.done_all, function: selectAll),
          Option().buildOption(tooltipMsg: 'Download selected', icon: Icons.file_download, function: downloadSelected)
        ],
      );
    }else{
      return PreferredSize(
        preferredSize: Size.fromHeight(14),
        child: AppBar(
          title: Text('Failed'),
          leading: Icon(Icons.sms_failed),
        ),
      );
    }
  }

  void getSelectedCount(int index){
    if(music[index].isSelected){
      selectedCount++;
      selectedMusic.add(music[index].data);
    }else{
      selectedCount--;
    }
  }

  Future populatedata() async{
    Map jsonObjects = await MyApi.readJson(MyApi.backendFile);
    for(MapEntry item in jsonObjects["failedDownloads"].entries){
      music.add(FailedListItem<Map>({item.key: item.value}));
    }
    print('MUSIC LIST: $music');
    //return music;   
  }

  Widget _getListItemTile(BuildContext context, int index){
    return GestureDetector(
      onTap: (){
        if(music.any((item) => item.isSelected)){
          setState(() {
            music[index].isSelected = !music[index].isSelected;
            getSelectedCount(index);
          });
        }//if(music.every((item) => item.isSelected == false)){
          //setState(() { // Reset following vars to default value
            //resetVars(c_options: true, c_countAfterLongPress: true, c_selectedCount: true);
          //});
        //}
      },
      onLongPress:(){
        setState(() {
          if(countAfterLongPress){
            music[index].isSelected = true;
            options = true;
            countAfterLongPress = false;
            getSelectedCount(index);
          }else{}
        });
      },
      // Actuall UI
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        color: music[index].isSelected ? Colors.blue[100]:Theme.of(context).accentColor,
        child: ListTile(
          title: Text(music[index].data.values['Type']), 
          subtitle: Text(music[index].data.values['Songname']), 
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // assign this variable your Future
    myFuture = populatedata();
  }

  @override
  Widget build(BuildContext context){
    print('FAILED WIDGET BEING CREATED');
    return Scaffold(
      appBar: getAppbar(options),
      body: FutureBuilder(builder: (context, snapshot){
        return ListView.builder(itemBuilder: _getListItemTile, itemCount: music.length,);
      },
      future: myFuture,
      ),
    );
  } 
}


//     return AspectRatio(
//       aspectRatio: 5/4,
//       child: Container(
//         child: SingleChildScrollView(
//           child: Column(
            
//           ),
//         ),
//       ),
//     );