import 'package:blue/common/style.dart';
import 'package:blue/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastMessageController extends GetxController {
  final HomeController homeCon = Get.put(HomeController());

  showDeviceAlreadyConnectedMsg(){
    showToastMessage("Connecting");
  }

  showDeviceEmptyMsg(){
    if(homeCon.useridTextController.value.text.trim() == ''){
      showToastMessage("Please enter your User ID");
    }else{
      showToastMessage("Enter device name");
    }
  }

  showDeviceConnectedMsg(name){
    showToastMessage("$name Connected");
  }

  showDeviceNotFoundMsg(name){
    showToastMessage("$name Not found");
  }

  showEmptyRequiredFieldMsg(){
    showToastMessage("Please enter the required items");
  }

  showRequiredPermissionMsg(){
    showToastMessage("Please allow GPS/BL");
  }

  showSaveSnackBar(){
    showToastMessage("Saved");
  }

  showAdminModeEnabledMsg(context){
    var snackBar = const SnackBar(
      backgroundColor:black,
      duration: Duration(seconds: 1),
      content: Text("デバッグモード有効",textAlign: TextAlign.center,style: TextStyle(
        fontSize: 18.0,
        color: white,
        fontWeight: FontWeight.bold
      ))
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  showSenseStartStopMsg(){
    showToastMessage( homeCon.start.value == 0?'Sensing START...':'Sensing END...');
  }

  showCompanyAlreadyVerifiedMsg(){
    showToastMessage('Company code already registered '+homeCon.companyCodeTextController.value.text.toString().trim());
  }

  showRequireCompanyCodeMsg(){
    showToastMessage("Please enter company code");
  }

  showRequirePassCodeEmptyMsg(){
    showToastMessage("Please enter your passcode");
  }

  showLogDownloadedMsg(fileName){
    showToastMessage('$fileName \n CSV Downloaded @ Downloads Folder.');
  }

  showPermissionDeniedMsg(){
    showToastMessage('Permission denied.');
  }

  showPermissionDeniedPermanentMsg(){
    showToastMessage('Permission Permanently Denied.');
  }

  emptyVoltageLogMsg(device){
    showToastMessage('Empty Device $device Logs.');
  }

  deviceDisconnectedMsg(device){
    showToastMessage('Disconnected $device.');
  }

  apiErrorMsg(msg){
    showToastMessage(msg);
  }

  emptyLogMsg(){
    showToastMessage('Log is Empty.');
  }

  device1ConnectingWaitMsg(){
    showToastMessage('Device 1 is connecting, Try again when device 1 is connected.');
  }

  device2ConnectingWaitMsg(){
    showToastMessage('Device 2 is connecting, Try again when device 2 is connected.');
  }

  showDeviceUUIDNotCorrectMsg(device){
    showToastMessage('$device MainUUID dose not match with settings UUID');
  }

  showScanningInProgressMsg(){
    showToastMessage("Please Wait Scanning in progress");
  }

  showToastMessage(message) {
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.BOTTOM,
    );
  }
}