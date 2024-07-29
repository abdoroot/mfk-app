import 'package:booking_system_flutter/model/product_data_model.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';

class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    loadCartItems();
  }

  void loadCartItems() {
    List<dynamic> storedItems = box.read<List<dynamic>>('cartItems') ?? [];
    cartItems.assignAll(
        storedItems.map((e) => CartItem.fromJson(json.decode(e))).toList());
  }

  void saveCartItems() {
    List<String> items = cartItems.map((e) => json.encode(e.toJson())).toList();
    box.write('cartItems', items);
  }

  void addToCart(ProductModel product, {int quantity = 1}) {
    var existingItem =
        cartItems.firstWhereOrNull((item) => item.product.id == product.id);
    if (existingItem != null) {
      existingItem.quantity += quantity;
    } else {
      cartItems.add(CartItem(product: product, quantity: quantity));
    }
    cartItems.refresh(); // Ensure the UI is updated
    saveCartItems();

    update();
  }

  void removeItem(CartItem item) {
    cartItems.remove(item);
    saveCartItems();
  }

  void updateQuantity(CartItem item, int quantity) {
    item.quantity = quantity;
    cartItems.refresh(); // Ensure the UI is updated
    saveCartItems();

    update();
  }

  void clearCart() {
    cartItems.clear();
    saveCartItems();
  }
}

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: ProductModel.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }
}
