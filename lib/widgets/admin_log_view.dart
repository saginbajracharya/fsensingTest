import 'package:blue/common/style.dart';
import 'package:blue/controllers/device1_controller.dart';
import 'package:blue/controllers/device2_controller.dart';
import 'package:blue/controllers/home_controller.dart';
import 'package:blue/controllers/log_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminLogView extends StatefulWidget {
  const AdminLogView({ Key? key }) : super(key: key);

  @override
  State<AdminLogView> createState() => _AdminLogViewState();
}

class _AdminLogViewState extends State<AdminLogView> {
  final HomeController homeCon = Get.put(HomeController());
  final Device1Controller device1Con = Get.put(Device1Controller());
  final Device2Controller device2Con = Get.put(Device2Controller());
  final LogController logCon = Get.put(LogController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>( // specify type as Controller
      init: HomeController(), // intialize with the Controller
      builder:(_){
        return SizedBox(
          // width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height/1.5,
          child: Column(
            children: [
              const Divider(
                color: primaryColor,
                thickness: 1,
                height: 1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top:12.0,bottom: 12.0,left: 8.0),
                    child: RichText(
                      text: TextSpan(
                        text: 'デバイス L : ',
                        style: const TextStyle(
                          color: black, 
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: device1Con.logs1.length.toString(),
                            style: const TextStyle(
                              color: primaryColor, 
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0
                            ),
                          )
                        ]
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:12.0,bottom: 12.0,right: 8.0),
                    child: RichText(
                      text: TextSpan(
                        text: device2Con.logs2.length.toString(),
                        style: const TextStyle(
                          color: primaryColor, 
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0
                        ),
                        children: const <TextSpan>[
                          TextSpan(
                            text: ' : デバイス R',
                            style: TextStyle(
                              color: black, 
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold
                            ),
                          )
                        ]
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(
                color: primaryColor,
                thickness: 1,
                height: 1,
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: const EdgeInsets.only(left:10.0,right:10.0,top:4.0,bottom:4.0),
                  color: grey.withOpacity(0.1),
                  child: ListView.builder(
                    itemCount: device1Con.logs1.length,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(device1Con.logs1[index].mainUUID,style: const TextStyle(color: green)),
                          Text(device1Con.logs1[index].dateTime,style: const TextStyle(color: green)),
                          Text(device1Con.logs1[index].characteristic + " return:",style: const TextStyle(color: grey)),
                          Text(device1Con.logs1[index].data),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                          )
                        ],
                      );
                    }
                  ),
                ),
              ),
              const Divider(
                color: primaryColor,
                thickness: 1,
                height: 1,
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: const EdgeInsets.only(left:10.0,right:10.0,top:4.0,bottom:4.0),
                  color: grey.withOpacity(0.1),
                  child: ListView.builder(
                    itemCount: device2Con.logs2.length,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(device2Con.logs2[index].mainUUID,style: const TextStyle(color: green)),
                          Text(device2Con.logs2[index].dateTime,style: const TextStyle(color: green)),
                          Text(device2Con.logs2[index].characteristic + " return:",style: const TextStyle(color: grey)),
                          Text(device2Con.logs2[index].data),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                          )
                        ],
                      );
                    }
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}