import 'package:cloud_firestore/cloud_firestore.dart';

class MasterWorker
{
  final int ? id;
  final int ? companyId;
  final int ? groupId;
  final int ? siteId;
  final String ? code;
  final String ? name;
  final String ? pressureValue;
  final String ? profileImageUrl;
  final String ? status; 
  final String ? averagePressureValue;

  MasterWorker({
    this.id,
    this.companyId,
    this.groupId,
    this.siteId,
    this.code,
    this.name,
    this.pressureValue,
    this.profileImageUrl,
    this.status,
    this.averagePressureValue
  });

  factory MasterWorker.fromDocumentSnapshot({required DocumentSnapshot<Map<String,dynamic>> doc})
  {
    return MasterWorker(
      id              : doc['id'],
      companyId       : doc['company_id'],
      groupId         : doc['group_id'],
      siteId          : doc['site_id'],
      code            : doc['code'].toString(),
      name            : doc['name'].toString(),
      pressureValue   : doc['pressure_value'].toString(),
      profileImageUrl : doc['profile_image_url'].toString(),
      status          : doc['status'].toString(),
      averagePressureValue:  doc['average_pressure_value'].toString(),
    );
  }
}