import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:blue/controllers/home_controller.dart';
import 'package:blue/controllers/log_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';
import 'package:volume_controller/volume_controller.dart';

class AudioController extends GetxController{

  AudioPlayer player = AudioPlayer();
  String audioasset = "assets/audio/alert.mp3";
  String audioassetConnected = "assets/audio/alert_connect.mp3";

  @override
  void onInit() {
    player.setReleaseMode(ReleaseMode.STOP); 
    super.onInit();
  }

  playConnectedAudio()async{
    ByteData bytes = await rootBundle.load(audioassetConnected); //load sound from assets
    Uint8List  soundbytes = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    int result = await player.playBytes(soundbytes);
    if(result == 1){ //play success
      player.setReleaseMode(ReleaseMode.RELEASE); 
      if (kDebugMode) {
        print("Sound playing successful.");
      }
    }else{
      player.setReleaseMode(ReleaseMode.STOP); 
      if (kDebugMode) {
        print("Error while playing sound.");
      } 
    }
  }

  playAudio() async {
    VolumeController().setVolume(0);
    ByteData bytes = await rootBundle.load(audioasset); //load sound from assets
    Uint8List  soundbytes = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    int result = await player.playBytes(soundbytes);
    if(result == 1){ //play success
      player.setReleaseMode(ReleaseMode.LOOP); 
      Vibration.vibrate(pattern: [100, 200, 400], repeat: 1);
      if (kDebugMode) {
        print("Sound playing successful.");
      }
    }else{
      player.setReleaseMode(ReleaseMode.STOP); 
      if (kDebugMode) {
        print("Error while playing sound.");
      } 
    }
  }

  stopAudio(){
    final HomeController homeCon = Get.find();
    final LogController logCon = Get.find();
    // final ToastMessageController toastCon = Get.find();
    // toastCon.showToastMessage("Stop function call but delay for" + homeCon.alertTimerTextController.text);
    if(homeCon.start.value==0){
      Vibration.cancel();
      player.setReleaseMode(ReleaseMode.STOP); 
      player.stop();
    }
    else{
      Future.delayed(
        Duration(
          seconds: homeCon.alertTimerTextController.text.trim()==""
          ? 0
          : int.parse(homeCon.alertTimerTextController.text.trim())
        ), () 
      {
        if(logCon.playCondition==false){
          Vibration.cancel();
          player.setReleaseMode(ReleaseMode.STOP); 
          player.stop();
          // toastCon.showToastMessage("Stopped alert after "+ homeCon.alertTimerTextController.text + " duration");
        }
      });
    }
  }
}