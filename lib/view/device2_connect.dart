import 'package:blue/common/style.dart';
import 'package:blue/controllers/device1_controller.dart';
import 'package:blue/controllers/device2_controller.dart';
import 'package:blue/controllers/home_controller.dart';
import 'package:blue/controllers/toast_message_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_elves/flutter_blue_elves.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Device2Connect extends StatefulWidget {
  const Device2Connect({ Key? key }) : super(key: key);

  @override
  State<Device2Connect> createState() => _Device2ConnectState();
}

class _Device2ConnectState extends State<Device2Connect> {
  final Device2Controller device2Con = Get.put(Device2Controller());
  final HomeController homeCon = Get.put(HomeController());
  final ToastMessageController toastMsgCon = Get.put(ToastMessageController());

  @override
  void initState() {
    super.initState();
    getPref();
  }

  // getdeviceName2 if already saved before
  getPref()async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if(prefs.getString('deviceName2').toString()!="null"){
        device2Con.device2TextController.text=prefs.getString('deviceName2').toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Device2Controller>( // specify type as Controller
      init: Device2Controller(), // intialize with the Controller
      builder:(_){ 
        return Row(
          children: [
            //Year
            Flexible(
              child: InputDecorator(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(8, 12, 8, 12),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius : BorderRadius.all(Radius.circular(10.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius : BorderRadius.all(Radius.circular(10.0)),
                  ),
                  disabledBorder:OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius : BorderRadius.all(Radius.circular(10.0)),
                  ),
                  focusedErrorBorder:OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius : BorderRadius.all(Radius.circular(10.0)),
                  ),
                  focusedBorder:OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius : BorderRadius.all(Radius.circular(10.0)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius : BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    alignment : AlignmentDirectional.center,
                    hint: const Text('Year'),
                    isExpanded: true,
                    isDense :true,
                    value: homeCon.initialYearValueDeviceRight,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: homeCon.year.map((items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                        alignment: Alignment.centerLeft,
                      );
                    }).toList(),
                    onChanged: (newValue) async{ 
                      if(homeCon.start.value!=1){
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setString('devRightYear',newValue.toString());
                        setState(() {
                          homeCon.initialYearValueDeviceRight = newValue.toString();
                          //Save to shared Preference
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            //Month
            Flexible(
              child: InputDecorator(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(8, 12, 8, 12),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius : BorderRadius.all(Radius.circular(10.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius : BorderRadius.all(Radius.circular(10.0)),
                  ),
                  disabledBorder:OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius : BorderRadius.all(Radius.circular(10.0)),
                  ),
                  focusedErrorBorder:OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius : BorderRadius.all(Radius.circular(10.0)),
                  ),
                  focusedBorder:OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius : BorderRadius.all(Radius.circular(10.0)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius : BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    alignment : AlignmentDirectional.center,
                    hint: const Text('Month'),
                    isExpanded: true,
                    isDense :true,
                    value: homeCon.initialMonthValueDeviceRight,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: homeCon.month.map((items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                        alignment: Alignment.centerLeft,
                      );
                    }).toList(),
                    onChanged: (newValue) async{ 
                      if(homeCon.start.value!=1){
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setString('devRightMonth',newValue.toString());
                        setState(() {
                          homeCon.initialMonthValueDeviceRight = newValue.toString();
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            //Device Code
            Flexible(
              child: Obx(()=>
                TextFormField(
                  controller: device2Con.device2TextController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textAlign: TextAlign.center,
                  enabled: homeCon.start.value==1?false:true,
                  decoration: InputDecoration(
                    errorStyle: const TextStyle(fontSize: 0.01),
                    fillColor: white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: primaryColor)
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: primaryColor)
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: primaryColor)
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: red)
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: red)
                    ), 
                    filled: true,
                    hintText: 'デバイス 2',
                    hintStyle: const TextStyle(color: grey),
                    contentPadding: const EdgeInsets.only(left: 2.0, right: 2.0),
                  ),
                  onChanged: (text) async {
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString('deviceName2',text).toString();
                  },
                  style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold
                  ),
                  validator:  (value) {
                    if (value == null || value.isEmpty) {
                      return '';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            Obx(
              () => Column(
                children: [
                  device2Con.reconnectingDev2
                  ?Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: GestureDetector(
                      behavior:HitTestBehavior.translucent,
                      onTap: (){
                        device2Con.stopDevice2Connection();
                      },
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: primaryColor.withOpacity(0.2),
                        child: const Icon(
                          Icons.close,
                          color: primaryColor,
                          size: 16,
                        )
                      ),
                    ),
                  )
                  :const SizedBox(),
                  CircleAvatar(
                    radius:14,
                    backgroundColor: primaryColor.withOpacity(0.2),
                    child: device2Con.deviceState2!.value == DeviceState.connecting || device2Con.isScaningDev2.value == true
                      ?const SizedBox(
                        width: 8,
                        height: 8,
                        child: CircularProgressIndicator(
                          strokeWidth: 1
                        )
                      )
                      :device2Con.deviceState2!.value == DeviceState.connected
                      ?const Icon(Icons.done,color: green,size: 16)
                      :IconButton(
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: () async{
                        //CHECK ALL PERMISSIONS
                        if(homeCon.blueLack.contains(AndroidBluetoothLack.bluetoothFunction)||homeCon.blueLack.contains(AndroidBluetoothLack.bluetoothPermission)||homeCon.blueLack.contains(AndroidBluetoothLack.locationPermission)||homeCon.blueLack.contains(AndroidBluetoothLack.locationFunction))
                        {
                          //All Permission NOT OK
                          //Show Permission Required Toast
                          toastMsgCon.showRequiredPermissionMsg();
                        }
                        else{
                          if(homeCon.formKey.currentState!.validate()){
                            if(homeCon.initDropDownValue.id==0){
                              setState(() {
                                homeCon.showDropDownError.value=true;
                              });
                            }
                            else{
                              setState(() {
                                homeCon.showDropDownError.value=false;
                              });
                              Device1Controller device1Con = Get.find();
                              if(device2Con.deviceState2!.value != DeviceState.disconnected && device1Con.deviceState1!.value != DeviceState.connecting || device1Con.isScaningDev1.value!=true){
                                homeCon.deviceNameLeft = homeCon.initialYearValueDeviceLeft+homeCon.initialMonthValueDeviceLeft+device1Con.device1TextController.text.trim();
                                homeCon.deviceNameRight = homeCon.initialYearValueDeviceRight+homeCon.initialMonthValueDeviceRight+device2Con.device2TextController.text.trim();  
                                if(device2Con.device2TextController.text.trim() ==""||homeCon.useridTextController.value.text.trim()==""||homeCon.companyCodeTextController.value.text.trim()==""){
                                  toastMsgCon.showDeviceEmptyMsg();
                                }
                                else if(homeCon.initDropDownValue.id==0){
                                  toastMsgCon.showEmptyRequiredFieldMsg();
                                }
                                else if(device2Con.deviceState2!.value == DeviceState.connected){
                                  toastMsgCon.showDeviceAlreadyConnectedMsg();
                                }else{
                                  await homeCon.checkBeforeStartApi(
                                    homeCon.companyCodeTextController.value.text.trim(),
                                    homeCon.initDropDownValue.id,
                                    homeCon.useridTextController.value.text.trim(),
                                    homeCon.deviceNameLeft,
                                    homeCon.deviceNameRight
                                  ).then((value)async{
                                    if(value == true){
                                      setState(() {
                                        homeCon.device2SingleConnected.value = true;
                                        homeCon.start.value = 1;
                                      });
                                      device2Con.startScan(homeCon.initialYearValueDeviceRight+homeCon.initialMonthValueDeviceRight+device2Con.device2TextController.text.trim(),'device2',context);
                                    }
                                    else{
                                    }
                                  });
                                }
                              }else{
                                toastMsgCon.device1ConnectingWaitMsg();
                              }
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.insert_link,color: primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }
    );
  }
}