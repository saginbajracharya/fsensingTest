import 'dart:io';
import 'package:blue/controllers/log_controller.dart';
import 'package:blue/controllers/toast_message_controller.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart' as open_file;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class SaveData {
  final _con = LogController();
  // generate excel for service as per value
  Future<void> generateExcel(value) async {
    String fileNameStart = '';
    if(value ==1){
      await _con.getAllLogs();
      fileNameStart = 'Detect';
    }else if(value == 2){
      await _con.getAllRealValueLogs();
      fileNameStart = 'Real';
    }else if(value ==3){
      await _con.getAllBatteryValueLogs();
      fileNameStart = 'Battery';
    }else if(value == 4){
      await _con.getAllDeviceStatusValueLogs();
      fileNameStart = 'DeviceStatus';
    }
    
    var data = _con.logData;
    if(data.isNotEmpty){
      List<List<dynamic>> rows = <List<dynamic>>[];
      //Create a Excel document.
      //Creating a workbook.
      final Workbook workbook = Workbook();
      //Accessing via index
      final Worksheet sheet = workbook.worksheets[0];
      sheet.showGridlines = false;

      if(value == 4){
        for (int i = 0; i < data.length; i++) {
          List<dynamic> row = [];
          row.add(data[i]['id']);
          row.add(data[i]['devName']);
          row.add(data[i]['connectionStatus']);
          row.add(data[i]['dateTime']);
          rows.add(row);
        }
        // Enable calculation for worksheet.
        sheet.enableSheetCalculations();

        //Set data in the worksheet.
        sheet.getRangeByName('A1:W1').columnWidth = 10;
        sheet.getRangeByName('A2').setText('ID');
        sheet.getRangeByName('B2').setText('devName');
        sheet.getRangeByName('C2').setText('connectionStatus');
        sheet.getRangeByName('D2').setText('dateTime');
        var sheetRow = 3;
        for (var i = 0; i < rows.length; i++) {
          var columnID = sheetRow + i;
          var id =rows[i][0].toString();
          var devName =rows[i][1].toString();
          var connectionStatus =rows[i][2].toString();
          var dateTime =rows[i][3].toString();
          sheet.getRangeByName('A$columnID:N$columnID').columnWidth = 10;
          sheet.getRangeByName('A$columnID').setText(id);
          sheet.getRangeByName('B$columnID').setText(devName);
          sheet.getRangeByName('C$columnID').setText(connectionStatus);
          sheet.getRangeByName('D$columnID').setText(dateTime);
        }
      }
      else if(value == 1){
        for (int i = 0; i < data.length; i++) {
          List<dynamic> row = [];
          row.add(data[i]['id']);
          row.add(data[i]['dev_id1']);
          row.add(data[i]['failure1']);
          row.add(data[i]['status1']);
          row.add(data[i]['fail_message1']);
          row.add(data[i]['fail_datetime1']);
          row.add(data[i]['datetime1']);
          row.add(data[i]['detect_value1']);
          row.add(data[i]['use_status1']);
          row.add(data[i]['event_uuid1']);
          row.add(data[i]['dev_main_UUID1']);
          row.add(data[i]['dev_id2']);
          row.add(data[i]['failure2']);
          row.add(data[i]['status2']);
          row.add(data[i]['fail_message2']);
          row.add(data[i]['fail_datetime2']);
          row.add(data[i]['datetime2']);
          row.add(data[i]['detect_value2']);
          row.add(data[i]['use_status2']);
          row.add(data[i]['event_uuid2']);
          row.add(data[i]['dev_main_UUID2']);
          row.add(data[i]['dev1_Pressure']);
          row.add(data[i]['dev1_Temperature']);
          row.add(data[i]['dev2_Pressure']);
          row.add(data[i]['dev2_Temperature']);
          rows.add(row);
        }
        // Enable calculation for worksheet.
        sheet.enableSheetCalculations();

        //Set data in the worksheet.
        sheet.getRangeByName('A1:W1').columnWidth = 20;
        sheet.getRangeByName('A2').setText('ID');
        sheet.getRangeByName('B2').setText('dev_id1');
        // sheet.getRangeByName('C2').setText('dev_no1');
        sheet.getRangeByName('C2').setText('failure1');
        sheet.getRangeByName('D2').setText('status1');
        sheet.getRangeByName('E2').setText('fail_message1');
        sheet.getRangeByName('F2').setText('fail_dateTime1');
        sheet.getRangeByName('G2').setText('datetime1');
        sheet.getRangeByName('H2').setText('detect_value1');
        sheet.getRangeByName('I2').setText('use_status1');
        sheet.getRangeByName('J2').setText('event_uuid1');
        sheet.getRangeByName('K2').setText('dev_main_UUID1');
        sheet.getRangeByName('L2').setText('dev_id2');
        // sheet.getRangeByName('N2').setText('dev_no2');
        sheet.getRangeByName('M2').setText('failure2');
        sheet.getRangeByName('N2').setText('status2');
        sheet.getRangeByName('O2').setText('fail_message2');
        sheet.getRangeByName('P2').setText('fail_dateTime2');
        sheet.getRangeByName('Q2').setText('datetime2');
        sheet.getRangeByName('R2').setText('detect_value2');
        sheet.getRangeByName('S2').setText('use_status2');
        sheet.getRangeByName('T2').setText('event_uuid2');
        sheet.getRangeByName('U2').setText('dev_main_UUID2');
        sheet.getRangeByName('V2').setText('dev1_Pressure');
        sheet.getRangeByName('W2').setText('dev1_Temperature');
        sheet.getRangeByName('X2').setText('dev2_Pressure');
        sheet.getRangeByName('Y2').setText('dev2_Temperature');
        var sheetRow = 3;
        for (var i = 0; i < rows.length; i++) {
          var columnID = sheetRow + i;
          var id =rows[i][0].toString();
          var devid1 =rows[i][1].toString();
          var failure1 =rows[i][2].toString();
          var status1 =rows[i][3].toString();
          var failMessage1 =rows[i][4].toString();
          var failDateTime1 =rows[i][5].toString();
          var datetime1 =rows[i][6].toString();
          var detectValue1 =rows[i][7].toString();
          var useStatus1 =rows[i][8].toString();
          var eventUuid1 =rows[i][9].toString();
          var devMainUUID1 =rows[i][10].toString();
          var devId2 =rows[i][11].toString();
          var failure2 =rows[i][12].toString();
          var status2 =rows[i][13].toString();
          var failMessage2 =rows[i][14].toString();
          var failDateTime2 =rows[i][15].toString();
          var datetime2 =rows[i][16].toString();
          var detectValue2 =rows[i][17].toString();
          var useStatus2 =rows[i][18].toString();
          var eventUuid2 =rows[i][19].toString();
          var devMainUUID2 =rows[i][20].toString();
          var dev1Pressure =rows[i][21].toString();
          var dev1Temperature =rows[i][22].toString();
          var dev2Pressure =rows[i][23].toString();
          var dev2Temperature =rows[i][24].toString();
          sheet.getRangeByName('A$columnID:N$columnID').columnWidth = 10;
          sheet.getRangeByName('A$columnID').setText(id);
          sheet.getRangeByName('B$columnID').setText(devid1);
          sheet.getRangeByName('C$columnID').setText(failure1);
          sheet.getRangeByName('D$columnID').setText(status1);
          sheet.getRangeByName('E$columnID').setText(failMessage1);
          sheet.getRangeByName('F$columnID').setText(failDateTime1);
          sheet.getRangeByName('G$columnID').setText(datetime1);
          sheet.getRangeByName('H$columnID').setText(detectValue1);
          sheet.getRangeByName('I$columnID').setText(useStatus1);
          sheet.getRangeByName('J$columnID').setText(eventUuid1);
          sheet.getRangeByName('K$columnID').setText(devMainUUID1);
          sheet.getRangeByName('L$columnID').setText(devId2);
          sheet.getRangeByName('M$columnID').setText(failure2);
          sheet.getRangeByName('N$columnID').setText(status2);
          sheet.getRangeByName('O$columnID').setText(failMessage2);
          sheet.getRangeByName('P$columnID').setText(failDateTime2);
          sheet.getRangeByName('Q$columnID').setText(datetime2);
          sheet.getRangeByName('R$columnID').setText(detectValue2);
          sheet.getRangeByName('S$columnID').setText(useStatus2);
          sheet.getRangeByName('T$columnID').setText(eventUuid2);
          sheet.getRangeByName('U$columnID').setText(devMainUUID2);
          sheet.getRangeByName('V$columnID').setText(dev1Pressure);
          sheet.getRangeByName('W$columnID').setText(dev1Temperature);
          sheet.getRangeByName('X$columnID').setText(dev2Pressure);
          sheet.getRangeByName('Y$columnID').setText(dev2Temperature);
        }
      }
      else{
        for (int i = 0; i < data.length; i++) {
          List<dynamic> row = [];
          row.add(data[i]['id']);
          row.add(data[i]['dev_id1']);
          // row.add(data[i]['dev_no1']);
          row.add(data[i]['failure1']);
          row.add(data[i]['status1']);
          row.add(data[i]['fail_message1']);
          row.add(data[i]['fail_datetime1']);
          row.add(data[i]['datetime1']);
          row.add(data[i]['detect_value1']);
          row.add(data[i]['use_status1']);
          row.add(data[i]['event_uuid1']);
          row.add(data[i]['dev_main_UUID1']);
          row.add(data[i]['dev_id2']);
          // row.add(data[i]['dev_no2']);
          row.add(data[i]['failure2']);
          row.add(data[i]['status2']);
          row.add(data[i]['fail_message2']);
          row.add(data[i]['fail_datetime2']);
          row.add(data[i]['datetime2']);
          row.add(data[i]['detect_value2']);
          row.add(data[i]['use_status2']);
          row.add(data[i]['event_uuid2']);
          row.add(data[i]['dev_main_UUID2']);
          rows.add(row);
        }
        // print(rows[0]);
        // Enable calculation for worksheet.
        sheet.enableSheetCalculations();

        //Set data in the worksheet.
        sheet.getRangeByName('A1:W1').columnWidth = 20;
        sheet.getRangeByName('A2').setText('ID');
        sheet.getRangeByName('B2').setText('dev_id1');
        // sheet.getRangeByName('C2').setText('dev_no1');
        sheet.getRangeByName('C2').setText('failure1');
        sheet.getRangeByName('D2').setText('status1');
        sheet.getRangeByName('E2').setText('fail_message1');
        sheet.getRangeByName('F2').setText('fail_dateTime1');
        sheet.getRangeByName('G2').setText('datetime1');
        sheet.getRangeByName('H2').setText('detect_value1');
        sheet.getRangeByName('I2').setText('use_status1');
        sheet.getRangeByName('J2').setText('event_uuid1');
        sheet.getRangeByName('K2').setText('dev_main_UUID1');
        sheet.getRangeByName('L2').setText('dev_id2');
        // sheet.getRangeByName('N2').setText('dev_no2');
        sheet.getRangeByName('M2').setText('failure2');
        sheet.getRangeByName('N2').setText('status2');
        sheet.getRangeByName('O2').setText('fail_message2');
        sheet.getRangeByName('P2').setText('fail_dateTime2');
        sheet.getRangeByName('Q2').setText('datetime2');
        sheet.getRangeByName('R2').setText('detect_value2');
        sheet.getRangeByName('S2').setText('use_status2');
        sheet.getRangeByName('T2').setText('event_uuid2');
        sheet.getRangeByName('U2').setText('dev_main_UUID2');
        var sheetRow = 3;
        for (var i = 0; i < rows.length; i++) {
          var columnID = sheetRow + i;
          var id =rows[i][0].toString();
          var devid1 =rows[i][1].toString();
          // var devNo1 =rows[i][2].toString();
          var failure1 =rows[i][2].toString();
          var status1 =rows[i][3].toString();
          var failMessage1 =rows[i][4].toString();
          var failDateTime1 =rows[i][5].toString();
          var datetime1 =rows[i][6].toString();
          var detectValue1 =rows[i][7].toString();
          var useStatus1 =rows[i][8].toString();
          var eventUuid1 =rows[i][9].toString();
          var devMainUUID1 =rows[i][10].toString();
          var devId2 =rows[i][11].toString();
          // var devNo2 =rows[i][13].toString();
          var failure2 =rows[i][12].toString();
          var status2 =rows[i][13].toString();
          var failMessage2 =rows[i][14].toString();
          var failDateTime2 =rows[i][15].toString();
          var datetime2 =rows[i][16].toString();
          var detectValue2 =rows[i][17].toString();
          var useStatus2 =rows[i][18].toString();
          var eventUuid2 =rows[i][19].toString();
          var devMainUUID2 =rows[i][20].toString();
          sheet.getRangeByName('A$columnID:N$columnID').columnWidth = 10;
          sheet.getRangeByName('A$columnID').setText(id);
          sheet.getRangeByName('B$columnID').setText(devid1);
          // sheet.getRangeByName('C$columnID').setText(devNo1);
          sheet.getRangeByName('C$columnID').setText(failure1);
          sheet.getRangeByName('D$columnID').setText(status1);
          sheet.getRangeByName('E$columnID').setText(failMessage1);
          sheet.getRangeByName('F$columnID').setText(failDateTime1);
          sheet.getRangeByName('G$columnID').setText(datetime1);
          sheet.getRangeByName('H$columnID').setText(detectValue1);
          sheet.getRangeByName('I$columnID').setText(useStatus1);
          sheet.getRangeByName('J$columnID').setText(eventUuid1);
          sheet.getRangeByName('K$columnID').setText(devMainUUID1);
          sheet.getRangeByName('L$columnID').setText(devId2);
          // sheet.getRangeByName('N$columnID').setText(devNo2);
          sheet.getRangeByName('M$columnID').setText(failure2);
          sheet.getRangeByName('N$columnID').setText(status2);
          sheet.getRangeByName('O$columnID').setText(failMessage2);
          sheet.getRangeByName('P$columnID').setText(failDateTime2);
          sheet.getRangeByName('Q$columnID').setText(datetime2);
          sheet.getRangeByName('R$columnID').setText(detectValue2);
          sheet.getRangeByName('S$columnID').setText(useStatus2);
          sheet.getRangeByName('T$columnID').setText(eventUuid2);
          sheet.getRangeByName('U$columnID').setText(devMainUUID2);
        }
      }

      //Save and launch the excel.
      final List<int> bytes = workbook.saveAsStream();
      //Dispose the document.
      workbook.dispose();
      var date = DateTime.now();
      String dateString = date.toString();
      String removeDash = dateString.replaceAll("-","");
      String removeColon = removeDash.replaceAll(":","");
      String removeSpace = removeColon.replaceAll(" ","");
      String finalDate = removeSpace.split(".")[0];
      //Save and launch the file.
      await saveAndLaunchFile(bytes, fileNameStart+finalDate+".xlsx");
    }
    else{
      ToastMessageController toastCon = Get.find();
      toastCon.emptyLogMsg();
    }
  }

  ///To save the Excel file in the device
  Future<void> saveAndLaunchFile(List<int> bytes, String fileName) async {
    //Get the storage folder location using path_provider package.
    String? path;
    if (Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isLinux ||
        Platform.isWindows) {
      final Directory directory = await path_provider.getApplicationSupportDirectory();
      path = directory.path;
    } else {
      path = await PathProviderPlatform.instance.getApplicationSupportPath();
    }
    final File file = File(Platform.isWindows ? '$path\\$fileName' : '$path/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    if (Platform.isAndroid || Platform.isIOS) {
      //Launch the file (used open_file package)
      await open_file.OpenFile.open('$path/$fileName');
    } else if (Platform.isWindows) {
      await Process.run('start', <String>['$path\\$fileName'], runInShell: true);
    } else if (Platform.isMacOS) {
      await Process.run('open', <String>['$path/$fileName'], runInShell: true);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', <String>['$path/$fileName'], runInShell: true);
    }
  }
}
