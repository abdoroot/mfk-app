import 'package:booking_system_flutter/model/booking_data_model.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:nb_utils/nb_utils.dart';

import 'pagination_model.dart';

class BookingListResponse {
  List<BookingData>? data;
  Pagination? pagination;

  BookingListResponse({this.data, this.pagination});

  factory BookingListResponse.fromJson(Map<String, dynamic> json) {
    return BookingListResponse(
      data: json['data'] != null
          ? (json['data'] as List).map((i) => BookingData.fromJson(i)).toList()
          : null,
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}

class OrderData {
  final int id;
  final String shippingAddress;
  final int customerId;
  final List<Item> items;
  final String createdAt;
  final dynamic? price;
  final String? type;
  final dynamic? discount;
  final String status;
  final String statusLabel;
  final String? description;
  final String customerName;
  final int? paymentId;
  final String? paymentStatus;
  final String? paymentMethod;
  final int? quantity;
  final String? couponData;
  final dynamic totalAmount;
  final dynamic amount;

  OrderData({
    required this.id,
    required this.shippingAddress,
    required this.customerId,
    required this.items,
    required this.createdAt,
    this.price,
    this.type,
    this.discount,
    required this.status,
    required this.statusLabel,
    this.description,
    required this.customerName,
    this.paymentId,
    this.paymentStatus,
    this.paymentMethod,
    this.quantity,
    this.couponData,
    required this.totalAmount,
    required this.amount,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      id: json['id'],
      shippingAddress: json['shipping_address'],
      customerId: json['customer_id'],
      items: (json['items'] as List<dynamic>)
          .map((item) => Item.fromJson(item))
          .toList(),
      createdAt: json['created_at'],
      price:
          json['price'] != null ? double.parse(json['price'].toString()) : null,
      type: json['type'],
      discount: json['discount'] != null
          ? double.parse(json['discount'].toString())
          : null,
      status: json['status'],
      statusLabel: json['status_label'],
      description: json['description'],
      customerName: json['customer_name'],
      paymentId: json['payment_id'],
      paymentStatus: json['payment_status'],
      paymentMethod: json['payment_method'],
      quantity: json['quantity'],
      couponData: json['coupon_data'],
      totalAmount: double.parse(json['total_amount'].toString()),
      amount: double.parse(json['amount'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shipping_address': shippingAddress,
      'customer_id': customerId,
      'items': items.map((item) => item.toJson()).toList(),
      'price': price,
      'type': type,
      'discount': discount,
      'status': status,
      'status_label': statusLabel,
      'description': description,
      'customer_name': customerName,
      'payment_id': paymentId,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'quantity': quantity,
      'coupon_data': couponData,
      'total_amount': totalAmount,
      'amount': amount,
    };
  }
}

class Item {
  final String id;
  final String name;
  final double price;
  final double amount;
  final dynamic quantity;
  final List<String> attachments;

  Item({
    required this.id,
    required this.name,
    required this.price,
    required this.amount,
    required this.quantity,
    required this.attachments,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      price: json['price'].toString().toDouble(),
      amount: json['amount'].toString().toDouble(),
      quantity: json['quantity'],
      attachments: List<String>.from(json['attachments']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'amount': amount,
      'quantity': quantity,
      'attachments': attachments,
    };
  }
}

class OrderListResponse {
  List<OrderData>? data;
  Pagination? pagination;

  OrderListResponse({this.data, this.pagination});

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    return OrderListResponse(
      data: json['data'] != null
          ? (json['data'] as List).map((i) => OrderData.fromJson(i)).toList()
          : null,
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}

class Handyman {
  int? bookingId;
  String? createdAt;
  String? deletedAt;
  UserData? handyman;
  int? handymanId;
  int? id;
  String? updatedAt;

  Handyman(
      {this.bookingId,
      this.createdAt,
      this.deletedAt,
      this.handyman,
      this.handymanId,
      this.id,
      this.updatedAt});

  factory Handyman.fromJson(Map<String, dynamic> json) {
    return Handyman(
      bookingId: json['booking_id'],
      createdAt: json['created_at'],
      deletedAt: json['deleted_at'],
      handyman:
          json['handyman'] != null ? UserData.fromJson(json['handyman']) : null,
      handymanId: json['handyman_id'],
      id: json['id'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['booking_id'] = this.bookingId;
    data['created_at'] = this.createdAt;
    data['deleted_at'] = this.deletedAt;
    data['handyman_id'] = this.handymanId;
    data['id'] = this.id;
    data['updated_at'] = this.updatedAt;
    if (this.handyman != null) {
      data['handyman'] = this.handyman!.toJson();
    }
    return data;
  }
}
