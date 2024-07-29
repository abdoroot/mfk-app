import 'package:booking_system_flutter/model/product_data_model.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';

import 'pagination_model.dart';

class SingelProductResponse {
  ProductModel? Product;
  UserData? provider;

  SingelProductResponse({
    this.Product,
    this.provider,
  });

  factory SingelProductResponse.fromJson(Map<String, dynamic> json) {
    return SingelProductResponse(
      Product: json['item_detail'] != null
          ? ProductModel.fromJson(json['item_detail'])
          : null,
      provider:
          json['provider'] != null ? UserData.fromJson(json['provider']) : null,
    );
  }
}

class ProductResponse {
  List<ProductModel>? ProductList;
  Pagination? pagination;
  int? max;
  int? min;
  List<ProductModel>? userProducts;

  ProductResponse(
      {this.ProductList,
      this.pagination,
      this.max,
      this.min,
      this.userProducts});

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      ProductList: json['data'] != null
          ? (json['data'] as List).map((i) => ProductModel.fromJson(i)).toList()
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
    if (this.ProductList != null) {
      data['data'] = this.ProductList!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }

    return data;
  }
}
