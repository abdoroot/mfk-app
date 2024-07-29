import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/booking_list_model.dart';
import 'package:booking_system_flutter/model/configuration_response.dart';
import 'package:booking_system_flutter/model/my_home_data_model.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/booking/component/booking_status_filter_bottom_sheet.dart';
import 'package:booking_system_flutter/screens/booking/component/order_item_component.dart';
import 'package:booking_system_flutter/screens/dashboard/dashboard_screen.dart';
import 'package:booking_system_flutter/screens/service/component/service_component.dart';
import 'package:booking_system_flutter/screens/service/shimmer/favourite_service_shimmer.dart';
import 'package:booking_system_flutter/services/stripe_service_new.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/empty_error_state_widget.dart';
import '../../utils/constant.dart';

import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/booking_data_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/booking/booking_detail_screen.dart';
import 'package:booking_system_flutter/screens/booking/component/booking_item_component.dart';
import 'package:booking_system_flutter/screens/booking/shimmer/booking_shimmer.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/empty_error_state_widget.dart';

class MyOrderScreen extends StatefulWidget {
  @override
  _MyOrderScreenState createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  UniqueKey keyForList = UniqueKey();

  ScrollController scrollController = ScrollController();

  Future<List<OrderData>>? future;
  List<OrderData> bookings = [];

  int page = 1;
  bool isLastPage = false;

  String selectedValue = BOOKING_TYPE_ALL;

  @override
  void initState() {
    super.initState();
    init();

    afterBuildCreated(() {
      if (appStore.isLoggedIn) {
        setStatusBarColor(context.primaryColor);
      }
    });

    LiveStream().on(LIVESTREAM_UPDATE_BOOKING_LIST, (p0) {
      page = 1;
      appStore.setLoading(true);
      init();
      setState(() {});
    });
    cachedBookingStatusDropdown.validate().forEach((element) {
      element.isSelected = false;
    });
  }

  String paymentType = "cash";
  List<PaymentSetting> paymentList = [];

  PaymentSetting? currentPaymentMethod;
  void init({String status = ''}) async {
    if (appStore.isLoggedIn)
      paymentList = PaymentSetting.decode(getStringAsync(PAYMENT_LIST))
          .where(
            (element) =>
                element.type == PAYMENT_METHOD_COD ||
                element.type == PAYMENT_METHOD_STRIPE,
          )
          .toList();
    if (appStore.isLoggedIn) currentPaymentMethod = paymentList.first;
    if (appStore.isLoggedIn) paymentType = 'stripe';
    future = getOrderList(page, status: status, orders: bookings,
        lastPageCallback: (b) {
      isLastPage = b;
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    LiveStream().dispose(LIVESTREAM_UPDATE_BOOKING_LIST);
    //scrollController.dispose();
    super.dispose();
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
                payStatus ? language.paymentSuccess : language.orderSuccess,
                textAlign: TextAlign.center,
                style: primaryTextStyle(size: 16),
              ),
              20.height,
              InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                      width: 180,
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
            ],
          ),
        );
      },
    );
  }

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

    saveOrderPayment(request).then((value) {
      appStore.setLoading(false);
      showThankYouDialog(true);

      init();
    }).catchError((e) {
      toast(e.toString());
      appStore.setLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language.MyOrder,
        textColor: white,
        showBack: false,
        textSize: APP_BAR_TEXT_SIZE,
        elevation: 3.0,
        color: context.primaryColor,
        actions: [
          IconButton(
            icon: ic_filter.iconImage(color: white, size: 20),
            onPressed: () async {
              String? res = await showModalBottomSheet(
                backgroundColor: Colors.transparent,
                context: context,
                isScrollControlled: true,
                isDismissible: true,
                shape: RoundedRectangleBorder(
                    borderRadius: radiusOnly(
                        topLeft: defaultRadius, topRight: defaultRadius)),
                builder: (_) {
                  return BookingStatusFilterBottomSheet();
                },
              );

              if (res.validate().isNotEmpty) {
                page = 1;
                appStore.setLoading(true);

                selectedValue = res!;
                init(status: res);

                if (bookings.isNotEmpty) {
                  scrollController.animateTo(0,
                      duration: 1.seconds, curve: Curves.easeOutQuart);
                } else {
                  scrollController = ScrollController();
                  keyForList = UniqueKey();
                }

                setState(() {});
              }
            },
          ),
        ],
      ),
      body: SizedBox(
        width: context.width(),
        height: context.height(),
        child: Stack(
          children: [
            SnapHelperWidget<List<OrderData>>(
              initialData: cachedOrderList,
              future: future,
              errorBuilder: (error) {
                return NoDataWidget(
                  title: error,
                  imageWidget: ErrorStateWidget(),
                  retryText: language.reload,
                  onRetry: () {
                    page = 1;
                    appStore.setLoading(true);

                    init();
                    setState(() {});
                  },
                );
              },
              loadingWidget: BookingShimmer(),
              onSuccess: (list) {
                return AnimatedListView(
                  key: keyForList,
                  controller: scrollController,
                  physics: AlwaysScrollableScrollPhysics(),
                  padding:
                      EdgeInsets.only(bottom: 60, top: 16, right: 16, left: 16),
                  itemCount: list.length,
                  shrinkWrap: true,
                  disposeScrollController: true,
                  listAnimationType: ListAnimationType.FadeIn,
                  fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                  slideConfiguration: SlideConfiguration(verticalOffset: 400),
                  emptyWidget: NoDataWidget(
                    title: language.NoOrdersFound,
                    subTitle: language.NoOrdersSubTitle,
                    imageWidget: EmptyStateWidget(),
                  ),
                  itemBuilder: (_, index) {
                    OrderData? data = list[index];

                    return GestureDetector(
                      onTap: () {
                        if (data.paymentStatus == null && appStore.isLoggedIn ||
                            data.paymentStatus == 'pedning' &&
                                appStore.isLoggedIn &&
                                !appStore.isLoading) {
                          print('teadsadas');
                          paymentType = 'stripe';
                          appStore.setLoading(true);

                          currentPaymentMethod = paymentList.firstWhere(
                              (element) =>
                                  element.type == PAYMENT_METHOD_STRIPE);
                          StripeServiceNew stripeServiceNew = StripeServiceNew(
                            paymentSetting: currentPaymentMethod!,
                            totalAmount: data.totalAmount,
                            onComplete: (p0) {
                              savePay(
                                data.id.toString(),
                                paymentMethod: PAYMENT_METHOD_STRIPE,
                                paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
                                txnId: p0['transaction_id'],
                              );
                            },
                          );
                          stripeServiceNew.stripePay();
                        }
                      },
                      child: OrderItemComponent(orderData: data),
                    );
                  },
                  onNextPage: () {
                    if (!isLastPage) {
                      page++;
                      appStore.setLoading(true);

                      init();
                      setState(() {});
                    }
                  },
                  onSwipeRefresh: () async {
                    page = 1;
                    appStore.setLoading(true);

                    init(status: selectedValue);
                    setState(() {});

                    return await 1.seconds.delay;
                  },
                );
              },
            ),
            Observer(
                builder: (_) => LoaderWidget().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
