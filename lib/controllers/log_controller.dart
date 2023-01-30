import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:blue/controllers/audio_controller.dart';
import 'package:blue/controllers/connectivity_controller.dart';
import 'package:blue/helper/current_time.dart';
import 'package:blue/helper/height_alert_calculation.dart';
import 'package:blue/helper/height_calculation.dart';
import 'package:convert/convert.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blue/controllers/device1_controller.dart';
import 'package:blue/controllers/device2_controller.dart';
import 'package:blue/controllers/home_controller.dart';
import 'package:blue/controllers/toast_message_controller.dart';
import 'package:blue/helper/db_connection.dart';
import 'package:blue/services/apiservices.dart';
import 'package:blue/services/firestore_services.dart';
import 'package:collection/collection.dart';

class LogController extends GetxController{
  final ConnectivityController connectionCon =  Get.put(ConnectivityController());
  // LOCAL DATABASE HELPER //
  final dbHelper = DatabaseHandler.instance;
  String tableName = '';

  // API SERVICE CLASS //
  final _apiendpoint = ApiEndpointRepo();

  //API LOG CONTROLLER //
  int success = 0; //insertLogsToApi
  List logData = [].obs; //getAllLogs//getAllRealValueLogs//getAllBatteryValueLogs//getAllDeviceStatusValueLogs//
  
  // RUNTIME STORAGE //

  // DETECT //
  var useStatusDetectDev1 = '1';
  var useStatusDetectDev2 = '1';
  // REAL //
  var useStatusRealDev1 = '1';
  var useStatusRealDev2 = '1';
  // BATTERY //
  var useStatusBatteryDev1 = '1';
  var useStatusBatteryDev2 = '1';
  // PRESSURE //
  List pressureValues = []; // PRESSURE VALUES ARRAY FOR AVERAGE CALCULATION //
  
  // UUID //
  var devMainUUID1 = '';
  var devMainUUID2 = '';

  //Play Sound Timer
  int alertCounter = 0;
  Timer? alertTimer;
  dynamic currentDev1UseStatus;
  dynamic currentDev2UseStatus;
  bool isPlayingAlert = false;
  bool playCondition = false;
  HomeController homeCon = Get.find();
  ToastMessageController toastMsgCon = Get.find();

  insertLogLoaclAndApi(devNo,devName,useStatus,eventUUID,devMainUUID) async {
    if(connectionCon.online.value == true){
      if (kDebugMode) {
        print('insertLogLoaclAndApi Function Reached');
        print('Device No =============> '+devNo);
        print('Device Name ==============> '+devName);
        print('Use Status =============> '+useStatus);
        print('Event UUID =============> '+eventUUID);
        print('Device Main UUID =============> '+devMainUUID);
      }
      Map<String, dynamic> row = {};
      String device1Name =  homeCon.deviceNameLeft.trim();
      String device2Name =  homeCon.deviceNameRight.trim();
      final prefs = await SharedPreferences.getInstance();
      String? dev1ServiceUUID = homeCon.dev1ServiceUUID.text.trim();
      String? dev1DetectValueUUID = homeCon.dev1DetectValueUUID.text.trim();
      String? dev1RealValueUUID = homeCon.dev1RealValueUUID.text.trim();
      String? dev1BatteryValueUUID = homeCon.dev1BatteryValueUUID.text.trim();
      String? dev1PressureValueUUID = homeCon.dev1PressureValueUUID.text.trim();
      String? dev1TemperatureValueUUID = homeCon.dev1TemperatureValueUUID.text.trim();
      String? dev2ServiceUUID = homeCon.dev2ServiceUUID.text.trim();
      String? dev2DetectValueUUID = homeCon.dev2DetectValueUUID.text.trim();
      String? dev2RealValueUUID = homeCon.dev2RealValueUUID.text.trim();
      String? dev2BatteryValueUUID = homeCon.dev2BatteryValueUUID.text.trim();
      String? dev2PressureValueUUID = homeCon.dev2PressureValueUUID.text.trim();
      String? dev2TemperatureValueUUID = homeCon.dev2TemperatureValueUUID.text.trim();
      String? userid = prefs.getString('userid').toString()=="null"?homeCon.userid.text.trim():prefs.getString('userid').toString();
      String? dev1PressureValue = prefs.getString('dev1Pressure').toString()=="null"?'0':prefs.getString('dev1Pressure').toString();
      String? dev1TemperatureValue = prefs.getString('dev1Temperature').toString()=="null"?'0':prefs.getString('dev1Temperature').toString();
      String? dev2PressureValue = prefs.getString('dev2Pressure').toString()=="null"?'0':prefs.getString('dev2Pressure').toString();
      String? dev2TemperatureValue = prefs.getString('dev2Temperature').toString()=="null"?'0':prefs.getString('dev2Temperature').toString();
      String now = DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now().toUtc());

      //if eventUUID equal to Settings page device 1 Detect Value UUID (FB & Local)
      if(eventUUID==dev1DetectValueUUID && devMainUUID == dev1ServiceUUID && devNo == '1'){
        if (kDebugMode) {
          print('insertLogLoaclAndApi Function Reached to Dev1 Detect Value UUID');
          print('Device No =============> '+devNo);
          print('Device Name ==============> '+devName);
          print('Use Status =============> '+useStatus);
          print('Event UUID =============> '+eventUUID);
          print('Device Main UUID =============> '+devMainUUID);
        }
        row = {
          DatabaseHandler.devNo1: devNo,
          DatabaseHandler.devId1: device1Name,
          DatabaseHandler.datetime1: now,
          DatabaseHandler.useStatus1: useStatus,
          DatabaseHandler.eventUUID1: eventUUID,
          DatabaseHandler.devMainUUID1: devMainUUID,
          DatabaseHandler.dev1Pressure: format(dev1PressureValue), //pressure val dev 1
          DatabaseHandler.dev1Temperature : format(dev1TemperatureValue), //Temperature val dev1
          DatabaseHandler.devNo2: '2',
          DatabaseHandler.devId2: device2Name,
          DatabaseHandler.datetime2: now,
          DatabaseHandler.useStatus2: useStatusDetectDev2,
          DatabaseHandler.eventUUID2: eventUUID,
          DatabaseHandler.devMainUUID2: devMainUUID2,
          DatabaseHandler.dev2Pressure: format(dev2PressureValue), //pressure val dev 2
          DatabaseHandler.dev2Temperature : format(dev2TemperatureValue),//Temperature val dev2
        };
        tableName = '_logTableDetectValue';
        prefs.setString('useStatusDetectDev1',useStatus).toString();
        prefs.setString('devMainUUID1',devMainUUID).toString();
        useStatusDetectDev2 = prefs.getString('useStatusDetectDev2').toString()=="null"?'1':prefs.getString('useStatusDetectDev2').toString();
        devMainUUID2 = prefs.getString('devMainUUID2').toString();
        if(homeCon.isLeader==1){
          insertMasterWorkerLogsToFB(row,userid.trim(),eventUUID,dev1DetectValueUUID,dev2DetectValueUUID,devNo,useStatus);
        }
        else{
          insertWorkerStatustLogsToFB(row,userid.trim(),eventUUID,dev1DetectValueUUID,dev2DetectValueUUID,devNo,useStatus);
        }
        dbHelper.insertLogToLocal(row,tableName).then((values) {
          if (kDebugMode) {
            print('Local DB Insert dev1 dev1DetectValueUUID LOCAL Time/NEPAL Time====>' +DateTime.now().toString());
            print('Local DB Insert dev2 dev1DetectValueUUID JAPAN Time====>' +getCurrentTimeofJapan());
          }
        });
      }
      //if eventUUID equal to Settings page device 1 Real Value UUID (Local)
      else if(eventUUID==dev1RealValueUUID && devMainUUID == dev1ServiceUUID && devNo == '1'){
        if (kDebugMode) {
          if (kDebugMode) {
            print('insertLogLoaclAndApi Function Reached to Dev1 Real Value UUID');
            print('Device No =============> '+devNo);
            print('Device Name ==============> '+devName);
            print('Use Status =============> '+useStatus);
            print('Event UUID =============> '+eventUUID);
            print('Device Main UUID =============> '+devMainUUID);
          }
        }
        row = {
          DatabaseHandler.devNo1: devNo,
          DatabaseHandler.devId1: device1Name,
          DatabaseHandler.datetime1: now,
          DatabaseHandler.useStatus1: useStatus,
          DatabaseHandler.eventUUID1: eventUUID,
          DatabaseHandler.devMainUUID1: devMainUUID,

          DatabaseHandler.devNo2: '2',
          DatabaseHandler.devId2: device2Name,
          DatabaseHandler.datetime2: now,
          DatabaseHandler.useStatus2: 'null',
          DatabaseHandler.eventUUID2: eventUUID,
          DatabaseHandler.devMainUUID2: devMainUUID2,
        };
        tableName = '_logTableRealValue';
        prefs.setString('useStatusRealDev1',useStatus).toString();
        prefs.setString('devMainUUID1',devMainUUID).toString();
        useStatusRealDev2 = prefs.getString('useStatusRealDev2').toString();
        devMainUUID2 = prefs.getString('devMainUUID2').toString();
        dbHelper.insertLogToLocal(row,tableName).then((values) {
          if (kDebugMode) {
            print('Local DB Insert dev1 dev1RealValueUUID LOCAL Time/NEPAL Time====>' +DateTime.now().toString());
            print('Local DB Insert dev2 dev1RealValueUUID JAPAN Time====>' +getCurrentTimeofJapan());
          }
        });
      }
      //if eventUUID equal to Settings page device 1 Battery Value UUID (Local)
      else if(eventUUID==dev1BatteryValueUUID && devMainUUID == dev1ServiceUUID && devNo == '1'){
        if (kDebugMode) {
          print('insertLogLoaclAndApi Function Reached to Device1 Battery Value UUID');
          print('Device No =============> '+devNo);
          print('Device Name ==============> '+devName);
          print('Use Status =============> '+useStatus);
          print('Event UUID =============> '+eventUUID);
          print('Device Main UUID =============> '+devMainUUID);
        }
        row = {
          DatabaseHandler.devNo1: devNo,
          DatabaseHandler.devId1: device1Name,
          DatabaseHandler.datetime1: now,
          DatabaseHandler.useStatus1: useStatus,
          DatabaseHandler.eventUUID1: eventUUID,
          DatabaseHandler.devMainUUID1: devMainUUID,

          DatabaseHandler.devNo2: '2',
          DatabaseHandler.devId2: device2Name,
          DatabaseHandler.datetime2: now,
          DatabaseHandler.useStatus2: 'null',
          DatabaseHandler.eventUUID2: eventUUID,
          DatabaseHandler.devMainUUID2: devMainUUID2,
        };
        tableName = '_logTableBatteryValue';
        prefs.setString('useStatusBatteryDev1',useStatus).toString();
        prefs.setString('devMainUUID1',devMainUUID).toString();
        useStatusBatteryDev2 = prefs.getString('useStatusBatteryDev2').toString();
        devMainUUID2 = prefs.getString('devMainUUID2').toString();
        dbHelper.insertLogToLocal(row,tableName).then((values) {
          if (kDebugMode) {
            print('Local DB Insert dev1 dev1BatteryValueUUID LOCAL Time/NEPAL Time====>' +DateTime.now().toString());
            print('Local DB Insert dev2 dev1BatteryValueUUID JAPAN Time====>' +getCurrentTimeofJapan());
          }
        });
      }
      //if eventUUID equal to Settings page device 1 Pressure Value UUID save to detect value (Local)
      else if(eventUUID==dev1PressureValueUUID && devMainUUID == dev1ServiceUUID && devNo == '1'){
        if (kDebugMode) {
          print('insertLogLoaclAndApi Function Reached to Device1 Pressure Value UUID');
          print('Device No =============> '+devNo);
          print('Device Name ==============> '+devName);
          print('Use Status =============> '+useStatus);
          print('Event UUID =============> '+eventUUID);
          print('Device Main UUID =============> '+devMainUUID);
        }
        row = {
          DatabaseHandler.devNo1: devNo,
          DatabaseHandler.devId1: device1Name,
          DatabaseHandler.datetime1: now,
          DatabaseHandler.useStatus1: useStatusDetectDev1,
          DatabaseHandler.eventUUID1: eventUUID,
          DatabaseHandler.devMainUUID1: devMainUUID1,
          DatabaseHandler.dev1Pressure: format(useStatus), //pressure val dev 1
          DatabaseHandler.dev1Temperature : format(dev1TemperatureValue),

          DatabaseHandler.devNo2: '2',
          DatabaseHandler.devId2: device2Name,
          DatabaseHandler.datetime2: now,
          DatabaseHandler.useStatus2: useStatusDetectDev2,
          DatabaseHandler.eventUUID2: eventUUID,
          DatabaseHandler.devMainUUID2: devMainUUID2,
          DatabaseHandler.dev2Pressure: format(dev2PressureValue),
          DatabaseHandler.dev2Temperature : format(dev2TemperatureValue),
        };
        tableName = '_logTableDetectValue';
        prefs.setString('dev1Pressure',useStatus).toString();
        useStatusDetectDev1 = prefs.getString('useStatusDetectDev1').toString()=="null"?'1':prefs.getString('useStatusDetectDev1').toString();
        useStatusDetectDev2 = prefs.getString('useStatusDetectDev2').toString()=="null"?'1':prefs.getString('useStatusDetectDev2').toString();
        devMainUUID1 = prefs.getString('devMainUUID1').toString();
        devMainUUID2 = prefs.getString('devMainUUID2').toString();
        dbHelper.insertLogToLocal(row,tableName).then((values) {
          if (kDebugMode) {
            print('Local DB Insert dev1 dev1PressureValueUUID LOCAL Time/NEPAL Time====>' +DateTime.now().toString());
            print('Local DB Insert dev2 dev1PressureValueUUID JAPAN Time====>' +getCurrentTimeofJapan());
          }
        });
      }
      //if eventUUID equal to Settings page device 1 Temperature Value UUID save to detect value (Local)
      else if(eventUUID==dev1TemperatureValueUUID && devMainUUID == dev1ServiceUUID && devNo == '1'){
        if (kDebugMode) {
          print('insertLogLoaclAndApi Function Reached to Device1 Temperature Value UUID');
          print('Device No =============> '+devNo);
          print('Device Name ==============> '+devName);
          print('Use Status =============> '+useStatus);
          print('Event UUID =============> '+eventUUID);
          print('Device Main UUID =============> '+devMainUUID);
        }
        row = {
          DatabaseHandler.devNo1: devNo,
          DatabaseHandler.devId1: device1Name,
          DatabaseHandler.datetime1: now,
          DatabaseHandler.useStatus1: useStatusDetectDev1,
          DatabaseHandler.eventUUID1: eventUUID,
          DatabaseHandler.devMainUUID1: devMainUUID,
          DatabaseHandler.dev1Pressure: format(dev1PressureValue),
          DatabaseHandler.dev1Temperature : format(useStatus),

          DatabaseHandler.devNo2: '2',
          DatabaseHandler.devId2: device2Name,
          DatabaseHandler.datetime2: now,
          DatabaseHandler.useStatus2: useStatusDetectDev2,
          DatabaseHandler.eventUUID2: eventUUID,
          DatabaseHandler.devMainUUID2: devMainUUID2,
          DatabaseHandler.dev2Pressure: format(dev2PressureValue),
          DatabaseHandler.dev2Temperature : format(dev2TemperatureValue),
        };
        tableName = '_logTableDetectValue';
        prefs.setString('dev1Temperature',useStatus).toString();
        useStatusDetectDev1 = prefs.getString('useStatusDetectDev1').toString()=="null"?'1':prefs.getString('useStatusDetectDev1').toString();
        useStatusDetectDev2 = prefs.getString('useStatusDetectDev2').toString()=="null"?'1':prefs.getString('useStatusDetectDev2').toString();
        devMainUUID1 = prefs.getString('devMainUUID1').toString();
        devMainUUID2 = prefs.getString('devMainUUID2').toString();
        await dbHelper.insertLogToLocal(row,tableName).then((values) {
          if (kDebugMode) {
            print('Local Db Insert dev1 dev1TemperatureValueUUID LOCAL Time/NEPAL Time====>' +DateTime.now().toString());
            print('Local Db Insert dev2 dev1TemperatureValueUUID JAPAN Time====>' +getCurrentTimeofJapan());
          }
        });
      }

      //if eventUUID equal to Settings page device 2 Detect Value UUID (FB & Local)
      else if(eventUUID==dev2DetectValueUUID && devMainUUID == dev2ServiceUUID && devNo == '2'){
        if (kDebugMode) {
          print('insertLogLoaclAndApi Function Reached to Device2 Detect Value UUID');
          print('Device No =============> '+devNo);
          print('Device Name ==============> '+devName);
          print('Use Status =============> '+useStatus);
          print('Event UUID =============> '+eventUUID);
          print('Device Main UUID =============> '+devMainUUID);
        }
        row = {
          DatabaseHandler.devNo1: '1',
          DatabaseHandler.devId1: device1Name,
          DatabaseHandler.datetime1: now,
          DatabaseHandler.useStatus1: useStatusDetectDev1,
          DatabaseHandler.eventUUID1: eventUUID,
          DatabaseHandler.devMainUUID1: devMainUUID1,
          DatabaseHandler.dev1Pressure: format(dev1PressureValue), //pressure val dev 1
          DatabaseHandler.dev1Temperature : format(dev1TemperatureValue), //Temperature val dev1

          DatabaseHandler.devNo2: devNo,
          DatabaseHandler.devId2: device2Name,
          DatabaseHandler.datetime2: now,
          DatabaseHandler.useStatus2: useStatus,
          DatabaseHandler.eventUUID2: eventUUID,
          DatabaseHandler.devMainUUID2: devMainUUID,
          DatabaseHandler.dev2Pressure: format(dev2PressureValue), //pressure val dev 2
          DatabaseHandler.dev2Temperature : format(dev2TemperatureValue),//Temperature val dev2
        };
        tableName = '_logTableDetectValue';
        prefs.setString('useStatusDetectDev2',useStatus).toString();
        prefs.setString('devMainUUID2',devMainUUID).toString();
        useStatusDetectDev1 = prefs.getString('useStatusDetectDev1').toString()=="null"?'1':prefs.getString('useStatusDetectDev1').toString();
        devMainUUID1 = prefs.getString('devMainUUID1').toString();
        if(homeCon.isLeader==1){
          insertMasterWorkerLogsToFB(row,userid.trim(),eventUUID,dev1DetectValueUUID,dev2DetectValueUUID,devNo,useStatus);
        }
        else{
          insertWorkerStatustLogsToFB(row,userid.trim(),eventUUID,dev1DetectValueUUID,dev2DetectValueUUID,devNo,useStatus);
        }
        dbHelper.insertLogToLocal(row,tableName).then((values) {
          if (kDebugMode) {
            print('Local Db Insert dev2 dev2DetectValueUUID LOCAL Time/NEPAL Time====>' +DateTime.now().toString());
            print('Local Db Insert dev2 dev2DetectValueUUID JAPAN Time====>' +getCurrentTimeofJapan());
          }
        });
      }
      //if eventUUID equal to Settings page device 2 Real Value UUID (Local)
      else if(eventUUID==dev2RealValueUUID && devMainUUID == dev2ServiceUUID && devNo == '2'){
        if (kDebugMode) {
          print('insertLogLoaclAndApi Function Reached to Device2 Real Value UUID');
          print('Device No =============> '+devNo);
          print('Device Name ==============> '+devName);
          print('Use Status =============> '+useStatus);
          print('Event UUID =============> '+eventUUID);
          print('Device Main UUID =============> '+devMainUUID);
        }
        row = {
          DatabaseHandler.devNo1: '1',
          DatabaseHandler.devId1: device1Name,
          DatabaseHandler.datetime1: now,
          DatabaseHandler.useStatus1: 'null',
          DatabaseHandler.eventUUID1: eventUUID,
          DatabaseHandler.devMainUUID1: devMainUUID1,

          DatabaseHandler.devNo2: devNo,
          DatabaseHandler.devId2: device2Name,
          DatabaseHandler.datetime2: now,
          DatabaseHandler.useStatus2: useStatus,
          DatabaseHandler.eventUUID2: eventUUID,
          DatabaseHandler.devMainUUID2: devMainUUID,
        };
        tableName = '_logTableRealValue';
        prefs.setString('useStatusRealDev2',useStatus).toString();
        prefs.setString('devMainUUID2',devMainUUID).toString();
        useStatusRealDev1 = prefs.getString('useStatusRealDev1').toString();
        devMainUUID1 = prefs.getString('devMainUUID1').toString();
        dbHelper.insertLogToLocal(row,tableName).then((values) {
          if (kDebugMode) {
            print('Local Db Insert dev2 dev2RealValueUUID LOCAL Time/NEPAL Time====>' +DateTime.now().toString());
            print('Local Db Insert dev2 dev2RealValueUUID JAPAN Time====>' +getCurrentTimeofJapan());
          }
        });
      }
      //if eventUUID equal to Settings page device 2 Battery Value UUID (Local)
      else if(eventUUID==dev2BatteryValueUUID && devMainUUID == dev2ServiceUUID && devNo == '2'){
        if (kDebugMode) {
          print('insertLogLoaclAndApi Function Reached to Device2 Battery Value UUID');
          print('Device No =============> '+devNo);
          print('Device Name ==============> '+devName);
          print('Use Status =============> '+useStatus);
          print('Event UUID =============> '+eventUUID);
          print('Device Main UUID =============> '+devMainUUID);
        }
        row = {
          DatabaseHandler.devNo1: '1',
          DatabaseHandler.devId1: device1Name,
          DatabaseHandler.datetime1: now,
          DatabaseHandler.useStatus1: 'null',
          DatabaseHandler.eventUUID1: eventUUID,
          DatabaseHandler.devMainUUID1: devMainUUID1,

          DatabaseHandler.devNo2: devNo,
          DatabaseHandler.devId2: device2Name,
          DatabaseHandler.datetime2: now,
          DatabaseHandler.useStatus2: useStatus,
          DatabaseHandler.eventUUID2: eventUUID,
          DatabaseHandler.devMainUUID2: devMainUUID,
        };
        tableName = '_logTableBatteryValue';
        prefs.setString('useStatusBatteryDev2',useStatus).toString();
        prefs.setString('devMainUUID2',devMainUUID).toString();
        useStatusBatteryDev1 = prefs.getString('useStatusBatteryDev1').toString();
        devMainUUID1 = prefs.getString('devMainUUID1').toString();
        dbHelper.insertLogToLocal(row,tableName).then((values) {
          if (kDebugMode) {
            print('Local Db Insert dev2 dev2BatteryValueUUID LOCAL Time/NEPAL Time====>' +DateTime.now().toString());
            print('Local Db Insert dev2 dev2BatteryValueUUID JAPAN Time====>' +getCurrentTimeofJapan());
          }
        });
      }
      //if eventUUID equal to Settings page device 2 Pressure Value UUID save to detect value database (Local)
      else if(eventUUID==dev2PressureValueUUID && devMainUUID == dev2ServiceUUID && devNo == '2'){
        if (kDebugMode) {
          print('insertLogLoaclAndApi Function Reached to Device2 Pressure Value UUID');
          print('Device No =============> '+devNo);
          print('Device Name ==============> '+devName);
          print('Use Status =============> '+useStatus);
          print('Event UUID =============> '+eventUUID);
          print('Device Main UUID =============> '+devMainUUID);
        }
        row = {
          DatabaseHandler.devNo1: '1',
          DatabaseHandler.devId1: device1Name,
          DatabaseHandler.datetime1: now,
          DatabaseHandler.useStatus1: useStatusDetectDev1,
          DatabaseHandler.eventUUID1: eventUUID,
          DatabaseHandler.devMainUUID1: devMainUUID1,
          DatabaseHandler.dev1Pressure: format(dev1PressureValue),
          DatabaseHandler.dev1Temperature : format(dev1TemperatureValue),

          DatabaseHandler.devNo2: devNo,
          DatabaseHandler.devId2: device2Name,
          DatabaseHandler.datetime2: now,
          DatabaseHandler.useStatus2: useStatus,
          DatabaseHandler.eventUUID2: eventUUID,
          DatabaseHandler.devMainUUID2: devMainUUID,
          DatabaseHandler.dev2Pressure: format(useStatus),
          DatabaseHandler.dev2Temperature : format(dev1TemperatureValue),
        };
        tableName = '_logTableDetectValue';
        prefs.setString('dev2Pressure',useStatus).toString();
        useStatusDetectDev1 = prefs.getString('useStatusDetectDev1').toString()=="null"?'1':prefs.getString('useStatusDetectDev1').toString();
        useStatusDetectDev2 = prefs.getString('useStatusDetectDev2').toString()=="null"?'1':prefs.getString('useStatusDetectDev2').toString();
        devMainUUID1 = prefs.getString('devMainUUID1').toString();
        devMainUUID2 = prefs.getString('devMainUUID2').toString();
        dbHelper.insertLogToLocal(row,tableName).then((values) {
          if (kDebugMode) {
            print('Local Db Insert dev2 dev2PressureValueUUID LOCAL Time/NEPAL Time====>' +DateTime.now().toString());
            print('Local Db Insert dev2 dev2PressureValueUUID JAPAN Time====>' +getCurrentTimeofJapan());
          }
        });
      }
      //if eventUUID equal to Settings page device 2 Temperature Value UUID save to detect value database (Local)
      else if(eventUUID==dev2TemperatureValueUUID && devMainUUID == dev2ServiceUUID && devNo == '2'){
        if (kDebugMode) {
          print('insertLogLoaclAndApi Function Reached to Device2 Pressure Value UUID');
          print('Device No =============> '+devNo);
          print('Device Name ==============> '+devName);
          print('Use Status =============> '+useStatus);
          print('Event UUID =============> '+eventUUID);
          print('Device Main UUID =============> '+devMainUUID);
        }
        row = {
          DatabaseHandler.devNo1: '1',
          DatabaseHandler.devId1: device1Name,
          DatabaseHandler.datetime1: now,
          DatabaseHandler.useStatus1: useStatusDetectDev1,
          DatabaseHandler.eventUUID1: eventUUID,
          DatabaseHandler.devMainUUID1: devMainUUID1,
          DatabaseHandler.dev1Pressure: format(dev1PressureValue),
          DatabaseHandler.dev1Temperature : format(dev1TemperatureValue),

          DatabaseHandler.devNo2: devNo,
          DatabaseHandler.devId2: device2Name,
          DatabaseHandler.datetime2: now,
          DatabaseHandler.useStatus2: useStatus,
          DatabaseHandler.eventUUID2: eventUUID,
          DatabaseHandler.devMainUUID2: devMainUUID,
          DatabaseHandler.dev2Pressure: format(dev1PressureValue),
          DatabaseHandler.dev2Temperature : format(useStatus),
        };
        tableName = '_logTableDetectValue';
        prefs.setString('dev2Temperature',useStatus).toString();
        useStatusDetectDev1 = prefs.getString('useStatusDetectDev1').toString()=="null"?'1':prefs.getString('useStatusDetectDev1').toString();
        useStatusDetectDev2 = prefs.getString('useStatusDetectDev2').toString()=="null"?'1':prefs.getString('useStatusDetectDev2').toString();
        devMainUUID1 = prefs.getString('devMainUUID1').toString();
        devMainUUID2 = prefs.getString('devMainUUID2').toString();
        dbHelper.insertLogToLocal(row,tableName).then((values) {
          if (kDebugMode) {
            print('Local Db Insert dev2 dev2TemperatureValueUUID LOCAL Time/NEPAL Time====>' +DateTime.now().toString());
            print('Local Db Insert dev2 dev2TemperatureValueUUID JAPAN Time====>' +getCurrentTimeofJapan());
          }
        });
      }
      if(devNo == '1' && devMainUUID != dev1ServiceUUID){
        toastMsgCon.showDeviceUUIDNotCorrectMsg(device1Name);
      }
      if(devNo == '2' && devMainUUID != dev2ServiceUUID){
        toastMsgCon.showDeviceUUIDNotCorrectMsg(device2Name);
      }
    }
    else{
      // Do Nothing on No Internet Connection
      // ToastMessageController toastMsgCon = Get.find();
      // toastMsgCon.showToastMessage('No Internet');
    }
  }

  //Device Connected Status Log Save to local database _logTableDeviceConnection
  insertDeviceLog(devName,connectionStatus) {
    String now =DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now().toUtc());
    Map<String, dynamic> row = {};
    row = {
      DatabaseHandler.devName: devName,
      DatabaseHandler.connectionStatus: connectionStatus,
      DatabaseHandler.dateTime: now,
    };
    dbHelper.insertLogToLocal(row,'_logTableDeviceConnection').then((values) {
      if (kDebugMode) {
        print(values);
      }
      if (kDebugMode) {
        print(values);
      }
    });
  }

  //WORKER DATA TO FIREBASE
  insertWorkerStatustLogsToFB(row,userId,eventUUID,dev1DetectValueUUID,dev2DetectValueUUID,devNo,useStatus)async{
    final HomeController homeCon = Get.find();
    final prefs = await SharedPreferences.getInstance();
    int companyId = prefs.getInt('companyId')??0;
    int groupId = prefs.getInt('groupId')??0;
    int siteId = prefs.getInt('siteId')??0;
    int workerId = prefs.getInt('workerId')??0;
    int isLeader = prefs.getInt('isLeader')??0;
    String workerName = prefs.getString('workerName').toString();
    String workerProfileImageUrl = prefs.getString('workerProfileImageUrl').toString();
    String batteryValueDeviceLeft = prefs.getString('useStatusBatteryDev1').toString();
    String batteryValueDeviceRight = prefs.getString('useStatusBatteryDev2').toString();
    int startTime = prefs.getInt('startTime')??0;
    bool alertFlg = prefs.getBool('alertFlg')??false;
    if (kDebugMode) {
      print('Insert to FireBase insertWorkerStatustLogsToFB Requested====>' +DateTime.now().toString());
    }

    checkAndPlayAlarm(
      row,
      homeCon,
      eventUUID,
      dev1DetectValueUUID,
      dev2DetectValueUUID,
      devNo,
      row['use_status1']=="null"?useStatusDetectDev1.toString():row['use_status1'],
      row['use_status2']=="null"?useStatusDetectDev2.toString():row['use_status2'],
      isLeader,
      companyId,
      groupId,
      siteId,
      userId
    );
    //ADD Worker Status History
    FirestoreServices.addWorkerStatusHistory(
      companyId: companyId, 
      groupId: groupId, 
      leftBatteryValue: batteryValueDeviceLeft=="null"?0:int.parse(batteryValueDeviceLeft), 
      leftDeviceId: row['dev_id1'], 
      leftFailureValue: '', 
      pressureValue:homeCon.deviceLeftConnected=="Connected"?row['dev1_Pressure']:row['dev2_Pressure'], 
      rightBatteryValue: batteryValueDeviceRight=="null"?0:int.parse(batteryValueDeviceRight), 
      rightDeviceId: row['dev_id2'], 
      rightFailureValue: '', 
      siteId: siteId, 
      temperatureValue:homeCon.deviceLeftConnected=="Connected"?row['dev1_Temperature']:row['dev2_Temperature'], 
      useLeftStatus: row['use_status1']=="null"?useStatusDetectDev1.toString():row['use_status1'], 
      useRightStatus: row['use_status2']=="null"?useStatusDetectDev2.toString():row['use_status2'], 
      workerCode: userId, 
      workerId: workerId, 
      workerName: workerName, 
      workerProfileImageUrl: workerProfileImageUrl, 
      workerStatus: status(row['use_status1']=="null"?useStatusDetectDev1:row['use_status1'],row['use_status2']=="null"?useStatusDetectDev2:row['use_status2']), 
      startTime: startTime, 
      startHeightCalculation: false, 
      //if leader from real dev Updating
      masterPressureValue: isLeader==1
        ?homeCon.deviceLeftConnected=="Connected"
        ?row['dev1_Pressure']
        :row['dev2_Pressure']
        :homeCon.currentMasterAverageValue.value, 
      baseMasterPressureValue: homeCon.baseMasterValue, 
      baseUserPressureValue: homeCon.baseUserValue, 
      //A = Device current pressure value
      //B = Master pressure value current C
      //C = user master pressure value BU
      //D = Base Master pressure vlaue BM
      actualHeightM: actualheightCalculation(
        homeCon.deviceLeftConnected=="Connected"
        ?row['dev1_Pressure']
        :row['dev2_Pressure'], 
        isLeader==1
        ?homeCon.deviceLeftConnected=="Connected"
        ?row['dev1_Pressure']
        :row['dev2_Pressure']
        :homeCon.currentMasterAverageValue.value,
        homeCon.baseUserValue, 
        homeCon.baseMasterValue
      ),
      displayHeightM: displayheightCalculation(
        homeCon.deviceLeftConnected=="Connected"
        ?row['dev1_Pressure']
        :row['dev2_Pressure'], 
        isLeader==1
        ?homeCon.deviceLeftConnected=="Connected"
        ?row['dev1_Pressure']
        :row['dev2_Pressure']
        :homeCon.currentMasterAverageValue.value,
        homeCon.baseUserValue, 
        homeCon.baseMasterValue
      ),
      heightAlertClass: heightAlertCalculation(
        displayheightCalculation(
          homeCon.deviceLeftConnected=="Connected"
          ?row['dev1_Pressure']
          :row['dev2_Pressure'], 
          isLeader==1
          ?homeCon.deviceLeftConnected=="Connected"
          ?row['dev1_Pressure']
          :row['dev2_Pressure']
          :homeCon.currentMasterAverageValue.value,
          homeCon.baseUserValue, 
          homeCon.baseMasterValue
        ),
      ),
    );
    //ADD/UPDATE Worker Status Latest
    await FirestoreServices.checkWorkerDocExist(userId).then((value){
      if(value==true){
        //UPDATE Latest
        FirestoreServices.updateWorkerStatusLatest( 
          devNo: devNo,
          companyId: companyId, 
          groupId: groupId, 
          leftBatteryValue: batteryValueDeviceLeft=="null"?0:int.parse(batteryValueDeviceLeft), 
          leftDeviceId: row['dev_id1'], 
          leftFailureValue: '', 
          pressureValue:homeCon.deviceLeftConnected=="Connected"
          ?row['dev1_Pressure']
          :row['dev2_Pressure'], 
          rightBatteryValue: batteryValueDeviceRight=="null"?0:int.parse(batteryValueDeviceRight), 
          rightDeviceId: row['dev_id2'], 
          rightFailureValue: '', 
          siteId: siteId, 
          temperatureValue:homeCon.deviceLeftConnected=="Connected"?row['dev1_Temperature']:row['dev2_Temperature'],
          useLeftStatus: row['use_status1']=="null"?'1':row['use_status1'], 
          useRightStatus: row['use_status2']=="null"?'1':row['use_status2'], 
          workerCode: userId, 
          workerId: workerId, 
          workerName: workerName, 
          workerProfileImageUrl: workerProfileImageUrl, 
          workerStatus: status(row['use_status1']=="null"?useStatusDetectDev1:row['use_status1'],row['use_status2']=="null"?useStatusDetectDev2:row['use_status2']), 
          startTime: startTime,
          //if leader from real dev Updating
          masterPressureValue: isLeader==1?row['dev1_Pressure']:homeCon.currentMasterAverageValue.value,
          // baseMasterPressureValue: null, //BM
          // baseUserPressureValue: null, //BU
          //A = Device current pressure value
          //B = Master pressure value current C
          //C = user master pressure value BU
          //D = Base Master pressure vlaue BM
          actualHeightM: actualheightCalculation(
            homeCon.deviceLeftConnected=="Connected"
            ?row['dev1_Pressure']
            :row['dev2_Pressure'], 
            isLeader==1
            ?homeCon.deviceLeftConnected=="Connected"
            ?row['dev1_Pressure']
            :row['dev2_Pressure']
            :homeCon.currentMasterAverageValue.value,
            homeCon.baseUserValue, 
            homeCon.baseMasterValue
          ),
          displayHeightM: displayheightCalculation(
            homeCon.deviceLeftConnected=="Connected"
            ?row['dev1_Pressure']
            :row['dev2_Pressure'], 
            isLeader==1
            ?homeCon.deviceLeftConnected=="Connected"
            ?row['dev1_Pressure']
            :row['dev2_Pressure']
            :homeCon.currentMasterAverageValue.value,
            homeCon.baseUserValue, 
            homeCon.baseMasterValue
          ),
          heightAlertClass: heightAlertCalculation(
            displayheightCalculation(
              homeCon.deviceLeftConnected=="Connected"
              ?row['dev1_Pressure']
              :row['dev2_Pressure'], 
              isLeader==1
              ?homeCon.deviceLeftConnected=="Connected"
              ?row['dev1_Pressure']
              :row['dev2_Pressure']
              :homeCon.currentMasterAverageValue.value,
              homeCon.baseUserValue, 
              homeCon.baseMasterValue 
            ),
          ),
          alertFlg: alertFlg
        );
      }
      else{
        //ADD Latest
        FirestoreServices.addWorkerStatusLatest( 
          companyId: companyId, 
          groupId: groupId, 
          leftBatteryValue: batteryValueDeviceLeft=="null"?0:int.parse(batteryValueDeviceLeft), 
          leftDeviceId: row['dev_id1'], 
          leftFailureValue: '', 
          leftTime: '', 
          pressureValue:homeCon.deviceLeftConnected=="Connected"
          ?row['dev1_Pressure']
          :row['dev2_Pressure'], 
          rightBatteryValue: batteryValueDeviceRight=="null"?0:int.parse(batteryValueDeviceRight), 
          rightDeviceId: row['dev_id2'], 
          rightFailureValue: '', 
          rightTime: '', 
          siteId: siteId, 
          temperatureValue:homeCon.deviceLeftConnected=="Connected"?row['dev1_Temperature']:row['dev2_Temperature'],
          useLeftStatus: row['use_status1']=="null"?'1':row['use_status1'], 
          useRightStatus: row['use_status2']=="null"?'1':row['use_status2'], 
          workerCode: userId, 
          workerId: workerId, 
          workerName: workerName, 
          workerProfileImageUrl: workerProfileImageUrl, 
          workerStatus: status(row['use_status1']=="null"?useStatusDetectDev1:row['use_status1'],row['use_status2']=="null"?useStatusDetectDev2:row['use_status2']), 
          startTime: startTime,
          startHeightCalculation: false, 
          //if leader from real dev Updating
          masterPressureValue: isLeader==1
          ?homeCon.deviceLeftConnected=="Connected"
          ?row['dev1_Pressure']
          :row['dev2_Pressure']
          :homeCon.currentMasterAverageValue.value,
          baseMasterPressureValue: null, //BM
          baseUserPressureValue: null,   //BU
          //A = Device current pressure value
          //B = Master pressure value current C
          //C = user master pressure value BU
          //D = Base Master pressure vlaue BM
          actualHeightM: actualheightCalculation(
            homeCon.deviceLeftConnected=="Connected"
            ?row['dev1_Pressure']
            :row['dev2_Pressure'], 
            isLeader==1
            ?homeCon.deviceLeftConnected=="Connected"
            ?row['dev1_Pressure']
            :row['dev2_Pressure']
            :homeCon.currentMasterAverageValue.value,
            homeCon.baseUserValue, 
            isLeader==1?homeCon.baseMasterValueM:homeCon.baseMasterValueU 
          ),
          displayHeightM: displayheightCalculation(
            homeCon.deviceLeftConnected=="Connected"
            ?row['dev1_Pressure']
            :row['dev2_Pressure'], 
            isLeader==1
            ?homeCon.deviceLeftConnected=="Connected"
            ?row['dev1_Pressure']
            :row['dev2_Pressure']
            :homeCon.currentMasterAverageValue.value,
            homeCon.baseUserValue, 
            isLeader==1?homeCon.baseMasterValueM:homeCon.baseMasterValueU 
          ),
          heightAlertClass: heightAlertCalculation(
            displayheightCalculation(
              homeCon.deviceLeftConnected=="Connected"
              ?row['dev1_Pressure']
              :row['dev2_Pressure'], 
              isLeader==1
              ?homeCon.deviceLeftConnected=="Connected"
              ?row['dev1_Pressure']
              :row['dev2_Pressure']
              :homeCon.currentMasterAverageValue.value,
              homeCon.baseUserValue, 
              isLeader==1?homeCon.baseMasterValueM:homeCon.baseMasterValueU 
            ),
          ),
          alertFlg: false,
        );
      }
    });
  }

  //MASTER WORKER DATA TO FIREBASE
  insertMasterWorkerLogsToFB(row,userId,eventUUID,dev1DetectValueUUID,dev2DetectValueUUID,devNo,useStatus)async{
    final HomeController homeCon = Get.find();
    final prefs = await SharedPreferences.getInstance();
    int? companyId = prefs.getInt('companyId') as int;
    int? groupId = prefs.getInt('groupId')as int;
    int? siteId = prefs.getInt('siteId')as int;
    int? workerId = prefs.getInt('workerId')as int;
    String? workerName = prefs.getString('workerName')as String;
    String? workerProfileImageUrl = prefs.getString('workerProfileImageUrl')as String;
    int? averageMaxLength = prefs.getInt('averageMaxLength') as int;
    //For Average Pressure Value
    if(pressureValues.length!=averageMaxLength){ 
      pressureValues.add({'pressureValue':double.parse(homeCon.deviceLeftConnected=="Connected"?row['dev1_Pressure']:row['dev2_Pressure'])});
    }
    else{
      pressureValues.removeAt(0);
      pressureValues.add({'pressureValue':double.parse(homeCon.deviceLeftConnected=="Connected"?row['dev1_Pressure']:row['dev2_Pressure'])});
    }
    final dynamic averagePressureValueResult = pressureValues.map((pressure) => pressure["pressureValue"] as double).toList().average;
    final dynamic averagePressureValue = double.parse((averagePressureValueResult).toStringAsFixed(4));
    if (kDebugMode) {
      print(averagePressureValue);
    }
    //Always Update Master Current Average Value by own device value
    homeCon.currentMasterAverageValue.value = averagePressureValue.toString();
    FirestoreServices.checkMasterWorkerDocExist('$companyId-$groupId-$siteId').then((value){
      if(value==true){
        FirestoreServices.updateMasterWorkerData(
          companyId: companyId, 
          groupId: groupId, 
          siteId: siteId, 
          workerId: workerId,
          workerCode: userId, 
          workerName: workerName, 
          workerProfileImageUrl: workerProfileImageUrl, 
          status: status(row['use_status1']=="null"?useStatusDetectDev1:row['use_status1'],row['use_status2']=="null"?useStatusDetectDev2:row['use_status2']), 
          pressureValue: homeCon.deviceLeftConnected=="Connected"
          ?row['dev1_Pressure']
          :row['dev2_Pressure'], 
          averagePressureValue: averagePressureValue.toString(), 
        );
      }
      else{
        FirestoreServices.addMasterWorkerData( 
          companyId: companyId, 
          groupId: groupId, 
          siteId: siteId, 
          workerId: workerId,
          workerCode: userId, 
          workerName: workerName, 
          workerProfileImageUrl: workerProfileImageUrl, 
          status: status(row['use_status1']=="null"?useStatusDetectDev1:row['use_status1'],row['use_status2']=="null"?useStatusDetectDev2:row['use_status2']), 
          pressureValue: homeCon.deviceLeftConnected=="Connected"
          ?row['dev1_Pressure']
          :row['dev2_Pressure'], 
          averagePressureValue: averagePressureValue.toString(), 
        );
      }
    });
  }

  //Check if condition to play Alarm is Met
  checkAndPlayAlarm(row,homeCon,eventUUID,dev1DetectValueUUID,dev2DetectValueUUID,devNo,useStatusDev1,useStatusDev2,isLeader,companyId,groupId,siteId,userId){
    if(homeCon.deviceLeftConnected=="Connected" && eventUUID==dev1DetectValueUUID && homeCon.deviceRightConnected=="Connected" && eventUUID==dev2DetectValueUUID){
      var displayheightMaster = displayheightCalculation(
        homeCon.deviceLeftConnected=="Connected"
        ?row['dev1_Pressure']
        :row['dev2_Pressure'], 
        isLeader==1
        ?homeCon.deviceLeftConnected=="Connected"
        ?row['dev1_Pressure']
        :row['dev2_Pressure']
        :homeCon.currentMasterAverageValue.value,
        homeCon.baseUserValue, 
        homeCon.baseMasterValue
      );
      if(useStatusDev1=='1' && useStatusDev2=='1'){
        alertTimer ??= Timer.periodic(
          const Duration(seconds: 1),
          (timer) {
            alertCounter++;
            var displayheightM = displayheightCalculation(
              homeCon.deviceLeftConnected=="Connected"
              ?row['dev1_Pressure']
              :row['dev2_Pressure'], 
              isLeader==1
              ?homeCon.deviceLeftConnected=="Connected"
              ?row['dev1_Pressure']
              :row['dev2_Pressure']
              :homeCon.currentMasterAverageValue.value,
              homeCon.baseUserValue, 
              homeCon.baseMasterValue
            );
            if(alertCounter >= 60 && displayheightM!=null){
              if (kDebugMode) {
                print('DisplayHeightM ========>>> $displayheightM');
              }
              if(double.parse(displayheightM.toString())>2){
                if(isPlayingAlert==false && useStatusDev1=='1' && useStatusDev2=='1'){
                  isPlayingAlert=true;
                  playAlert(companyId,groupId,siteId,userId);
                }
              }
              else{
                stopAlert(companyId,groupId,siteId,userId);
              }
            }
            else if (isPlayingAlert==true && displayheightM==null){
              stopAlert(companyId,groupId,siteId,userId);
            }
          },
        );
      }
      //if 0 Stop timer
      dynamic displayHMaster = double.tryParse(displayheightMaster.toString())??0;
      if(useStatusDev1=='0' || useStatusDev2=='0' || displayHMaster<2 ){
      // if(useStatusDev1=='0' || useStatusDev2=='0' || double.tryParse(displayheightMaster.toString())!<2){
        stopAlert(companyId,groupId,siteId,userId);
      }
    }
  }

  //Play Alarm
  playAlert(companyId,groupId,siteId,workerName)async{
    playCondition = true;
    final prefs = await SharedPreferences.getInstance();
    AudioController audioCon = Get.find();
    String? workerFirstLastName = prefs.getString('workerName');
    String? workerProfileImage = prefs.getString('workerProfileImageUrl');
    audioCon.playAudio();
    prefs.setBool('alertFlg',true);
    DateTime now = DateTime.now();
    String todayDate = DateFormat('yyyy-MM-dd').format(now).toString();
    String currentTime = DateFormat('HH:mm:ss').format(now).toString();
    FirestoreServices.addAlertLog(
      companyId: companyId.toString(), 
      groupId: groupId.toString(), 
      siteId: siteId.toString(), 
      staffCode: workerName.toString(), 
      alertType: 'ON', 
      alertDate: todayDate.toString(), 
      alertTime: currentTime.toString(), 
      todayDate: todayDate.toString(), 
      workerProfileImageUrl: workerProfileImage ?? '', 
      workerName: workerFirstLastName ?? ''
    );
    _apiendpoint.alertLog(
      companyId, 
      siteId, 
      groupId, 
      workerName, 
      "ON", 
      todayDate, 
      currentTime
    );
  }

  //Stop Alarm
  stopAlert(companyId,groupId,siteId,workerName)async{
    playCondition = false;
    final prefs = await SharedPreferences.getInstance();
    alertCounter = 0;
    if(alertTimer!=null){
      alertTimer!.cancel();
      alertTimer=null;
    }
    if(isPlayingAlert==true){
      isPlayingAlert=false;
      AudioController audioCon = Get.find();
      String? workerFirstLastName = prefs.getString('workerName');
      String? workerProfileImage = prefs.getString('workerProfileImageUrl');
      audioCon.stopAudio();
      prefs.setBool('alertFlg',false);
      DateTime now = DateTime.now();
      String todayDate = DateFormat('yyyy-MM-dd').format(now).toString();
      String currentTime = DateFormat('HH:mm:ss').format(now).toString();
      FirestoreServices.addAlertLog(
        companyId: companyId.toString(), 
        groupId: groupId.toString(), 
        siteId: siteId.toString(), 
        staffCode: workerName.toString(), 
        alertType: 'OFF', 
        alertDate: todayDate.toString(), 
        alertTime: currentTime.toString(), 
        todayDate: todayDate.toString(), 
        workerProfileImageUrl: workerProfileImage??'', 
        workerName: workerFirstLastName??''
      );
      FirestoreServices.updateWorkerStatusLatestAlertFlgOnly(
        workerCode: workerName.toString(),
        alertFlg: false 
      );
      _apiendpoint.alertLog(
        companyId, 
        siteId, 
        groupId, 
        workerName, 
        "OFF", 
        todayDate, 
        currentTime
      );
    }
    update();
  }

  //Convert to json type String
  String getPrettyJSONString(jsonObject) {
    var encoder = const JsonEncoder.withIndent("   ");
    return encoder.convert(jsonObject);
  }

  // Format Pressure and Temperature Value
  format(hexStr){
    final myInteger = int.parse(hexStr);
    final hexString = myInteger.toRadixString(16).padLeft(8,'0');
    final byteData = ByteData.sublistView(Uint8List.fromList(hex.decode(hexString)));
    final littleEndianVal = byteData.getFloat32(0, Endian.little);
    return littleEndianVal.toStringAsFixed(4);
  }

  // NORMAL || WARNING || DANGER  WORKER STATUS
  status(useStatus1,useStatus2){
    if(int.parse(useStatus1)+int.parse(useStatus2)==0){
      return 'normal';
    }
    else if(int.parse(useStatus1)+int.parse(useStatus2)==1){
      return 'warning';
    }
    else if(int.parse(useStatus1)+int.parse(useStatus2)==2){
      return 'danger';
    }
  }

  //LIST DELETE And UPLOAD Functions for Real || Battery || DeviceStatus || Voltage Logs
  
  //Get All Detect Logs /Data List
  getAllLogs() async {
    await dbHelper.getAllLogs('_tblDetectValue').then((values) {
      logData = values!;
      if (kDebugMode) {
        print(logData);
      }
    });
  }

  //Get All Detect Logs 
  getAllRealValueLogs() async {
    await dbHelper.getAllRealLogs().then((values) {
      logData = values!;
      if (kDebugMode) {
        print(logData);
      }
    });
  }

  //Get All Battery Value Logs 
  getAllBatteryValueLogs() async {
    await dbHelper.getAllBatteryLogs().then((values) {
      logData = values!;
      if (kDebugMode) {
        print(logData);
      }
    });
  }

  //Get All Device Status Logs 
  getAllDeviceStatusValueLogs() async {
    await dbHelper.getAllDevConnectionLogs().then((values) {
      logData = values!;
      if (kDebugMode) {
        print(logData);
      }
    });
  }

  //Delete Detect Logs
  deleteAllLogs() async {
    await dbHelper.delete('_tblDetectValue');
  }

  //Delete Real Logs
  deleteAllRealLogs() async {
    await dbHelper.deleteRealLog('_logTableRealValue');
  }

  //Delete Battery Logs
  deleteAllBatteryLogs() async {
    await dbHelper.deleteBatteryLog('_logTableBatteryValue');
  }

  //Delete Device Connection Status Log
  deleteAllDeviceConnectionLogs() async {
    await dbHelper.deleteDeviceConnectionLog();
  }

  exportVoltageLog()async{
    Device1Controller device1Con = Get.find();
    Device2Controller device2Con = Get.find();
    HomeController homeCon = Get.find();
    String? dev1RealValueUUID = homeCon.dev1RealValueUUID.text ==""?'b7db6729-5dcc-4f4f-9ae2-1fec4db3701a':homeCon.dev1RealValueUUID.text;
    String? dev2RealValueUUID = homeCon.dev2RealValueUUID.text == ""?'homeCon.dev1RealValueUUID.text':homeCon.dev2RealValueUUID.text;
    List<List<dynamic>> rows1 = [];
    List<List<dynamic>> rows2 = [];
    if(device1Con.logs1.isNotEmpty){
      for (int i = 0; i <device1Con.logs1.length+1;i++){
        List<dynamic> rowA = [];
        if(i==0 && device1Con.logs1[0].characteristic == dev1RealValueUUID){
          rowA.add('Characteristic');
          rowA.add('Data');
          rowA.add('DateTime');
          rowA.add('MainUUID');
          rows1.add(rowA);
        }
        else if(i!=0 && i!=device1Con.logs1.length+1 && device1Con.logs1[i-1].characteristic == dev1RealValueUUID/* "b7db6729-5dcc-4f4f-9ae2-1fec4db3701a" */){
          rowA.add(device1Con.logs1[i-1].characteristic);
          rowA.add(device1Con.logs1[i-1].data);
          rowA.add(device1Con.logs1[i-1].dateTime);
          rowA.add(device1Con.logs1[i-1].mainUUID);
          rows1.add(rowA);
        }
      }
      await device1Con.requestStoragePermissionAndExport(rows1);
    }
    else{
      ToastMessageController toastCon = Get.find();
      toastCon.emptyVoltageLogMsg('L');
    }
    if(device2Con.logs2.isNotEmpty){
      for (int i = 0; i < device2Con.logs2.length+1;i++){
        List<dynamic> rowB = [];
        if(i==0 && device2Con.logs2[0].characteristic == dev2RealValueUUID){
          rowB.add('Characteristic');
          rowB.add('Data');
          rowB.add('DateTime');
          rowB.add('MainUUID');
          rows2.add(rowB);
        }
        else if(i!=0 && i!=device2Con.logs2.length+1 && device2Con.logs2[i-1].characteristic == dev2RealValueUUID/* "b7db6729-5dcc-4f4f-9ae2-1fec4db3701a" */){
          rowB.add(device2Con.logs2[i-1].characteristic);
          rowB.add(device2Con.logs2[i-1].data);
          rowB.add(device2Con.logs2[i-1].dateTime);
          rowB.add(device2Con.logs2[i-1].mainUUID);
          rows2.add(rowB);
        }
      }
      device2Con.requestStoragePermissionAndExport(rows2,context);
    }
    else{
      ToastMessageController toastCon = Get.find();
      toastCon.emptyVoltageLogMsg('R');
    }

  }

  uploadLogToFirebase(filePath,name,companyId,siteId) async {
    String fileName = basename(filePath);
    final firebaseStorageRef = FirebaseStorage.instance.ref().child("$companyId/$siteId/$fileName");
    firebaseStorageRef.putFile(File(filePath));
  }
}
