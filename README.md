# F Sensing

A Flutter Bluetooth/(BLE) project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

DOCUMENTATION FOR FSENSING::

### Main.dart (lib/)

  => Application Start page.(Necessary INITIALIZATIONS are done here)
  => WidgetsFlutterBinding.ensureInitialized() : you need to use this line, if your main function uses async keyword because you use await statement inside it.
  => await Firebase.initializeApp() Initialization for firebase.
  => SystemChrome.setPreferredOrientations for portrait only view.
  => HttpOverrides.global = MyHttpOverrides() & MyHttpOverrides Class : to solve flutter CERTIFICATE_VERIFY_FAILED error while performing a POST request.
  => androidConfig : Setup for Background service notification.
  => startCallback || FirstTaskHandler || updateCallback || SecondTaskHandler for FlutterForegroundTask
  => MyApp Class is the Root of this application, AppRepainWidget for native background service then navigate to HomePage().

### HomePage.dart (lib/view/)

  => HomePage is a Landing Page where it contains UI for (Permission Buttons(stateless) || AnimatedLogo(stateless) || Start/Stop Button(statefull) || Device1 and Device2 Connection UI in DeviceConnectFormWidget Class(stateful)|| C\BM\BU(stateless) || VersionText(Stateless) || Admin Log View(Stateless) )
  => HomePage requires GetX(state management) controllers (home_controller.dart || device1_controller.dart || device2_controller.dart || log_controller.dart || Toast_message_controller.dart) for logical parts
  => HomePageState initState() : clickCount to 0 on page load for admin mode && initialize database and setup logs on page loads
  => HomePageState dispose() : dispose AudioPlayer when page gets disposed
  => build: Contains AppBar where title clickable (Click 10 times to Enable Admin Mode) Settings, Battery, Device Connection Status and Data Logs Button visible only in Admin Mode @ leading: @action -click in title 10 times to enable and body contains other contents as logo,start btn ,text container and log view widgets.

  => Permission Buttons (Stateless)
    -Bluetooth Permission enabled/disabled View Row which detects location,bluetooth permision and location,bluetooth service enabled or disabled by searching if blueLack variable contains permission and services.

  => AnimatedLogo (stateless) : on start play animated logo else show png image.

  => Start/Stop Button (Statefull) 0 ? '開始' : '終了
  => if (widget.homeCon.formChecking.value
    || widget.device1Con.isScaningDev1.value == true
    || widget.device2Con.isScaningDev2.value == true
    || widget.device1Con.deviceState1!.value==DeviceState.connecting
    || widget.device2Con.deviceState2!.value==DeviceState.connecting) then show CircularProgressIndicator inside this Start/Stop Button
  => StartButton : 0 = Start
    -check first if all permission is ok then check form (CompanyCode,site dropdown,UserId,Dev1Name and Device2Name) textField is not empty if not ok show toast messages
    -check states/ variables ( formChecking.value==false && device1Con.deviceState1!.value==DeviceState.disconnected && device2Con.deviceState2!.value==DeviceState.disconnected && device1Con.isScaningDev1.value == false && device2Con.isScaningDev2.value == false && device1Con.deviceState1!.value!=DeviceState.connecting && device2Con.deviceState2!.value!=DeviceState.connecting && start.value == 0) if condition ok Start Scanning else Stop Scanning
    -On Scanning start firstly API Check is Done to check if company | site | user and device is registered through Api - {{SENSING_URL}}/public/api/v1/checkFormData which returns success true else error then scan start.
    -Scans through available bluetooth device as per name in device textfield if found connects and starts the notify services.
    -else if not found then scanning stops and then sends device status to device_status_history and device_status_latest collection in firebase i.e connected status.
  => StopButton : 1 = Stop
    -Stop connected Devices and disconnected status to firebase.
    -Exports Voltage Log to Downloads Folder Then upload to firestore storage with group and site id as folder and name as homeCon.useridTextController.value.text+'_'+homeCon.deviceNameRight+'_'+finalDate+".csv"

  => Device1 and Device2 Connection UI in DeviceConnectFormWidget Class(Stateful)
    -TextFieldContainer : (Saves automatically to shared pref on text change)
    -Contains CompanyCode readonly.
    -Edit button to change company code requires PassCode to change passCode not save in shared preference but company code is saved.
    -once the company is verified By API - {{SENSING_URL}}/public/api/v1/getSiteFromCompanyCode?company_code=C000000001&passcode=1234 returns sites which is saved once recived until companycode is changed.
    -Site dropdown is empty until company is not verified as soon as verified dropdown site items are received.
    -Contains UserId TextFormField useridTextController controller in homeController as obx, settings page and homepage userId same.
    -Contains Device1Connect Page as Device 1 Name(yearCombo+monthCombo+text) TextFormField controller in device1_controller.
    -Contains Device2Connect Page as Device 2 Name(yearCombo+monthCombo+text) TextFormField controller in device2_controller.

  => C\BM\BU (Stateless)
    -C (Current Average Pressure Value) (If User is Leader MasterAveragePressure else User Average Pressure Value)
    -BM (Base Master Pressure Value) (Master Pressure value when sensing was started)
    -BU (Base User) (User Pressure value when sensing was started)

  => VersionText (Stateless)  
    -Contains Version Detail of a current app version

  => AdminView/log (Stateless)
  -Contains device 1 and device 2 Realtime log view with Export Real log button onclick clears all log and saves the csv to downloads folder.
  -Only visible when Title F Sensing is clicked for 10 times

### Device1Connect.dart (lib/view/)

  => Device1Connect requires GetX(state management) controllers (device1_controller.dart || home_controller.dart || toast_message_controller.dart)
  => getPred() : getdeviceName1 if already saved before.
  => onChange Save device1 to shared preference.
  => This Device1 UI is called in HomePage view file.

### Device2Connect.dart (lib/view/)

  => Device2Connect requires GetX(state management) controllers (device1_controller.dart || home_controller.dart || toast_message_controller.dart)
  => getPred() : getdeviceName1 if already saved before.
  => onChange Save device1 to shared preference.
  => This Device2 UI is called in HomePage view file.

### BatteryValueLog.dart / Battery Value (lib/view/)

  => GetX(state management) Controller for this page is log_controller.dart.
  => Page to view Battery related log ,Database table name is _logTableBatteryValue
  => Home Page  App Bar 1st icon/battery icon to Navigate to this page.

### DeviceStatusLog.dart / Device Connection Status (lib/view/)

  => GetX(state management) Controller for this page is log_controller.dart.
  => Page to view Battery related log ,Database table name is _logTableDeviceConnection
  => Home Page  App Bar 2nd Device icon to Navigate to this page.

### DataLogPage.dart / Data List (lib/view/)

  => GetX(state management) Controller for this page is log_controller.dart.
  => Page to view Battery related log ,Database table name is _logTableDetectValue
  => Home Page  App Bar 3rd icon to Navigate to this page.

### SettingsPage.dart (lib/view/)

  => GetX(state management) Controller for SettingsPage is home_controller.dart.
  => contains textfields for log save control.
  => Company Code
  => UserId : Same field as home page user id needed for log userid.
  => Average max length (default 10) to get Average among (10) pressure values
  => Alert Timer (in Seconds) To Delay Stop Timer For Alert And Vibration
  => Endpoint Url : For Saving Data log to Api. (not Used)
  => X-api-key : key for API. (not Used)
  => Device 1 Service UUID. (4fafc201-1fb5-459e-8fcc-c5c9c331914b)
  => Device 1 Detect Value UUID. (beb5483e-36e1-4688-b7f5-ea07361b26a8)
  => Device 1 Real Value UUID. (b7db6729-5dcc-4f4f-9ae2-1fec4db3701a)
  => Device 1 Battery Value UUID. (cf7890fb-d86b-41d9-80bc-fcb2a7353a8f)
  => Device 1 Air Pressure Value UUID. (7043ea1a-fa87-4074-8981-e0534e996751)
  => Device 1 Temperature Value UUID. (f51fd052-8334-46e7-b09c-973a3f0568ff)
  => Device 2 Service UUID. (eb55b93d-7813-4221-ac3b-df7e3f6cadc6)
  => Device 2 Detect Value UUID. (beb5483e-36e1-4688-b7f5-ea07361b26a8)
  => Device 2 Real Value UUID. (b7db6729-5dcc-4f4f-9ae2-1fec4db3701a)
  => Device 2 Battery Value UUID. (cf7890fb-d86b-41d9-80bc-fcb2a7353a8f)
  => Device 2 Air Pressure Value UUID. (7043ea1a-fa87-4074-8981-e0534e996751)
  => Device 2 Temperature Value UUID. (f51fd052-8334-46e7-b09c-973a3f0568ff)
  => SaveButton saves to Shared Preferance / device storage.

### home_Controller.dart (lib/controller/)

  => Contains Bluetooth Permission and services check function for ios and android i.e iosGetBlueState & androidGetBlueLack.
  => Contains Setting page TextEditingControllers.
  => Contains Logo Animation variable.
  => Contains LogSave timers.
  => onInit() initially load all data and check bluetooth connection periodically every 2000 milliseconds
  => startForegroundTask() || stopForegroundTask() Start/Stop ForeGround Task
  => loadSettings() load settings data if previously saved from shared Preference(local storage) and set to settings page respective textfields
  => saveSetings() Save data to shared Preference(local Storage) called from settings page on save button click
  => checkCompanyAndValidate() check company called on 1st textfield Edit button opens a dialog where company code and pass code is required to verify if company is registered
  => onStartStopButtonClick() called on Start/Stop button click in home page to start or stop sensing bluetooth connection
  => checkAndStartSensing() called when onStartStopButtonClick() checks all the permissions and fields if ok this function is called where Api check is done checkBeforeStartApi which checks if all form value are ok then only bluetooth scanning and connection proccess is done
  => checkBeforeStartApi() checks if all form values are ok returns true false
  => startScanDevice2() called when checkBeforeStartApi() returns true then device 1 connects then only device 2 scan process is done whic is done by this function as parallel connection of 2 bluetooth device is not possible in current Ble flutter package
  => stopSensing() called when any bluetooth device connection is active and start/stop button is click this function is called
  => exportFileLogs() || setUpLogs() || doSetupForELKSchema() || doSetupForMQTT() || logData() || logToFile() || printAllLogs() || exportAllLogs() || printFileLogs() || setLogsStatus() for Flutter_log Package

### log_Controller.dart (lib/controller/)

  => Controller related to log  to Api / FireBase and local sqflite
  => insertLogLoaclAndApi:
    -check Internect connection first if Internet is Available then only setup log to firebase and local else do nothing
    -if eventUUID equal to Settings page device 1 Detect Value UUID save log to _logTableDetectValue. then if leader insertMasterWorkerLogsToFB else -insertWorkerStatustLogsToFB also insertLogToLocal
    -if eventUUID equal to Settings page device 1 Real Value UUID save log to_logTableRealValue. then insertLogToLocal.
    -if eventUUID equal to Settings page device 1 Battery Value UUID save log to_logTableBatteryValue. then insertLogToLocal.
    -if eventUUID equal to Settings page device 1 Pressure Value UUID save log to_logTableDetectValue. then insertLogToLocal.
    -if eventUUID equal to Settings page device 1 Temperature Value UUID save log_logTableDetectValue. then insertLogToLocal.
    -if eventUUID equal to Settings page device 2 Detect Value UUID save log to_logTableDetectValue. then if leader insertMasterWorkerLogsToFB else -insertWorkerStatustLogsToFB also insertLogToLocal
    -if eventUUID equal to Settings page device 2 Real Value UUID save log to_logTableRealValue. then insertLogToLocal.
    -if eventUUID equal to Settings page device 2 Battery Value UUID save log to_logTableBatteryValue. then insertLogToLocal.
    -if eventUUID equal to Settings page device 1 Pressure Value UUID save log to_logTableDetectValue. then insertLogToLocal.
    -if eventUUID equal to Settings page device 1 Temperature Value UUID save log_logTableDetectValue. then insertLogToLocal.
    -if devNo == '1' && devMainUUID != dev1ServiceUUID show showDeviceUUIDNotCorrectMsg
    -if devNo == '2' && devMainUUID != dev2ServiceUUID show showDeviceUUIDNotCorrectMsg
  => insertDeviceLog :
    -Device Connected Status Log Save to local database_logTableDeviceConnection
  => insertLogsToApi :
    -Insert Detect Log to Api if Api Toggle is on else wont save send to api. currently not used
  => insertWorkerStatustLogsToFB() insert worker data to Firebase to collection worker_status_latest and worker_status_history also checks checkAndPlayAlarm() to play or stop alarm/Vibration
  => checkAndPlayAlarm() checks if Alarm condition is met and play alarm (display height is greater than 2 || useStatusDev1=='1' && useStatusDev2=='1' || both device must be connected) then play alarm else stop alarm after delay as per seconds set in settings page Field Alarm Timer(in Seconds)
  => insertMasterWorkerLogsToFB() insert Master worker data to Firebase to collection master_worker
  => playAlert() if Play Alarm condition (display height is greater than 2 || useStatusDev1=='1' && useStatusDev2=='1' || both device must be connected) is meet then play alarm and set alert time and data to Firebase in alert_log collection
  => stopAlert() if (display height is greater than 2 || useStatusDev1=='1' && useStatusDev2=='1' || both device must be connected) condition is false stop alarm but with delay as per value set in settings page Alert Timer (in Seconds) Textfield
  => getPrettyJSONString() Convert to json type String required for insertLogsToApi()
  => format(hexStr) function to convert Pressure and temperature value to littleEndianVal with toStringAsFixed(4)
  => status() returns normal || warning || danger || null status as per useStatus of device 1 and device 2 for workers/Worker Status
  => Get and Delete logs for 4 local databases (getAllLogs() || getAllRealValueLogs() || getAllBatteryValueLogs() || getAllDeviceStatusValueLogs() || deleteAllLogs() || deleteAllRealLogs() || deleteAllBatteryLogs() || deleteAllDeviceConnectionLogs())
  => exportVoltageLog() export voltage log as a CSV file to Downloads folder called from Admin panel Export button
  => uploadLogToFirebase() upload csv file to firebase to storage path as "$companyId/$siteId/$fileName"

### device1_Controller.dart (lib/controller/)

  => This Controller Contains Bluetooth connection variables and deviceStatus for Device 1
  => dispose() Dispose Device 1 disposeCrontrolDevice() resets device 1 connection status
  => getHideConnectedDevice() gets hidden connections
  => StartScan() for device 1 as per text/device name in Device 1 TextFormField then start notify.
  => setDeviceControlDataDevice1 : Manage Service and Notify listener and log set as per services data recieved for device 1
  => saveLogs: Save device 1 logs with devName,dev1mainUUID ,uuid and data params then to insertLogLoaclAndApi in log Controller where logs are separated as per service uuid to know which data base to save.
  => stopDevice1Connection() stops device 1 connection status
  => requestStoragePermissionAndExport : Save Real Log to downloads folder for Device 1
  => addDeviceConnectedLogFbAndLocal() Add Connected Device Log to FireBase Device Status Latest And Device Status History Collection and Local
  => addDeviceDisconnectedLogFbAndLocal() Add Disconnected Device Log to FireBase Device Status Latest And Device Status History Collection and Local

### device2_Controller.dart (lib/controller/)

  => This Controller Contains Bluetooth connection variables and deviceStatus for Device 2
  => dispose() Dispose Device 2 disposeCrontrolDevice() resets device 2 connection status
  => getHideConnectedDevice() gets hidden connections
  => StartScan() for device 2 as per text/device name in Device 2 TextFormField then start notify.
  => setDeviceControlDataDevice2 : Manage Service and Notify listener and log set as per services data recieved for device 2
  => saveLogs: Save device 2 logs with devName,dev1mainUUID ,uuid and data params then to insertLogLoaclAndApi in log Controller where logs are separated as per service uuid to know which data base to save.
  => requestStoragePermissionAndExport : Save Real Log to downloads folder for Device 2
  => addDeviceConnectedLogFbAndLocal() Add Connected Device Log to FireBase Device Status Latest And Device Status History Collection and Local
  => addDeviceDisconnectedLogFbAndLocal() Add Disconnected Device Log to FireBase Device Status Latest And Device Status History Collection and Local

### toast_message_Controller.dart (lib/controller/)

  => Contains all SnackBar/toast messages
  
### audio_controller.dart (lib/controller/)

  => Audio Player is Initilized here
  => onInit() set player.setReleaseMode(ReleaseMode.STOP)
  => playConnectedAudio() Plays Device connected audio assets/audio/alert_connect.mp3
  => playAudio() Plays Alert audio from assets/audio/alert.mp3 and vibration until stop condition is meet
  => stopAudio() Stops Audio and vibration with delay as per settings textfield Alert Timer(in Seconds)

### connectivity_controller.dart (lib/controller/)

  => checkInitialConnectivity() checks for wifi network connection status at the start of app from main.dart page
  => checkForConnectivityChange() once checkInitialConnectivity() is called checkForConnectivityChange is called to listen changes in connectivity status /wifi change

### Style.dart (lib/common/)

  => Contains common style primaryColor & primarySwatch

### db_connection.dart (lib/helper/)

  => contains database related codes for CRRUD

### Save_file.dart (lib/helper/)

  => Main Controller for this page is LogController
  => generateExcel : Generates log in a Excel file
  => saveAndLaunchFile after generation of Excel Launch file to external app/Excel App Where u can download.

### ApiServices.dart (lib/Services/)

  => uploadToServer : Api to save detect log to api. where Api url and key from settings page / stored in shared preference/local Storage. (previous)
  => (now) contains check form Apis as companyCode validate and CheckFormOnSubmit

### FireStore_Services.dart (lib/Services/)

  => addHistory :: Add to worker_status_history with document name as workercode
  => updateLatest :: Update to worker_status_latest
  => addLatest :: Add to worker_status_latest with document name as workercode
  => checkAndGetLatestCollectionUserDocId :: check if document already exist in worker_status_latest collection if document found as per worker code returns document name.
  => checkAndGetLatestDeviceCollectionDocId :: check if document already exist in device_status_latest collection if document found as per worker code returns document name.
  => addDeviceStatusHistory :: Add to device_status_history with document name as workercode
  => updateDeviceStatusLatest :: Update to device_status_latest
  => addDeviceStatusLatest :: Add to device_status_latest with document name as workercode
  => worker_status set and sent to firebase as per detect value received as follows::
  0  0 = normal
  0  1 or 1  0 = warning
  1  1 = danger

### lable_widget.dart (lib/widgets/)

  => Commomn Lable Widget Design used in home_page.dart, Settings_page.dart

### company_verify_dialog.dart (lib/widgets/)

  => Widget to show Pop up Dialog opened from Homepage Edit Button to verify company registered contains Company code and pass code textfield and cancle and verify button

### admin_log_view.dart (lib/widgets/)

  => Admin view widget called in home_page.dart visible when title is clicked 10 times in homepage appbar.

### constants.dart (lib/common/)

  => Contains common baseUrl (Api) and firebase collection variable and names

### dio_client.dart (lib/common/)

  => Contains common dio (Api request) Base Options as baseUrl and headers

### style.dart (lib/common/)

  => Contains all styles and colors for the app

### db_connection.dart (lib/helper)

  => Contains all database connection and initialization for sqflite/local database for tables (_logTableDetectValue||_logTableRealValue||_logTableBatteryValue||_logTableDeviceConnection)

### formatter.dart (lib/helper)

  => format() to format value greater than 5 to length 5 number

### height_alert_calculation.dart (lib/helper)

  => heightAlertCalculation(displayResultValue) calculates height alert status
  => if displayResultValue>=0 && displayResultValue<2 then "normal-state"
  => if displayResultValue>=2 && displayResultValue<5 then "alert-state"
  => if displayResultValue>=5 && displayResultValue<10 then "warning-state"
  => if displayResultValue>=10 then "danger-state"
  => if displayResultValue!=null then null

### height_calculation.dart (lib/helper)

  => actualheightCalculation(a,b,c,d) calculates actual height a=pressureValue , b=masterPressureValue,c=userMasterPressureValue,d=baseMasterPressureValue
  => formulaResult = ((pressure-masterPressure)-(userMasterPressure-baseMasterPressure))*(-8.33) formula for actual height calculation
  => displayheightCalculation(a,b,c,d) calculates displayHeight where if actual height is less than 0 shows 0
  => formula is same as actual height calculation

### pref_helper.dart (lib/helper)

  => checkIsLeader() function to check leader here this value is saved once user,company,site and devices is verified in api and returns user and data before bluetooth connection starts

### save_file.dart (lib/helper)

  => Contains row and values to save for Csv file generation
  