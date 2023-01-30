import 'package:blue/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

checkIsLeader()async{
  final HomeController homeCon = Get.find();
  final prefs = await SharedPreferences.getInstance();
  homeCon.isLeader = prefs.getInt('isLeader'); 
}

checkUserId()async{
  final HomeController homeCon = Get.find();
  final prefs = await SharedPreferences.getInstance();
  homeCon.companyId = prefs.getInt('companyId');
  homeCon.groupId = prefs.getInt('groupId');
  homeCon.siteId = prefs.getInt('siteId');
}