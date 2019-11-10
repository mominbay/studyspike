import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'task.dart';
import 'package:intl/intl.dart';

class DBProvider {
  String tblTasks = "Tasks";
  String colId = "id";
  String colName = "name";
  String colDesc = "desc";
  String colType = "type";
  String colDate = "date";
  String colStart = "start";
  String colEnd = "end";
  String colDone = "done";
  String colRating = "rating";

  static final DBProvider _dbProvider = DBProvider._internal();

  DBProvider._internal();

  factory DBProvider() {
    return _dbProvider;
  }

  static Database _database;

  Future<Database> get database async {
    if (_database != null){
      return _database;
    }
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "spike.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  void _createDB(Database db, int version) async {
    await db.execute(
        "Create table $tblTasks($colId integer primary key, $colName text, " +
        "$colDesc text, $colType text, $colDate text, $colStart text, " +
        "$colEnd text, $colDone int, $colRating int)");
  }


  Future<int> insert(Task task) async {
    Database db = await this.database;
    var result = await db.insert(tblTasks, task.toMap());
    return result;
  }

  Future<int> update(Task task) async {
    Database db = await this.database;
    var result = await db.update(tblTasks, task.toMap(),
        where: "$colId =?", whereArgs: [task.id]);
    return result;
  }

  Future<Task> getById(int id) async {
    Database db = await this.database;
    List<Map> result = await db.rawQuery("Select * from $tblTasks where $colId = $id");
    Task task = Task.fromObject(result[0]);
    return task;
  }

  Future<int> delete(int id) async {
    Database db = await this.database;
    var result = await db.rawDelete("Delete from $tblTasks where $colId = $id");
    return result;
  }

  Future<List<Task>> getAllTasks() async{
    Database db = await this.database;
    List<Map> result = await db.rawQuery("Select * from $tblTasks");
    List<Task> tasks = new List<Task>();
    for(int i = 0; i < result.length; i++){
      tasks.add(Task.fromObject(result[i]));
    }
    return tasks;
  }

  Future<List<Task>> getByDate(DateTime date) async{
    Database db = await this.database;
    DateFormat format = new DateFormat("yyyy-MM-dd");
    String queryDate = format.format(date);
    List<Map> result = await db.rawQuery("Select * from $tblTasks where $colDate = \'$queryDate\'");
    List<Task> tasks = new List<Task>();
    for(int i = 0; i < result.length; i++){
      tasks.add(Task.fromObject(result[i]));
    }
    Task.sortByTime(tasks);
    return tasks;
  }

}