import 'package:booking_system_flutter/component/base_scaffold_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/configuration_response.dart';
import 'package:booking_system_flutter/model/product_data_model.dart';
import 'package:booking_system_flutter/network/network_utils.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/service/myOrder_screen.dart';
import 'package:booking_system_flutter/screens/wallet/user_wallet_balance_screen.dart';
import 'package:booking_system_flutter/services/stripe_service_new.dart';
import 'package:booking_system_flutter/store/app_store.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'cart_controller.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';

import 'dart:convert';

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final CartController cartController = Get.put(CartController());
  final TextEditingController shippingAddressController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<PaymentSetting> paymentList = [];
  PaymentSetting? currentPaymentMethod;
  String paymentType = "cash";

  bool checkoutByCredit = true;
  bool checkoutByCash = false;

  @override
  void initState() {
    super.initState();
    // Load payment settings
    loadPaymentSettings();
    updateAmount();
  }

  void loadPaymentSettings() {
    // Example data, replace with your actual data loading logic
    paymentList = [
      PaymentSetting(title: "Credit Card", type: "stripe", status: 1),
      PaymentSetting(title: "Cash", type: "cash", status: 1),
    ];
    currentPaymentMethod = paymentList.first;
  }

  void savePay(String orderID,
      {String txnId = '',
      String paymentMethod = '',
      String paymentStatus = ''}) async {
    // Save payment logic here
    appStore.setLoading(true);
    Map request = {
      'order_id': orderID,
      CommonKeys.customerId: appStore.userId,
      CommonKeys.paymentStatus: paymentStatus,
      CommonKeys.paymentMethod: paymentMethod,
    };
    saveOrderPayment(request).then((value) async {
      appStore.setLoading(false);
      cartController.clearCart();

      await Future.delayed(Duration(seconds: 2));
      Navigator.pop(context);
      Navigator.pop(context);
      push(MyOrderScreen(),
          isNewTask: false, pageRouteAnimation: PageRouteAnimation.Fade);
      Get.snackbar('Success', 'Order Paid successfully');

      push(MyOrderScreen(),
          isNewTask: false, pageRouteAnimation: PageRouteAnimation.Fade);
    }).catchError((e) {
      toast(e.toString());
      appStore.setLoading(false);
    });
  }

  void showThankYouDialog(bool payStatus) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 100),
              20.height,
              Text(
                language.thankYou,
                style: primaryTextStyle(size: 24, weight: FontWeight.bold),
              ),
              10.height,
              Text(
                language.orderSuccess,
                textAlign: TextAlign.center,
                style: primaryTextStyle(size: 16),
              ),
              20.height,
              InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                      width: 160,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Center(
                        child: Text(
                          language.close,
                          style: primaryTextStyle(
                              color: Colors.white, weight: FontWeight.bold),
                        ),
                      )))
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.pop(context);
              //   },
              //   child: Text(
              //     language.close,
              //     style: primaryTextStyle(),
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }

  double amount = 85.0;
  double tax = 5;
  double discount = 0.0;
  double totalAmount = 89.25;
  void updateAmount() {
    amount = cartController.cartItems.fold<double>(
        0,
        (sum, item) =>
            sum +
            (item.product.price - int.parse(item.product.discount ?? '0')) *
                item.quantity);

    tax = 0.05 * amount;

    totalAmount = amount + tax;
  }

  Future<void> createOrder(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        var queryParams = {
          "amount": cartController.cartItems
              .fold<double>(
                  0, (sum, item) => sum + item.product.price * item.quantity)
              .toInt()
              .toString(),
          "tax": '5', // يمكنك حساب الضريبة بناءً على السلة
          "discount": '0.0', // يمكنك حساب الخصم بناءً على السلة
          "total_amount": cartController.cartItems
              .fold<double>(
                  0, (sum, item) => sum + item.product.price * item.quantity)
              .toString(),
          "shipping_address": shippingAddressController.text,
          "payment_type": paymentType,
        };

        for (int i = 0; i < cartController.cartItems.length; i++) {
          final item = cartController.cartItems[i];
          queryParams["items[$i][id]"] = item.product.id.toString();
          queryParams["items[$i][quantity]"] = item.quantity.toString();
          queryParams["items[$i][price]"] = item.product.price.toString();
        }

        String url = 'http://mfk.ae/api/store-item-order';
        String queryString = Uri(queryParameters: queryParams).query;
        String fullUrl = '$url?$queryString';

        var response = await handleResponse(await buildHttpResponse(
          fullUrl,
          method: HttpMethodType.GET,
        ));

        if (response != null) {
          //   Get.snackbar('Success', 'Order Paid successfully');
          cartController.clearCart();
          // push(MyOrderScreen(),
          //     isNewTask: false, pageRouteAnimation: PageRouteAnimation.Fade);

          var orderId = response['order_id'];

          if (currentPaymentMethod!.type == 'cash' ||
              currentPaymentMethod!.type == PAYMENT_METHOD_FROM_WALLET) {
            if (currentPaymentMethod!.type == PAYMENT_METHOD_FROM_WALLET) {
              appStore.setLoading(true);
              num walletBalance = await getUserWalletBalance();

              appStore.setLoading(false);
              if (walletBalance >= totalAmount) {
                showConfirmDialogCustom(
                  context,
                  dialogType: DialogType.CONFIRMATION,
                  title:
                      "${language.lblPayWith} ${currentPaymentMethod!.title.validate()}?",
                  primaryColor: primaryColor,
                  positiveText: language.lblYes,
                  negativeText: language.lblCancel,
                  onAccept: (p0) {
                    _handleClick(orderId);
                  },
                );
              } else {
                toast(language.insufficientBalanceMessage);

                showConfirmDialogCustom(
                  context,
                  dialogType: DialogType.CONFIRMATION,
                  title: language.doYouWantToTopUpYourWallet,
                  positiveText: language.lblYes,
                  negativeText: language.lblNo,
                  cancelable: false,
                  primaryColor: context.primaryColor,
                  onAccept: (p0) {
                    pop();
                    push(UserWalletBalanceScreen());
                  },
                  onCancel: (p0) {
                    pop();
                  },
                );
              }
            } else {
              print('sadsad');
              showThankYouDialog(false);
              await Future.delayed(Duration(seconds: 2));
              Navigator.pop(context);
              Navigator.pop(context);
              toast('Order created successfully');
              _handleClick(orderId.toString());
            }
          } else {
            _handleClick(orderId.toString());
          }
        } else {
          toast('Failed to create order');
        }
      } catch (e, stackTrace) {
        print(e.toString() + " " + stackTrace.toString());
        toast('Error occurred: $e');
      }
    }
  }

  void _handleClick(String orderId) async {
    print('tesadadsad');
    if (currentPaymentMethod!.type == "cash") {
      savePay(orderId, paymentMethod: "cash", paymentStatus: "pending");
      print(PAYMENT_LIST.toString() + ' test PAYMENT_LIST');
    } else if (currentPaymentMethod!.type == "stripe") {
      toast('Order created successfully');
      cartController.clearCart();
      // showThankYouDialog(false);

      currentPaymentMethod!.isTest = 1;

      StripeServiceNew stripeServiceNew = StripeServiceNew(
        paymentSetting: currentPaymentMethod!,
        totalAmount: totalAmount,
        onComplete: (p0) {
          showThankYouDialog(true);
          savePay(orderId,
              paymentMethod: "stripe",
              paymentStatus: "paid",
              txnId: p0['transaction_id']);
        },
      );
      stripeServiceNew.stripePay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.checkout,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(language.lblYourAddress,
                    style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                8.height,
                AppTextField(
                  textFieldType: TextFieldType.MULTILINE,
                  controller: shippingAddressController,
                  maxLines: 3,
                  minLines: 3,
                  onFieldSubmitted: (s) {
                    shippingAddressController.text = s;
                  },
                  decoration: inputDecoration(
                    context,
                    prefixIcon: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ic_location.iconImage(size: 22).paddingOnly(top: 0),
                      ],
                    ),
                  ).copyWith(
                    fillColor: context.cardColor,
                    filled: true,
                    hintText: language.lblEnterYourAddress,
                    hintStyle: secondaryTextStyle(),
                  ),
                ),
                20.height,
                Text(language.product,
                    style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                8.height,
                Obx(() {
                  return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height:
                          cartController.cartItems.length > 1 ? 290 : 290 / 2,
                      child: ListView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: cartController.cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartController.cartItems[index];
                          updateAmount(); // Assuming this updates the cart total amount

                          return Card(
                            color: appStore.isDarkMode
                                ? Colors.black38
                                : Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: item.product.attachments.isEmpty
                                        ? 'https://via.assets.so/shoe.png?id=1&q=95&w=360&h=360&fit=fill'
                                        : item.product.attachments!.first,
                                    fit: BoxFit.cover,
                                    height: 100,
                                    width: 100,
                                    placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Image.network(
                                      'https://via.assets.so/shoe.png?id=1&q=95&w=360&h=360&fit=fill',
                                      fit: BoxFit.cover,
                                      height: 100,
                                      width: 100,
                                    ),
                                  ),
                                  8.width,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name,
                                          style: primaryTextStyle(
                                              size: 16,
                                              weight: FontWeight.bold),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        8.height,
                                        Text(
                                          '${language.hintQuantityTxt} : ${item.quantity}',
                                          style: secondaryTextStyle(size: 14),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          '${item.product.price * item.quantity} د.ر',
                                          style: primaryTextStyle(
                                              size: 14,
                                              weight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ));
                }),
                0.height,
                if (appStore.isLoggedIn)
                  Container(
                      width: getwidth(context, 375),
                      padding: EdgeInsetsDirectional.symmetric(
                          vertical: gethight(context, 10)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: appStore.isDarkMode
                            ? Colors.black38
                            : const Color(0xffffffff),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: gethight(context, 5),
                          ),

                          Container(
                            width: getwidth(context, 375),
                            height: gethight(context, 80),
                            padding: EdgeInsets.symmetric(
                                horizontal: getwidth(context, 26)),
                            decoration: BoxDecoration(
                              color: const Color(0xffffffff),
                              borderRadius: BorderRadius.circular(20.0),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0x0d04060f),
                                  offset: Offset(0, 4),
                                  blurRadius: 60,
                                ),
                              ],
                            ),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/visa.svg',
                                        width: getwidth(context, 24),
                                        height: gethight(context, 24),
                                      ),
                                      SizedBox(
                                        width: getwidth(context, 18),
                                      ),
                                      Text(
                                        language!.hintCreditCardTxt,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              fontSize: getwidth(context, 14),
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xff212121),
                                              height: 1.2222222222222223,
                                            ),
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        checkbycash = false;
                                        checkoutbycredit = true;
                                        paymentType = 'stripe';
                                        currentPaymentMethod =
                                            paymentList.firstWhere((element) =>
                                                element.type ==
                                                PAYMENT_METHOD_STRIPE);
                                      });
                                    },
                                    child: Container(
                                      width: getwidth(context, 24),
                                      height: gethight(context, 24),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: checkoutbycredit
                                              ? primaryColor
                                              : Colors.grey),
                                      child: Center(
                                        child: checkoutbycredit
                                            ? Icon(
                                                Icons.check,
                                                size: getwidth(
                                                    context,
                                                    13.0 *
                                                        MediaQuery.of(context)
                                                            .size
                                                            .height /
                                                        770),
                                                color: Colors.white,
                                              )
                                            : Icon(
                                                Icons.arrow_right_rounded,
                                                size: getwidth(
                                                    context,
                                                    13.0 *
                                                        MediaQuery.of(context)
                                                            .size
                                                            .height /
                                                        770),
                                                color: Colors.grey,
                                              ),
                                      ),
                                    ),
                                  ),
                                ]),
                          ),
                          20.height,

                          // Row for Wallet
                          Container(
                              width: getwidth(context, 375),
                              height: gethight(context, 80),
                              padding: EdgeInsets.symmetric(
                                  horizontal: getwidth(context, 26)),
                              decoration: BoxDecoration(
                                color: const Color(0xffffffff),
                                borderRadius: BorderRadius.circular(20.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0x0d04060f),
                                    offset: Offset(0, 4),
                                    blurRadius: 60,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(children: <Widget>[
                                    Container(
                                      width: getwidth(context, 24),
                                      height: gethight(context, 24),
                                      child: Image.asset(
                                        'assets/mobileWallet.png', // Wallet icon asset
                                        width: getwidth(context, 24),
                                        height: gethight(context, 24),
                                      ),
                                    ),
                                    SizedBox(
                                      width: getwidth(context, 18),
                                    ),
                                    Text(
                                      language!.hintCashTxt, // Wallet text
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            fontSize: getwidth(context, 14),
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xff212121),
                                            height: 1.2222222222222223,
                                          ),
                                    ),
                                  ]),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        checkoutbycredit = false;
                                        checkbycash =
                                            true; // Toggle wallet state
                                        // _scrollToBottom();
                                        paymentType = 'cash';
                                        currentPaymentMethod =
                                            paymentList.firstWhere((element) =>
                                                element.type ==
                                                PAYMENT_METHOD_COD);
                                      });
                                    },
                                    child: Container(
                                      width: getwidth(context, 24),
                                      height: gethight(context, 24),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: checkbycash
                                              ? primaryColor
                                              : Colors.grey),
                                      child: Center(
                                        child: checkbycash
                                            ? Icon(
                                                Icons.check,
                                                size: getwidth(
                                                    context,
                                                    13.0 *
                                                        MediaQuery.of(context)
                                                            .size
                                                            .height /
                                                        770),
                                                color: Colors.white,
                                              )
                                            : Icon(
                                                Icons.arrow_right_rounded,
                                                size: getwidth(
                                                    context,
                                                    13.0 *
                                                        MediaQuery.of(context)
                                                            .size
                                                            .height /
                                                        770),
                                                color: Colors.grey,
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      )),
                0.height,
                ShowUp(
                    delay: 400,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(language!.hintSubtotalTxt,
                                  style: primaryTextStyle()),
                              Text('${amount.toStringAsFixed(2)} د.ر',
                                  style: primaryTextStyle()),
                            ],
                          ),
                          8.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(language!.hintTaxTxt,
                                  style: primaryTextStyle()),
                              Text(' ${tax.toStringAsFixed(2)} د.ر',
                                  style: primaryTextStyle()),
                            ],
                          ),
                          8.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(language!.hintDiscountTxt,
                                  style: primaryTextStyle()),
                              Text('-\$${discount.toStringAsFixed(2)} د.ر',
                                  style: primaryTextStyle()),
                            ],
                          ),
                          Divider(height: 24, thickness: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(language!.hintTotalAmountTxt,
                                  style: primaryTextStyle(
                                      weight: FontWeight.bold)),
                              Text('\$${totalAmount.toStringAsFixed(2)} د.ر',
                                  style: primaryTextStyle(
                                      weight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ).paddingTop(16)),
                25.height,
                AppButton(
                  width: 370,
                  onTap: () {
                    if (_formKey.currentState!.validate() &&
                        !appStore.isLoading) {
                      appStore.setLoading(true);

                      if (cartController.cartItems.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Your cart is empty.',
                              style: primaryTextStyle(),
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }
                      createOrder(context);
                    }
                  },
                  color: context.primaryColor,
                  child: Text(language.createOrderTxt,
                      style: boldTextStyle(color: white)),
                  textColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool checkoutbycredit = true;
  bool checkbycash = false;
}
