import 'package:flutter/material.dart';
import 'package:Myapp/API.dart' as MyApi;

/// Logic model for DownloadPageState
class ListItem<T>{
  bool isSelected = false;// Selection property to highlight or not
  T data;
  ListItem(this.data);
}

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

///Valid id's
///
/// Singles or Playlists
class DownloadPage extends StatefulWidget{
  /// AppBar title
  String title = '';
  /// Single or Playlist
  String id = '';

  DownloadPage({Key key, this.title, this.id}) : super(key:key);

  @override
  DownloadPageState createState() => DownloadPageState();
}

class DownloadPageState extends State<DownloadPage> {
  bool options = false; // Display options or not
  bool countAfterLongPress = true; // increment or decrement [selectedCount] after a longtap
  int selectedCount = 0; // How many ListView items are selected
  List music = []; // Undownloaded music contains 'instance of...'
  List selectedMusic = []; // Indexes of selected items
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
    Map file = await MyApi.readJson(MyApi.frontendFile);
    for(List item in selectedMusic){
      file[widget.id].remove(item[0]);
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
    Map file = await MyApi.readJson(MyApi.frontendFile);
    String specific;
    Function func;

    // Figure out which 'specific' to place into in frontendFile
    if(widget.id == MyApi.idSingles){
      // singles
      specific = MyApi.idSpecificSingles;
      func = MyApi.downloadSingle;
    }else{
      // playlists
      specific = MyApi.idSpecificPlaylists;
      func = MyApi.downloadPlaylist;
    }

    // Start placing
    for(List item in selectedMusic){
      file[specific][item[0]] = item[1]; // Add to specific
      file[widget.id].remove(item[0]); // Remove from 'Singles' or 'Playlists'
    }
    await MyApi.writeJson(MyApi.frontendFile, file);
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
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          backgroundColor: Colors.transparent,
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
    Map jsonObjects = await MyApi.readJson(MyApi.frontendFile);
    music.clear();
    for(MapEntry item in jsonObjects[widget.id].entries){
      music.add(ListItem<List>([item.key,item.value]));
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
          title: Text(music[index].data[1]), // Name 
          subtitle: Text(music[index].data[0]), // Link
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
    return Scaffold(
      appBar: getAppbar(options),
      body: FutureBuilder(builder: (context, snapshot){
        return ListView.builder(itemBuilder: _getListItemTile,itemCount: music.length,);
      },
      future: myFuture,
      ),

      floatingActionButton: FloatingActionButton( // Download all 
        onPressed:() async{
          if(widget.id == 'Singles'){
            print('Downloading singles');
            MyApi.downloadSingle();
            setState(() {
              resetVars(all: true);
            });
          }
          else{ //Playlists
            print('Downloading playlists');
            MyApi.downloadPlaylist();
            setState(() {
              resetVars(all: true);
            });
          }
        },
        backgroundColor: Colors.blue,
        tooltip: 'Download All',
        child: Icon(Icons.file_download),// TODO: Might need to change icon
        ),
    );
  }
}