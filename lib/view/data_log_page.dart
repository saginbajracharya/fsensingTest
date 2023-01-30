import 'dart:convert';
import 'package:blue/common/style.dart';
import 'package:blue/controllers/log_controller.dart';
import 'package:blue/helper/save_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataLogPage extends StatefulWidget {
  const DataLogPage({Key? key}) : super(key: key);

  @override
  _DataLogPageState createState() => _DataLogPageState();
}

class _DataLogPageState extends State<DataLogPage> {
  final _save = SaveData();
  final _con = LogController();
  //Variables for log show as json format
  var id ='';
  var devId1 = '';
  var devNo1='';
  var failure1='';
  var status1='';
  var failMessage1='';
  var failDateTime1='';
  var datetime1='';
  var detectValues1='';
  var useStatus1='';
  var eventUuid1='';
  var devMainUUID1='';
  var dev1Pressure='';
  var dev1Temperature='';
  var devId2 = '';
  var devNo2='';
  var failure2='';
  var status2='';
  var failMessage2='';
  var failDateTime2='';
  var datetime2='';
  var detectValues2='';
  var useStatus2='';
  var eventUuid2='';
  var devMainUUID2='';
  var dev2Pressure='';
  var dev2Temperature='';
  var apiRespnse='';
  var userid='';

  @override
  void initState() {
    super.initState();
    getPref();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      getAllData();
    });
  }

  //Get UserId from local storage/Shared Preference and set to userId var
  getPref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userid = prefs.getString('userid').toString();
    });
  }

  //get All Data from table  _logTableDeviceConnection
  getAllData() {
    _con.getAllLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
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
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete_forever),
            color: black,
            onPressed: () {
              _con.deleteAllLogs();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (BuildContext context) => widget));
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            color: black,
            onPressed: () {
              generateCSV();
            },
          ),
        ],
        title: RichText(
          text: const TextSpan(
            text: 'DATA',
            style: TextStyle(
              color: black,
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
            children: <TextSpan>[
              TextSpan(
                text: ' LIST',
                style: TextStyle(
                    color: primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              )
            ]
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: IconButton(
          icon: const Icon(Icons.replay),
          color: white,
          onPressed: () {
            Navigator.pushReplacement(context,MaterialPageRoute(builder: (BuildContext context) => widget));
          },
        ),
      ),
      body: SingleChildScrollView(
        child: getAllDatas(),
      ),
    );
  }

  final Future<String> _calculation = Future<String>.delayed(
    const Duration(seconds: 2),
    () => 'Data Loaded',
  );

  generateCSV() async {
    _save.generateExcel(1);
  }

  getAllDatas() {
    _con.getAllLogs();
    return FutureBuilder<String>(
      future: _calculation, // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          if (kDebugMode) {
            print(_con.logData);
          }
          children = <Widget>[
            ListView.separated(
              shrinkWrap: true,
              reverse: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _con.logData.length,
              itemBuilder: (context, index) {
                String jsonUser = jsonEncode(_con.logData[index]);
                if (kDebugMode) {
                  print(jsonUser);
                }
                id = _con.logData[index]['id'].toString();
                devId1 = _con.logData[index]['dev_id1'].toString();
                devNo1 = _con.logData[index]['dev_no1'].toString();
                failure1 = _con.logData[index]['failure1'].toString();
                status1 = _con.logData[index]['status1'].toString();
                failMessage1 = _con.logData[index]['fail_message1'].toString();
                failDateTime1 = _con.logData[index]['fail_dateTime1'].toString();
                datetime1 = _con.logData[index]['datetime1'].toString();
                useStatus1 = _con.logData[index]['use_status1'].toString();
                eventUuid1 = _con.logData[index]['event_uuid1'].toString();
                detectValues1 = _con.logData[index]['detect_value2'].toString();
                devMainUUID1 = _con.logData[index]['dev_main_UUID1'].toString();
                dev1Pressure=_con.logData[index]['dev1_Pressure'].toString();
                dev1Temperature=_con.logData[index]['dev1_Temperature'].toString();

                devId2 = _con.logData[index]['dev_id2'].toString();
                devNo2 = _con.logData[index]['dev_no2'].toString();
                failure2 = _con.logData[index]['failure2'].toString();
                status2 = _con.logData[index]['status2'].toString();
                failMessage2 = _con.logData[index]['fail_message2'].toString();
                failDateTime2 = _con.logData[index]['fail_dateTime2'].toString();
                datetime2 = _con.logData[index]['datetime2'].toString();
                useStatus2 = _con.logData[index]['use_status2'].toString();
                eventUuid2 = _con.logData[index]['event_uuid2'].toString();
                detectValues2 = _con.logData[index]['detect_value2'].toString();
                devMainUUID2 = _con.logData[index]['dev_main_UUID2'].toString();
                dev2Pressure=_con.logData[index]['dev2_Pressure'].toString();
                dev2Temperature=_con.logData[index]['dev2_Temperature'].toString();
                apiRespnse = _con.logData[index]['api_response'].toString();
                final jsonConverted = {
                  "user_id": userid,
                  "hook_list": [
                    {
                      "dev_id": devId1,
                      "dev_no": devNo1,
                      "failure": failure1,
                      "datetime": datetime1,
                      "event_uuid1": eventUuid1,
                      "detect_values": {
                        "use_status": useStatus1
                      },
                      "device_main_UUID": devMainUUID1,
                      "device_1_Pressure": dev1Pressure,
                      "device_1_Temperature":dev1Temperature
                    },
                    {
                      "dev_id": devId2,
                      "dev_no": devNo2,
                      "failure": failure2,
                      "datetime": datetime2,
                      "event_uuid": eventUuid2,
                      "detect_values": {
                        "use_status": useStatus2
                      },
                      "device_main_UUID": devMainUUID2,
                      "device_2_Pressure": dev2Pressure,
                      "device_2_Temperature":dev2Temperature
                    }
                  ]
                };
                return Container(
                  color: grey.withOpacity(0.1),
                  padding: const EdgeInsets.only(left:20.0,right: 20.0,top: 10.0,bottom: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        id.toString(),
                        style: const TextStyle(
                            color: primaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      SelectableText(getPrettyJSONString(jsonConverted)),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        apiRespnse.toString()=="null"?"Api Toggled Off.":apiRespnse.toString(),
                        style: const TextStyle(
                            color: black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(
                  color: black,
                  height: 1,
                );
              },
            ),
          ];
        } else if (snapshot.hasError) {
          children = <Widget>[
            const Icon(
              Icons.error_outline,
              color: red,
              size: 60,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Error: ${snapshot.error}'),
            )
          ];
        } else {
          children = <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/1.3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Awaiting result...'),
                  ),
                ],
              ),
            ),
          ];
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        );
      },
    );
  }

  String getPrettyJSONString(jsonObject) {
    var encoder = const JsonEncoder.withIndent("   ");
    return encoder.convert(jsonObject);
  }
}
