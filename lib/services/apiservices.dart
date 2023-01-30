import 'package:blue/controllers/toast_message_controller.dart';
import 'package:blue/helper/db_connection.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'package:blue/common/dio_client.dart';
import 'package:blue/model/sites.dart';
import 'package:dio/dio.dart';

class ApiEndpointRepo {
  final dbHelper = DatabaseHandler.instance;
  var count = 0;

  uploadToServer(data, id) async {
    final prefs = await SharedPreferences.getInstance();
    var url = prefs.getString('apiendpoint').toString();
    var xapikey = prefs.getString('xapikey').toString();
    var response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'x-api-key': xapikey},
        body: data);
    // ignore: unnecessary_null_comparison
    if (response != null) {
      count = 1;
      dbHelper.updateLog(response.body, id,'');
    }

    if (kDebugMode) {
      print('Response status: $response');
      print('Response body: ${response.body}');
    }
  }

  checkCompany(companyCode,passCode) async {
    try {
      var response = await dio.get(
        'getSiteFromCompanyCode?company_code=$companyCode&passcode=$passCode',
      );
      if (response.statusCode == 200 && response.data["success"] == true) {
        var data = Sites.fromJson(response.data);
        return data.data;
      } else {
        return null;
      }
    } on DioError catch (e) {
      if(e.response == null ){
        ToastMessageController toastMsgCon = Get.find();
        toastMsgCon.showToastMessage(e.message);  
      }
      else{
        if(e.response!.data!= null){
          if(e.response!.data!["error"] is String){
            ToastMessageController toastMsgCon = Get.find();
            toastMsgCon.showToastMessage(e.response!.data!["error"]);
          }
          else{
            if(e.response!.data!["error"]!=null){
              e.response!.data!["error"].forEach((key, value){
                ToastMessageController toastMsgCon = Get.find();
                toastMsgCon.showToastMessage(value[0]);
              });
            }
          }
        }
      }
      return null;
    } catch (e) {
      ToastMessageController toastMsgCon = Get.find();
      toastMsgCon.showToastMessage(e.toString());
      return null;
    }
  }
  
  checkOnSubmit(companyCode,siteId,staffCode,deviceLeft,deviceRight) async {
    try {
      var data = {
        'company_code': companyCode.toString(),
        "site_id": siteId.toString(),
        "staff_code":staffCode.toString(),
        "device_left":deviceLeft.toString(),
        "device_right":deviceRight.toString(),
      };
      dynamic params = jsonEncode(data);
      var response = await dio.post(
        'checkFormData',
        data: params
      );
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setInt('companyId', response.data['data']["companyId"]);
        prefs.setInt('groupId', response.data['data']["groupId"]);
        prefs.setInt('siteId', response.data['data']["siteId"]);
        prefs.setInt('workerId', response.data['data']["workerId"]);
        prefs.setString('workerName', response.data['data']["workerName"]);
        prefs.setString('workerProfileImageUrl', response.data['data']["workerProfileImageUrl"]);
        prefs.setInt('isLeader', response.data['data']["is_leader"]);
        return response.data["success"];
      } else {
        return false;
      }
    } on DioError catch (e) {
      if(e.response!= null){
        if(e.response!.data!= null){
          e.response!.data!["error"].forEach((key, value){
            ToastMessageController toastMsgCon = Get.find();
            toastMsgCon.showToastMessage(value[0]);
            // print('key is $key');
            // print('value is $value ');
          });
        }
      }else{
        ToastMessageController toastMsgCon = Get.find();
        toastMsgCon.showToastMessage(e.message);
      }
      return false;
    } catch (e) {
      ToastMessageController toastMsgCon = Get.find();
      toastMsgCon.showToastMessage(e.toString());
      return false;
    }
  }

  alertLog(companyId,siteId,groupId,userId,alertType,alertDate,alertTime)async{
    try{
      var data = {
        "company_id": companyId.toString(),
        "site_id": siteId.toString(),
        "group_id":groupId.toString(),
        "user_id":userId.toString(),
        "alert_type":alertType.toString(),
        "alert_date":alertDate.toString(),
        "alert_time":alertTime.toString(),
      };
      dynamic params = jsonEncode(data);
      var response = await dio.post(
        'alert-log',
        data: params
      );
      if (response.statusCode == 200) {
        return response.data["success"];
      } else {
        return false;
      }
    } on DioError catch (e) {
      if(e.response!= null){
        if(e.response!.data!= null){
          e.response!.data!["error"].forEach((key, value){
            ToastMessageController toastMsgCon = Get.find();
            toastMsgCon.showToastMessage(value[0]);
            // print('key is $key');
            // print('value is $value ');
          });
        }
      }else{
        ToastMessageController toastMsgCon = Get.find();
        toastMsgCon.showToastMessage(e.message);
      }
      return false;
    } catch (e) {
      ToastMessageController toastMsgCon = Get.find();
      toastMsgCon.showToastMessage(e.toString());
      return false;
    }
  }
}
