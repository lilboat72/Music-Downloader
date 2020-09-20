import 'dart:io';
import 'package:flutter/material.dart';
import 'API.dart' as MyApi;
import 'main.dart' show SettingsPage;
import 'package:path_provider/path_provider.dart' as Storage;

class FeedbackPage extends StatefulWidget{
  @override
  FeedbackPageState createState() => FeedbackPageState();
}

class FeedbackPageState extends State<FeedbackPage>{
  String dropdownValue;
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('Help improve the app'),),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
        child: Container(
          height: 1000,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[

                // Choose feedback type
                Align(
                  alignment: Alignment.topLeft,
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    hint: Text('Feedback type'),
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 15,
                    elevation: 16,
                    style: TextStyle(color: Colors.blue),
                    onChanged: (String newvalue){
                      setState(() {
                        dropdownValue = newvalue;
                      });
                    },
                    items: <String>['Suggestion','Problem'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),

                SizedBox(height: 20,),
        
                // Input feedback
                TextFormField(
                  maxLines: 13,
                  maxLength: 700,
                  textAlign: TextAlign.left,
                  initialValue: 'Please keep suggestions and problems separate.',
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    labelText: "Feedback here",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)
                      ),
                  ),
                  validator: (val){
                    if(val.length < 20){
                      return "Feeback too short";
                    }else{
                      return null;
                    }
                  },
                ),
                SizedBox(height: 120,),

                // Butons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // Cancel
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel')),
                    ),

                    // Submit
                    Align(
                      alignment: Alignment.bottomRight,
                      child: FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Submit')),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsPageState extends State<SettingsPage>{
  bool _darkMode = MyApi.prefs.getBool('${MyApi.Setting.Dark_Mode}');
  bool _autoDownload = MyApi.prefs.getBool('${MyApi.Setting.Auto_Downloads}');
  String _internalExternal = MyApi.prefs.getString('${MyApi.Setting.Internal_External}');

  // options
  darkMode(){
    return SwitchListTile(
      value: _darkMode,
      title: Text('Dark Mode'),
      activeColor: Colors.blue[700],
      onChanged: (value){
        MyApi.prefs.setBool('${MyApi.Setting.Dark_Mode}', value);
        setState(() {
          _darkMode = value;
        });
      },
    );
  }
  autoDownload(){
    return SwitchListTile(
      value: _autoDownload,
      title: Text('Auto downloads'),
      activeColor: Colors.blue[700],
      onChanged: (value){
        MyApi.prefs.setBool('${MyApi.Setting.Auto_Downloads}', value);
        setState(() {
          _autoDownload = value;
        });
      },
    );
  }

  storageLoction(){
    return ListTile(
      title: Text('Storage Location'),
      subtitle: Text(_internalExternal), //TODO: This should point to where the 'Audios' folder is stored not the app
      trailing: Icon(Icons.keyboard_arrow_right),
      onTap: () async{
        switch (await showDialog(
          context: context,
          builder: (BuildContext context){
            return SimpleDialog(
              title: Text('Choose Storage Location'),
              children: <Widget>[
                SimpleDialogOption(
                  child: Text('Internal'),
                  onPressed: (){ Navigator.pop(context, 'Internal'); },
                ),
                SimpleDialogOption(
                  child: Text('External'),
                  onPressed: (){ Navigator.pop(context, 'External'); },
                ),
              ],
            );
          }
        )) {
            case 'Internal':
              Storage.getExternalStorageDirectory().then((Directory directory){
                MyApi.prefs.setString('${MyApi.Setting.Storage_Location}', directory.path);
                MyApi.prefs.setString('${MyApi.Setting.Internal_External}', "Internal");
                setState(() {
                  _internalExternal = 'Internal';
                });
              });
            break;
            case 'External': //TODO: Need to confirm that SD card storage exists
              Storage.getExternalStorageDirectory().then((Directory directory){ //TODO: This isn't SD card storage
                MyApi.prefs.setString('${MyApi.Setting.Internal_External}', directory.path);
                MyApi.prefs.setString('${MyApi.Setting.Internal_External}', "External");
                print(directory);
                setState(() {
                  _internalExternal = 'External';
                });
              });
            break;
          } // cases here
      },
    );
  }

  version(){
    return ListTile(
      title: Text('Version 1.0.0'), //TODO: Need to do sum about this hardcode
    );
  }
  tutorial(){
    return ListTile(
      title: Text('Tutorial'),
      subtitle: Text('Get started on how the app works :)'),
      onTap: (){},
      trailing: Icon(Icons.keyboard_arrow_right),
    );
  }
  submitFeedback(){
    return ListTile(
      title: Text('Submit feedback'),
      subtitle: Text('Got something to say? Tell me about it'),
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackPage()));
      },
      trailing: Icon(Icons.keyboard_arrow_right),
    );
  }
  aboutDeveloper(){
    return ListTile(
      title: Text('About developer'),
      subtitle: Text('Link to website'),
      onTap: (){},
      trailing: Icon(Icons.keyboard_arrow_right),
    );
  }

  /// Recover lost music
  ///
  /// For this to work, music will need to be on local device
  recoveryMode(){
    return ListTile(
      title: Text('Recovery mode'),
      subtitle: Text('Recover lost music'),
      onTap: (){},
      trailing: Icon(Icons.keyboard_arrow_right),
    );
  }
  @override
  Widget build(BuildContext context){
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          expandedHeight: 50,
          flexibleSpace: FlexibleSpaceBar(
            title: Text('Settings'),
            centerTitle: true,
          ),
        ),
        SliverFixedExtentList(
          itemExtent: 75, //75
          delegate: SliverChildListDelegate([
            version(),
            darkMode(),
            autoDownload(),
            storageLoction(),
            tutorial(),
            submitFeedback(),
            aboutDeveloper(),
            recoveryMode()
          ])
        ),
      ],
    );
  }
}
