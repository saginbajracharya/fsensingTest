import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:blue/controllers/device1_controller.dart';
import 'package:blue/controllers/device2_controller.dart';
import 'package:blue/controllers/log_controller.dart';
import 'package:blue/controllers/toast_message_controller.dart';
import 'package:blue/main.dart';
import 'package:blue/services/apiservices.dart';
import 'package:blue/services/firestore_services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_elves/flutter_blue_elves.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blue/model/sites.dart';
import 'package:vibration/vibration.dart';

class HomeController extends GetxController {
  
  // API SERVICE CLASS // checkCompany // checkOnSubmit // uploadToServer
  final _apiendpoint = ApiEndpointRepo();

  // FOREGROUND SERVICE Controller //
  ReceivePort? _receivePort;

  // APP BAR ADMIN MODE Controller //
  int clickCount = 0;
  bool visible = false;

  // BLUETOOTH GPS Controllers //
  List<AndroidBluetoothLack> blueLack = [];

  // LOGO Contollers //
  var start = 0.obs;

  // SETTING TEXT Controllers //
  final userid = TextEditingController();
  final companyCode = TextEditingController();
  final averageMaxLengthTextController = TextEditingController(); //Average Max length (default 10)
  final alertTimerTextController = TextEditingController(); // Alert Timer
  
  final dev1ServiceUUID = TextEditingController();
  final dev1DetectValueUUID = TextEditingController();
  final dev1RealValueUUID = TextEditingController();
  final dev1BatteryValueUUID = TextEditingController();
  final dev1PressureValueUUID = TextEditingController();
  final dev1TemperatureValueUUID = TextEditingController();
  
  final dev2ServiceUUID = TextEditingController();
  final dev2DetectValueUUID = TextEditingController();
  final dev2RealValueUUID = TextEditingController();
  final dev2BatteryValueUUID = TextEditingController();
  final dev2PressureValueUUID = TextEditingController();
  final dev2TemperatureValueUUID = TextEditingController();

  // HOME FORM Controllers //
  final formKey = GlobalKey<FormState>();
  final companyCodeTextController = TextEditingController().obs;
  final companyPassCodeTextController = TextEditingController().obs;
  final useridTextController = TextEditingController().obs;
  RxBool showDropDownError = false.obs;

  // COMPANY SITE DROPDOWN Controller //
  SiteData initDropDownValue = SiteData(id:0,code: 'hint',siteName: '現場を選択'); 
  List<SiteData> siteList = [
    SiteData(id:0,code: 'hint',siteName: '現場を選択')
  ];

  // HOME DEVICE 1(LEFT) && DEVICE 2(RIGHT) Controllers //
  num startNum = 00;
  NumberFormat formatter = NumberFormat("00");
  // MONTH && YEAR Controllers //
  List month = [];
  String initialMonthValueDeviceLeft = NumberFormat("00").format(DateTime.now().month).toString();
  String initialMonthValueDeviceRight = NumberFormat("00").format(DateTime.now().month).toString();  
  List year = []; 
  String initialYearValueDeviceLeft = DateTime.now().year.toString().substring(2);
  String initialYearValueDeviceRight = DateTime.now().year.toString().substring(2);
  // DEVICE NAME,CONNECTION,STATUS //
  String deviceNameLeft = '';
  String deviceNameRight = '';
  String deviceLeftConnected = 'Disconnected';
  String deviceRightConnected = 'Disconnected';
  RxBool device1SingleConnected = false.obs;
  RxBool device2SingleConnected = false.obs;

  // COMPANY VERIFIED & FORM VERIFIED STATUS Controller //
  RxBool formChecking = false.obs;
  RxBool companyVerifying = false.obs;
  RxBool companyVerified = false.obs;

  // RUNTIME DATA STORAGE FOR CURRENT WORKER Controller //
  int? companyId;
  int? groupId;
  int? siteId;
  int? workerId;
  String? workerName;
  String? workerProfileImageUrl;
  int? isLeader = 0; // 0 = false (NOT LEADER) 1 = true (IS LEADER)
  // C | BM | BU Controls //
  RxString currentMasterAverageValue = '0.00'.obs; //Master worker updating current value
  String baseMasterValueM = ''; //BM start value of Master Worker
  String baseMasterValueU = ''; //BM start value of if Master is User
  dynamic baseMasterValue; //BM start value of if Master is User FB
  dynamic baseUserValue; // BU start value of User/MasterWorker FB

  // LOG SAVE Controller //
  Timer? scanTimerDev1;
  Timer? scanTimerDev2;

  @override
  void onInit() {
    device1SingleConnected.value = false;
    device2SingleConnected.value = false;
    loadSettings();
    loadHomePageData();
    loadWorkerDetail();
    resetSiteSelectionDD();
    addYear();
    addMonth();
    Timer.periodic(
      const Duration(milliseconds: 2000),
      androidGetBlueLack
    );    
    super.onInit();
  }

  Future<bool> startForegroundTask() async {
    // You can save data using the saveData function.
    await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

    ReceivePort? receivePort;
    if (await FlutterForegroundTask.isRunningService) {
      receivePort = (await FlutterForegroundTask.restartService());
    } else {
      receivePort = (await FlutterForegroundTask.startService(
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
      ));
    }

    if (receivePort != null) {
      _receivePort = receivePort;
      _receivePort?.listen((message) {
        if (message is DateTime) {
          if (kDebugMode) {
            print('receive timestamp: $message');
          }
        } else if (message is int) {
          if (kDebugMode) {
            print('receive updateCount: $message');
          }
        }
      });

      return true;
    }

    return false;
  }

  Future<bool> stopForegroundTask() async {
    return await FlutterForegroundTask.stopService();
  }

  loadHomePageData() async {
    final prefs = await SharedPreferences.getInstance();

    //Load Company Code
    String? companyCode = prefs.getString('companyCode').toString();
    companyCodeTextController.value.text = companyCode == "" || companyCode == "null" ? "" : companyCode.toString().trim();

    //Load DropDown Values And PassCode If Stored
    if(companyCode!="" && companyCode!="null"){
      final List<String>? siteListRawJson = prefs.getStringList('siteList');
      if(siteListRawJson!=null){
        if(siteListRawJson.isNotEmpty && companyVerifying.value==false && companyVerified.value == false){
          companyVerified.value = true;
          update();
          for (var i = 0; i < siteListRawJson.length; i++) {
            Map<String, dynamic> site = jsonDecode(siteListRawJson[i]);
            SiteData data = SiteData.fromJson(site);
            if(data.code!="hint"){
              siteList.add(data);
            }
          }
        }
      }
      String? companyPassCode = prefs.getString('companyPassCode').toString();
      if(companyPassCode!="" && companyPassCode!="null"){
        companyPassCodeTextController.value.text = companyPassCode.toString().trim();
      }
    }

    //Load USER CODE
    String? userid = prefs.getString('userid').toString();
    useridTextController.value.text = userid == "" || userid == "null" ? "" : userid.toString().trim();

    String? devLeftYear = prefs.getString('devLeftYear').toString();
    if(devLeftYear!=""&&devLeftYear!="null"){
      initialYearValueDeviceLeft = devLeftYear;
      update();
    }

    String? devRightYear = prefs.getString('devRightYear').toString();
    if(devRightYear!=""&&devRightYear!="null"){
      initialYearValueDeviceRight = devRightYear;
      update();
    }

    String? devLeftMonth = prefs.getString('devLeftMonth').toString();
    if(devLeftMonth!=""&&devLeftMonth!="null"){
      initialMonthValueDeviceLeft = devLeftMonth;
      update();
    }

    String? devRightMonth = prefs.getString('devRightMonth').toString();
    if(devRightMonth!=""&&devRightMonth!="null"){
      initialMonthValueDeviceRight = devRightMonth;
      update();
    }

  }

  loadWorkerDetail() async{
    final prefs = await SharedPreferences.getInstance();
    companyId =prefs.getInt('companyId');
    groupId = prefs.getInt('groupId');
    siteId = prefs.getInt('siteId');
    workerId = prefs.getInt('workerId');
    workerName = prefs.getString('workerName');
    workerProfileImageUrl = prefs.getString('workerProfileImageUrl');
  }

  void androidGetBlueLack(timer) {
    FlutterBlueElves.instance.androidCheckBlueLackWhat().then((values) async {
      blueLack = values;
      if(blueLack.contains(AndroidBluetoothLack.bluetoothFunction)||blueLack.contains(AndroidBluetoothLack.bluetoothPermission)||blueLack.contains(AndroidBluetoothLack.locationPermission)||blueLack.contains(AndroidBluetoothLack.locationFunction)){
        Device1Controller device1Con = Get.find();
        Device2Controller device2Con = Get.find();
        if(device1Con.deviceState1!.value!=DeviceState.disconnected || device2Con.deviceState2!.value!=DeviceState.disconnected){
          stopSensing();
        }
      }
      else{
        if (kDebugMode) {
          print('All Required Permissions .... ok.');
        }
      }
      update();
    });
  }

  // Conrols for Dropdown fields 

  resetSiteSelectionDD(){
    siteList.clear();
    initDropDownValue = SiteData(id:0,code: 'hint',siteName: '現場を選択');  
    siteList.add(initDropDownValue);
  }

  addYear(){
    year.clear();
    for (var i = 20; i <= 30; i++) {
      String increment = formatter.format(startNum+i).toString();
      year.add(
        increment
      );
    }
  }

  addMonth(){
    month.clear();
    for (var i = 1; i <= 12; i++) {
      String increment = formatter.format(startNum+i).toString();
      month.add(
        increment
      );
    }
  }

  //Settings Page Controls

  loadSettings() async {
    // LOAD STORED SETTING DATA //
    final prefs = await SharedPreferences.getInstance();
    String? useridP = prefs.getString('userid').toString();
    String? companyCodeP = prefs.getString('companyCode').toString();
    int? averageMaxLengthP = prefs.getInt('averageMaxLength');
    int? alertTimerP = prefs.getInt('alertTimer');

    String? dev1ServiceUUIDP = prefs.getString('dev1ServiceUUID').toString();
    String? dev1DetectValueUUIDP = prefs.getString('dev1DetectValueUUID').toString();
    String? dev1RealValueUUIDP = prefs.getString('dev1RealValueUUID').toString();
    String? dev1BatteryValueUUIDP = prefs.getString('dev1BatteryValueUUID').toString();
    String? dev1PressureValueUUIDP = prefs.getString('dev1PressureValueUUID').toString();
    String? dev1TemperatureValueUUIDP = prefs.getString('dev1TemperatureValueUUID').toString();

    String? dev2ServiceUUIDP = prefs.getString('dev2ServiceUUID').toString();
    String? dev2DetectValueUUIDP = prefs.getString('dev2DetectValueUUID').toString();
    String? dev2RealValueUUIDP = prefs.getString('dev2RealValueUUID').toString();
    String? dev2BatteryValueUUIDP = prefs.getString('dev2BatteryValueUUID').toString();
    String? dev2PressureValueUUIDP = prefs.getString('dev2PressureValueUUID').toString();
    String? dev2TemperatureValueUUIDP = prefs.getString('dev2TemperatureValueUUID').toString();

    //SET LOADED DATA TO RESPECTIVE TEXTFIELD //
    userid.text = useridP == "" || useridP == "null" ? "" : useridP.toString().trim();
    companyCode.text = companyCodeP == "" || companyCodeP == "null" ? "" : companyCodeP.toString();

    dev1ServiceUUID.text = dev1ServiceUUIDP == "" || dev1ServiceUUIDP == "null" ? "4fafc201-1fb5-459e-8fcc-c5c9c331914b" : dev1ServiceUUIDP;
    dev1DetectValueUUID.text = dev1DetectValueUUIDP == "" || dev1DetectValueUUIDP == "null" ? "beb5483e-36e1-4688-b7f5-ea07361b26a8" : dev1DetectValueUUIDP;
    dev1RealValueUUID.text = dev1RealValueUUIDP == "" || dev1RealValueUUIDP == "null"? "b7db6729-5dcc-4f4f-9ae2-1fec4db3701a" : dev1RealValueUUIDP;
    dev1BatteryValueUUID.text = dev1BatteryValueUUIDP == "" || dev1BatteryValueUUIDP == "null" ? "cf7890fb-d86b-41d9-80bc-fcb2a7353a8f" : dev1BatteryValueUUIDP;
    dev1PressureValueUUID.text = dev1PressureValueUUIDP == "" || dev1PressureValueUUIDP == "null" ? "7043ea1a-fa87-4074-8981-e0534e996751" : dev1PressureValueUUIDP;
    dev1TemperatureValueUUID.text = dev1TemperatureValueUUIDP == "" || dev1TemperatureValueUUIDP == "null" ? "f51fd052-8334-46e7-b09c-973a3f0568ff" : dev1TemperatureValueUUIDP;

    dev2ServiceUUID.text = dev2ServiceUUIDP == "" || dev2ServiceUUIDP == "null" ? "eb55b93d-7813-4221-ac3b-df7e3f6cadc6" : dev2ServiceUUIDP;
    dev2DetectValueUUID.text = dev2DetectValueUUIDP == "" || dev2DetectValueUUIDP == "null" ? "beb5483e-36e1-4688-b7f5-ea07361b26a8" : dev2DetectValueUUIDP;
    dev2RealValueUUID.text = dev2RealValueUUIDP == "" || dev2RealValueUUIDP == "null" ? "b7db6729-5dcc-4f4f-9ae2-1fec4db3701a" : dev2RealValueUUIDP;
    dev2BatteryValueUUID.text = dev2BatteryValueUUIDP == "" || dev2BatteryValueUUIDP == "null" ? "cf7890fb-d86b-41d9-80bc-fcb2a7353a8f" : dev2BatteryValueUUIDP;
    dev2PressureValueUUID.text = dev2PressureValueUUIDP == "" || dev2PressureValueUUIDP == "null" ? "7043ea1a-fa87-4074-8981-e0534e996751" : dev2PressureValueUUIDP;
    dev2TemperatureValueUUID.text = dev2TemperatureValueUUIDP == "" || dev2TemperatureValueUUIDP == "null" ? "f51fd052-8334-46e7-b09c-973a3f0568ff" : dev2TemperatureValueUUIDP;
    averageMaxLengthTextController.text = averageMaxLengthP == null ? '10' :averageMaxLengthP.toString();
    alertTimerTextController.text = alertTimerP == null ? '0' :alertTimerP.toString();

    // SAVE AGAIN TO SHARED PREFERENCE //
    prefs.setString('dev1ServiceUUID', dev1ServiceUUID.text.trim());
    prefs.setString('dev1DetectValueUUID', dev1DetectValueUUID.text.trim());
    prefs.setString('dev1RealValueUUID', dev1RealValueUUID.text.trim());
    prefs.setString('dev1BatteryValueUUID', dev1BatteryValueUUID.text.trim());
    prefs.setString('dev1PressureValueUUID', dev1PressureValueUUID.text.trim());
    prefs.setString('dev1TemperatureValueUUID', dev1TemperatureValueUUID.text.trim());

    prefs.setString('dev2ServiceUUID', dev2ServiceUUID.text.trim());
    prefs.setString('dev2DetectValueUUID', dev2DetectValueUUID.text.trim());
    prefs.setString('dev2RealValueUUID', dev2RealValueUUID.text.trim());
    prefs.setString('dev2BatteryValueUUID', dev2BatteryValueUUID.text.trim());
    prefs.setString('dev2PressureValueUUID', dev2PressureValueUUID.text.trim());
    prefs.setString('dev2TemperatureValueUUID', dev2TemperatureValueUUID.text.trim());
    prefs.setInt('averageMaxLength', averageMaxLengthTextController.text.trim()==""?10:int.parse(averageMaxLengthTextController.text.trim()));
    prefs.setInt('alertTimer', alertTimerTextController.text.trim()==""?0:int.parse(alertTimerTextController.text.trim()));
    update();
  }

  //Save to local storage/shared preference (Settings Page)
  saveSetings() async {
    final prefs = await SharedPreferences.getInstance();
    // prefs.setString('apiToggle', isSwitched.toString());

    prefs.setString('dev1ServiceUUID', dev1ServiceUUID.text.trim());
    prefs.setString('dev1DetectValueUUID', dev1DetectValueUUID.text.trim());
    prefs.setString('dev1RealValueUUID', dev1RealValueUUID.text.trim());
    prefs.setString('dev1BatteryValueUUID', dev1BatteryValueUUID.text.trim());
    prefs.setString('dev1PressureValueUUID', dev1PressureValueUUID.text.trim());
    prefs.setString('dev1TemperatureValueUUID', dev1TemperatureValueUUID.text.trim());

    prefs.setString('dev2ServiceUUID', dev2ServiceUUID.text.trim());
    prefs.setString('dev2DetectValueUUID', dev2DetectValueUUID.text.trim());
    prefs.setString('dev2RealValueUUID', dev2RealValueUUID.text.trim());
    prefs.setString('dev2BatteryValueUUID', dev2BatteryValueUUID.text.trim());
    prefs.setString('dev2PressureValueUUID', dev2PressureValueUUID.text.trim());
    prefs.setString('dev2TemperatureValueUUID', dev2TemperatureValueUUID.text.trim());

    prefs.setString('companyCode',companyCode.text.trim()).toString();
    prefs.setString('userid', userid.text.trim());
    useridTextController.value.text = userid.text.trim();
    companyCodeTextController.value.text = companyCode.text.trim();
    // apiToggle.text=isSwitched.toString();
    prefs.setInt('averageMaxLength', averageMaxLengthTextController.text==""?10:int.parse(averageMaxLengthTextController.text));
    prefs.setInt('alertTimer', alertTimerTextController.text==""?0:int.parse(alertTimerTextController.text));
    //show msg from toastController
    ToastMessageController toastCon = Get.find();
    toastCon.showSaveSnackBar();
  }

  //Home Page Controls

  //Company Verify Dialog check
  checkCompanyAndValidate(companyCode,passCode,context,triggeredFrom) async {
    final prefs = await SharedPreferences.getInstance();
    var response = await _apiendpoint.checkCompany(companyCode,passCode);
    if (response != null) {
      siteList.clear();
      siteList.add(initDropDownValue);
      for (var i = 0; i < response.length; i++) {
        siteList.add(
          SiteData(id:response[i].id,code:response[i].code,siteName:response[i].siteName)
        );
      }
      List<String> datas = siteList.map((sites) => jsonEncode(sites.toJson())).toList();
      prefs.setStringList('siteList', datas);
      prefs.setString('companyCode',companyCodeTextController.value.text.trim()).toString();
      companyVerifying.value = false;
      companyVerified.value = true;
      update();
      if(triggeredFrom=='fromCompanyVerfyDialog'){
        Navigator.of(context).pop(context);
      }
    }
    else{
      companyVerifying.value = false;
      companyVerified.value = false;
      update();
    }
  }

  //check first if UserId,Dev1Name and Device2Name textField is not empty 
  //if empty show msg else start scan. 
  //Scans through available bluetooth device as per name in device textfield 
  //if found connects and starts the notify services else if not found then scanning stops.
  onStartStopButtonClick(context) async{
    Device1Controller device1Con = Get.find();
    Device2Controller device2Con = Get.find();
    ToastMessageController toastCon = Get.find();
    //CHECK ALL PERMISSIONS
    if(blueLack.contains(AndroidBluetoothLack.bluetoothFunction)||blueLack.contains(AndroidBluetoothLack.bluetoothPermission)||blueLack.contains(AndroidBluetoothLack.locationPermission)||blueLack.contains(AndroidBluetoothLack.locationFunction))
    {
      //All Permission NOT OK
      //Show Permission Required Toast
      toastCon.showRequiredPermissionMsg();
    }
    else{
      //All Permission OK
      //Check Form ALl Value OK OR NOT
      if(companyCodeTextController.value.text.trim()!=""&& initDropDownValue.id!=0&& useridTextController.value.text.trim()!=""&& device1Con.device1TextController.value.text.trim()!=""&& device2Con.device2TextController.value.text.trim()!="")
      {
        // IF Form value is Ok then start/stop
        //START DEVICE SENSING/CONNECTION
        if (formChecking.value==false && device1Con.deviceState1!.value==DeviceState.disconnected && device2Con.deviceState2!.value==DeviceState.disconnected && device1Con.isScaningDev1.value == false && device2Con.isScaningDev2.value == false && device1Con.deviceState1!.value!=DeviceState.connecting && device2Con.deviceState2!.value!=DeviceState.connecting && start.value == 0) 
        {
          checkAndStartSensing(context);
        }
        //STOP DEVICE SENSING/CONNECTION
        else if(
          formChecking.value==false 
          && device1Con.deviceState1!.value!=DeviceState.disconnected 
          || device2Con.deviceState2!.value!=DeviceState.disconnected 
          && device1Con.isScaningDev1.value!=true 
          || device2Con.isScaningDev2.value!=true 
          && device1Con.deviceState1!.value!=DeviceState.connecting 
          || device2Con.deviceState2!.value!=DeviceState.connecting 
          && start.value == 1
        )
        {
          stopSensing();
        }
        else if(formChecking.value==true){
          if(device1Con.isScaningDev1.value==true || device2Con.isScaningDev2.value==true){
            toastCon.showScanningInProgressMsg();
          }
          else if(start.value == 1){
            start.value = 0;
            stopSensing();
            formChecking.value = false;
            update();
          }
        }
      }
      //Form Value Not Ok show Form Error And Toast Msg
      else{
        if(initDropDownValue.id==0){
          showDropDownError.value=true;
        }
        formChecking.value = false;
        device1SingleConnected.value = false;
        device2SingleConnected.value = false;
        update();
        toastCon.showEmptyRequiredFieldMsg();
      }
    }
  }
  
  //Check SUBMIT API RESULT Start
  checkAndStartSensing(context) async{
    Device1Controller device1Con = Get.find();
    Device2Controller device2Con = Get.find();
    ToastMessageController toastCon = Get.find();
    LogController logCon = Get.find();
    device1SingleConnected.value = false;
    device2SingleConnected.value = false;
    formChecking.value = true;
    update();
    toastCon.showSenseStartStopMsg();
    logCon.stopAlert(companyId,groupId,siteId,userid.text);
    logCon.pressureValues.clear();
    deviceNameLeft = initialYearValueDeviceLeft+initialMonthValueDeviceLeft+device1Con.device1TextController.text.trim();
    deviceNameRight = initialYearValueDeviceRight+initialMonthValueDeviceRight+device2Con.device2TextController.text.trim();
    await checkBeforeStartApi(
      companyCodeTextController.value.text.trim(),
      initDropDownValue.id,
      useridTextController.value.text.trim(),
      deviceNameLeft,
      deviceNameRight
    ).then((value)async{
      if(value == true ){
        if (kDebugMode) {
          print('API SUBMIT CHECK ALL DATA OK');
          print('START Device1 Scan');
        }
        device1Con.startScan(deviceNameLeft,'device1',context);
        scanTimerDev1 = Timer.periodic(
          const Duration(seconds: 1), 
          (Timer t) {
            startScanDevice2(context);
          }
        );
        formChecking.value = false;
        update();
      }
    });
  }

  //Connect to device2 if device1 status is connected
  startScanDevice2(context) async {
    Device1Controller device1Con = Get.find();
    Device2Controller device2Con = Get.find();
    device2Con.isScaningDev2.value = true;
    update();
    if(device1Con.deviceState1!.value==DeviceState.connected){
      if (kDebugMode) {
        print('STOP scanTimerDev1 which awaits for Dev1 to Connect And Starts Dev2 Scanning');
      }
      scanTimerDev1?.cancel();
      scanTimerDev1 = null;

      if (kDebugMode) {
        print('START ForeGround TAsk');
      }
      startForegroundTask();
      if (kDebugMode) {
        print('START Device2 Scan');
      }
      loadWorkerDetail();
      device2Con.startScan(deviceNameRight,'device2',context);
    }
  }

  Future<bool> checkBeforeStartApi(companyCode,siteId,staffCode,deviceLeft,deviceRight) async {
    var response = await _apiendpoint.checkOnSubmit(companyCode,siteId,staffCode,deviceLeft,deviceRight);
    if (response != null && response == true) {
      return true;
    }
    else{
      return false;
    }
  }
  
  //Stop
  stopSensing()async{
    Device1Controller device1Con = Get.find();
    Device2Controller device2Con = Get.find();
    LogController logCon = Get.find();
    ToastMessageController toastCon = Get.find();
    formChecking.value = false;
    toastCon.showSenseStartStopMsg();
    logCon.pressureValues.clear();
    deviceLeftConnected = 'Disconnected';
    deviceRightConnected = 'Disconnected';
    loadWorkerDetail();
    device1Con.isScaningDev1.value = false;
    device2Con.isScaningDev2.value = false;
    scanTimerDev1=null;
    scanTimerDev2=null;
    update();
    if(device1Con.reconnectingDev1==true || device1Con.reconnectTimer!=null){
      device1Con.reconnectTimer!.cancel();
      device1Con.reconnectTimer=null;
      device1Con.reconnectingDev1 = false;
      update();
    }
    if(device2Con.reconnectingDev2==true || device2Con.reconnectTimer!=null){
      device2Con.reconnectTimer!.cancel();
      device2Con.reconnectTimer=null;
      device2Con.reconnectingDev2 = false;
      update();
    }
    //Device1 Stop and log
    if(device1Con.deviceState1!.value!=DeviceState.disconnected){
      device1Con.deviceState1!.value = DeviceState.disconnected;
      device1Con.serviceInfos1.clear();
      device1Con.hideConnectedList.clear();
      device1Con.connectedList.clear();
      device1Con.disposeCrontrolDevice();
      logCon.stopAlert(companyId,groupId,siteId,userid.text);
      update();
      FirestoreServices.addDeviceStatusHistory(
        companyId: companyId??0, 
        deviceNameLeft: deviceNameLeft, 
        deviceNameRight: deviceNameRight, 
        deviceStatusLeft: deviceLeftConnected, 
        deviceStatusRight: deviceRightConnected, 
        groupId: groupId??0, 
        siteId: siteId??0, 
        workerCode: useridTextController.value.text.trim(), 
        workerId: workerId??0, 
        workerName: workerName??'', 
        workerProfileImageUrl: workerProfileImageUrl??'', 
      );
      await FirestoreServices.checkDeviceDocExist(useridTextController.value.text.trim()).then((value){
        if(value==true){
          FirestoreServices.updateDeviceStatusLatest(
            companyId: companyId??0, 
            deviceNameLeft: deviceNameLeft, 
            deviceNameRight: deviceNameRight, 
            deviceStatusLeft: deviceLeftConnected, 
            deviceStatusRight: deviceRightConnected, 
            groupId: groupId??0, 
            siteId: siteId??0, 
            workerCode: useridTextController.value.text.trim(), 
            workerId: workerId??0, 
            workerName: workerName??'', 
            workerProfileImageUrl: workerProfileImageUrl??'',
          );
        }
        else{
          FirestoreServices.addDeviceStatusLatest(
            companyId: companyId??0, 
            deviceNameLeft: deviceNameLeft, 
            deviceNameRight: deviceNameRight, 
            deviceStatusLeft: deviceLeftConnected, 
            deviceStatusRight: deviceRightConnected, 
            groupId: groupId??0, 
            siteId: siteId??0, 
            workerCode: useridTextController.value.text.trim(), 
            workerId: workerId??0, 
            workerName: workerName??'', 
            workerProfileImageUrl: workerProfileImageUrl??'',
          );
        }
      });
      Vibration.vibrate();
    } 
    //Device2 Stop and log
    if(device2Con.deviceState2!.value!=DeviceState.disconnected){
      device2Con.deviceState2!.value = DeviceState.disconnected;
      device2Con.serviceInfos2.clear();
      device2Con.hideConnectedList.clear();
      device2Con.connectedList.clear();
      device2Con.disposeCrontrolDevice();
      logCon.stopAlert(companyId,groupId,siteId,userid.text);
      update();
      FirestoreServices.addDeviceStatusHistory(
        companyId: companyId??0, 
        deviceNameLeft: deviceNameLeft, 
        deviceNameRight: deviceNameRight, 
        deviceStatusLeft: deviceLeftConnected, 
        deviceStatusRight: deviceRightConnected, 
        groupId: groupId??0, 
        siteId: siteId??0, 
        workerCode: useridTextController.value.text.trim(), 
        workerId: workerId??0, 
        workerName: workerName??'', 
        workerProfileImageUrl: workerProfileImageUrl??'', 
      );
      await FirestoreServices.checkDeviceDocExist(useridTextController.value.text.trim()).then((value){
        if(value==true){
          FirestoreServices.updateDeviceStatusLatest(
            companyId: companyId??0, 
            deviceNameLeft: deviceNameLeft, 
            deviceNameRight: deviceNameRight, 
            deviceStatusLeft: deviceLeftConnected, 
            deviceStatusRight: deviceRightConnected, 
            groupId: groupId??0, 
            siteId: siteId??0, 
            workerCode: useridTextController.value.text.trim(), 
            workerId: workerId??0, 
            workerName: workerName??"", 
            workerProfileImageUrl: workerProfileImageUrl??"",
          );
        }
        else{
          FirestoreServices.addDeviceStatusLatest(
            companyId: companyId??0, 
            deviceNameLeft: deviceNameLeft, 
            deviceNameRight: deviceNameRight, 
            deviceStatusLeft: deviceLeftConnected, 
            deviceStatusRight: deviceRightConnected, 
            groupId: groupId??0, 
            siteId: siteId??0, 
            workerCode: useridTextController.value.text.trim(), 
            workerId: workerId??0, 
            workerName: workerName??"", 
            workerProfileImageUrl: workerProfileImageUrl??"",
          );
        }
      });
      Vibration.vibrate();
    }
    device1Con.i=0;
    device2Con.i=0;
    start.value = 0;
    logCon.stopAlert(companyId,groupId,siteId,userid.text);
    baseMasterValue = null;
    baseUserValue = null;
    update();
    stopForegroundTask();
  }
}