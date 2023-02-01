import 'dart:async';
import 'dart:typed_data';
import 'package:blue/controllers/audio_controller.dart';
import 'package:blue/controllers/connectivity_controller.dart';
import 'package:blue/helper/height_alert_calculation.dart';
import 'package:blue/helper/height_calculation.dart';
import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blue/controllers/home_controller.dart';
import 'package:blue/controllers/toast_message_controller.dart';
import 'package:blue/services/apiservices.dart';
import 'package:blue/services/firestore_services.dart';
import 'package:collection/collection.dart';

class LogController extends GetxController{
  final ConnectivityController connectionCon =  Get.put(ConnectivityController());
  final AudioController audioCon = Get.put(AudioController());
  final HomeController homeCon = Get.find();

  // API SERVICE CLASS //
  final _apiendpoint = ApiEndpointRepo();

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
  ToastMessageController toastMsgCon = Get.find();
  Map<String, dynamic> row = {};

  // insertLogLoacl Dev1 & Dev2

  insertLogFBDev1(devName,useStatus,eventUUID,devMainUUID) async {
    if(connectionCon.online.value == true){
      String device1Name =  homeCon.deviceNameLeft.trim();
      String device2Name =  homeCon.deviceNameRight.trim();
      final prefs = await SharedPreferences.getInstance();
      String? dev1ServiceUUID = homeCon.dev1ServiceUUID.text.trim();
      String? dev1DetectValueUUID = homeCon.dev1DetectValueUUID.text.trim();
      String? dev1RealValueUUID = homeCon.dev1RealValueUUID.text.trim();
      String? dev1BatteryValueUUID = homeCon.dev1BatteryValueUUID.text.trim();
      String? dev1PressureValueUUID = homeCon.dev1PressureValueUUID.text.trim();
      String? dev1TemperatureValueUUID = homeCon.dev1TemperatureValueUUID.text.trim();
      String? dev2DetectValueUUID = homeCon.dev2DetectValueUUID.text.trim();
      String? userid = prefs.getString('userid').toString()=="null"?homeCon.userid.text.trim():prefs.getString('userid').toString();
      String? dev1PressureValue = prefs.getString('dev1Pressure').toString()=="null"?'0':prefs.getString('dev1Pressure').toString();
      String? dev1TemperatureValue = prefs.getString('dev1Temperature').toString()=="null"?'0':prefs.getString('dev1Temperature').toString();
      String? dev2PressureValue = prefs.getString('dev2Pressure').toString()=="null"?'0':prefs.getString('dev2Pressure').toString();
      String? dev2TemperatureValue = prefs.getString('dev2Temperature').toString()=="null"?'0':prefs.getString('dev2Temperature').toString();
      String now = DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now().toUtc());
      if(devMainUUID != dev1ServiceUUID){
        toastMsgCon.showDeviceUUIDNotCorrectMsg(device1Name);
      }
      //if eventUUID equal to Settings page device 1 Detect Value UUID (FB & Local)
      if(eventUUID==dev1DetectValueUUID && devMainUUID == dev1ServiceUUID){
        row = {
          'dev_no1': '1',
          'dev_id1': device1Name,
          'datetime1': now,
          'use_status1': useStatus,
          'event_uuid1': eventUUID,
          'dev_main_UUID1': devMainUUID,
          'dev1_Pressure': format(dev1PressureValue), //pressure val dev 1
          'dev1_Temperature' : format(dev1TemperatureValue), //Temperature val dev1
          'dev_no2': '2',
          'dev_id2': device2Name,
          'datetime2': now,
          'use_status2': useStatusDetectDev2,
          'event_uuid2': eventUUID,
          'dev_main_UUID2': devMainUUID2,
          'dev2_Pressure': format(dev2PressureValue), //pressure val dev 2
          'dev2_Temperature': format(dev2TemperatureValue),//Temperature val dev2
        };
        prefs.setString('useStatusDetectDev1',useStatus).toString();
        prefs.setString('devMainUUID1',devMainUUID).toString();
        useStatusDetectDev2 = prefs.getString('useStatusDetectDev2').toString()=="null"?'1':prefs.getString('useStatusDetectDev2').toString();
        devMainUUID2 = prefs.getString('devMainUUID2').toString();
        if(homeCon.isLeader==1){
          insertMasterWorkerLogsToFBDev1(row,userid.trim(),eventUUID,dev1DetectValueUUID,dev2DetectValueUUID,'1',useStatus);
        }
        else{
          insertWorkerStatustLogsToFBDev1(row,userid.trim(),eventUUID,dev1DetectValueUUID,dev2DetectValueUUID,'1',useStatus);
        }
      }
      //if eventUUID equal to Settings page device 1 Real Value UUID (Local)
      else if(eventUUID==dev1RealValueUUID && devMainUUID == dev1ServiceUUID){
        prefs.setString('useStatusRealDev1',useStatus).toString();
        prefs.setString('devMainUUID1',devMainUUID).toString();
        useStatusRealDev2 = prefs.getString('useStatusRealDev2').toString();
        devMainUUID2 = prefs.getString('devMainUUID2').toString();
      }
      //if eventUUID equal to Settings page device 1 Battery Value UUID (Local)
      else if(eventUUID==dev1BatteryValueUUID && devMainUUID == dev1ServiceUUID){
        prefs.setString('useStatusBatteryDev1',useStatus).toString();
        prefs.setString('devMainUUID1',devMainUUID).toString();
        useStatusBatteryDev2 = prefs.getString('useStatusBatteryDev2').toString();
        devMainUUID2 = prefs.getString('devMainUUID2').toString();
      }
      //if eventUUID equal to Settings page device 1 Pressure Value UUID save to detect value (Local)
      else if(eventUUID==dev1PressureValueUUID && devMainUUID == dev1ServiceUUID){
        prefs.setString('dev1Pressure',useStatus).toString();
        useStatusDetectDev1 = prefs.getString('useStatusDetectDev1').toString()=="null"?'1':prefs.getString('useStatusDetectDev1').toString();
        useStatusDetectDev2 = prefs.getString('useStatusDetectDev2').toString()=="null"?'1':prefs.getString('useStatusDetectDev2').toString();
        devMainUUID1 = prefs.getString('devMainUUID1').toString();
        devMainUUID2 = prefs.getString('devMainUUID2').toString();
      }
      //if eventUUID equal to Settings page device 1 Temperature Value UUID save to detect value (Local)
      else if(eventUUID==dev1TemperatureValueUUID && devMainUUID == dev1ServiceUUID){
        prefs.setString('dev1Temperature',useStatus).toString();
        useStatusDetectDev1 = prefs.getString('useStatusDetectDev1').toString()=="null"?'1':prefs.getString('useStatusDetectDev1').toString();
        useStatusDetectDev2 = prefs.getString('useStatusDetectDev2').toString()=="null"?'1':prefs.getString('useStatusDetectDev2').toString();
        devMainUUID1 = prefs.getString('devMainUUID1').toString();
        devMainUUID2 = prefs.getString('devMainUUID2').toString();
      }
    }
    else{
      // Do Nothing on No Internet Connection
    }
  }

  insertLogFBDev2(devName,useStatus,eventUUID,devMainUUID) async {
    if(connectionCon.online.value == true){
      String device1Name =  homeCon.deviceNameLeft.trim();
      String device2Name =  homeCon.deviceNameRight.trim();
      final prefs = await SharedPreferences.getInstance();
      String? dev1DetectValueUUID = homeCon.dev1DetectValueUUID.text.trim();
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

      if(devMainUUID != dev2ServiceUUID){
        toastMsgCon.showDeviceUUIDNotCorrectMsg(device2Name);
      }
      //if eventUUID equal to Settings page device 2 Detect Value UUID (FB & Local)
      if(eventUUID==dev2DetectValueUUID && devMainUUID == dev2ServiceUUID){
        row = {
          'dev_no1': '1',
          'dev_id1': device1Name,
          'datetime1': now,
          'use_status1': useStatusDetectDev1,
          'event_uuid1': eventUUID,
          'dev_main_UUID1': devMainUUID1,
          'dev1_Pressure': format(dev1PressureValue), //pressure val dev 1
          'dev1_Temperature': format(dev1TemperatureValue), //Temperature val dev1
          'dev_no2': '2',
          'dev_id2': device2Name,
          'datetime2': now,
          'use_status2': useStatus,
          'event_uuid2': eventUUID,
          'dev_main_UUID2': devMainUUID,
          'dev2_Pressure': format(dev2PressureValue), //pressure val dev 2
          'dev2_Temperature': format(dev2TemperatureValue),//Temperature val dev2
        };
        prefs.setString('useStatusDetectDev2',useStatus).toString();
        prefs.setString('devMainUUID2',devMainUUID).toString();
        useStatusDetectDev1 = prefs.getString('useStatusDetectDev1').toString()=="null"?'1':prefs.getString('useStatusDetectDev1').toString();
        devMainUUID1 = prefs.getString('devMainUUID1').toString();
        if(homeCon.isLeader==1){
          insertMasterWorkerLogsToFBDev2(row,userid.trim(),eventUUID,dev1DetectValueUUID,dev2DetectValueUUID,'2',useStatus);
        }
        else{
          insertWorkerStatustLogsToFBDev2(row,userid.trim(),eventUUID,dev1DetectValueUUID,dev2DetectValueUUID,'2',useStatus);
        }
      }
      //if eventUUID equal to Settings page device 2 Real Value UUID (Local)
      else if(eventUUID==dev2RealValueUUID && devMainUUID == dev2ServiceUUID){
        prefs.setString('useStatusRealDev2',useStatus).toString();
        prefs.setString('devMainUUID2',devMainUUID).toString();
        useStatusRealDev1 = prefs.getString('useStatusRealDev1').toString();
        devMainUUID1 = prefs.getString('devMainUUID1').toString();
      }
      //if eventUUID equal to Settings page device 2 Battery Value UUID (Local)
      else if(eventUUID==dev2BatteryValueUUID && devMainUUID == dev2ServiceUUID){
        prefs.setString('useStatusBatteryDev2',useStatus).toString();
        prefs.setString('devMainUUID2',devMainUUID).toString();
        useStatusBatteryDev1 = prefs.getString('useStatusBatteryDev1').toString();
        devMainUUID1 = prefs.getString('devMainUUID1').toString();
      }
      //if eventUUID equal to Settings page device 2 Pressure Value UUID save to detect value database (Local)
      else if(eventUUID==dev2PressureValueUUID && devMainUUID == dev2ServiceUUID){
        prefs.setString('dev2Pressure',useStatus).toString();
        useStatusDetectDev1 = prefs.getString('useStatusDetectDev1').toString()=="null"?'1':prefs.getString('useStatusDetectDev1').toString();
        useStatusDetectDev2 = prefs.getString('useStatusDetectDev2').toString()=="null"?'1':prefs.getString('useStatusDetectDev2').toString();
        devMainUUID1 = prefs.getString('devMainUUID1').toString();
        devMainUUID2 = prefs.getString('devMainUUID2').toString();
      }
      //if eventUUID equal to Settings page device 2 Temperature Value UUID save to detect value database (Local)
      else if(eventUUID==dev2TemperatureValueUUID && devMainUUID == dev2ServiceUUID){
        prefs.setString('dev2Temperature',useStatus).toString();
        useStatusDetectDev1 = prefs.getString('useStatusDetectDev1').toString()=="null"?'1':prefs.getString('useStatusDetectDev1').toString();
        useStatusDetectDev2 = prefs.getString('useStatusDetectDev2').toString()=="null"?'1':prefs.getString('useStatusDetectDev2').toString();
        devMainUUID1 = prefs.getString('devMainUUID1').toString();
        devMainUUID2 = prefs.getString('devMainUUID2').toString();
      }
    }
    else{
      // Do Nothing on No Internet Connection
    }
  }

  //WORKER DATA TO FIREBASE Dev 1 And Dev 2

  insertWorkerStatustLogsToFBDev1(row,userId,eventUUID,dev1DetectValueUUID,dev2DetectValueUUID,devNo,useStatus)async{
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
        FirestoreServices.updateWorkerStatusLatestDev1( 
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

  insertWorkerStatustLogsToFBDev2(row,userId,eventUUID,dev1DetectValueUUID,dev2DetectValueUUID,devNo,useStatus)async{
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
        FirestoreServices.updateWorkerStatusLatestDev2( 
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
        FirestoreServices.addWorkerStatusLatestDev2( 
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

  //----------------------------------------------

  //MASTER WORKER DATA TO FIREBASE Dev 1 And Dev 2

  insertMasterWorkerLogsToFBDev1(row,userId,eventUUID,dev1DetectValueUUID,dev2DetectValueUUID,devNo,useStatus)async{
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

  insertMasterWorkerLogsToFBDev2(row,userId,eventUUID,dev1DetectValueUUID,dev2DetectValueUUID,devNo,useStatus)async{
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

  //-----------------------------------------------

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
}
