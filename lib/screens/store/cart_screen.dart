import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/screens/store/checkout.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'cart_controller.dart';

class CartPage extends StatelessWidget {
  final CartController cartController = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.cart, style: primaryTextStyle()),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              cartController.clearCart();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (cartController.cartItems.isEmpty) {
          return Center(
              child: Text(
            language.yourCartIsEmpty,
            style: primaryTextStyle(),
          ));
        } else {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartController.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartController.cartItems[index];
                    return Card(
                        margin: EdgeInsets.all(8),
                        color: appStore.isDarkMode
                            ? Colors.black38
                            : const Color(0xffffffff),
                        child: ShowUp(
                          child: ListTile(
                              leading: SizedBox(
                                  width: 60, // Adjust the width as needed
                                  child: (item.product.attachments.isEmpty)
                                      ? CachedNetworkImage(
                                          imageUrl:
                                              'https://via.assets.so/shoe.png?id=1&q=95&w=360&h=360&fit=fill',
                                          fit: BoxFit.cover,
                                          height: 80,
                                          placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Image.network(
                                            'https://via.assets.so/shoe.png?id=1&q=95&w=360&h=360&fit=fill',
                                            fit: BoxFit.cover,
                                            height: 80,
                                          ),
                                        )
                                      : CachedNetworkImage(
                                          imageUrl: item.product.attachments !=
                                                      null &&
                                                  item.product.attachments
                                                      .isNotEmpty
                                              ? item.product.attachments.first
                                              : '',
                                          fit: BoxFit.cover,
                                          height: 80,
                                          placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Image.network(
                                            'https://via.assets.so/shoe.png?id=1&q=95&w=360&h=360&fit=fill',
                                            fit: BoxFit.cover,
                                            height: 80,
                                          ),
                                        )),
                              title: Text(
                                item.product.name,
                                style:
                                    primaryTextStyle(weight: FontWeight.bold),
                              ),
                              subtitle: Padding(
                                  padding: EdgeInsetsDirectional.only(top: 20),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 40,
                                        padding: EdgeInsets.all(8),
                                        decoration:
                                            boxDecorationWithRoundedCorners(
                                          backgroundColor:
                                              context.scaffoldBackgroundColor,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.arrow_drop_down_sharp,
                                                    size: 24)
                                                .onTap(
                                              () {
                                                if (item.quantity > 1) {
                                                  cartController.updateQuantity(
                                                      item, item.quantity - 1);
                                                }
                                              },
                                            ),
                                            16.width,
                                            Text(item.quantity.toString(),
                                                style: primaryTextStyle()),
                                            16.width,
                                            Icon(Icons.arrow_drop_up_sharp,
                                                    size: 24)
                                                .onTap(
                                              () {
                                                cartController.updateQuantity(
                                                    item, item.quantity + 1);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      15.width,
                                      Text(
                                        '${item.product.price} د.ر',
                                        style: primaryTextStyle(size: 20),
                                      ),
                                    ],
                                  )),
                              trailing: Column(children: [
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    cartController.removeItem(item);
                                  },
                                ),
                              ])),
                        ));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(language.hintSubtotalTxt,
                            style: primaryTextStyle(size: 18)),
                        Text(
                          '${cartController.cartItems.fold<double>(0, (sum, item) => sum + item.product.price * item.quantity).toStringAsFixed(2)} د.ر',
                          style: primaryTextStyle(size: 18),
                        ),
                      ],
                    ),
                    10.height,
                    AppButton(
                      width: 370,
                      onTap: () {
                        doIfLoggedIn(context, () {
                          pop();
                          CheckoutPage().launch(context);
                        });
                      },
                      color: context.primaryColor,
                      child: Text(language.proceedToCheckout,
                          style: boldTextStyle(color: white)),
                      textColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      }),
    );
  }
}
