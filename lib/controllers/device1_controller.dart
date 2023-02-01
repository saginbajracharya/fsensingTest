import 'dart:async';
import 'dart:io';
import 'package:blue/controllers/device2_controller.dart';
import 'package:blue/controllers/home_controller.dart';
import 'package:blue/controllers/log_controller.dart';
import 'package:blue/controllers/toast_message_controller.dart';
import 'package:blue/helper/current_time.dart';
import 'package:blue/model/connected_item.dart';
import 'package:blue/model/log_item.dart';
import 'package:blue/model/service_list_item.dart';
import 'package:blue/services/firestore_services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_elves/flutter_blue_elves.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class Device1Controller extends GetxController {
  
  final ToastMessageController toastMsgCon = Get.put(ToastMessageController());
  final HomeController homeCon = Get.put(HomeController());
  final LogController logCon = Get.put(LogController());

  final TextEditingController device1TextController = TextEditingController();

  //Bluetooth Variables
  List<AndroidBluetoothLack> blueLack = [];
  IosBluetoothState iosBlueState = IosBluetoothState.unKnown;
  List<HideConnectedDevice> hideConnectedList = [];
  List<ScanResult> scanResultList = [];
  final List<ConnectedItem> connectedList = [];

  // device 1
  int mtu = 0;
  StreamSubscription<BleService>? serviceDiscoveryStream;
  StreamSubscription<DeviceState>? stateStream;
  StreamSubscription<DeviceSignalResult>? deviceSignalResultStream;
  Rx<DeviceState>? deviceState1= DeviceState.disconnected.obs;
  Device? connectedDevice;
  final List<LogItem> logs1 = [];
  final List<ServiceListItem> serviceInfos1 = [];

  // Created variables
  dynamic devmainUUID1;
  RxBool isScaningDev1 = false.obs;
  Timer? reconnectTimer;
  bool reconnectingDev1=false;
  var i = 0;

  @override
  void dispose() {
    disposeCrontrolDevice();
    super.dispose();
  }

  //Dispose After Done
  void disposeCrontrolDevice() {
    if(connectedDevice!=null){
      connectedDevice!.disConnect();
      connectedDevice!.destroy();
    }
    if(serviceDiscoveryStream!=null){
      serviceDiscoveryStream!.cancel();
      serviceDiscoveryStream=null;
    }
    if(stateStream!=null){
      stateStream!.cancel();
      stateStream=null;
    }
    if(deviceSignalResultStream!=null){
      deviceSignalResultStream!.cancel();
      deviceSignalResultStream=null;
    }
  }

  //Get Hidden Connections
  void getHideConnectedDevice() {
    FlutterBlueElves.instance.getHideConnectedDevices().then((values) {
      hideConnectedList = values;
    });
  }

  //Scan for available devices and Connect As per Device name in TEXTFORMFIELD  1st scan
  startScan(deviceName,whichdevice,context) {
    isScaningDev1.value = true;
    update();
    dynamic foundDevice;
    getHideConnectedDevice();
    //Check BlueTooth Available/ON in Device1 Before Start Scan
    if ((Platform.isAndroid && blueLack.isEmpty) || (Platform.isIOS && iosBlueState == IosBluetoothState.poweredOn)) {
      scanResultList = [];
      if (kDebugMode) {
        print('DEVICE 1 SCANNING');
      }
      FlutterBlueElves.instance.startScan(5000).listen((event) {
        scanResultList.insert(0, event);
      }).onDone(() async {
        if (kDebugMode) {
          print('Scanning DONE');
        }
        for (var i = 0; i < scanResultList.length; i++) {
          if (kDebugMode) {
            print('Scanning Found Devices');
          }
          if(scanResultList[i].name==deviceName){
            foundDevice = scanResultList[i];
            if (kDebugMode) {
              print('Scanning Found Device1 Set To foundDevice Variable');
            }
          }
        }
        //after scan and search stop circular progress bar
        if (kDebugMode) {
          print('Scanning STOP');
        }
        isScaningDev1.value = false;
        //If Found Device In search result else show not found error msg
        if(foundDevice!=null){
          Device toConnectDevice = foundDevice.connect(connectTimeout:10000);
          connectedList.insert(0,ConnectedItem(
              toConnectDevice,
              foundDevice.macAddress,
              foundDevice.name
            )
          );
          final prefs = await SharedPreferences.getInstance();
          prefs.setInt('startTime',DateTime.now().toUtc().millisecondsSinceEpoch).toString();
          homeCon.start.value = 1;
          connectedDevice = toConnectDevice;
          update();
          // SETDEVICE CONTROL DEVICE 1
          Future.delayed(const Duration(milliseconds: 1000), () {
            setDeviceControlDataDevice1(
              toConnectDevice,
              foundDevice.macAddress,
              foundDevice.name,
              connectedList[connectedList.length-1],
              context,
            );
          });
        }
        //not found device 1 0. on 1st scan
        else{
          //If Single Connected
          //Disconnect device 1
          if(homeCon.scanTimerDev1!=null){
            homeCon.scanTimerDev1!.cancel();
            homeCon.scanTimerDev1=null;
          }
          if(connectedDevice!=null){
            connectedDevice!.disConnect();
          }
          if(reconnectingDev1 == true||homeCon.device1SingleConnected.value == true){
            //Stop device 1 only if single connected
            homeCon.device1SingleConnected.value=false;
          }
          else{
            //Stop both device Connection
            Device2Controller device2Con = Get.find();
            if(homeCon.scanTimerDev2!=null){
              homeCon.scanTimerDev2!.cancel();
              homeCon.scanTimerDev2=null;
            }
            device2Con.isScaningDev2.value = false;
            if(device2Con.reconnectingDev2==true || device2Con.deviceState2!.value==DeviceState.connected){
              homeCon.start.value = 0;
            }
            update();
          }
          i=0;
          toastMsgCon.showDeviceNotFoundMsg(deviceName);
          Vibration.vibrate();
        }
      });
    }
  }

  //Manage Service and Notify listener and log set as per services data recieved for device 1
  setDeviceControlDataDevice1(Device _device, _name,devName,connectedDevice,context){
    mtu = _device.mtu;
    serviceDiscoveryStream = _device.serviceDiscoveryStream.listen((event) {
      if(event.serviceUuid.substring(4, 8)!="1800" && event.serviceUuid.substring(4, 8)!="1801"){
        devmainUUID1 = event.serviceUuid;
        serviceInfos1.add(ServiceListItem(event, false));
        for (var i = 0; i < serviceInfos1[serviceInfos1.length-1].serviceInfo.characteristics.length; i++) {
          connectedDevice.device.setNotify(serviceInfos1[serviceInfos1.length-1].serviceInfo.serviceUuid,serviceInfos1[serviceInfos1.length-1].serviceInfo.characteristics[i].uuid,true).then((value) {
            if (value) {
              if (kDebugMode) {
                print(value);
              }
            }
          });
        }
        if (kDebugMode) {
          print('_serviceInfos =>>>>>>$serviceInfos1');
          print('serviceUuid =>>>>>>${event.serviceUuid}');
        }
      }
    });
    deviceState1!.value = _device.state;
    update();
    //First CONNECT
    if (deviceState1!.value == DeviceState.connected) {
      // addDeviceConnectedLogFbAndLocal();
      if (!_device.isWatchingRssi) _device.startWatchRssi();
      _device.discoveryService();
      //After Connected If ReconnectTimer Dev1 is going on Stop Timer
      if(reconnectTimer!=null){
        reconnectingDev1=false;
        reconnectTimer!.cancel();
        homeCon.start.value=1;
      }
      logCon.stopAlert(homeCon.companyId,homeCon.groupId,homeCon.siteId,homeCon.userid.text);
    }
    //AFTER CONNECTION LISTEN TO CONNECTION CHANGES / EVENTS
    stateStream = _device.stateStream.listen((event) {
      deviceState1!.value = event;
      if (kDebugMode) {
        print('Listining For DeviceState Dev1 Event');
      }
      if (event == DeviceState.connected) {
        addDeviceConnectedLogFbAndLocal();
        if(reconnectTimer!=null && reconnectingDev1==true){
          reconnectingDev1=false;
          reconnectTimer!.cancel();
          homeCon.start.value=1;
          logCon.stopAlert(homeCon.companyId,homeCon.groupId,homeCon.siteId,homeCon.userid.text);
        }
        if (!_device.isWatchingRssi) _device.startWatchRssi();
          mtu = _device.mtu;
          serviceInfos1.clear();
        _device.discoveryService();
      }
      if(event == DeviceState.disconnected){
        i=0;
        if (kDebugMode) {
          print('Device 1 Disconnected During Connected');
        }
        logCon.stopAlert(homeCon.companyId,homeCon.groupId,homeCon.siteId,homeCon.userid.text);
        addDeviceDisconnectedLogFbAndLocal();
        deviceSignalResultStream!.cancel();
        //Reconnection Device 1
        if(homeCon.start.value==1 && deviceState1!.value==DeviceState.disconnected){
          reconnectTimer = Timer.periodic(
            const Duration(seconds: 10), 
            (Timer t) {
              reconnectingDev1=true;
              if(deviceState1!.value==DeviceState.disconnected && homeCon.start.value==1){
                startScan(homeCon.initialYearValueDeviceLeft+homeCon.initialMonthValueDeviceLeft+device1TextController.text.trim(),'device1',context);
              }
              else{
                if(reconnectTimer!=null){
                  reconnectingDev1=false;
                  reconnectTimer!.cancel();
                }
              }
            }
          );
        }
      }
    });
    deviceSignalResultStream = _device.deviceSignalResultStream.listen((event) {
      String? data;
      if (event.data != null && event.data!.isNotEmpty) {
        data = "0x";
        for (int i = 0; i < event.data!.length; i++) {
          String currentStr = event.data![i].toRadixString(16).toUpperCase();
          if (currentStr.length < 2) {
            currentStr = "0" + currentStr;
          }
          data = data! + currentStr;
        }
      }
      if (event.type == DeviceSignalType.characteristicsRead || event.type == DeviceSignalType.unKnown) {
        logs1.insert(0,LogItem(devmainUUID1,event.uuid,(event.isSuccess
          ? "read data success signal and data:"
          : "read data failed signal and data:") + (data ?? "none"),DateTime.now().toString())
        );
        if (kDebugMode) {
          print('Device 1 Event Received characteristicsRead'+getCurrentTimeofJapan());
        }
        saveLogs(_name,devmainUUID1,event.uuid,event.isSuccess?data:'error');
      } else if (event.type == DeviceSignalType.characteristicsWrite) {
        logs1.insert(0,LogItem(devmainUUID1,event.uuid,(event.isSuccess
          ? "write data success signal and data:"
          : "write data success signal and data:") + (data ?? "none"),DateTime.now().toString())
        );
        if (kDebugMode) {
          print('Device 1 Event Received characteristicsWrite'+getCurrentTimeofJapan());
        }
        saveLogs(_name,devmainUUID1,event.uuid,event.isSuccess?data:'error');
      } else if (event.type == DeviceSignalType.characteristicsNotify) {
        logs1.insert(0,LogItem(devmainUUID1,event.uuid, data ?? "none", DateTime.now().toString()));
        if (kDebugMode) {
          print('Device 1 Event Received characteristicsNotify'+getCurrentTimeofJapan());
        }
        saveLogs(_name,devmainUUID1,event.uuid,event.isSuccess?data:'error');
      } else if (event.type == DeviceSignalType.descriptorRead) {
        logs1.insert(0,LogItem(devmainUUID1,event.uuid,(event.isSuccess
          ? "read descriptor data success signal and data:"
          : "read descriptor data failed signal and data:") + (data ?? "none"), DateTime.now().toString())
        );
        if (kDebugMode) {
          print('Device 1 Event Received descriptorRead'+getCurrentTimeofJapan());
        }
        saveLogs(_name,devmainUUID1,event.uuid,event.isSuccess?data:'error');
      }
    });
  }

  //Save device 1 logs with devName,dev1mainUUID ,uuid and data params then to insertLogLoaclAndApi in log Controller where logs are separated as per service uuid to know which data base to save.
  saveLogs(devName,dev1mainUUID,uuid,data) async {
    final prefs = await SharedPreferences.getInstance();
    String? dev1RealValueUUID = prefs.getString('dev1RealValueUUID').toString();
    //uuid from device == settings device 1 real value uuid then dont parse
    Future.delayed(Duration(seconds: i==0?2:0), () {
      if(uuid==dev1RealValueUUID){
        logCon.insertLogFBDev1(devName,data,uuid,dev1mainUUID);
      }
      else{
        var parsedData = int.parse(data).toString();
        logCon.insertLogFBDev1(devName,parsedData,uuid,dev1mainUUID);
      }
      i++;
    });
  }

  stopDevice1Connection(){
    reconnectingDev1=false;
    isScaningDev1.value=false;
    if(reconnectTimer!=null){reconnectTimer!.cancel();}
    if(deviceState1!=null){deviceState1!.value = DeviceState.disconnected;}
    disposeCrontrolDevice();
    logCon.stopAlert(homeCon.companyId,homeCon.groupId,homeCon.siteId,homeCon.userid.text);
    Vibration.vibrate();
    update();
    Device2Controller device2Con = Get.find();
    if(
      device2Con.reconnectingDev2==false
      && device2Con.deviceState2!.value!=DeviceState.connected
    ){
      serviceInfos1.clear();
      hideConnectedList.clear();
      connectedList.clear();
      homeCon.stopSensing();
    }
  }

  //Add Connected Device Log to FireBase Device Status Latest And Device Status History Collection and Local
  addDeviceConnectedLogFbAndLocal()async{
    // AudioController audioCon = Get.find();
    // audioCon.playConnectedAudio();
    HomeController homeCon = Get.find();
    homeCon.deviceLeftConnected = 'Connected';
    toastMsgCon.showDeviceConnectedMsg(homeCon.deviceNameLeft);
    FirestoreServices.addDeviceStatusHistory(
      companyId: homeCon.companyId??0, 
      deviceNameLeft: homeCon.deviceNameLeft, 
      deviceNameRight: homeCon.deviceNameRight, 
      deviceStatusLeft: homeCon.deviceLeftConnected, 
      deviceStatusRight: homeCon.deviceRightConnected, 
      groupId: homeCon.groupId??0, 
      siteId: homeCon.siteId??0, 
      workerCode: homeCon.useridTextController.value.text.trim(), 
      workerId: homeCon.workerId??0, 
      workerName: homeCon.workerName??'', 
      workerProfileImageUrl: homeCon.workerProfileImageUrl??'', 
    );
    //ADD/UPDATE Worker Status Latest
    await FirestoreServices.checkDeviceDocExist(homeCon.useridTextController.value.text.trim()).then((value){
      if(value==true){
        //UPDATE Latest
        FirestoreServices.updateDeviceStatusLatest(
          companyId: homeCon.companyId??0, 
          deviceNameLeft: homeCon.deviceNameLeft, 
          deviceNameRight: homeCon.deviceNameRight, 
          deviceStatusLeft: homeCon.deviceLeftConnected, 
          deviceStatusRight: homeCon.deviceRightConnected, 
          groupId: homeCon.groupId??0, 
          siteId: homeCon.siteId??0, 
          workerCode: homeCon.useridTextController.value.text.trim(), 
          workerId: homeCon.workerId??0, 
          workerName: homeCon.workerName??'', 
          workerProfileImageUrl: homeCon.workerProfileImageUrl??'', 
        );
      }
      else{
        //Add
        FirestoreServices.addDeviceStatusLatest(
          companyId: homeCon.companyId??0, 
          deviceNameLeft: homeCon.deviceNameLeft, 
          deviceNameRight: homeCon.deviceNameRight, 
          deviceStatusLeft: homeCon.deviceLeftConnected, 
          deviceStatusRight: homeCon.deviceRightConnected, 
          groupId: homeCon.groupId??0, 
          siteId: homeCon.siteId??0, 
          workerCode: homeCon.useridTextController.value.text.trim(), 
          workerId: homeCon.workerId??0, 
          workerName: homeCon.workerName??'', 
          workerProfileImageUrl: homeCon.workerProfileImageUrl??'', 
        );
      }
    });
  }

  //Add Disconnected Device Log to FireBase Device Status Latest And Device Status History Collection and Local
  addDeviceDisconnectedLogFbAndLocal()async{
    HomeController homeCon = Get.find();
    toastMsgCon.deviceDisconnectedMsg('L');
    homeCon.deviceLeftConnected = 'Disconnected';
    // device1Connected.value = false;
    deviceState1!.value= DeviceState.disconnected;
    Vibration.vibrate();
    FirestoreServices.addDeviceStatusHistory(
      companyId: homeCon.companyId??0, 
      deviceNameLeft: homeCon.deviceNameLeft, 
      deviceNameRight: homeCon.deviceNameRight, 
      deviceStatusLeft: homeCon.deviceLeftConnected, 
      deviceStatusRight: homeCon.deviceRightConnected, 
      groupId: homeCon.groupId??0, 
      siteId: homeCon.siteId??0, 
      workerCode: homeCon.useridTextController.value.text.trim(), 
      workerId: homeCon.workerId??0, 
      workerName: homeCon.workerName??'', 
      workerProfileImageUrl: homeCon.workerProfileImageUrl??'', 
    );
    //ADD/UPDATE Worker Status Latest
    await FirestoreServices.checkDeviceDocExist(homeCon.useridTextController.value.text.trim()).then((value){
      if(value==true){
        //UPDATE Latest
        FirestoreServices.updateDeviceStatusLatest(
          companyId: homeCon.companyId??0, 
          deviceNameLeft: homeCon.deviceNameLeft, 
          deviceNameRight: homeCon.deviceNameRight, 
          deviceStatusLeft: homeCon.deviceLeftConnected, 
          deviceStatusRight: homeCon.deviceRightConnected, 
          groupId: homeCon.groupId??0, 
          siteId: homeCon.siteId??0, 
          workerCode: homeCon.useridTextController.value.text.trim(), 
          workerId: homeCon.workerId??0, 
          workerName: homeCon.workerName??'', 
          workerProfileImageUrl: homeCon.workerProfileImageUrl??'', 
        );
      }
      else{
        //Add Latest
        FirestoreServices.addDeviceStatusLatest(
          companyId: homeCon.companyId??0, 
          deviceNameLeft: homeCon.deviceNameLeft, 
          deviceNameRight: homeCon.deviceNameRight, 
          deviceStatusLeft: homeCon.deviceLeftConnected, 
          deviceStatusRight: homeCon.deviceRightConnected, 
          groupId: homeCon.groupId??0, 
          siteId: homeCon.siteId??0, 
          workerCode: homeCon.useridTextController.value.text.trim(), 
          workerId: homeCon.workerId??0, 
          workerName: homeCon.workerName??'', 
          workerProfileImageUrl: homeCon.workerProfileImageUrl??'', 
        );
      }
    });
  }
}