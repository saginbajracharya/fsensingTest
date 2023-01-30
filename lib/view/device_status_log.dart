import 'dart:convert';
import 'package:blue/common/style.dart';
import 'package:blue/controllers/log_controller.dart';
import 'package:blue/helper/save_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DeviceStatusLog extends StatefulWidget {
  const DeviceStatusLog({Key? key}) : super(key: key);

  @override
  _DeviceStatusLogState createState() => _DeviceStatusLogState();
}

class _DeviceStatusLogState extends State<DeviceStatusLog> {
  final _save = SaveData();
  final _con = LogController();
  //Variables for log show as json format
  var id ='';
  var devName = '';
  var connectionStatus='';
  var dateTime='';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      getAllData();
    });
  }

  //get All Data from table  _logTableDeviceConnection
  getAllData() {
    _con.getAllDeviceStatusValueLogs();
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
              _con.deleteAllDeviceConnectionLogs();
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
              text: 'Device',
              style: TextStyle(
                color: black,
                fontSize: 24,
                fontWeight: FontWeight.bold
              ),
              children: <TextSpan>[
                TextSpan(
                  text: ' Status',
                  style: TextStyle(
                      color: primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                )
              ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: IconButton(
          icon: const Icon(Icons.replay),
          color: white,
          onPressed: () {
            // getAllDatas();
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (BuildContext context) => widget));
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

  //generate CSV function
  generateCSV() async {
    _save.generateExcel(4);
  }

  //Build log view
  getAllDatas() {
    _con.getAllDeviceStatusValueLogs();

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
                devName = _con.logData[index]['devName'].toString();
                connectionStatus = _con.logData[index]['connectionStatus'].toString();
                dateTime = _con.logData[index]['dateTime'].toString();
                final jsonConverted = {
                  "deviceStatus": {
                    "dev_name": devName,
                    "dev_status": connectionStatus,
                    "datetime": dateTime,
                  }
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

  //Convert to json type String
  String getPrettyJSONString(jsonObject) {
    var encoder = const JsonEncoder.withIndent("   ");
    return encoder.convert(jsonObject);
  }
}
