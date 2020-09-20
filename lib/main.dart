// For info on the behavior on platforms read '${PlatformName}Docs.txt'
// As it currently stands this whole app is designed for android
import 'package:flutter/material.dart';
import 'HomePage/Gui_HomePage.dart';
import 'MusicPage/Gui_MusicPage.dart';
import 'Gui_SettingsPage.dart';
import 'permissions.dart';
import 'API.dart' as MyApi;

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await MyApi.config();
  MyApi.queue();
  runApp(MyApp());
}

/// This is the app in it's ground form.
/// Most [settingsTab] configurations will take effect here,
/// Thus the need for a StatefulWidget
/// 
/// E.G dark mode
class MyApp extends StatefulWidget{
  @override
  _BaseAppState createState() => _BaseAppState();
}

class MyTheme{
  Color primaryColor = Colors.red[900];
  Color _blackOrWhite;

  /// Brightness and textColor cannot be the same.
  /// 
  /// [blackOrWhite] must be same as brightness
  getTheme({Brightness brightness,Color blackOrWhite}){
    return ThemeData(
        brightness: brightness,
        primaryColor: primaryColor,
        accentColor: blackOrWhite,
      );
    }
  }

class _BaseAppState extends State<MyApp>{
  static int _currentIndex = 0; // for navigation in NavigationBar
  List<Widget> tabs = [
    HomePage(),
    MusicPage(),
    SettingsPage(),
  ];

  @override
  void initState(){
    super.initState();
    AskPermission().askAll().whenComplete((){ setState(() {}); });
  }

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: MyTheme().getTheme(brightness: Brightness.dark, blackOrWhite: Colors.black45),
      title: 'Music Downloader',
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(child: IndexedStack(index: _currentIndex, children: tabs)),
        //tabs[_currentIndex] 
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.shifting,
          items: [
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.home, color: Colors.red,),
              icon: Icon(Icons.home, color: Colors.grey[400],),
              title: Text('Home'),
              //backgroundColor: Colors.white,  
            ),

            BottomNavigationBarItem(
              activeIcon: Icon(Icons.music_note, color: Colors.red,),
              icon: Icon(Icons.music_note, color: Colors.grey[400],),
              title: Text('Music'),
              //backgroundColor: Colors.white,
            ),

            BottomNavigationBarItem(
              activeIcon: Icon(Icons.settings, color: Colors.red,),
              icon: Icon(Icons.settings, color: Colors.grey[400],),
              title: Text('Settings'),
              //backgroundColor: Colors.white,
            ),
          ],
          onTap: (index){// Transitioning between tabs
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}


/// Big red scrapping button and Statistics
class HomePage extends StatefulWidget{
  @override
  HomePageState createState() => HomePageState();
}

/// Contains 3 subpages. Custom |Album |Singles
/// 
/// Albums creator, create custom albums
/// 
/// Album - Download albums
/// 
/// Singles - Download Singles
class MusicPage extends StatefulWidget{
  @override
  MusicPageState createState() => MusicPageState();
}

/// App configurations
class SettingsPage extends StatefulWidget{
  @override
  SettingsPageState createState() => SettingsPageState();
}
