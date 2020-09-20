import 'package:flutter/material.dart';
import 'package:Myapp/main.dart' show HomePage;
import 'HomePage_utilities.dart';

class HomePageState extends State<HomePage>{

  ///[type] can either be 'downloading' or 'failed', each with their own distict GUI
  createStatistic(String heading, {String type}){
    return Expanded(
      flex: 1,
      child: GestureDetector(
        onLongPress: (){
          setState(() {
            if(type == 'downloading'){
              print('Gesture detected');
              Stack(
                children: <Widget>[
                  Center(child: CurrentlyDownloading()),
                ],
              );
            }
            if(type == 'failed'){
              print('Gesture detected');
              Stack(
                children: <Widget>[
                  Center(child: Failed()),
                ],
              );
            }
          });
        },
        child: Container(
          child: Column(
            children: <Widget>[
              Text(heading,textAlign: TextAlign.center),
              Text('0') //Real values placed here
            ],),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.red,
            boxShadow: [
              BoxShadow(
                blurRadius: 3.0,
                spreadRadius: 0.0
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[

          //Big red Url scraper that takes us to YouTube
          Expanded(
            flex: 4, 
            child: RaisedButton(
              child: Text('Youtube',style: TextStyle(color: Colors.white),),
              onPressed: (){},//TODO: Open youtube, if not installed open GooglePlay store
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.red[900],
              ),
            ),

          SizedBox(child: Divider(thickness: 2, color: Colors.blue,)),

          // 'Stats' heading
          Row(
            children: <Widget>[
                Icon(Icons.info, size: 30,),
                Text('Stats:', style: TextStyle(fontSize: 20),)
            ],
          ),

          // Stats
          createStatistic('Currently downloading', type: 'downloading'),
          SizedBox(height: 10,),
          createStatistic('Total downloaded music'),
          SizedBox(height: 10,),
          createStatistic('Total created albums'),
          SizedBox(height: 10,),
          createStatistic('Failed downloads', type: 'failed')
        ],
      ),
    );
  }
}