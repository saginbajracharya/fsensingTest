import 'package:dio/dio.dart';
import 'package:blue/common/constants.dart' as constants;

final dio = Dio(
  BaseOptions(
    baseUrl:constants.baseUrl,
    headers: <String, String>{
      "Content-Type": "application/json",
      "Accept": "application/json",
    },
    receiveDataWhenStatusError: true,
  ),
);