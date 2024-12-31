import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:note_app/service/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  final Function(bool) onThemeChanged;
  
  // const Home({super.key});
  Home({super.key,required this.onThemeChanged});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isDarkMode=false;
  Future<void>_loadThemePreferences() async{
    SharedPreferences pref =await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode=pref.getBool("isDarkMode")?? false;
    });
  }

void _toggleTheme(bool value){

  setState(() {
    _isDarkMode =value;
    widget.onThemeChanged(_isDarkMode);

  });
}


  List<Map<String,dynamic>>_allNotes=[];
  bool _isLoadingNote=true;

  final TextEditingController _noteTitleController=TextEditingController();
  final TextEditingController _noteDescriptionController=TextEditingController();

  void _reloadNotes()async{
    final note=await QueryHelper.getAllNotes();
    setState(() {
      _allNotes=note;
      _isLoadingNote=false;

    });

  }

    Future<void> _addNote() async{
      await QueryHelper.createNote(_noteTitleController.text, _noteDescriptionController.text);
      _reloadNotes();
    }

Future<void> _updateNote(int id)async{
  await QueryHelper.updateNote(id, _noteTitleController.text, _noteDescriptionController.text);
  _reloadNotes();
}

void _deleteNote(int id)async{
  await QueryHelper.deleteNote(id);
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Note Has Been Deleted")) );
  _reloadNotes();
}


  @override
  void initState() {
    
    super.initState();

    _reloadNotes();
    _loadThemePreferences();
  }




  void _deleteAllNotes() async{
    final noteCount=await QueryHelper.getNoteCount();
    if(noteCount >0){
      await QueryHelper.deleteAllNotes();
      _reloadNotes();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("all notes have been deleted"),backgroundColor: _isDarkMode? Colors.grey[600]:Colors.purple) 
      );
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("no notes to delete")));
      
    }
  }




  void showBottomSheetContent(int? id)async{
    
    if(id !=null){
      final currentNote =_allNotes.firstWhere((element)=> element['id'] == id);
      _noteTitleController.text=currentNote['title'];
      _noteDescriptionController.text=currentNote['description'];
    }


    showModalBottomSheet(
      isScrollControlled: true,
      context: context, builder: (_)=> SafeArea(
        child: SingleChildScrollView(
          child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 15,left: 15,right: 15,bottom:MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _noteTitleController,
                    decoration: const InputDecoration(
                      border:OutlineInputBorder(),
          
                      hintText: "note title",
                    ),
                  ),
                  const SizedBox(height:5.0),
                  TextField(
                    controller: _noteDescriptionController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Description",
          
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Center(
                    child: OutlinedButton(
                      onPressed: ()async{
                        if(id ==null){
                          await _addNote();

                        }
                        if(id !=null){

                          await _updateNote(id);
                        }
                        _noteTitleController.text ="";
                         _noteDescriptionController.text='';
                         Navigator.of(context).pop();

          
                      },
                       child: Text(
                        id ==null ? "Add Note":"Update Note"
                        
                        ,style: const TextStyle(
                        fontSize: 17,
                        fontWeight:FontWeight.w300,
          
                       ),),
                       ),
                  )
                ],
              ),
            )
          ],
              ),
        ),
      ));
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('notes',style:TextStyle(fontFamily: 'IndieFlower',fontWeight:FontWeight.bold),),
      actions: [
        IconButton(onPressed: (){
            _deleteAllNotes();


        }, icon: Icon(Icons.delete_forever)),
        IconButton(onPressed: (){
          _appExit();

        }, icon: const Icon(Icons.exit_to_app)),

        Transform.scale(
          scale: 0.9 ,
          child: Switch(value: _isDarkMode,
           onChanged: (value){
            _toggleTheme(value);
           }),
        )










      ],
      ),
      body:SafeArea(child: _isLoadingNote ?
      Center(child: CircularProgressIndicator(),):
      ListView.builder(itemCount: _allNotes.length,
      itemBuilder: (context, index) => Card(
        margin: EdgeInsets.all(16),
        child: ListTile(
          title:Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Padding(padding: EdgeInsets.symmetric(vertical: 5),
              child:Text(_allNotes[index]['title'],style:TextStyle(
                fontSize: 24,
                fontFamily: 'IndieFlower',
                fontWeight: FontWeight.bold,
              )),
              
              )),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(onPressed: (){

                    showBottomSheetContent(_allNotes[index]['id']);
                  }, icon: Icon(Icons.edit)),
                  IconButton(onPressed: (){
                    _deleteNote(_allNotes[index]['id'] );
                  },icon: const Icon(Icons.delete),)

                ],
              ),
            ],
          ),
          subtitle: Text(_allNotes[index]['description'],style: TextStyle(
            fontFamily: 'IndieFlower',
            fontSize: 22,

          ),),
        ),
      ),)
      
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        showBottomSheetContent(null);

      },
      child: const Icon(Icons.add),),
    );
  }
  
  void _appExit() {
     showDialog(context: context, 
     builder: (BuildContext context){
      return AlertDialog(
        title: const Text(' Exxit App?'),
        content: const  Text ("are you sure u want to exit the app"),
        actions:[
          OutlinedButton(onPressed: (){
            Navigator.of(context).pop();

          }, child: const Text  ('Cancel')),
          OutlinedButton(onPressed: (){
            SystemNavigator.pop(); 
          

          }, child: const Text  ('Exit')),
        ]
      );
     });

  }
}