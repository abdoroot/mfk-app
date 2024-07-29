import 'package:booking_system_flutter/model/plans_data.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';

import 'pagination_model.dart';

class MyPlanResponse {
  PlansData? plan;

  MyPlanResponse({this.plan});

  factory MyPlanResponse.fromJson(Map<String, dynamic> json) {
    return MyPlanResponse(
      plan: json['service_detail'] != null
          ? PlansData.fromJson(json['service_detail'])
          : null,
    );
  }
}

class PlansResponse {
  List<PlansData>? plansList;
  Pagination? pagination;
  int? max;
  int? min;

  PlansResponse({this.plansList, this.pagination, this.max, this.min});

  factory PlansResponse.fromJson(Map<String, dynamic> json) {
    return PlansResponse(
      plansList: json['data'] != null
          ? (json['data'] as List).map((i) => PlansData.fromJson(i)).toList()
          : null,
      max: json['max'],
      min: json['min'],
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['max'] = this.max;
    data['min'] = this.min;
    if (this.plansList != null) {
      data['data'] = this.plansList!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }

    return data;
  }
}

class singelPlanResponse {
  PlansData? plansList;
  Pagination? pagination;
  int? max;
  int? min;

  singelPlanResponse({this.plansList, this.pagination, this.max, this.min});

  factory singelPlanResponse.fromJson(Map<String, dynamic> json) {
    return singelPlanResponse(
      plansList: json['data'] != null ? PlansData.fromJson(json['data']) : null,
      max: json['max'],
      min: json['min'],
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['max'] = this.max;
    data['min'] = this.min;

    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }

    return data;
  }
}

class HistoryPlanResponse {
  List<HistoryPlanData>? plan;
  Pagination? pagination;
  int? max;
  int? min;

  HistoryPlanResponse({this.plan, this.pagination, this.max, this.min});

  factory HistoryPlanResponse.fromJson(Map<String, dynamic> json) {
    return HistoryPlanResponse(
      plan: json['data'] != null
          ? (json['data'] as List)
              .map((i) => HistoryPlanData.fromJson(i))
              .toList()
          : null,
      max: json['max'],
      min: json['min'],
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['max'] = this.max;
    data['min'] = this.min;

    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }

    return data;
  }
}
