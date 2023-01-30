import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:blue/common/style.dart';
import 'package:blue/controllers/audio_controller.dart';
import 'package:blue/controllers/device1_controller.dart';
import 'package:blue/controllers/device2_controller.dart';
import 'package:blue/controllers/home_controller.dart';
import 'package:blue/controllers/log_controller.dart';
import 'package:blue/controllers/toast_message_controller.dart';
import 'package:blue/helper/db_connection.dart';
import 'package:blue/helper/pref_helper.dart';
import 'package:blue/model/master_worker_model.dart';
import 'package:blue/model/sites.dart';
import 'package:blue/model/worker_model.dart';
import 'package:blue/services/firestore_services.dart';
import 'package:blue/view/battery_value_log.dart';
import 'package:blue/view/device1_connect.dart';
import 'package:blue/view/device2_connect.dart';
import 'package:blue/view/data_log_page.dart';
import 'package:blue/view/device_status_log.dart';
import 'package:blue/view/settings_page.dart';
import 'package:blue/widgets/admin_log_view.dart';
import 'package:blue/widgets/company_verify_dialog.dart';
import 'package:blue/widgets/lable_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_blue_elves/flutter_blue_elves.dart';

// Home StateFull Widget
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  //Controllers Instance
  final HomeController homeCon = Get.put(HomeController());
  final Device1Controller device1Con = Get.put(Device1Controller());
  final Device2Controller device2Con = Get.put(Device2Controller());
  final LogController logCon = Get.put(LogController());
  final AudioController audioCon = Get.put(AudioController());
  final ToastMessageController toastCon = Get.put(ToastMessageController());
  //Storage Instance
  final prefs = SharedPreferences.getInstance();
  //DataBase Instance
  final dbHelper = DatabaseHandler.instance;

  @override
  void initState() {
    // Initiallize Database
    dbHelper.initializeDB();
    homeCon.setUpLogs();
    super.initState();
  }

  @override
  void dispose() {
    AudioPlayer().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: white,
        resizeToAvoidBottomInset: true,
        //Set AppBar Settings,
        //Logs Button homeCon.visible only in Admin Mode 
        //@ leading: @action -click in title 10 times to enable 
        appBar: AppBar(
          backgroundColor: white,
          elevation: 0,
          centerTitle: true,
          leading: homeCon.visible
          ?IconButton(
            icon: const Icon(Icons.menu_rounded),
            color: black,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingPage()),
              );
            },
          )
          :null,
          actions: <Widget>[
            //Battery Log
            homeCon.visible
            ?IconButton(
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.only(left:0,right:0),
              icon: const Icon(Icons.battery_charging_full),
              color: black,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BatteryValueLog()),
                );
              },
            )
            :const SizedBox(),
            //Device Log
            homeCon.visible
            ?IconButton(
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.only(left:6,right:6),
              icon: const Icon(Icons.mobile_friendly),
              color: black,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DeviceStatusLog()),
                );
              },
            )
            :const SizedBox(),
            //Detect Log
            homeCon.visible
            ?IconButton(
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.only(left:4,right:6),
              icon: const Icon(Icons.document_scanner_outlined),
              color: black,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DataLogPage()),
                );
              },
            )
            :const SizedBox(),
          ],
          title: InkWell(
            onTap: (){
              if(homeCon.clickCount == 9 && homeCon.visible == false){
                setState(() {
                  homeCon.visible = true;
                });
                toastCon.showAdminModeEnabledMsg(context);
              }else if(homeCon.visible == false){
                setState(() {
                  homeCon.clickCount += 1;
                });
              }
            },
            child: RichText(
              text: const TextSpan(
                text: 'F',
                style: TextStyle(
                  color: black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: ' Sensing',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                    ),
                  )
                ]
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,// left right
            mainAxisAlignment: MainAxisAlignment.end,//top down
            mainAxisSize: MainAxisSize.max,
            children: [
              //Permission Widget 
              PermissionButtonWidget(
                homeCon: homeCon,
              ),
              AnimatedLogo(
                homeCon: homeCon
              ),
              //Start/Stop Button Widget 
              StartStopButtonWidget(
                homeCon: homeCon,
                device1Con: device1Con,
                device2Con: device2Con
              ),
              //Company || Site DropDown || User Id 
              //Device 1(Left) | Device 2(Right)
              DeviceConnectFormWidget(
                homeCon: homeCon,
                device1Con: device1Con,
                device2Con: device2Con,
              ),
              //C || BM || BU Pressure Values (Currently from Device 1 only ) 
              //C - Current Values of Leader/Master Worker (Real Time Updating Value)
              //BM - Base Master Value (C value on Start from Web Dashboard)
              //BU - Base User Value (Your Device )
              CBMBUValueWidget(
                homeCon:homeCon
              ),
              // App Version
              const VersionText(),
              //Show when in admin mode only
              //Log View Widget device 1 and device 2 with Export Real Log Button 
              //Exports Both device 1 and device 2 Real log to downloads folder 
              //only homeCon.visible if Countclick is 10/admin Mode
              AdminToggleViewWidget(
                homeCon: homeCon
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//------------------------------------------------------------------------------

//PermissionButton StateLess
class PermissionButtonWidget extends StatelessWidget {
  const PermissionButtonWidget({Key? key,required this.homeCon}) : super(key: key);
  final dynamic homeCon;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder:(_){
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: Platform.isAndroid
          ? [
            //GPS Permission
            Column(
              children: [
                const Text('GPS許可',textAlign: TextAlign.center),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: homeCon.blueLack.contains(AndroidBluetoothLack.locationPermission)
                    ? red
                    : primaryColor.withOpacity(0.1),
                    side: const BorderSide(width: 1.0, color: primaryColor),
                    minimumSize: Size.zero, // Set this
                    padding: const EdgeInsets.all(2.0), // and this
                  ),
                  icon: Icon(homeCon.blueLack.contains(AndroidBluetoothLack.locationPermission)
                    ? Icons.error
                    : Icons.done,
                    color: black,
                  ),
                  label: const Icon(
                    Icons.gps_fixed,
                    color:black,
                  ),
                  onPressed: () {
                    if (homeCon.blueLack.contains(AndroidBluetoothLack.locationPermission)) {
                      FlutterBlueElves.instance.androidApplyLocationPermission((isOk) {
                        if (kDebugMode) {
                          print(isOk
                            ? "User agrees to grant location permission"
                            : "User does not agree to grant location permission"
                          );
                        }
                      });
                    }
                  },
                ),
              ],
            ),
            Column(
              children: [
                const Text('GPS有効',textAlign: TextAlign.center),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: homeCon.blueLack.contains(AndroidBluetoothLack.locationFunction)
                    ? red
                    : primaryColor.withOpacity(0.1),
                    side: const BorderSide(width: 1.0, color: primaryColor),
                    minimumSize: Size.zero, // Set this
                    padding: const EdgeInsets.all(2.0), // and this
                  ),
                  icon: Icon(homeCon.blueLack.contains(AndroidBluetoothLack.locationFunction)
                    ? Icons.error
                    : Icons.done,
                    color: black,
                  ),
                  label: const Icon(
                    Icons.gps_fixed,
                    color:black,
                  ),
                  onPressed: () {
                    if (homeCon.blueLack.contains(AndroidBluetoothLack.locationFunction)) {
                      FlutterBlueElves.instance.androidOpenLocationService((isOk) {
                        if (kDebugMode) {
                          print(isOk
                            ? "The user agrees to turn on the positioning function"
                            : "The user does not agree to enable the positioning function"
                          );
                        }
                      });
                    }
                  },
                ),
              ],
            ),
            //Bluetooth Permission
            Column(
              children: [
                const Text('BL許可',textAlign: TextAlign.center),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: homeCon.blueLack.contains(AndroidBluetoothLack.bluetoothPermission)
                    ? red
                    : primaryColor.withOpacity(0.1),
                    side: const BorderSide(width: 1.0, color: primaryColor),
                    minimumSize: Size.zero, // Set this
                    padding: const EdgeInsets.all(2.0), // and this
                  ),
                  icon: Icon(homeCon.blueLack.contains(AndroidBluetoothLack.bluetoothPermission)
                    ? Icons.error
                    : Icons.done,
                    color: black,
                  ),
                  label: const Icon(
                    Icons.bluetooth,
                    color:black,
                  ),
                  onPressed: () {
                    if (homeCon.blueLack.contains(AndroidBluetoothLack.bluetoothPermission)) {
                      FlutterBlueElves.instance.androidApplyBluetoothPermission((isOk) {
                        if (kDebugMode) {
                          print(
                            isOk
                            ? "User agrees to grant Bluetooth permission"
                            : "User does not agree to grant Bluetooth permission"
                          );
                        }
                      });
                    }
                  },
                ),
              ],
            ),
            Column(
              children: [
                const Text('BL有効',textAlign: TextAlign.center),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: homeCon.blueLack.contains(AndroidBluetoothLack.bluetoothFunction)
                    ? red
                    : primaryColor.withOpacity(0.1),
                    side: const BorderSide(width: 1.0, color: primaryColor),
                    minimumSize: Size.zero, // Set this
                    padding: const EdgeInsets.all(2.0), // and this
                  ),
                  icon: Icon(homeCon.blueLack.contains(AndroidBluetoothLack.bluetoothFunction)
                    ? Icons.error
                    : Icons.done,
                    color: black,
                  ),
                  label: const Icon(
                    Icons.bluetooth,
                    color:black,
                  ),
                  onPressed: () {
                    if (homeCon.blueLack.contains(AndroidBluetoothLack.bluetoothFunction)) {
                      FlutterBlueElves.instance.androidOpenBluetoothService((isOk) {
                        if (kDebugMode) {
                          print(
                            isOk
                            ? "The user agrees to turn on the Bluetooth function"
                            : "The user does not agree to enable the Bluetooth function"
                          );
                        }
                      });
                    }
                  },
                ),
              ],
            ),
          ]
          :[],
        );
      }
    );
  }
}

//------------------------------------------------------------------------------

//Animated Logo StateLess
class AnimatedLogo extends StatelessWidget {
  const AnimatedLogo({Key? key,required this.homeCon}) : super(key: key);
  final dynamic homeCon;
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Obx(()=>
        homeCon.start.value == 0
        ? Image.asset(
          'assets/images/image.jpg',
          height: 120,
          width: 160,
        )
        : Lottie.asset(
          'assets/images/pulse.json',
          width: 160,
          height: 120
        )
      ),
    );
  }
}

//------------------------------------------------------------------------------

//StartStopButton StateFull
class StartStopButtonWidget extends StatefulWidget {
  const StartStopButtonWidget({Key? key,required this.homeCon,required this.device1Con,required this.device2Con}) : super(key: key);
  final dynamic homeCon;
  final dynamic device1Con;
  final dynamic device2Con;

  @override
  State<StartStopButtonWidget> createState() => _StartStopButtonWidgetState();
}

class _StartStopButtonWidgetState extends State<StartStopButtonWidget> {
  ToastMessageController toastCon = Get.find();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: InkWell(
        onTap: () async {
          widget.homeCon.onStartStopButtonClick(context);
        },
        child: Obx(()=>
          Container(
            width: 180,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical:12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: primaryColor)
            ),
            child: widget.device1Con.reconnectingDev1==true || widget.device2Con.reconnectingDev2==true
            ?RichText(
              textAlign:TextAlign.center,
              text: TextSpan(
                text: widget.homeCon.start.value == 0 ||widget.device1Con.deviceState1!.value==DeviceState.disconnected||widget.device2Con.deviceState2!.value==DeviceState.disconnected 
                ? '開始' 
                : '終了',
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: widget.homeCon.start.value == 0 ? '\nSTART' : '\nSTOP',
                    style: const TextStyle(
                      color: black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1
                    ),
                  )
                ]
              ),
            )
            :widget.homeCon.formChecking.value 
            || widget.device1Con.isScaningDev1.value == true
            || widget.device2Con.isScaningDev2.value == true
            || widget.device1Con.deviceState1!.value==DeviceState.connecting 
            || widget.device2Con.deviceState2!.value==DeviceState.connecting
            ? const SizedBox(
              width: 38,
              height: 38,
              child: Center(child: CircularProgressIndicator())
            )
            :RichText(
              textAlign:TextAlign.center,
              text: TextSpan(
                text: widget.homeCon.start.value == 0 ? '開始' : '終了',
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: widget.homeCon.start.value == 0 ? '\nSTART' : '\nSTOP',
                    style: const TextStyle(
                      color: black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1
                    ),
                  )
                ]
              ),
            )
          ),
        ),
      ),
    );
  }
}

//------------------------------------------------------------------------------

//StateFull
//Company || Site DropDown || User Id  //Device 1(Left) | Device 2(Right) 
class DeviceConnectFormWidget extends StatefulWidget {
  const DeviceConnectFormWidget({Key? key,required this.homeCon,required this.device1Con,required this.device2Con}) : super(key: key);
  final dynamic homeCon;
  final dynamic device1Con;
  final dynamic device2Con;

  @override
  State<DeviceConnectFormWidget> createState() => _DeviceConnectFormWidgetState();
}

class _DeviceConnectFormWidgetState extends State<DeviceConnectFormWidget> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>( // specify type as Controller
      init: HomeController(), // intialize with the Controller
      builder:(_){
        return Padding(
          padding: const EdgeInsets.only(left:20.0,right: 20),
          child: Form(
            key: widget.homeCon.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Enter CompanyId,Site Selection and UserID
                Container(
                  padding: const EdgeInsets.only(top:5.0,bottom:10.0,left:10.0,right:10.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Company Code Lable
                      const LableWidget(lableText: '企業コード'),
                      //Company Code TextField And Button
                      Row(
                        children: [
                          // Company Code TextField
                          Flexible(
                            child: Obx(
                              ()=>TextFormField(
                                controller: widget.homeCon.companyCodeTextController.value,
                                readOnly: true,
                                textAlign: TextAlign.start,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                decoration: InputDecoration(
                                  errorStyle: const TextStyle(fontSize: 0.01),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(color: primaryColor)
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(color: primaryColor)
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
                                  hintText: '企業コード',
                                  hintStyle: const TextStyle(color: grey),
                                  contentPadding: const EdgeInsets.only(
                                    bottom: 10.0, 
                                    left: 16.0, 
                                    right: 0.0
                                  ),
                                ),
                                onChanged: (text) async {
                                  widget.homeCon.companyVerified.value=false;
                                  widget.homeCon.siteList.clear();
                                  widget.homeCon.resetSiteSelectionDD();
                                  widget.homeCon.initDropDownValue = widget.homeCon.siteList[0];
                                },
                                style: const TextStyle(
                                  fontSize: 14, 
                                  fontWeight: FontWeight.bold
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
                          const SizedBox(width: 10.0),
                          //Company Verify Button
                          OutlinedButton(
                            onPressed: (){
                              if(widget.homeCon.start.value !=1){
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) => const CompanyVerifyDialog(),
                                );
                              }
                            }, 
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(width: 1.0, color: primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(top:12.0,bottom: 12.0),
                              child: widget.homeCon.companyVerifying.value == false && widget.homeCon.companyVerified.value == true
                              ?const Icon(Icons.edit,color: green)
                              :const Icon(Icons.edit,color: darkGrey),
                            )
                          )
                        ],
                      ),

                      //Site Selection as per Company
                      const LableWidget(lableText: '現場選択'),
                      //Site Selection DropDown
                      InputDecorator(
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: widget.homeCon.showDropDownError.value?red:primaryColor),
                            borderRadius : const BorderRadius.all(Radius.circular(10.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: widget.homeCon.showDropDownError.value?red:primaryColor),
                            borderRadius : const BorderRadius.all(Radius.circular(10.0)),
                          ),
                          disabledBorder:OutlineInputBorder(
                            borderSide: BorderSide(color: widget.homeCon.showDropDownError.value?red:primaryColor),
                            borderRadius : const BorderRadius.all(Radius.circular(10.0)),
                          ),
                          focusedErrorBorder:OutlineInputBorder(
                            borderSide: BorderSide(color: widget.homeCon.showDropDownError.value?red:primaryColor),
                            borderRadius : const BorderRadius.all(Radius.circular(10.0)),
                          ),
                          focusedBorder:OutlineInputBorder(
                            borderSide: BorderSide(color: widget.homeCon.showDropDownError.value?red:primaryColor),
                            borderRadius : const BorderRadius.all(Radius.circular(10.0)),
                          ),
                          errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: red),
                            borderRadius : BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<SiteData>(
                            alignment : AlignmentDirectional.center,
                            isExpanded: true,
                            isDense : true,
                            borderRadius:BorderRadius.circular(10.0),
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: widget.homeCon.companyVerified.value?green:grey,
                            ),
                            value: widget.homeCon.initDropDownValue,
                            items:widget.homeCon.siteList.map<DropdownMenuItem<SiteData>>((SiteData items) {
                              return DropdownMenuItem<SiteData>(
                                value: items,
                                child: Text(items.siteName.toString()),
                                alignment: Alignment.centerLeft,
                              );
                            }).toList(),
                            onChanged: (newValue) { 
                              if(widget.homeCon.start.value !=1){
                                setState(() {
                                  widget.homeCon.initDropDownValue = newValue!;
                                  if(widget.homeCon.initDropDownValue.id==0){
                                    widget.homeCon.showDropDownError.value=true;
                                  }
                                  else{
                                    widget.homeCon.showDropDownError.value=false;
                                  }
                                });
                              }
                            },
                            onTap: (){
                              // on Tapp DropDown Reload Here
                              // if(
                              //   homeCon.companyCodeTextController.value.text.toString().trim()!="" 
                              //   && homeCon.companyPassCodeTextController.value.text.toString().trim()!=""
                              // ){
                              //   setState(() {
                              //     homeCon.companyVerifying.value=true;
                              //   });
                              //   //to do verify company code
                              //   homeCon.checkCompanyAndValidate(
                              //     homeCon.companyCodeTextController.value.text.toString().trim(),
                              //     homeCon.companyPassCodeTextController.value.text.toString().trim(),
                              //     context,
                              //     'dropdown'
                              //   );
                              // }
                            },
                          ),
                        ),
                      ),

                      //User ID as per company
                      const LableWidget(lableText: 'ユーザID'),
                      Obx(
                        ()=>TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: widget.homeCon.useridTextController.value,
                          readOnly: widget.homeCon.start.value==1?true:false,
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                            errorStyle: const TextStyle(fontSize: 0.01),
                            fillColor: white,
                            suffixIcon: IconButton(
                              onPressed: () {
                                if(widget.homeCon.start.value!=1){
                                  widget.homeCon.useridTextController.value.clear();
                                }
                              },
                              icon: const Icon(Icons.clear),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: primaryColor)
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
                            hintText: 'ユーザID',
                            hintStyle: const TextStyle(color: grey),
                            contentPadding: const EdgeInsets.only(
                              bottom: 10.0, 
                              left: 16.0, 
                              right: 0.0
                            ),
                          ),
                          onChanged: (text) async {
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString('userid',text).toString();
                          },
                          style: const TextStyle(
                            fontSize: 14, 
                            fontWeight: FontWeight.bold
                          ),
                          validator:  (value) {
                            if (value == null || value.isEmpty) {
                              return '';
                            }
                            return null;
                          },
                        )
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                //Device 1 and Device 2 to Connect Text Container
                Container(
                  padding: const EdgeInsets.only(left:10,right:10,top:5,bottom:10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.circular(10),
                    // border: Border.all(color: primaryColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      //デバイス 1 Header Text
                      LableWidget(lableText: 'デバイス 1'),
                      //Device 1 
                      Device1Connect(),
                      //デバイス 2 Header Text
                      LableWidget(lableText: 'デバイス 2'),
                      //Device 2 
                      Device2Connect(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}

//------------------------------------------------------------------------------

//C || BM || BU Pressure Values StateLess
class CBMBUValueWidget extends StatelessWidget {
  const CBMBUValueWidget({Key? key,this.homeCon}) : super(key: key);
  final dynamic homeCon;

  @override
  Widget build(BuildContext context) {
    checkIsLeader();
    checkUserId();
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder:(_){
        return IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical:10.0,horizontal: 20.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.all(10.0),
              child: homeCon.deviceLeftConnected=="Connected"||homeCon.deviceRightConnected=="Connected"
              //Start data from fb
              ?Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //C => current averagePressureValue
                      Container(
                        // color: red,
                        alignment: Alignment.center,
                        width: (MediaQuery.of(context).size.width/3)-30,
                        child: homeCon.isLeader==0
                        //not leader
                        ?StreamBuilder<MasterWorker>(
                          stream: FirestoreServices.getMasterWorkerData('${homeCon.companyId}-${homeCon.groupId}-${homeCon.siteId}'),
                          builder:(BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasError || !snapshot.hasData) {
                              return const Text('C  _ _ _');
                            } 
                            else{
                              homeCon.currentMasterAverageValue.value=snapshot.data.averagePressureValue;
                              return Text(
                                'C  ${snapshot.data.averagePressureValue}',
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                softWrap: false,
                              );
                            }
                          }
                        )
                        //leader
                        :Obx(()=>
                          Text(
                            'C ${homeCon.currentMasterAverageValue.value}',
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ),
                      ),
                      //BM | BU
                      StreamBuilder<NormalWorker>(
                        stream: FirestoreServices.getWorkerStatusLatestData(homeCon.useridTextController.value.text.trim()),
                        builder:(BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasError || !snapshot.hasData) {
                            return SizedBox(
                              // color: red,
                              width: (MediaQuery.of(context).size.width/2)-30,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  VerticalDivider(color: black,thickness: 1,width: 1.5),
                                  //BM => Master Worker pressure value at start baseMasterValue for User set from fb
                                  Text('BM  _ _ _'),
                                  VerticalDivider(color: black,thickness: 1),
                                  //BU => User Worker pressure value at start
                                  Text('BU  _ _ _'),
                                ],
                              ),
                            );
                          } 
                          else{
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const VerticalDivider(color: black,thickness: 1,width: 1.5),
                                //BM => Master Worker pressure value at start baseMasterValue for User set from fb
                                Container(
                                  // color: red,
                                  alignment: Alignment.center,
                                  width: (MediaQuery.of(context).size.width/3)-30,
                                  child: Text(
                                    'BM ${snapshot.data.masterPressureValue ?? '  _ _ _'}',
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                    softWrap: false,
                                  )
                                ),
                                const VerticalDivider(color: black,thickness: 1,width: 1.5),
                                //BU => User Worker pressure value at start
                                Container(
                                  // color: red,
                                  alignment: Alignment.center,
                                  width: (MediaQuery.of(context).size.width/3)-30,
                                  child: Text(
                                    'BU ${snapshot.data.baseUserPressureValue ?? '  _ _ _'}',
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                    softWrap: false,
                                  )
                                ),
                              ],
                            );
                          }
                        }
                      ),
                    ],
                  ),
                ],
              )
              //Stopped dummy
              :Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  // C 1010.2300 | BM 1010.556 | BU 1006.692
                  Text('C  _ _ _'),
                  VerticalDivider(color: black,thickness: 1,width: 1),
                  Text('BM  _ _ _'),
                  VerticalDivider(color: black,thickness: 1,width: 1),
                  Text('BU  _ _ _'),
                ]
              )
            ),
          ),
        );
      }
    );
  }
}

//------------------------------------------------------------------------------

//Version Text StateLess
class VersionText extends StatelessWidget {
  const VersionText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom:10.0),
      child: Text('v 3.1.1108'),
    );
  }
}

//------------------------------------------------------------------------------

//Admin Mode StateLess
class AdminToggleViewWidget extends StatelessWidget {
  const AdminToggleViewWidget({Key? key,required this.homeCon}) : super(key: key);
  final dynamic homeCon;
  @override
  Widget build(BuildContext context) {
    return homeCon.visible
    ?const AdminLogView()
    :const SizedBox();
  }
}

//------------------------------------------------------------------------------