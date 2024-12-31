import 'package:flutter/material.dart';
import 'package:note_app/ui/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main(){
  runApp(const NoteApp());

}

class NoteApp extends StatefulWidget {

  





  const NoteApp({super.key});

  @override
  State<NoteApp> createState() => _NoteAppState();
}

class _NoteAppState extends State<NoteApp> {

  ThemeMode _themeMode=ThemeMode.light;

  Future<void>_loadThemePreferences()async{
    SharedPreferences pref =await  SharedPreferences.getInstance();
    bool isDarkMode=pref.getBool('isDarkMode')??  false;
    setState(() {
      _themeMode=isDarkMode ? ThemeMode.dark :ThemeMode.light;

    });
  }

  @override
  void initState(){

    super.initState();
    _loadThemePreferences();
  }



  Future<void>_toggleTheme(bool isDarkMode) async{
    SharedPreferences pref=await SharedPreferences.getInstance();
    setState(() {
      _themeMode=isDarkMode? ThemeMode.dark :ThemeMode.light;
      pref.setBool('isDarkMode',isDarkMode );
    });
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title:"NoteApp",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode,
      home: Home(onThemeChanged:_toggleTheme),
    );
  }
} 