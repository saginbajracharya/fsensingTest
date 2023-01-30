import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityController extends GetxController{
  String result = '';
  String internet = '';
  RxBool online = true.obs;

  checkInitialConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      online.value = true;
    } else {
      online.value = false;
    }
    checkForConnectivityChange();
  }

  checkForConnectivityChange() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
        online.value = true;
      }
      else{
        online.value = false;
      }
    });
  }
}