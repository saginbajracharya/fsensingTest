import 'package:cloud_firestore/cloud_firestore.dart';

class NormalWorker
{
  final int ? workerId;
  final int ? companyId;
  final int ? groupId;
  final int ? siteId;
  final String ? workerCode;
  final String ? workerName;
  final String ? workerProfileImageUrl;
  final String ? workerStatus; 
  final String ? rightDeviceId;
  final String ? leftDeviceId;
  final String ? rightBatteryValue;
  final String ? leftBatteryValue;
  final String ? rightFailureValue;
  final String ? leftFailureValue;
  final String ? useRightStatus;
  final String ? useLeftStatus;
  final String ? temperatureValue;
  final String ? pressureValue;
  final int ? startTime;
  final bool ? startHeightCalculation;
  final String ? masterPressureValue;
  final String ? baseUserPressureValue;
  final double ? actualHeightM;
  final double ? displayHeightM;
  final String ? heightAlertClass;

  NormalWorker({
    this.workerId,
    this.companyId,
    this.groupId,
    this.siteId,
    this.workerCode,
    this.workerName,
    this.workerProfileImageUrl,
    this.workerStatus,
    this.rightDeviceId,
    this.leftDeviceId,
    this.rightBatteryValue,
    this.leftBatteryValue,
    this.rightFailureValue,
    this.leftFailureValue,
    this.useRightStatus,
    this.useLeftStatus,
    this.temperatureValue,
    this.pressureValue,
    this.startTime,
    this.startHeightCalculation,
    this.masterPressureValue,
    this.baseUserPressureValue,
    this.actualHeightM,
    this.displayHeightM,
    this.heightAlertClass,
  });

  factory NormalWorker.fromDocumentSnapshot({required DocumentSnapshot<Map<String,dynamic>> doc})
  {
    return NormalWorker(
      workerId                : doc['worker_id'],
      companyId               : doc['company_id'],
      groupId                 : doc['group_id'],
      siteId                  : doc['site_id'],
      workerCode              : doc['worker_code'],
      workerName              : doc['worker_name'],
      workerProfileImageUrl   : doc['worker_profile_image_url'],
      workerStatus            : doc['worker_status'],
      rightDeviceId           : doc['right_device_id'],
      leftDeviceId            : doc['left_device_id'],
      rightBatteryValue       : doc['right_battery_value'].toString(),
      leftBatteryValue        : doc['left_battery_value'].toString(),
      rightFailureValue       : doc['right_failure_value'],
      leftFailureValue        : doc['left_failure_value'],
      useRightStatus          : doc['left_useleft_status'],
      useLeftStatus           : doc['right_useright_status'],
      temperatureValue        : doc['temperature_value'],
      pressureValue           : doc['pressure_value'],
      startTime               : doc['start_time'],
      startHeightCalculation  : doc['start_height_calculation'],
      masterPressureValue     : doc['base_master_pressure_value'],
      baseUserPressureValue   : doc['base_user_pressure_value'],
      actualHeightM           : doc['actual_height_m'],
      displayHeightM          : doc['display_height_m'],
      heightAlertClass        : doc['height_alert_class'],
    );
  }
}