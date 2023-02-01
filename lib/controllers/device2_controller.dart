import 'dart:async';
import 'dart:io';
import 'package:blue/controllers/device1_controller.dart';
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

class Device2Controller extends GetxController {

  final ToastMessageController toastMsgCon = Get.put(ToastMessageController());
  final HomeController homeCon = Get.put(HomeController());
  final LogController logCon = Get.put(LogController());
  final Device1Controller device1Con = Get.put(Device1Controller());

  final TextEditingController device2TextController = TextEditingController();

  //Bluetooth Variables
  List<AndroidBluetoothLack> blueLack = [];
  IosBluetoothState iosBlueState = IosBluetoothState.unKnown;
  List<HideConnectedDevice> hideConnectedList = [];
  List<ScanResult> scanResultList = [];
  final List<ConnectedItem> connectedList = [];

  //device2
  int mtu = 0;
  StreamSubscription<BleService>? serviceDiscoveryStream;
  StreamSubscription<DeviceState>? stateStream;
  StreamSubscription<DeviceSignalResult>? deviceSignalResultStream;
  Rx<DeviceState>? deviceState2= DeviceState.disconnected.obs;
  Device? connectedDevice;
  List<LogItem> logs2 = [];
  final List<ServiceListItem> serviceInfos2 = [];

  // Created variables
  dynamic devmainUUID2;
  RxBool isScaningDev2 = false.obs;
  Timer? reconnectTimer;
  bool reconnectingDev2 = false;
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

  //Scan for available devices and Connect As per Device name in TEXTFORMFIELD
  startScan(deviceName,whichdevice,context) {
    isScaningDev2.value = true; 
    update();
    dynamic foundDevice;
    getHideConnectedDevice();
    //Check BlueTooth Available/ON in Device2 Before Start Scan
    if ((Platform.isAndroid && blueLack.isEmpty) || (Platform.isIOS && iosBlueState == IosBluetoothState.poweredOn)) {
      scanResultList = [];
      if (kDebugMode) {
        print('DEVICE 2 SCANNING');
      }
      FlutterBlueElves.instance.startScan(5000).listen((event) {
        scanResultList.insert(0, event);
      }).onDone(() async {

        if (kDebugMode) {
          print('Scanning DONE');
        }
        for (var i = 0; i < scanResultList.length; i++) {
          if(scanResultList[i].name==deviceName){
            foundDevice = scanResultList[i];
          }
        }

        //after scan and search stop circular progress bar
        if (kDebugMode) {
          print('Scanning STOP');
        }
        isScaningDev2.value = false;

        //If Found Device In search result else show not found error msg
        if(foundDevice!=null){
          i=0;
          if (kDebugMode) {
            print('DEVICE 2 FOUND');
          }
          Device toConnectDevice = foundDevice.connect(connectTimeout:10000);
          connectedList.insert(0,ConnectedItem(
              toConnectDevice,
              foundDevice.macAddress,
              foundDevice.name
            )
          );
          
          if (kDebugMode) {
            print('Set Start Time for Dev2 in SP prefs.setInt startTime');
          }
          final prefs = await SharedPreferences.getInstance();
          prefs.setInt('startTimeDev2',DateTime.now().toUtc().millisecondsSinceEpoch).toString();

          if (kDebugMode) {
            print('START/STOP BUTTON VALUE TO 1');
          }
          homeCon.start.value = 1;
          connectedDevice = toConnectDevice;
          update();

          // SETDEVICE CONTROL DEVICE 1
          Future.delayed(const Duration(milliseconds: 1000), () {
            setDeviceControlDataDevice2(
              toConnectDevice,
              foundDevice.macAddress,
              foundDevice.name,
              connectedList[connectedList.length-1],
              context
            );
          });
        }
        //not found device 2
        else{
          if (kDebugMode) {
            print('NOT FOUND DEVICE 1');
          }
          Device1Controller dev1Con = Get.find();
          if(homeCon.scanTimerDev2!=null){
            homeCon.scanTimerDev2!.cancel();
            homeCon.scanTimerDev2=null;
          }
          
          //if single connected 
          if(homeCon.device2SingleConnected.value==true){
            homeCon.device2SingleConnected.value=false;
          }

          //If Device 1 Connected or Connecting/Scanning Stop Dev1 only
          if(dev1Con.isScaningDev1.value==true || device1Con.deviceState1!.value==DeviceState.connected || dev1Con.reconnectingDev1==true || reconnectingDev2==true){
            if(connectedDevice!=null){
              connectedDevice!.disConnect();
            }
          }
          //stop completely
          else{
            if(homeCon.scanTimerDev2!=null){
              homeCon.scanTimerDev2!.cancel();
              homeCon.scanTimerDev2=null;
            }
            homeCon.start.value = 0;
            // update();
          }
          toastMsgCon.showDeviceNotFoundMsg(deviceName);
          Vibration.vibrate();
        }
      });
    }
  }
 
  //Manage Service and Notify listener and log set as per services data recieved for device 2
  setDeviceControlDataDevice2(Device _device, _name,devName,connectedDevice,context){
    mtu = _device.mtu;
    serviceDiscoveryStream = _device.serviceDiscoveryStream.listen((event) {
      if(event.serviceUuid.substring(4, 8)!="1800" && event.serviceUuid.substring(4, 8)!="1801"){
        devmainUUID2 = event.serviceUuid;
        serviceInfos2.add(ServiceListItem(event, false));
        for (var i = 0; i < serviceInfos2[serviceInfos2.length-1].serviceInfo.characteristics.length; i++) {
          connectedDevice.device.setNotify(serviceInfos2[serviceInfos2.length-1].serviceInfo.serviceUuid,serviceInfos2[serviceInfos2.length-1].serviceInfo.characteristics[i].uuid,true).then((value) {
            if (value) {
              if (kDebugMode) {
                print(value);
              }
            }
          });
        }
        if (kDebugMode) {
          print('_serviceInfos =>>>>>>$serviceInfos2');
          print('serviceUuid =>>>>>>${event.serviceUuid}');
        }
      }
    });
    deviceState2!.value = _device.state;
    update();

    //First Connect                                                                             
    if (deviceState2!.value == DeviceState.connected) {
      if (kDebugMode) {
        print('INSERT LOG TO LOCAL DB DEVICE 2 CONNECTED AND CONNECTED MSG');
        print('STOP SCANTIMERDEV2');
      }
      // addDeviceConnectedLogFbAndLocal();
      homeCon.scanTimerDev2?.cancel();
      homeCon.scanTimerDev2=null;
      update();

      if (!_device.isWatchingRssi) _device.startWatchRssi();
      _device.discoveryService();
      //After Connected If ReconnectTimer Dev2 is going on Stop Timer
      if(reconnectTimer!=null){
        reconnectingDev2 = false;
        reconnectTimer!.cancel();
        homeCon.start.value=1;
      }
      logCon.stopAlert(homeCon.companyId,homeCon.groupId,homeCon.siteId,homeCon.userid.text);
    }

    //AFTER CONNECTION LISTEN TO CONNECTION CHANGES / EVENTS
    stateStream = _device.stateStream.listen((event) {
      deviceState2!.value = event;
      if (kDebugMode) {
        print('Listining For DeviceState Dev1 Event');
      }
      if (event == DeviceState.connected) {
        if (kDebugMode) {
          print('REConnected');
        }
        addDeviceConnectedLogFbAndLocal();
        if(reconnectTimer!=null){
          reconnectingDev2 = false;
          reconnectTimer!.cancel();
          logCon.stopAlert(homeCon.companyId,homeCon.groupId,homeCon.siteId,homeCon.userid.text);
          homeCon.start.value=1;
        }
        if (!_device.isWatchingRssi) _device.startWatchRssi();
          mtu = _device.mtu;
          serviceInfos2.clear();
        _device.discoveryService();
      }
      if(event == DeviceState.disconnected){
        i=0;
        if (kDebugMode) {
          print('Device 2 Disconnected During Connected');
        }
        logCon.stopAlert(homeCon.companyId,homeCon.groupId,homeCon.siteId,homeCon.userid.text);
        addDeviceDisconnectedLogFbAndLocal();

        //Reconnection Device 2
        if(homeCon.start.value==1 && deviceState2!.value==DeviceState.disconnected){
          reconnectTimer = Timer.periodic(
            const Duration(seconds: 10), 
            (Timer t) {
              reconnectingDev2 = true;
              if(deviceState2!.value==DeviceState.disconnected && homeCon.start.value==1){
                startScan(homeCon.initialYearValueDeviceRight+homeCon.initialMonthValueDeviceRight+device2TextController.text.trim(),'device2',context);
              }
              else{
                if(reconnectTimer!=null){
                  reconnectingDev2=false;
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
        logs2.insert(0,LogItem(devmainUUID2,event.uuid,(event.isSuccess
          ? "read data success signal and data:"
          : "read data failed signal and data:") + (data ?? "none"),DateTime.now().toString())
        );
        if (kDebugMode) {
          print('Device 2 Event Received characteristicsRead'+getCurrentTimeofJapan());
        }
        saveLogs(_name,devmainUUID2,event.uuid,event.isSuccess?data:'error');
      } else if (event.type == DeviceSignalType.characteristicsWrite) {
        logs2.insert(0,LogItem(devmainUUID2,event.uuid,(event.isSuccess
          ? "write data success signal and data:"
          : "write data success signal and data:") + (data ?? "none"),DateTime.now().toString())
        );
        if (kDebugMode) {
          print('Device 2 Event Received characteristicsWrite'+getCurrentTimeofJapan());
        }
        saveLogs(_name,devmainUUID2,event.uuid,event.isSuccess?data:'error');
      } else if (event.type == DeviceSignalType.characteristicsNotify) {
        logs2.insert(0,LogItem(devmainUUID2,event.uuid, data ?? "none", DateTime.now().toString()));
        if (kDebugMode) {
          print('Device 2 Event Received characteristicsNotify'+getCurrentTimeofJapan());
        }
        saveLogs(_name,devmainUUID2,event.uuid,event.isSuccess?data:'error');
      } else if (event.type == DeviceSignalType.descriptorRead) {
        logs2.insert(0,LogItem(devmainUUID2,event.uuid,(event.isSuccess
          ? "read descriptor data success signal and data:"
          : "read descriptor data failed signal and data:") + (data ?? "none"), DateTime.now().toString())
        );
        if (kDebugMode) {
          print('Device 2 Event Received descriptorRead'+getCurrentTimeofJapan());
        }
        saveLogs(_name,devmainUUID2,event.uuid,event.isSuccess?data:'error');
      }
    });
  }

  //Save device 2 logs with devName,dev1mainUUID ,uuid and data params then to insertLogLoaclAndApi in log Controller where logs are separated as per service uuid to know which data base to save.
  saveLogs(devName,dev2mainUUID,uuid,data) async {
    final prefs = await SharedPreferences.getInstance();
    String? dev2RealValueUUID = prefs.getString('dev2RealValueUUID').toString();
    //uuid from device == settings device 1 real value uuid then dont parse
    Future.delayed(Duration(seconds: i==0?2:0), () {
      if(uuid==dev2RealValueUUID){
        logCon.insertLogFBDev2(devName,data,uuid,dev2mainUUID);
      }
      else{
        var parsedData = int.parse(data).toString();
        logCon.insertLogFBDev2(devName,parsedData,uuid,dev2mainUUID);
      }
      i++;
    });
  }

  stopDevice2Connection(){
    reconnectingDev2=false;
    isScaningDev2.value=false;
    if(reconnectTimer!=null){reconnectTimer!.cancel();}
    if(deviceState2!=null){deviceState2!.value = DeviceState.disconnected;}
    disposeCrontrolDevice();
    logCon.stopAlert(homeCon.companyId,homeCon.groupId,homeCon.siteId,homeCon.userid.text);
    update();
    Vibration.vibrate();
    Device1Controller device1Con = Get.find();
    if(
      device1Con.reconnectingDev1==false
      &&device1Con.deviceState1!.value!=DeviceState.connected
    ){
      serviceInfos2.clear();
      hideConnectedList.clear();
      connectedList.clear();
      homeCon.stopSensing();
    }
  }

  //Add Connected Device Log to FireBase Device Status Latest And Device Status History Collection and Local
  addDeviceConnectedLogFbAndLocal()async{
    HomeController homeCon = Get.find();
    homeCon.deviceRightConnected = 'Connected';
    toastMsgCon.showDeviceConnectedMsg(homeCon.deviceNameRight);
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
    toastMsgCon.deviceDisconnectedMsg('R');
    homeCon.deviceRightConnected = 'Disconnected';
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