import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHandler {
  static const _databaseName     = "BlueLog.db";
  static const _databaseVersion  = 1;

  static const _tblDetectValue  = '_logTableDetectValue';
  static const _tblRealValue    = '_logTableRealValue';
  static const _tblBatteryValue = '_logTableBatteryValue';
  static const _tblDeviceConnection = '_logTableDeviceConnection';
  
  static const id = 'id';
  static const apiResponse = 'api_response';
  static const deviceResponse = 'api_response';

  static const devId1 = 'dev_id1';
  static const devNo1 = 'dev_no1';
  static const failure1 = 'failure1';
  static const status1 = 'status1';
  static const failmessage1 = 'fail_message1';
  static const faildatetime1 = 'fail_datetime1';
  static const datetime1 = 'datetime1';
  static const useStatus1 = 'use_status1';
  static const detectValue1 = 'detect_value1';
  static const realValue1 = 'real_value1';
  static const batteryValue1 = 'battery_value1';
  static const eventUUID1 = 'event_uuid1';
  static const devMainUUID1 = 'dev_main_UUID1';
  static const dev1Pressure = 'dev1_Pressure';
  static const dev1Temperature = 'dev1_Temperature';

  static const devId2 = 'dev_id2';
  static const devNo2 = 'dev_no2';
  static const failure2 = 'failure2';
  static const status2 = 'status2';
  static const failmessage2 = 'fail_message2';
  static const faildatetime2 = 'fail_datetime2';
  static const datetime2 = 'datetime2';
  static const useStatus2 = 'use_status2';
  static const detectValue2 = 'detect_value2';
  static const realValue2 = 'real_value2';
  static const batteryValue2 = 'battery_value2';
  static const eventUUID2 = 'event_uuid2';
  static const devMainUUID2 = 'dev_main_UUID2';
  static const dev2Pressure = 'dev2_Pressure';
  static const dev2Temperature = 'dev2_Temperature';

  static const devName = 'devName';
  static const connectionStatus = 'connectionStatus';
  static const dateTime = 'dateTime';

  // make this a singleton class

  DatabaseHandler._privateConstructor();
  static final DatabaseHandler instance = DatabaseHandler._privateConstructor();
  DateTime currentDateTime = DateTime.now();
  var count = 0;

  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await initializeDB();
    return _database;
  }

  //Initialize database
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, _databaseName),
      onCreate: _onCreate,
      version: _databaseVersion,
    );
  }

  // Create db initially all 4 db Detect/Real/Battery/Device Connection
  Future _onCreate(Database db, int version) async {
    //Detect Value
    await db.execute('''
      CREATE TABLE $_tblDetectValue(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dev_id1 TEXT,
        dev_no1 TEXT,
        failure1 TEXT,
        status1 TEXT,
        fail_message1 TEXT,
        fail_dateTime1 TEXT,
        datetime1 TEXT,
        detect_value1 TEXT,
        use_status1 TEXT,
        event_uuid1 TEXT,
        dev_main_UUID1 TEXT,
        dev1_Pressure TEXT,
        dev1_Temperature TEXT,
        dev_id2 TEXT,
        dev_no2 TEXT,
        failure2 TEXT,
        status2 TEXT,
        fail_message2 TEXT,
        fail_dateTime2 TEXT,
        datetime2 TEXT,
        detect_value2 TEXT,
        use_status2 TEXT,
        event_uuid2 TEXT,
        dev_main_UUID2 TEXT,
        dev2_Pressure TEXT,
        dev2_Temperature TEXT,
        api_response TEXT,
        api_response_datetime TEXT
      )
    ''');
    //Real Value
    await db.execute('''
      CREATE TABLE $_tblRealValue(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dev_id1 TEXT,
        dev_no1 TEXT,
        failure1 TEXT,
        status1 TEXT,
        fail_message1 TEXT,
        fail_dateTime1 TEXT,
        datetime1 TEXT,
        real_value1 TEXT,
        use_status1 TEXT,
        event_uuid1 TEXT,
        dev_main_UUID1 TEXT,
        dev_id2 TEXT,
        dev_no2 TEXT,
        failure2 TEXT,
        status2 TEXT,
        fail_message2 TEXT,
        fail_dateTime2 TEXT,
        datetime2 TEXT,
        real_value2 TEXT,
        use_status2 TEXT,
        event_uuid2 TEXT,
        dev_main_UUID2 TEXT
      )
    ''');
    //Battery Level
    await db.execute('''
      CREATE TABLE $_tblBatteryValue(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dev_id1 TEXT,
        dev_no1 TEXT,
        failure1 TEXT,
        status1 TEXT,
        fail_message1 TEXT,
        fail_dateTime1 TEXT,
        datetime1 TEXT,
        battery_value1 TEXT,
        use_status1 TEXT,
        event_uuid1 TEXT,
        dev_main_UUID1 TEXT,
        dev_id2 TEXT,
        dev_no2 TEXT,
        failure2 TEXT,
        status2 TEXT,
        fail_message2 TEXT,
        fail_dateTime2 TEXT,
        datetime2 TEXT,
        battery_value2 TEXT,
        use_status2 TEXT,
        event_uuid2 TEXT,
        dev_main_UUID2 TEXT
      )
    ''');
    //Device Connection Level
    await db.execute('''
      CREATE TABLE $_tblDeviceConnection(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        devName TEXT,
        connectionStatus TEXT,
        dateTime TEXT
      )
    ''');
  }

  //Insert Log to Local Database / sqflite
  Future<int> insertLogToLocal(Map<String, dynamic> row,tableName) async {
    Database? db = await instance.database;
    //Added necessary data
    // row[DatabaseHandler.createddatetime] = now;
    var result = await db!.insert(tableName, row);
    if (kDebugMode) {
      print(result);
    }
    return result;
  }

  //The data present in the _tblLogTable is returned as a List of Map, where each
  // row is of type map
  //Get Detect Value logs
  Future<List<Map<String, dynamic>>?> getAllLogs(tableName) async {
    Database? db = await instance.database;
    // var tableName ='';
    String query = '''
      SELECT * FROM $_tblDetectValue
    ''';
    var result = await db?.rawQuery(query);
    return result;
  }

  //Get Real Value logs
  Future<List<Map<String, dynamic>>?> getAllRealLogs() async {
    Database? db = await instance.database;
    // var tableName ='';
    String query = '''
      SELECT * FROM $_tblRealValue
    ''';
    var result = await db?.rawQuery(query);
    return result;
  }

  //Get Battery Value logs
  Future<List<Map<String, dynamic>>?> getAllBatteryLogs() async {
    Database? db = await instance.database;
    // var tableName ='';
    String query = '''
      SELECT * FROM $_tblBatteryValue
    ''';
    var result = await db?.rawQuery(query);
    return result;
  }

  //Get Device Connection Value logs
  Future<List<Map<String, dynamic>>?> getAllDevConnectionLogs() async {
    Database? db = await instance.database;
    // var tableName ='';
    String query = '''
      SELECT * FROM $_tblDeviceConnection
    ''';
    var result = await db?.rawQuery(query);
    return result;
  }

  //Delete All Detect Value logs
  delete(tableName) async {
    Database? db = await instance.database;
    String query = '''
      DELETE FROM $_tblDetectValue
    ''';
    var result = await db?.rawQuery(query);
    return result;
  }

  //Delete All Battery Value logs
  deleteBatteryLog(tableName) async {
    Database? db = await instance.database;
    String query = '''
      DELETE FROM $_tblBatteryValue
    ''';
    var result = await db?.rawQuery(query);
    return result;
  }

  //Delete All Real Value logs
  deleteRealLog(tableName) async {
    Database? db = await instance.database;
    String query = '''
      DELETE FROM $_tblRealValue
    ''';
    var result = await db?.rawQuery(query);
    return result;
  }

  //Delete All Device Value logs
  deleteDeviceConnectionLog() async {
    Database? db = await instance.database;
    String query = '''
      DELETE FROM $_tblDeviceConnection
    ''';
    var result = await db?.rawQuery(query);
    return result;
  }

  //Update Detect Value Log as per Api response for api_response date time  
  updateLog(apiRespnse, id,tableName) async {
    Database? db = await instance.database;
    count = (await db?.rawUpdate(
      'UPDATE  $_tblDetectValue SET api_response = ?, api_response_datetime = ? WHERE id = ?',
      [apiRespnse, DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now().toUtc()) ,id]))!;
    if (kDebugMode) {
      print('updated: $count');
    }
    return count;
  }
}
