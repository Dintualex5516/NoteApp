import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqflite.dart';



class QueryHelper{
  static Future<void> createTable(sql.Database database)async{
    await database.execute("""

CREATE TABLE note(
id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
title TEXT,

description TEXT,
time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP

)

""");
  }
  // END TABLE CREATION
  // DB

  static Future<sql.Database> db()async{
    return sql.openDatabase("note_database.db",version:1,
    onCreate:(sql.Database database,int version)async{
      await createTable(database);
    });
    
  }
// new note

static Future<int> createNote(String title,String? description)async{
  final db=await QueryHelper.db();
  final dataNote={'title':title,'description':description};
  final id = await db.insert('note',dataNote,conflictAlgorithm: sql.ConflictAlgorithm.replace);
  return id;
}

// allnote

static Future<List<Map<String,dynamic>>> getAllNotes()async{
  final db=await QueryHelper.db();
  return db.query('note',orderBy:'id');

}

// singlenote

static Future<List<Map<String,dynamic>>> getNote(int id )async{
  final db=await QueryHelper.db();
  return db.query('note',where:"id=?",whereArgs: [id],limit: 1);
}

// update

static Future<int> updateNote( int id ,
  String title,
  String? description)async{
    final db=await QueryHelper.db();
    final dataNote={
      'title':title,
      'description':description,
      'time':DateTime.now().toString()
    };
    final result= await db.update('note',dataNote,where: "id =?", whereArgs: [id]);
    return result ;
  }
  // delete

  static Future<void>deleteNote(int id)async{
    final db=await QueryHelper.db();
    try{
      await db.delete('note',where:"id=?", whereArgs: [id]);


    }catch(e){
      e.toString(); 
    }
  }
 
//  delete all

static Future<void> deleteAllNotes()async{
  final db=await QueryHelper.db();
  try{
    await db.delete('note');

  }catch(e){
    print(e.toString());

  }
}

// count

static Future<int>getNoteCount()async{
  final db=await QueryHelper.db();
  try{
    final count=Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM note'),

    );
    return count?? 0;

  }catch(e){
    print(e.toString());
    return 0;
  }
}



}