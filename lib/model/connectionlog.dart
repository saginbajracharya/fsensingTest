class DataLog {
  final int? id;
  final int? requestid;
  final String userid;
  final int deviceno1;
  final String deviceid1;
  final int? usestatus1;
  final int? failstatus1;
  final String? failmessage1;
  final String? faildatetime1;
  final int deviceno2;
  final String deviceid2;
  final int usestatus2;
  final int? failstatus2;
  final String? failmessage2;
  final String? faildatetime2;
  final String createddatetime;
  final String apiResponse;
  final String apiResponseDateTime;

  DataLog(
      {this.id,
      this.requestid,
      required this.userid,
      required this.deviceno1,
      required this.deviceid1,
      required this.usestatus1,
      required this.failstatus1,
      required this.failmessage1,
      required this.faildatetime1,
      required this.deviceno2,
      required this.deviceid2,
      required this.usestatus2,
      required this.failstatus2,
      required this.failmessage2,
      required this.faildatetime2,
      required this.createddatetime,
      required this.apiResponse,
      required this.apiResponseDateTime,
      }
  );

  DataLog.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        userid = res["userid"],
        requestid = res["requestid"],
        deviceno1 = res["deviceno1"],
        deviceid1 = res["deviceid1"],
        usestatus1 = res["use_status1"],
        failstatus1 = res["fail_status1"],
        failmessage1 = res["fail_message1"],
        faildatetime1 = res["fail_datetime1"],
        deviceno2 = res["deviceno2"],
        deviceid2 = res["deviceid2"],
        usestatus2 = res["use_status2"],
        failstatus2 = res["fail_status2"],
        failmessage2 = res["fail_message2"],
        faildatetime2 = res["fail_datetime2"],
        createddatetime = res["created_datetime"],
        apiResponse = res["api_response"],
        apiResponseDateTime = res["api_response_datetime"];

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'userid': userid,
      'requestid': requestid,
      'deviceno1': deviceno1,
      'deviceid1': deviceid1,
      'use_status1': usestatus1,
      'fail_status1': failstatus1,
      'fail_message1': failmessage1,
      'fail_datetime1': faildatetime1,
      'deviceno2': deviceno2,
      'deviceid2': deviceid2,
      'use_status2': usestatus2,
      'fail_status2': failstatus2,
      'fail_message2': failmessage2,
      'fail_datetime2': faildatetime2,
      'created_datetime': createddatetime,
      'api_response': apiResponse,
      'api_response_datetime' : apiResponseDateTime,
    };
  }
}
