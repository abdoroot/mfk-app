import 'package:booking_system_flutter/model/my_home_data_model.dart';
import 'package:booking_system_flutter/model/plans_data.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';

import 'pagination_model.dart';

class MyHomeResponse {
  final MyHomeData? data;

  MyHomeResponse({required this.data});

  factory MyHomeResponse.fromJson(Map<String, dynamic> json) {
    return MyHomeResponse(
      data: json['data']  == null ? null  :MyHomeData.fromJson(json['data']),
    );
  }

 
}