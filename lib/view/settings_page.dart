import 'package:blue/common/style.dart';
import 'package:blue/controllers/home_controller.dart';
import 'package:blue/widgets/lable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final HomeController homeCon = Get.put(HomeController());

  @override
  void initState() {
    //Load Settings
    homeCon.loadSettings();
    super.initState();
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
        appBar: AppBar(
          backgroundColor: white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: black,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'SETTINGS',
            style: TextStyle(color: primaryColor, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left:20.0,right:20.0,bottom: 20.0,top: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Enter Company Code
                  Container(
                    padding: const EdgeInsets.only(left:10,right:10.0,top:5.0,bottom: 10.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LableWidget(lableText: '企業コード'),
                        TextFormField(
                          controller: homeCon.companyCode,
                          enabled: homeCon.start.value==1?false:true,
                          decoration: InputDecoration(
                            fillColor: white,
                            suffixIcon: IconButton(
                              onPressed: () {
                                if(homeCon.start.value!=1){
                                  homeCon.companyCode.clear();
                                }
                              },
                              icon: const Icon(Icons.clear),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: primaryColor)
                            ),
                            filled: true,
                            hintText: 'Company Code',
                            hintStyle: const TextStyle(color: grey),
                            contentPadding: const EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
                          ),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Enter UserID
                  Container(
                    padding: const EdgeInsets.only(left:10,right:10.0,top:5.0,bottom: 10.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LableWidget(lableText: 'ユーザID'),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: homeCon.userid,
                          enabled: homeCon.start.value==1?false:true,
                          decoration: InputDecoration(
                            fillColor: white,
                            suffixIcon: IconButton(
                              onPressed: () {
                                if(homeCon.start.value!=1){
                                  homeCon.userid.clear();
                                }
                              },
                              icon: const Icon(Icons.clear),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: primaryColor)
                            ),
                            filled: true,
                            hintText: 'User ID',
                            hintStyle: const TextStyle(color: grey),
                            contentPadding: const EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
                          ),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Average max length
                  Container(
                    padding: const EdgeInsets.only(left:10,right:10.0,top:5.0,bottom: 10.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LableWidget(lableText: 'Average Max Length (default 10)'),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: homeCon.averageMaxLengthTextController,
                          keyboardType: TextInputType.number,
                          enabled: homeCon.start.value==1?false:true,
                          decoration: InputDecoration(
                            fillColor: white,
                            suffixIcon: IconButton(
                              onPressed: () {
                                if(homeCon.start.value!=1){
                                  homeCon.averageMaxLengthTextController.clear();
                                }
                              },
                              icon: const Icon(Icons.clear),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: primaryColor)
                            ),
                            filled: true,
                            hintText: 'Average max length',
                            hintStyle: const TextStyle(color: grey),
                            contentPadding: const EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
                          ),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          inputFormatters:[FilteringTextInputFormatter.allow(RegExp("[0-9]"))],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Alert Timer
                  Container(
                    padding: const EdgeInsets.only(left:10,right:10.0,top:5.0,bottom: 10.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LableWidget(lableText: 'Alert Timer (In Seconds)'),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: homeCon.alertTimerTextController,
                          keyboardType: TextInputType.number,
                          enabled: homeCon.start.value==1?false:true,
                          decoration: InputDecoration(
                            fillColor: white,
                            suffixIcon: IconButton(
                              onPressed: () {
                                if(homeCon.start.value!=1){
                                  homeCon.alertTimerTextController.clear();
                                }
                              },
                              icon: const Icon(Icons.clear),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: primaryColor)
                            ),
                            filled: true,
                            hintText: 'Alert Timer',
                            hintStyle: const TextStyle(color: grey),
                            contentPadding: const EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
                          ),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          inputFormatters:[FilteringTextInputFormatter.allow(RegExp("[0-9]"))],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  //Device 1 UUIDS 
                  Container(
                    padding: const EdgeInsets.only(left:10,right:10.0,top:5.0,bottom: 10.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(10),
                      // border: Border.all(color: primaryColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LableWidget(lableText: 'DEVICE 1'),
                        const SizedBox(
                          height: 5,
                        ),
                        //Service UUID
                        TextFormField(
                          controller: homeCon.dev1ServiceUUID,
                          enabled: homeCon.start.value==1?false:true,
                          decoration: InputDecoration(
                            fillColor: white,
                            suffixIcon: IconButton(
                              onPressed: () {
                                if(homeCon.start.value!=1){
                                  homeCon.dev1ServiceUUID.clear();
                                }
                              },
                              icon: const Icon(Icons.clear),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: primaryColor)
                            ),
                            filled: true,
                            hintText: 'Service UUID',
                            hintStyle: const TextStyle(color: grey),
                            contentPadding: const EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
                          ),
                          style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        //DetectValue UUID
                        TextFormField(
                          controller: homeCon.dev1DetectValueUUID,
                          enabled: homeCon.start.value==1?false:true,
                          decoration: InputDecoration(
                            fillColor: white,
                            suffixIcon: IconButton(
                              onPressed: () {
                                if(homeCon.start.value!=1){
                                  homeCon.dev1DetectValueUUID.clear();
                                }
                              },
                              icon: const Icon(Icons.clear),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: primaryColor)
                            ),
                            filled: true,
                            hintText: 'DetectValue UUID',
                            hintStyle: const TextStyle(color: grey),
                            contentPadding: const EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
                          ),
                          style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        //RealValue UUID
                        TextFormField(
                          controller: homeCon.dev1RealValueUUID,
                          enabled: homeCon.start.value==1?false:true,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            fillColor: white,
                            suffixIcon: IconButton(
                              onPressed: () {
                                if(homeCon.start.value!=1){
                                  homeCon.dev1RealValueUUID.clear();
                                }
                              },
                              icon: const Icon(Icons.clear),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)
                            ),
                            borderSide: BorderSide(color: primaryColor)),
                            filled: true,
                            hintText: 'RealValue UUID',
                            hintStyle: const TextStyle(color: grey),
                            contentPadding: const EdgeInsets.only(
                              bottom: 10.0, left: 10.0, right: 10.0
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        //Battery UUID
                        TextFormField(
                          controller: homeCon.dev1BatteryValueUUID,
                          enabled: homeCon.start.value==1?false:true,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            fillColor: white,
                            suffixIcon: IconButton(
                              onPressed: () {
                                if(homeCon.start.value!=1){
                                  homeCon.dev1BatteryValueUUID.clear();
                                }
                              },
                              icon: const Icon(Icons.clear),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)
                            ),
                            borderSide: BorderSide(color: primaryColor)),
                            filled: true,
                            hintText: 'BatteryValue UUID',
                            hintStyle: const TextStyle(color: grey),
                            contentPadding: const EdgeInsets.only(
                              bottom: 10.0, left: 10.0, right: 10.0
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        //Pressure UUID
                        TextFormField(
                          controller: homeCon.dev1PressureValueUUID,
                          enabled: homeCon.start.value==1?false:true,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            fillColor: white,
                            suffixIcon: IconButton(
                              onPressed: () {
                                if(homeCon.start.value!=1){
                                  homeCon.dev1PressureValueUUID.clear();
                                }
                              },
                              icon: const Icon(Icons.clear),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)
                            ),
                            borderSide: BorderSide(color: primaryColor)),
                            filled: true,
                            hintText: 'Pressure UUID',
                            hintStyle: const TextStyle(color: grey),
                            contentPadding: const EdgeInsets.only(
                              bottom: 10.0, left: 10.0, right: 10.0
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        //Temperature UUID
                        TextFormField(
                          controller: homeCon.dev1TemperatureValueUUID,
                          enabled: homeCon.start.value==1?false:true,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            fillColor: white,
                            suffixIcon: IconButton(
                              onPressed: () {
                                if(homeCon.start.value!=1){
                                  homeCon.dev1TemperatureValueUUID.clear();
                                }
                              },
                              icon: const Icon(Icons.clear),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)
                            ),
                            borderSide: BorderSide(color: primaryColor)),
                            filled: true,
                            hintText: 'Temperature UUID',
                            hintStyle: const TextStyle(color: grey),
                            contentPadding: const EdgeInsets.only(
                              bottom: 10.0, left: 10.0, right: 10.0
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  //Device 2 UUIDS
                  Container(
                    padding: const EdgeInsets.only(left:10,right:10.0,top:5.0,bottom: 10.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(10),
                      // border: Border.all(color: primaryColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LableWidget(lableText: 'DEVICE 2'),
                        const SizedBox(
                          height: 5,
                        ),
                        //Service UUID
                        TextFormField(
                          controller: homeCon.dev2ServiceUUID,
                          enabled: homeCon.start.value==1?false:true,
                          decoration: InputDecoration(
                            fillColor: white,
                            suffixIcon: IconButton(
                              onPressed: () {
                                if(homeCon.start.value!=1){
                                  homeCon.dev2ServiceUUID.clear();
                                }
                              },
                              icon: const Icon(Icons.clear),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: primaryColor)
                            ),
                            filled: true,
                            hintText: 'Service UUID',
                            hintStyle: const TextStyle(color: grey),
                            contentPadding: const EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
                          ),
                          style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        //DetectValue UUID
                        TextFormField(
                          controller: homeCon.dev2DetectValueUUID,
                          enabled: homeCon.start.value==1?false:true,
                          decoration: InputDecoration(
                            fillColor: white,
                            suffixIcon: IconButton(
                              onPressed: () {
                                if(homeCon.start.value!=1){
                                  homeCon.dev2DetectValueUUID.clear();
                                }
                              },
                              icon: const Icon(Icons.clear),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: primaryColor)
                            ),
                            filled: true,
                            hintText: 'DetectValue UUID',
                            hintStyle: const TextStyle(color: grey),
                            contentPadding: const EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
                          ),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        //RealValue UUID
                        TextFormField(
                          controller: homeCon.dev2RealValueUUID,
                          enabled: homeCon.start.value==1?false:true,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            fillColor: white,
                            suffixIcon: IconButton(
                              onPressed: () {
                                if(homeCon.start.value!=1){
                                  homeCon.dev2RealValueUUID.clear();
                                }
                              },
                              icon: const Icon(Icons.clear),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: primaryColor)
                            ),
                            filled: true,
                            hintText: 'RealValue UUID',
                            hintStyle: const TextStyle(color: grey),
                            contentPadding: const EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
                          ),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        //Battery UUID
                        TextFormField(
                          controller: homeCon.dev2BatteryValueUUID,
                          enabled: homeCon.start.value==1?false:true,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            fillColor: white,
                            suffixIcon: IconButton(
                              onPressed: () {
                                if(homeCon.start.value!=1){
                                  homeCon.dev2BatteryValueUUID.clear();
                                }
                              },
                              icon: const Icon(Icons.clear),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: primaryColor)
                            ),
                            filled: true,
                            hintText: 'BatteryValue UUID',
                            hintStyle: const TextStyle(color: grey),
                            contentPadding: const EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
                          ),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        //Pressure UUID
                        TextFormField(
                          controller: homeCon.dev2PressureValueUUID,
                          enabled: homeCon.start.value==1?false:true,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            fillColor: white,
                            suffixIcon: IconButton(
                              onPressed: () {
                                if(homeCon.start.value!=1){
                                  homeCon.dev2PressureValueUUID.clear();
                                }
                              },
                              icon: const Icon(Icons.clear),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)
                            ),
                            borderSide: BorderSide(color: primaryColor)),
                            filled: true,
                            hintText: 'Pressure UUID',
                            hintStyle: const TextStyle(color: grey),
                            contentPadding: const EdgeInsets.only(
                              bottom: 10.0, left: 10.0, right: 10.0
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        //Temperature UUID
                        TextFormField(
                          controller: homeCon.dev2TemperatureValueUUID,
                          enabled: homeCon.start.value==1?false:true,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            fillColor: white,
                            suffixIcon: IconButton(
                              onPressed: () {
                                if(homeCon.start.value!=1){
                                  homeCon.dev2TemperatureValueUUID.clear();
                                }
                              },
                              icon: const Icon(Icons.clear),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: primaryColor)
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)
                            ),
                            borderSide: BorderSide(color: primaryColor)),
                            filled: true,
                            hintText: 'Temperature UUID',
                            hintStyle: const TextStyle(color: grey),
                            contentPadding: const EdgeInsets.only(
                              bottom: 10.0, left: 10.0, right: 10.0
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  //Save Button
                  InkWell(
                    onTap: () {
                      homeCon.saveSetings();
                    },
                    child: Container(
                      width: 200,
                      height: 60,
                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: primaryColor)
                      ),
                      child: Center(
                        child: RichText(
                          text: const TextSpan(
                            text: '保存',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: '\n SAVE',
                                style: TextStyle(
                                    color: black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              )
                            ]
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
