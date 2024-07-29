 
class MyHomeData {
  final String startDate;
  final String endDate;
  final String address;
  final String buildingNo;
  final String flatNo;
  final String maintenanceBorne;
  final String borneType;
  final String borneAmount;

  MyHomeData({
    required this.startDate,
    required this.endDate,
    required this.address,
    required this.buildingNo,
    required this.flatNo,
    required this.maintenanceBorne,
    required this.borneType,
    required this.borneAmount,
  });

  factory MyHomeData.fromJson(Map<String, dynamic> json) {
    return MyHomeData(
      startDate: json['start_date'],
      endDate: json['end_date'],
      address: json['address'],
      buildingNo: json['building_no'],
      flatNo: json['flat_no'],
      maintenanceBorne: json['maintenance_borne'],
      borneType: json['borne_type'],
      borneAmount: json['borne_amount'],
    );
  }
}
 