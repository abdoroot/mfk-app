import 'dart:convert';

import 'package:booking_system_flutter/component/empty_error_state_widget.dart';
import 'package:booking_system_flutter/model/configuration_response.dart';
import 'package:booking_system_flutter/model/package_data_model.dart';
import 'package:booking_system_flutter/network/network_utils.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/auth/sign_in_screen.dart';
import 'package:booking_system_flutter/screens/dashboard/dashboard_screen.dart';
import 'package:booking_system_flutter/screens/service/myOrder_screen.dart';
import 'package:booking_system_flutter/screens/service/shimmer/service_detail_shimmer.dart';
import 'package:booking_system_flutter/screens/store/cart_controller.dart';
import 'package:booking_system_flutter/screens/store/cart_screen.dart';
import 'package:booking_system_flutter/screens/store/product_detail_header_component.dart';
import 'package:booking_system_flutter/screens/wallet/user_wallet_balance_screen.dart';
import 'package:booking_system_flutter/services/stripe_service_new.dart';
import 'package:booking_system_flutter/store/app_store.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart' as nb;
import 'package:dio/dio.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/product_data_model.dart';
import 'package:booking_system_flutter/model/product_response.dart';
import 'package:booking_system_flutter/store/service_addon_store.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

ServiceAddonStore serviceAddonStore = ServiceAddonStore();
final CartController cartController = Get.put(CartController());

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  final ProductModel? product;
  final bool isFromProviderInfo;

  ProductDetailScreen(
      {required this.productId, this.product, this.isFromProviderInfo = false});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  PageController pageController = PageController();

  Future<SingelProductResponse>? future;

  int selectedAddressId = 0;
  int selectedBookingAddressId = -1;
  BookingPackage? selectedPackage;

  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> items = [
    {"id": 5, "quantity": 2, "price": 40},
  ];
  double amount = 85.0;
  double tax = 4.25;
  double discount = 0.0;
  double totalAmount = 89.25;
  TextEditingController shippingAddress = TextEditingController();

  FocusNode shippingAddressFocus = FocusNode();

  String paymentType = "cash";
  List<PaymentSetting> paymentList = [];

  PaymentSetting? currentPaymentMethod;

  @override
  void initState() {
    super.initState();
    if (appStore.isLoggedIn) getAppConfigurations();

    serviceAddonStore.selectedServiceAddon.clear();
    nb.setStatusBarColor(nb.transparentColor);
    init();
    updateAmount(widget.product!);
    print(PAYMENT_LIST.toString() + ' test PAYMENT_LIST');
    if (appStore.isLoggedIn)
      paymentList = PaymentSetting.decode(nb.getStringAsync(PAYMENT_LIST))
          .where(
            (element) =>
                element.type == PAYMENT_METHOD_COD ||
                element.type == PAYMENT_METHOD_STRIPE,
          )
          .toList();
    if (appStore.isLoggedIn) currentPaymentMethod = paymentList.first;
    if (appStore.isLoggedIn) paymentType = 'stripe';
    if (appStore.isLoggedIn) if (appStore.isEnableUserWallet) {
      paymentList.add(PaymentSetting(
          title: language.wallet, type: PAYMENT_METHOD_FROM_WALLET, status: 1));
    }

    nb.log(totalAmount);

    setState(() {});
  }

  void init() async {
    future = getProductDetails(
      ProductId: widget.productId.validate(),
    );
    items = [
      {
        "id": widget.productId.validate(),
        "quantity": 1,
        "price": widget.product!.price
      },
    ];
  }

  void updateAmount(ProductModel product) {
    amount =
        items.fold(0, (sum, item) => sum + (item['quantity'] * item['price']));

    tax = 0.14 * amount;
    double productDiscount = product.discount == null
        ? 0.0
        : double.parse(product.discount.toString());
    totalAmount = (amount - productDiscount) + tax;

    setState(() {});
  }

  bool checkoutbycredit = false;
  bool checkbycash = false;
  void savePay(
    orderID, {
    String txnId = '',
    String paymentMethod = '',
    String paymentStatus = '',
  }) async {
    Map request = {
      'order_id': orderID,
      CommonKeys.customerId: appStore.userId,
      CommonKeys.paymentStatus: paymentStatus,
      CommonKeys.paymentMethod: paymentMethod,
    };

    appStore.setLoading(true);
    saveOrderPayment(request).then((value) {
      appStore.setLoading(false);
      nb.push(MyOrderScreen(),
          isNewTask: true, pageRouteAnimation: nb.PageRouteAnimation.Fade);
    }).catchError((e) {
      nb.toast(e.toString());
      appStore.setLoading(false);
    });
  }

  int selectedQuantity = 1;

  Widget buildOrderForm(ProductModel product) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AppTextField(
          //   textFieldType: TextFieldType.OTHER,
          //   controller: shippingAddress,
          //   focus: shippingAddressFocus,
          //   nextFocus: null,
          //   validator: (value) {
          //     if (value == null || value.isEmpty) {
          //       return language.fieldIsRequiredTxt;
          //     }
          //     return null;
          //   },
          //   errorThisFieldRequired: language.fieldIsRequiredTxt,
          //   decoration: inputDecoration(context,
          //       labelText: language.hintShipAddressTxt),
          //   suffix: ic_info.iconImage(size: 10).paddingAll(14),
          //   autoFillHints: [AutofillHints.email],
          // ),
          // 18.height,
          // if (appStore.isLoggedIn)
          //   Container(
          //       width: getwidth(context, 375),
          //       padding: EdgeInsetsDirectional.symmetric(
          //           vertical: gethight(context, 10)),
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(6),
          //         color: Color.fromRGBO(255, 255, 255, 1),
          //       ),
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.start,
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: <Widget>[
          //           SizedBox(
          //             height: gethight(context, 5),
          //           ),

          //           Container(
          //             width: getwidth(context, 375),
          //             height: gethight(context, 80),
          //             padding: EdgeInsets.symmetric(
          //                 horizontal: getwidth(context, 26)),
          //             decoration: BoxDecoration(
          //               color: const Color(0xffffffff),
          //               borderRadius: BorderRadius.circular(20.0),
          //               boxShadow: [
          //                 BoxShadow(
          //                   color: const Color(0x0d04060f),
          //                   offset: Offset(0, 4),
          //                   blurRadius: 60,
          //                 ),
          //               ],
          //             ),
          //             child: Row(
          //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                 children: <Widget>[
          //                   Row(
          //                     children: [
          //                       SvgPicture.asset(
          //                         'assets/visa.svg',
          //                         width: getwidth(context, 24),
          //                         height: gethight(context, 24),
          //                       ),
          //                       SizedBox(
          //                         width: getwidth(context, 18),
          //                       ),
          //                       Text(
          //                         language!.hintCreditCardTxt,
          //                         style: Theme.of(context)
          //                             .textTheme
          //                             .bodyMedium!
          //                             .copyWith(
          //                               fontSize: getwidth(context, 14),
          //                               fontWeight: FontWeight.w700,
          //                               color: const Color(0xff212121),
          //                               height: 1.2222222222222223,
          //                             ),
          //                       ),
          //                     ],
          //                   ),
          //                   InkWell(
          //                     onTap: () {
          //                       setState(() {
          //                         checkbycash = false;
          //                         checkoutbycredit = true;
          //                         paymentType = 'stripe';
          //                         currentPaymentMethod = paymentList.firstWhere(
          //                             (element) =>
          //                                 element.type ==
          //                                 PAYMENT_METHOD_STRIPE);
          //                       });
          //                     },
          //                     child: Container(
          //                       width: getwidth(context, 24),
          //                       height: gethight(context, 24),
          //                       decoration: BoxDecoration(
          //                           shape: BoxShape.circle,
          //                           color: checkoutbycredit
          //                               ? primaryColor
          //                               : Colors.grey),
          //                       child: Center(
          //                         child: checkoutbycredit
          //                             ? Icon(
          //                                 Icons.check,
          //                                 size: getwidth(
          //                                     context,
          //                                     13.0 *
          //                                         MediaQuery.of(context)
          //                                             .size
          //                                             .height /
          //                                         770),
          //                                 color: Colors.white,
          //                               )
          //                             : Icon(
          //                                 Icons.arrow_right_rounded,
          //                                 size: getwidth(
          //                                     context,
          //                                     13.0 *
          //                                         MediaQuery.of(context)
          //                                             .size
          //                                             .height /
          //                                         770),
          //                                 color: Colors.grey,
          //                               ),
          //                       ),
          //                     ),
          //                   ),
          //                 ]),
          //           ),

          //           SizedBox(
          //             height: gethight(context, 30),
          //           ),

          //           // Row for Wallet
          //           Container(
          //               width: getwidth(context, 375),
          //               height: gethight(context, 80),
          //               padding: EdgeInsets.symmetric(
          //                   horizontal: getwidth(context, 26)),
          //               decoration: BoxDecoration(
          //                 color: const Color(0xffffffff),
          //                 borderRadius: BorderRadius.circular(20.0),
          //                 boxShadow: [
          //                   BoxShadow(
          //                     color: const Color(0x0d04060f),
          //                     offset: Offset(0, 4),
          //                     blurRadius: 60,
          //                   ),
          //                 ],
          //               ),
          //               child: Row(
          //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                 children: <Widget>[
          //                   Row(children: <Widget>[
          //                     Container(
          //                       width: getwidth(context, 24),
          //                       height: gethight(context, 24),
          //                       child: Image.asset(
          //                         'assets/mobileWallet.png', // Wallet icon asset
          //                         width: getwidth(context, 24),
          //                         height: gethight(context, 24),
          //                       ),
          //                     ),
          //                     SizedBox(
          //                       width: getwidth(context, 18),
          //                     ),
          //                     Text(
          //                       language!.hintCashTxt, // Wallet text
          //                       style: Theme.of(context)
          //                           .textTheme
          //                           .bodyMedium!
          //                           .copyWith(
          //                             fontSize: getwidth(context, 14),
          //                             fontWeight: FontWeight.w700,
          //                             color: const Color(0xff212121),
          //                             height: 1.2222222222222223,
          //                           ),
          //                     ),
          //                   ]),
          //                   InkWell(
          //                     onTap: () {
          //                       setState(() {
          //                         checkoutbycredit = false;
          //                         checkbycash = true; // Toggle wallet state
          //                         // _scrollToBottom();
          //                         paymentType = 'cash';
          //                         currentPaymentMethod = paymentList.firstWhere(
          //                             (element) =>
          //                                 element.type == PAYMENT_METHOD_COD);
          //                       });
          //                     },
          //                     child: Container(
          //                       width: getwidth(context, 24),
          //                       height: gethight(context, 24),
          //                       decoration: BoxDecoration(
          //                           shape: BoxShape.circle,
          //                           color: checkbycash
          //                               ? primaryColor
          //                               : Colors.grey),
          //                       child: Center(
          //                         child: checkbycash
          //                             ? Icon(
          //                                 Icons.check,
          //                                 size: getwidth(
          //                                     context,
          //                                     13.0 *
          //                                         MediaQuery.of(context)
          //                                             .size
          //                                             .height /
          //                                         770),
          //                                 color: Colors.white,
          //                               )
          //                             : Icon(
          //                                 Icons.arrow_right_rounded,
          //                                 size: getwidth(
          //                                     context,
          //                                     13.0 *
          //                                         MediaQuery.of(context)
          //                                             .size
          //                                             .height /
          //                                         770),
          //                                 color: Colors.grey,
          //                               ),
          //                       ),
          //                     ),
          //                   ),
          //                 ],
          //               )),
          //         ],
          //       )),

          // if (paymentList.isNotEmpty)
          //   AnimatedListView(
          //     itemCount: paymentList.length,
          //     shrinkWrap: true,
          //     physics: NeverScrollableScrollPhysics(),
          //     listAnimationType: ListAnimationType.FadeIn,
          //     fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
          //     itemBuilder: (context, index) {
          //       PaymentSetting value = paymentList[index];

          //       if (value.status.validate() == 0) return Offstage();

          //       return RadioListTile<PaymentSetting>(
          //         dense: true,
          //         activeColor: primaryColor,
          //         value: value,
          //         controlAffinity: ListTileControlAffinity.trailing,
          //         groupValue: currentPaymentMethod,
          //         onChanged: (PaymentSetting? ind) {
          //           currentPaymentMethod = ind;

          //           setState(() {});
          //         },
          //         title:
          //             Text(value.title.validate(), style: primaryTextStyle()),
          //       );
          //     },
          //   )
          // else
          //   NoDataWidget(
          //     title: language.noPaymentMethodFound,
          //     imageWidget: EmptyStateWidget(),
          //   ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget buildBodyWidget(AsyncSnapshot<SingelProductResponse> snap) {
      if (snap.hasError) {
        return Text(snap.error.toString()).center();
      } else if (snap.hasData) {
        return Stack(
          children: [
            nb.AnimatedScrollView(
              padding: EdgeInsets.only(bottom: 120),
              listAnimationType: nb.ListAnimationType.FadeIn,
              fadeInConfiguration:
                  nb.FadeInConfiguration(duration: Duration(seconds: 2)),
              onSwipeRefresh: () async {
                appStore.setLoading(true);
                init();
                setState(() {});
                return await Future.delayed(Duration(seconds: 2));
              },
              children: [
                ProductDetailHeaderComponent(
                    ProductDetail: snap.data!.Product!),
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     8.height,
                //     Text(language.serviceVisitType, style: boldTextStyle()),
                //     8.height,
                //     Text(language.thisServiceIsOnlineRemote,
                //         style: secondaryTextStyle()),
                //   ],
                // ).paddingAll(16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(language.hintDescription,
                        style: nb.boldTextStyle(size: LABEL_TEXT_SIZE)),
                    8.height,
                    snap.data!.Product!.description.validate().isNotEmpty
                        ? nb.ReadMoreText(
                            snap.data!.Product!.description.validate(),
                            style: nb.secondaryTextStyle(),
                            colorClickableText: context.primaryColor,
                            textAlign: TextAlign.justify,
                          )
                        : Text(language.lblNotDescription,
                            style: nb.secondaryTextStyle()),
                  ],
                ).paddingAll(16),
                buildOrderForm(snap.data!.Product!)
                    .paddingAll(16), // Add the form here
              ],
            ),
          ],
        );
      }
      return ServiceDetailShimmer();
    }

    return FutureBuilder<SingelProductResponse>(
      initialData: null,
      future: future,
      builder: (context, snap) {
        return Scaffold(
          bottomNavigationBar: BottomAppBar(
              height: 150,
              child: Column(
                children: [
                  SizedBox(
                      width: 325,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 40,
                            padding: EdgeInsets.all(8),
                            decoration: nb.boxDecorationWithRoundedCorners(
                              backgroundColor: context.scaffoldBackgroundColor,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.arrow_drop_down_sharp, size: 24)
                                    .onTap(
                                  () {
                                    if (selectedQuantity != 1)
                                      selectedQuantity--;
                                    setState(() {});
                                  },
                                ),
                                16.width,
                                Text(selectedQuantity.toString(),
                                    style: nb.primaryTextStyle()),
                                16.width,
                                Icon(Icons.arrow_drop_up_sharp, size: 24).onTap(
                                  () {
                                    selectedQuantity++;
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                          ShowUp(
                              delay: 400,
                              child: Text(
                                  '${language!.hintPriceTxt}: ${widget.product!.price * selectedQuantity}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          fontSize: getwidth(context, 14),
                                          fontWeight: FontWeight.w600))),
                        ],
                      )),
                  20.height,
                  nb.AppButton(
                    width: 335,
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        bool isProductInCart = cartController.cartItems.any(
                          (element) => element.product.id == widget.product!.id,
                        );
                        if (isProductInCart) {
                          cartController
                              .removeItem(cartController.cartItems.firstWhere(
                            (element) =>
                                element.product.id == widget.product!.id,
                          ));
                        }
                        cartController.addToCart(widget.product!,
                            quantity: selectedQuantity);
                        push(CartPage(),
                            isNewTask: false,
                            pageRouteAnimation: PageRouteAnimation.Fade);
                        Get.snackbar('Success', 'Product added to cart');
                      }
                    },
                    color: context.primaryColor,
                    child: Text(language.addToCartTxt,
                        style: nb.boldTextStyle(color: nb.white)),
                    textColor: Colors.white,
                  ),
                ],
              )),
          body: Stack(
            children: [
              buildBodyWidget(snap),
              Observer(
                  builder: (context) =>
                      LoaderWidget().visible(appStore.isLoading)),
            ],
          ),
        );
      },
    );
  }
}
