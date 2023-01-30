import 'package:flutter_blue_elves/flutter_blue_elves.dart';

class ServiceListItem {
  // ignore: unused_field
  final BleService serviceInfo;
  // ignore: prefer_final_fields, unused_field
  bool isExpanded;

  ServiceListItem(this.serviceInfo, this.isExpanded);
}