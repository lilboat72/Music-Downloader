import 'package:flutter/material.dart';
import 'package:Myapp/main.dart';
import 'music_page_utilities.dart';
import 'package:Myapp/API.dart' show idSingles, idPlaylists;

class MusicPageState extends State<MusicPage>{
  @override 
  Widget build(BuildContext context){
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: AppBar(
            //backgroundColor: Colors.white,
            title: Text(''),
            bottom: TabBar(
              //indicatorColor: Colors.red,
              //labelColor: Colors.red,
              //unselectedLabelColor: Colors.black,
              tabs: <Widget>[Tab(text: 'Custom',),Tab(text: 'Albums',),Tab(text: 'Singles',),],
            ),
          ),
        ),
        body: TabBarView(
          children: <Widget>[AlbumCreator(),DownloadPage(title: 'Albums',id: idPlaylists,),DownloadPage(title: 'Singles',id: idSingles,)],// subpages 1, 2 and 3
        ),
      ),
    );
  }
}

///Sub-Page 1
///
///Display playlists(albums) from youtube in album queue,
///and creating albums
class AlbumCreator extends StatefulWidget{
  @override
  AlbumCreatorState createState() => AlbumCreatorState();
}

class AlbumCreatorState extends State<AlbumCreator>{
  @override
  Widget build(BuildContext context){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[

              // Album name
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue[900])
                ),
                child: TextField(
                  showCursor: true,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(hintText: 'album name',focusedBorder: InputBorder.none),
                ),
              ),

              SizedBox(height: 5,),

              // TODO:add 'image' input button
              Container(
                width: double.infinity,
                height: 340,
                color: Colors.grey,
              ),

              SizedBox(height: 3,),

              // add music button from singles music
              Container(
                width: double.infinity,
                height: 57,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue[900])
                ),
                child: FlatButton(
                  onPressed: (){}, // display pop-up with options
                  child: Text('add music',),
                ),
              ),

              //SizedBox(height: 30,),

              // create button
              Container(
                width: double.infinity,
                child: RaisedButton(
                onPressed: (){},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),),
                color: Colors.blue,
                child: Text('CREATE',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                ),
              ),
          ],),
        ),
      ),
    );
  }
}
