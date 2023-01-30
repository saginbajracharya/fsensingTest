import 'package:blue/controllers/home_controller.dart';
import 'package:blue/helper/current_time.dart';
import 'package:blue/model/master_worker_model.dart';
import 'package:blue/model/worker_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blue/common/constants.dart' as constants;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

//Worker Status History
final String dbCollectionHistory = constants.firebaseCollection['history'];
final CollectionReference historyCollection = firestore.collection(dbCollectionHistory);

//Worker Status Latest
final String dbCollectionLatest = constants.firebaseCollection['latest'];
final CollectionReference latestCollection = firestore.collection(dbCollectionLatest);

//Device Status History
final String dbCollectionDeviceStatusHistory = constants.firebaseCollection['deviceStatusHistory'];
final CollectionReference deviceStatusCollectionHistory = firestore.collection(dbCollectionDeviceStatusHistory);

//Device Status Latest
final String dbCollectionDeviceStatusLatest = constants.firebaseCollection['deviceStatusLatest'];
final CollectionReference deviceStatusCollectionLatest = firestore.collection(dbCollectionDeviceStatusLatest);

//Master Worker
final String dbCollectionMasterWorker = constants.firebaseCollection['masterWorker'];
final CollectionReference masterWorkerCollection = firestore.collection(dbCollectionMasterWorker);

//Alert Log
final String dbCollectionAlertLog = constants.firebaseCollection['alertLog'];
final CollectionReference alertLogCollection = firestore.collection(dbCollectionAlertLog);

class FirestoreServices {

  // Device Status History / Latest

  static addDeviceStatusHistory({
    required int companyId,
    required int groupId,
    required int siteId,
    required String workerCode,
    required int workerId,
    required String workerName,
    required String workerProfileImageUrl,
    required String deviceNameLeft,
    required String deviceNameRight,
    required String deviceStatusLeft,
    required String deviceStatusRight,
  }){
    DocumentReference documentReferencer = deviceStatusCollectionHistory.doc();
    Map<String, dynamic> data = <String, dynamic>{
      "company_id": companyId,
      "group_id": groupId,
      "site_id": siteId,
      "worker_code": workerCode,
      "worker_id": workerId,
      "worker_name": workerName,
      "worker_profile_image_url": workerProfileImageUrl,
      "device_name_left" : deviceNameLeft,
      "device_name_right" : deviceNameRight,
      "device_status_left" : deviceStatusLeft,
      "device_status_right" : deviceStatusRight,
      "created_at": DateTime.now().toUtc().millisecondsSinceEpoch,
      "updated_at": '',
    };
    documentReferencer
    .set(data)
    .whenComplete(() {
      if (kDebugMode) {
        print('FB Insert Complete addDeviceStatusHistory Local Time/NEPAL Time====>' +DateTime.now().toString());
        print('FB Insert Complete addDeviceStatusHistory JAPAN Time====>' +getCurrentTimeofJapan());
      }
    })
    .catchError((e) {});
  }

  static updateDeviceStatusLatest({
    required int companyId,
    required int groupId,
    required int siteId,
    required String workerCode,
    required int workerId,
    required String workerName,
    required String workerProfileImageUrl,
    required String deviceNameLeft,
    required String deviceNameRight,
    required String deviceStatusLeft,
    required String deviceStatusRight,
  })  {
    DocumentReference documentReferencer = deviceStatusCollectionLatest.doc(workerCode);
    Map<String, dynamic> data = <String, dynamic>{
      "company_id": companyId,
      "group_id": groupId,
      "site_id": siteId,
      "worker_code": workerCode,
      "worker_id": workerId,
      "worker_name": workerName,
      "worker_profile_image_url": workerProfileImageUrl,
      "device_name_left" : deviceNameLeft,
      "device_name_right" : deviceNameRight,
      "device_status_left" : deviceStatusLeft,
      "device_status_right" : deviceStatusRight,
      "updated_at": DateTime.now().toUtc().millisecondsSinceEpoch,
    };
    documentReferencer
    .update(data)
    .whenComplete(() {
      if (kDebugMode) {
        print('FB Insert Complete updateDeviceStatusLatest Local Time/NEPAL Time====>' +DateTime.now().toString());
        print('FB Insert Complete updateDeviceStatusLatest JAPAN Time====>' +getCurrentTimeofJapan());
      }
    })
    .catchError((e) {});
  }

  static addDeviceStatusLatest({
    required int companyId,
    required int groupId,
    required int siteId,
    required String workerCode,
    required int workerId,
    required String workerName,
    required String workerProfileImageUrl,
    required String deviceNameLeft,
    required String deviceNameRight,
    required String deviceStatusLeft,
    required String deviceStatusRight,
  }){
    DocumentReference documentReferencer = deviceStatusCollectionLatest.doc(workerCode);
    Map<String, dynamic> data = <String, dynamic>{
      "company_id": companyId,
      "group_id": groupId,
      "site_id": siteId,
      "worker_code": workerCode,
      "worker_id": workerId,
      "worker_name": workerName,
      "worker_profile_image_url": workerProfileImageUrl,
      "device_name_left" : deviceNameLeft,
      "device_name_right" : deviceNameRight,
      "device_status_left" : deviceStatusLeft,
      "device_status_right" : deviceStatusRight,
      "created_at": DateTime.now().toUtc().millisecondsSinceEpoch,
      "updated_at": '',
    };
    documentReferencer
    .set(data)
    .whenComplete(() {
      if (kDebugMode) {
        print('FB Insert Complete addDeviceStatusLatest Local Time/NEPAL Time====>' +DateTime.now().toString());
        print('FB Insert Complete addDeviceStatusLatest JAPAN Time====>' +getCurrentTimeofJapan());
      }
    })
    .catchError((e) {});
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  //Worker Status History / Latest

  static addWorkerStatusHistory({
    required int companyId,
    required int groupId,
    required int leftBatteryValue,
    // required String leftTime,
    required String leftDeviceId,
    required String leftFailureValue,
    required String useLeftStatus,
    required String pressureValue,
    required int rightBatteryValue,
    // required String rightTime,
    required String rightDeviceId,
    required String rightFailureValue,
    required String useRightStatus,
    required int siteId,
    required String temperatureValue,
    required String workerCode,
    required int workerId,
    required String workerName,
    required String workerProfileImageUrl,
    required String workerStatus,
    required int startTime,

    required bool startHeightCalculation,
    required String masterPressureValue,
    required dynamic baseUserPressureValue,
    required dynamic baseMasterPressureValue,
    required dynamic actualHeightM,
    required dynamic displayHeightM,
    required dynamic heightAlertClass,
  }){
    DocumentReference documentReferencer = historyCollection.doc();
    Map<String,dynamic> data = <String,dynamic>{
      "company_id": companyId,
      "created_at": DateTime.now().toUtc().millisecondsSinceEpoch,
      "deleted_at": '',
      "group_id": groupId,
      "left_battery_value": leftBatteryValue,
      "left_datetime": DateTime.now().toUtc().millisecondsSinceEpoch,
      "left_device_id": leftDeviceId,
      "left_failure_value": leftFailureValue,
      "left_useleft_status": useLeftStatus,
      "pressure_value": pressureValue,
      "right_battery_value": rightBatteryValue,
      "right_datetime": DateTime.now().toUtc().millisecondsSinceEpoch,
      "right_device_id": rightDeviceId,
      "right_failure_value": rightFailureValue,
      "right_useright_status": useRightStatus,
      "site_id": siteId,
      "temperature_value": temperatureValue,
      "updated_at": DateTime.now().toUtc().millisecondsSinceEpoch,
      "worker_code": workerCode,
      "worker_id": workerId,
      "worker_name": workerName,
      "worker_profile_image_url": workerProfileImageUrl,
      "worker_status": workerStatus,
      "start_time" : startTime, 
      
      "start_height_calculation":startHeightCalculation,
      "master_pressure_value":masterPressureValue,
      "base_user_pressure_value":baseUserPressureValue,
      "base_master_pressure_value":baseMasterPressureValue,
      "actual_height_m":actualHeightM,
      "display_height_m":displayHeightM,
      "height_alert_class":heightAlertClass,
    };
    documentReferencer
    .set(data)
    .whenComplete(() {
      if (kDebugMode) {
        print('FB Insert Complete addWorkerStatusHistory Local Time/NEPAL Time====>' +DateTime.now().toString());
        print('FB Insert Complete addWorkerStatusHistory JAPAN Time====>' +getCurrentTimeofJapan());
      }
    })
    .catchError((e) {
      if (kDebugMode) {
        print(e);
      }
    });
  }

  static updateWorkerStatusLatest({
    required String devNo,
    required int companyId,
    required int groupId,
    required int leftBatteryValue,
    // required String leftTime,
    required String leftDeviceId,
    required String leftFailureValue,
    required String useLeftStatus,
    required String pressureValue,
    required int rightBatteryValue,
    // required String rightTime,
    required String rightDeviceId,
    required String rightFailureValue,
    required String useRightStatus,
    required int siteId,
    required String temperatureValue,
    required String workerCode,
    required int workerId,
    required String workerName,
    required String workerProfileImageUrl,
    required String workerStatus,
    required int startTime,

    // required bool startHeightCalculation,
    required String masterPressureValue,
    dynamic baseMasterPressureValue,
    dynamic baseUserPressureValue,
    required dynamic actualHeightM,
    required dynamic displayHeightM,
    required dynamic heightAlertClass,
    required bool alertFlg,
  }){
    DocumentReference documentReferencer = latestCollection.doc(workerCode);
    Map<String, dynamic> data = <String, dynamic>{};
    if(devNo=='1'){
      data = <String, dynamic>{
        "company_id": companyId,
        // "created_at": DateTime.now().toUtc().millisecondsSinceEpoch,
        // "deleted_at": DateTime.now(),
        "group_id": groupId,
        "left_battery_value": leftBatteryValue,
        "left_datetime": DateTime.now().toUtc().millisecondsSinceEpoch,
        "left_device_id": leftDeviceId,
        "left_failure_value": leftFailureValue,
        "left_useleft_status": useLeftStatus,
        "pressure_value": pressureValue,
        // "right_battery_value": rightBatteryValue,
        // "right_datetime": DateTime.now().toUtc().millisecondsSinceEpoch,
        "right_device_id": rightDeviceId,
        // "right_failure_value": rightFailureValue,
        // "right_useright_status": useRightStatus.toString(),
        "site_id": siteId,
        "temperature_value": temperatureValue,
        "updated_at": DateTime.now().toUtc().millisecondsSinceEpoch,
        "worker_code": workerCode,
        "worker_id": workerId,
        "worker_name": workerName,
        "worker_profile_image_url": workerProfileImageUrl,
        "worker_status": workerStatus,
        "start_time" : startTime,
        // "start_height_calculation":startHeightCalculation,
        "master_pressure_value":masterPressureValue,
        // "base_user_pressure_value":baseUserPressureValue,
        // "base_master_pressure_value":baseMasterPressureValue,
        "actual_height_m":actualHeightM,
        "display_height_m":displayHeightM,
        "height_alert_class":heightAlertClass,
        "alert_flg":alertFlg,
      };
    }
    else if(devNo=='2'){
      data = <String, dynamic>{
        "company_id": companyId,
        // "created_at": DateTime.now().toUtc().millisecondsSinceEpoch,
        // "deleted_at": DateTime.now(),
        "group_id": groupId,
        // "left_battery_value": leftBatteryValue,
        // "left_datetime": DateTime.now().toUtc().millisecondsSinceEpoch,
        "left_device_id": leftDeviceId,
        // "left_failure_value": leftFailureValue,
        // "left_useleft_status": useLeftStatus,
        "pressure_value": pressureValue,
        "right_battery_value": rightBatteryValue,
        "right_datetime": DateTime.now().toUtc().millisecondsSinceEpoch,
        "right_device_id": rightDeviceId,
        "right_failure_value": rightFailureValue,
        "right_useright_status": useRightStatus.toString(),
        "site_id": siteId,
        "temperature_value": temperatureValue,
        "updated_at": DateTime.now().toUtc().millisecondsSinceEpoch,
        "worker_code": workerCode,
        "worker_id": workerId,
        "worker_name": workerName,
        "worker_profile_image_url": workerProfileImageUrl,
        "worker_status": workerStatus,
        "start_time" : startTime,

        // "start_height_calculation":startHeightCalculation,
        "master_pressure_value":masterPressureValue,
        // "base_user_pressure_value":baseUserPressureValue,
        // "base_master_pressure_value":baseMasterPressureValue,
        "actual_height_m":actualHeightM,
        "display_height_m":displayHeightM,
        "height_alert_class":heightAlertClass,
        "alert_flg":alertFlg,
      };
    }
    documentReferencer
    .update(data)
    .whenComplete(() {
      if (kDebugMode) {
        print('FB Insert Complete updateWorkerStatusLatest Local Time/NEPAL Time====>' +DateTime.now().toString());
        print('FB Insert Complete updateWorkerStatusLatest JAPAN Time====>' +getCurrentTimeofJapan());
      }
    })
    .catchError((e) {});
  }

  static addWorkerStatusLatest({
    required int companyId,
    required int groupId,
    required int leftBatteryValue,
    required String leftTime,
    required String leftDeviceId,
    required String leftFailureValue,
    required String useLeftStatus,
    required String pressureValue,
    required int rightBatteryValue,
    required String rightTime,
    required String rightDeviceId,
    required String rightFailureValue,
    required String useRightStatus,
    required int siteId,
    required String temperatureValue,
    required String workerCode,
    required int workerId,
    required String workerName,
    required String workerProfileImageUrl,
    required String workerStatus,
    required int startTime,

    required bool startHeightCalculation,
    required String masterPressureValue,
    required dynamic baseMasterPressureValue,
    required dynamic baseUserPressureValue,
    required dynamic actualHeightM,
    required dynamic displayHeightM,
    required dynamic heightAlertClass,
    required bool alertFlg,
  }){
    DocumentReference documentReferencer = latestCollection.doc(workerCode);
    Map<String, dynamic> data = <String, dynamic>{
      "company_id": companyId,
      "created_at": DateTime.now().toUtc().millisecondsSinceEpoch,
      "deleted_at": '',
      "group_id": groupId,
      "left_battery_value": leftBatteryValue,
      "left_datetime": DateTime.now().toUtc().millisecondsSinceEpoch,
      "left_device_id": leftDeviceId,
      "left_failure_value": leftFailureValue,
      "left_useleft_status": useLeftStatus,
      "pressure_value": pressureValue,
      "right_battery_value": rightBatteryValue,
      "right_datetime": DateTime.now().toUtc().millisecondsSinceEpoch,
      "right_device_id": rightDeviceId,
      "right_failure_value": rightFailureValue,
      "right_useright_status": useRightStatus,
      "site_id": siteId,
      "temperature_value": temperatureValue,
      "updated_at": DateTime.now().toUtc().millisecondsSinceEpoch,
      "worker_code": workerCode,
      "worker_id": workerId,
      "worker_name": workerName,
      "worker_profile_image_url": workerProfileImageUrl,
      "worker_status": workerStatus,
      "start_time" : startTime, 

      "start_height_calculation":startHeightCalculation,
      "master_pressure_value":masterPressureValue,
      "base_user_pressure_value":null,
      "base_master_pressure_value":null,
      "actual_height_m":actualHeightM,
      "display_height_m":displayHeightM,
      "height_alert_class":heightAlertClass,

      "alert_flg":alertFlg,
    };
    documentReferencer
    .set(data)
    .whenComplete(() {
      // final prefs = await SharedPreferences.getInstance();
      // prefs.setString('latestDocId', documentReferencer.id);
      if (kDebugMode) {
        print('FB Insert Complete MasterWorkerLatest Local Time/NEPAL Time====>' +DateTime.now().toString());
        print('FB Insert Complete MasterWorkerLatest JAPAN Time====>' +getCurrentTimeofJapan());
      }
    })
    .catchError((e) {});
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  ///MASTER WORKER COLLECTION
  
  static addMasterWorkerData({
    required int companyId,
    required int groupId,
    required int siteId,
    required String workerCode,
    required int workerId,
    required String workerName,
    required String workerProfileImageUrl,
    required String status,
    required String pressureValue,
    required String averagePressureValue,
  }){
    DocumentReference documentReferencer = masterWorkerCollection.doc('$companyId-$groupId-$siteId');
    Map<String, dynamic> data = <String, dynamic>{
      "id":workerId,
      "company_id": companyId,
      "group_id": groupId,
      "site_id": siteId,
      "code": workerCode,
      "name": workerName,
      "profile_image_url": workerProfileImageUrl,
      "status" : status,
      "pressure_value" : pressureValue,
      "average_pressure_value": averagePressureValue
    };
    documentReferencer
    .set(data)
    .whenComplete(() {
      if (kDebugMode) {
        print('FB Insert Complete addMasterWorkerData Local Time/NEPAL Time====>' +DateTime.now().toString());
        print('FB Insert Complete addMasterWorkerData JAPAN Time====>' +getCurrentTimeofJapan());
      }
    })
    .catchError((e) {});
  }

  static updateMasterWorkerData({
    required int companyId,
    required int groupId,
    required int siteId,
    required String workerCode,
    required int workerId,
    required String workerName,
    required String workerProfileImageUrl,
    required String status,
    required String pressureValue,
    required String averagePressureValue,
  }){
    DocumentReference documentReferencer = masterWorkerCollection.doc('$companyId-$groupId-$siteId');
    Map<String, dynamic> data = <String, dynamic>{
      "id":workerId,
      "company_id": companyId,
      "group_id": groupId,
      "site_id": siteId,
      "code": workerCode,
      "name": workerName,
      "profile_image_url": workerProfileImageUrl,
      "status" : status,
      "pressure_value" : pressureValue,
      "average_pressure_value": averagePressureValue
    };
    documentReferencer
    .update(data)
    .whenComplete(() {
      if (kDebugMode) {
        print('FB Insert Complete MasterWorkerHistory Local Time/NEPAL Time====>' +DateTime.now().toString());
        print('FB Insert Complete MasterWorkerHistory JAPAN Time====>' +getCurrentTimeofJapan());
      }
    })
    .catchError((e) {});
  }

  static Stream<MasterWorker>getMasterWorkerData(docId) {
    return 
    FirebaseFirestore.instance.collection(dbCollectionMasterWorker)
    .doc(docId)
    .snapshots()
    .map((masterWorker){
      MasterWorker masterWorkerFb = MasterWorker();
      masterWorkerFb = MasterWorker.fromDocumentSnapshot(doc:masterWorker);
      final HomeController homeCon = Get.find();
      homeCon.currentMasterAverageValue.value=masterWorkerFb.averagePressureValue!;
      return masterWorkerFb;
    });
  }

  static Stream<NormalWorker>getWorkerStatusLatestData(docId) {
    return 
    FirebaseFirestore.instance.collection(dbCollectionLatest)
    .doc(docId)
    .snapshots()
    .map((worker){
      NormalWorker workerFb = NormalWorker();
      workerFb = NormalWorker.fromDocumentSnapshot(doc:worker);
      final HomeController homeCon = Get.find();
      homeCon.baseMasterValue = workerFb.masterPressureValue;
      homeCon.baseUserValue = workerFb.baseUserPressureValue;
      return workerFb;
    });
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  //Find Latest DocID for Collections :-
  //device_status_latest
  //master_work
  //worker_status_latest

  static Future<bool> checkDeviceDocExist(String docId) async {
    // Get reference to Firestore collection
    var collectionRef = FirebaseFirestore.instance.collection(dbCollectionDeviceStatusLatest);
    var doc = await collectionRef.doc(docId).get();
    return doc.exists;
  }
  
  static Future<bool> checkMasterWorkerDocExist(String docId) async {
    // Get reference to Firestore collection
    var collectionRef = FirebaseFirestore.instance.collection(dbCollectionMasterWorker);
    var doc = await collectionRef.doc(docId).get();
    return doc.exists;
  }

  static Future<bool> checkWorkerDocExist(String docId) async {
    // Get reference to Firestore collection
    var collectionRef = FirebaseFirestore.instance.collection(dbCollectionLatest);
    var doc = await collectionRef.doc(docId).get();
    return doc.exists;
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///
  // Alert Log

  static addAlertLog({
    required String todayDate,
    required String alertDate,
    required String alertTime,
    required String alertType,
    required String companyId,
    required String groupId,
    required String siteId,
    required String staffCode,
    required String workerProfileImageUrl,
    required String workerName
  }){
    DocumentReference documentReferencer = alertLogCollection.doc('$companyId-$groupId-$siteId').collection(todayDate).doc();
    Map<String, dynamic> data = <String, dynamic>{
      "alert_date" : alertDate,
      "alert_time" : alertTime,
      "alert_type" : alertType,
      "company_id": companyId,
      "group_id": groupId,
      "site_id": siteId,
      "staff_code": staffCode,
      "created_at": DateTime.now().toUtc().millisecondsSinceEpoch,
      "worker_profile_image_url":workerProfileImageUrl,
      "worker_name":workerName,
    };
    documentReferencer
    .set(data)
    .whenComplete((){
      if (kDebugMode) {
        print('FB Insert Complete Add Alert Log Local Time/NEPAL Time====>' +DateTime.now().toString());
        print('FB Insert Complete Add Alert Log JAPAN Time====>' +getCurrentTimeofJapan());
      }
    })
    .catchError((e) {});
  }

  static updateWorkerStatusLatestAlertFlgOnly({
    required String workerCode,
    required bool alertFlg,
  }){
    DocumentReference documentReferencer = latestCollection.doc(workerCode);
    Map<String, dynamic> data = <String, dynamic>{};
    data = <String, dynamic>{
      "alert_flg":alertFlg,
    };
    documentReferencer
    .update(data)
    .whenComplete(() {
      if (kDebugMode) {
        print('FB Insert Complete updateWorkerStatusLatestAlertFlgOnly Local Time/NEPAL Time====>' +DateTime.now().toString());
        print('FB Insert Complete updateWorkerStatusLatestAlertFlgOnly JAPAN Time====>' +getCurrentTimeofJapan());
      }
    })
    .catchError((e) {});
  }

  //Transaction Test
  //Write updateWorkerStatusLatest
  static updateWorkerStatusLatestTransaction(
    String devNo, //1
    int companyId, //2
    int groupId, //3
    int leftBatteryValue, //4
    String leftDeviceId, //5
    String leftFailureValue, //6
    String pressureValue, //7
    int rightBatteryValue, //8
    String rightDeviceId, //9
    String rightFailureValue, //10
    String useLeftStatus, //11
    String useRightStatus, //12
    String temperatureValue, //13
    String workerCode, //14
    int workerId,//15
    String workerName, //16
    String workerProfileImageUrl,//17
    String workerStatus,//18
    int siteId,//19
    int startTime,//20
    String masterPressureValue,//21
    dynamic baseMasterPressureValue,//22
    dynamic baseUserPressureValue,//23
    dynamic actualHeightM,//24
    dynamic displayHeightM,//25
    dynamic heightAlertClass,//26
    bool alertFlg,//27
  ){
    final docRef = firestore.collection(dbCollectionHistory).doc(workerCode);
    firestore.runTransaction((transaction) async {
      Map<String, dynamic> data = <String, dynamic>{};
      if(devNo=='1'){
        data = <String, dynamic>{
          "company_id": companyId,
          // "created_at": DateTime.now().toUtc().millisecondsSinceEpoch,
          // "deleted_at": DateTime.now(),
          "group_id": groupId,
          "left_battery_value": leftBatteryValue,
          "left_datetime": DateTime.now().toUtc().millisecondsSinceEpoch,
          "left_device_id": leftDeviceId,
          "left_failure_value": leftFailureValue,
          "left_useleft_status": useLeftStatus,
          "pressure_value": pressureValue,
          // "right_battery_value": rightBatteryValue,
          // "right_datetime": DateTime.now().toUtc().millisecondsSinceEpoch,
          "right_device_id": rightDeviceId,
          // "right_failure_value": rightFailureValue,
          // "right_useright_status": useRightStatus.toString(),
          "site_id": siteId,
          "temperature_value": temperatureValue,
          "updated_at": DateTime.now().toUtc().millisecondsSinceEpoch,
          "worker_code": workerCode,
          "worker_id": workerId,
          "worker_name": workerName,
          "worker_profile_image_url": workerProfileImageUrl,
          "worker_status": workerStatus,
          "start_time" : startTime,
          // "start_height_calculation":startHeightCalculation,
          "master_pressure_value":masterPressureValue,
          // "base_user_pressure_value":baseUserPressureValue,
          // "base_master_pressure_value":baseMasterPressureValue,
          "actual_height_m":actualHeightM,
          "display_height_m":displayHeightM,
          "height_alert_class":heightAlertClass,
          "alert_flg":alertFlg,
        };
      }
      else if(devNo=='2'){
        data = <String, dynamic>{
          "company_id": companyId,
          // "created_at": DateTime.now().toUtc().millisecondsSinceEpoch,
          // "deleted_at": DateTime.now(),
          "group_id": groupId,
          // "left_battery_value": leftBatteryValue,
          // "left_datetime": DateTime.now().toUtc().millisecondsSinceEpoch,
          "left_device_id": leftDeviceId,
          // "left_failure_value": leftFailureValue,
          // "left_useleft_status": useLeftStatus,
          "pressure_value": pressureValue,
          "right_battery_value": rightBatteryValue,
          "right_datetime": DateTime.now().toUtc().millisecondsSinceEpoch,
          "right_device_id": rightDeviceId,
          "right_failure_value": rightFailureValue,
          "right_useright_status": useRightStatus.toString(),
          "site_id": siteId,
          "temperature_value": temperatureValue,
          "updated_at": DateTime.now().toUtc().millisecondsSinceEpoch,
          "worker_code": workerCode,
          "worker_id": workerId,
          "worker_name": workerName,
          "worker_profile_image_url": workerProfileImageUrl,
          "worker_status": workerStatus,
          "start_time" : startTime,

          // "start_height_calculation":startHeightCalculation,
          "master_pressure_value":masterPressureValue,
          // "base_user_pressure_value":baseUserPressureValue,
          // "base_master_pressure_value":baseMasterPressureValue,
          "actual_height_m":actualHeightM,
          "display_height_m":displayHeightM,
          "height_alert_class":heightAlertClass,
          "alert_flg":alertFlg,
        };
      }
      transaction.update(docRef,data);
    }).then(
      (value) {
        if (kDebugMode) {
          print("DocumentSnapshot successfully updated!");
        }
      },
      onError: (e) {
        if (kDebugMode) {
          print("Error updating document $e");
        }
      }
    );
  }
}
