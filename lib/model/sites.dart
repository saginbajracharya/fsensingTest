import 'dart:convert';

Sites sitesFromJson(String str) => Sites.fromJson(json.decode(str));

String sitesToJson(Sites data) => json.encode(data.toJson());

class Sites {
  Sites({
    this.success,
    this.data,
    this.code,
  });

  bool? success;
  List<SiteData>? data;
  int? code;

  factory Sites.fromJson(Map<String, dynamic> json) => Sites(
    success: json["success"],
    data: List<SiteData>.from(json["data"].map((x) => SiteData.fromJson(x))),
    code: json["code"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": List<dynamic>.from(data!.map((x) => x.toJson())),
    "code": code,
  };
}

class SiteData {
  SiteData({
    this.id,
    this.code,
    // this.companyId,
    // this.groupId,
    this.siteName,
    // this.address,
    // this.memo,
    // this.siteIncharge,
    // this.phone,
    // this.startDate,
    // this.endDate,
  });

  int? id;
  String? code;
  // int? companyId;
  // int? groupId;
  String? siteName;
  // String? address;
  // String? memo;
  // String? siteIncharge;
  // String? phone;
  // String? startDate;
  // String? endDate;

  factory SiteData.fromJson(Map<String, dynamic> json) => SiteData(
    id: json["id"],
    code: json["code"],
    // companyId: json["company_id"],
    // groupId: json["group_id"],
    siteName: json["site_name"] ?? "",
    // address: json["address"] ?? "",
    // memo: json["memo"] ?? "",
    // siteIncharge: json["site_incharge"],
    // phone: json["phone"] ?? "",
    // startDate: json["start_date"],
    // endDate: json["end_date"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    // "company_id": companyId,
    // "group_id": groupId,
    "site_name": siteName,
    // "address": address ?? '',
    // "memo": memo ?? '',
    // "siteIncharge": siteIncharge,
    // "phone": phone ?? '',
    // "start_date": startDate,
    // "end_date": endDate,
  };
}
