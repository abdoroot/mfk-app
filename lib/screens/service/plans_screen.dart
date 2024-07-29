import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/configuration_response.dart';
import 'package:booking_system_flutter/model/plans_data.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/auth/sign_in_screen.dart';
import 'package:booking_system_flutter/screens/dashboard/dashboard_screen.dart';
import 'package:booking_system_flutter/screens/service/component/service_component.dart';
import 'package:booking_system_flutter/screens/service/myOrder_screen.dart';
import 'package:booking_system_flutter/screens/service/shimmer/favourite_service_shimmer.dart';
import 'package:booking_system_flutter/services/stripe_service_new.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/empty_error_state_widget.dart';
import '../../utils/constant.dart';

class PlansScreen extends StatefulWidget {
  final bool allPlans;
  final int? singelPlanId;
  const PlansScreen({Key? key, required this.allPlans, this.singelPlanId})
      : super(key: key);

  @override
  _PlansScreenState createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  Future<List<PlansData>>? future;

  List<PlansData> plans = [];
  PlansData? myPlans;
  Future<PlansData>? myCurrentPlan;
  List<HistoryPlanData>? historyPlan;
  bool hasPlan = false;
  int page = 1;

  bool isLastPage = false;

  String paymentType = "cash";
  List<PaymentSetting> paymentList = [];

  PaymentSetting? currentPaymentMethod;
  @override
  void initState() {
    super.initState();
    init();
  }

  List<HistoryPlanData>? historysPlan;
  bool isloading = true;
  Future<void> _fetchPlans() async {
    if (widget.singelPlanId != null) {
      future = getPlanlist(page, plans: plans, lastPageCallBack: (p0) {
        isLastPage = p0;
      }).then((planList) {
        print(widget.singelPlanId.toString() + 'test singelPlanId');
        historysPlan!.removeWhere(
          (plan) => plan.id != widget.singelPlanId,
        );
        return planList
            .where((plan) =>
                historysPlan!.any((history) => history.plan_id == plan.id))
            .toList();
      });
    } else if (widget.allPlans == true) {
      print('tesadsadsad');
      future = getPlanlist(page, plans: plans, lastPageCallBack: (p0) {
        isLastPage = p0;
      }).then((planList) {
        planList.removeWhere(
          (plan) => historysPlan!.any((history) => history.plan_id == plan.id),
        );
        return historysPlan!.isEmpty
            ? planList
            : planList
                .where((plan) =>
                    historysPlan!.any((history) => history.plan_id != plan.id))
                .toList();
      });
    } else {
      future = getPlanlist(page, plans: plans, lastPageCallBack: (p0) {
        isLastPage = p0;
      }).then((planList) {
        return planList
            .where((plan) =>
                historysPlan!.any((history) => history.plan_id == plan.id))
            .toList();
      });
    }
  }

  Future<void> init() async {
    setState(() {
      isloading = true;
    });
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

    historysPlan = appStore.isLoggedIn
        ? await getHistoryPlan(page, plan: historyPlan, lastPageCallBack: (p0) {
            isLastPage = p0;
          })
        : [];
    setState(
      () {
        hasPlan = false;
      },
    );

    await _fetchPlans();
    // else if (hasPlan)
    //   myCurrentPlan = getMyPlan(page,
    //       plan: myPlans,
    //       plan_id: historysPlan!.first.plan_id!, lastPageCallBack: (p0) {
    //     isLastPage = p0;
    //   });

    setState(() {
      isloading = false;
    });
  }

  void savePay(
    orderID, {
    String txnId = '',
    String paymentMethod = '',
    String paymentStatus = '',
  }) async {
    Map request = {
      'subscription_id': orderID,
      'discount': 0,
      CommonKeys.customerId: appStore.userId,
      CommonKeys.paymentStatus: paymentStatus,
      CommonKeys.paymentMethod: paymentMethod,
    };

    appStore.setLoading(true);
    saveSubscribtionOrderPayment(request).then((value) {
      appStore.setLoading(false);
      init();
      // push(DashboardScreen(redirectToBooking: true),
      //     isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
    }).catchError((e) {
      toast(e.toString());
      init();
      appStore.setLoading(false);
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        !widget.allPlans ? language.myPlan : language.lblPlans,
        color: context.primaryColor,
        textColor: white,
        backWidget: BackWidget(),
        textSize: APP_BAR_TEXT_SIZE,
      ),
      body: Stack(
        children: [
          if (!hasPlan && !isloading)
            FutureBuilder<List<PlansData>>(
              future: future,
              initialData: cachedPlanList,
              builder: (context, snap) {
                if (snap.hasData) {
                  if (snap.data.validate().isEmpty)
                    return NoDataWidget(
                      title: !widget.allPlans
                          ? language.myPlan
                          : language.lblPlans,
                      subTitle: widget.allPlans
                          ? language.noPackageOffers
                          : language.noSubscribedPackages,
                      imageWidget: EmptyStateWidget(),
                    );

                  return AnimatedScrollView(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 60),
                    listAnimationType: ListAnimationType.FadeIn,
                    fadeInConfiguration:
                        FadeInConfiguration(duration: 2.seconds),
                    physics: AlwaysScrollableScrollPhysics(),
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

                      init();
                      setState(() {});

                      return await 2.seconds.delay;
                    },
                    children: [
                      AnimatedWrap(
                        spacing: 16,
                        runSpacing: 16,
                        listAnimationType: ListAnimationType.FadeIn,
                        fadeInConfiguration:
                            FadeInConfiguration(duration: 2.seconds),
                        scaleConfiguration: ScaleConfiguration(
                            duration: 300.milliseconds, delay: 50.milliseconds),
                        itemCount: snap.data!.length,
                        itemBuilder: (_, index) {
                          return Padding(
                            padding: EdgeInsetsDirectional.only(
                              bottom: gethight(context, 20),
                              top: gethight(context, 20),
                              start: getwidth(context, 20),
                              end: getwidth(context, 20),
                            ),
                            child: PlanWidget(context, snap.data![index]),
                          );
                        },
                      )
                    ],
                  );
                }

                return snapWidgetHelper(
                  snap,
                  loadingWidget: SizedBox(),
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
                );
              },
            ),
          if (hasPlan & !isloading)
            FutureBuilder<PlansData>(
              future: myCurrentPlan,
              initialData: cachedMyPlan,
              builder: (context, snap) {
                if (snap.hasData) {
                  if (snap.data == null)
                    return NoDataWidget(
                      title: language.lblNoServicesFound,
                      subTitle: language.noFavouriteSubTitle,
                      imageWidget: EmptyStateWidget(),
                    );

                  return AnimatedScrollView(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 60),
                    listAnimationType: ListAnimationType.FadeIn,
                    fadeInConfiguration:
                        FadeInConfiguration(duration: 2.seconds),
                    physics: AlwaysScrollableScrollPhysics(),
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

                      init();
                      setState(() {});

                      return await 2.seconds.delay;
                    },
                    children: [
                      AnimatedWrap(
                        spacing: 16,
                        runSpacing: 16,
                        listAnimationType: ListAnimationType.FadeIn,
                        fadeInConfiguration:
                            FadeInConfiguration(duration: 2.seconds),
                        scaleConfiguration: ScaleConfiguration(
                            duration: 300.milliseconds, delay: 50.milliseconds),
                        itemCount: 1,
                        itemBuilder: (_, index) {
                          return Padding(
                            padding: EdgeInsetsDirectional.only(
                              bottom: gethight(context, 20),
                              top: gethight(context, 20),
                              start: getwidth(context, 20),
                              end: getwidth(context, 20),
                            ),
                            child: PlanWidget(context, snap.data!),
                          );
                        },
                      )
                    ],
                  );
                }

                return snapWidgetHelper(
                  snap,
                  loadingWidget: ShimmerPlanWidget(context),
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
                );
              },
            ),
          Observer(
              builder: (context) => LoaderWidget()
                  .visible(isloading ? true : appStore.isLoading)),
        ],
      ),
    );
  }

  Widget ShimmerPlanWidget(
    context,
  ) {
    var theme = Theme.of(context).textTheme;
    return Container(
        width: getwidth(context, 380.6),
        padding: EdgeInsetsDirectional.symmetric(
            vertical: gethight(context, 40), horizontal: getwidth(context, 30)),
        decoration: BoxDecoration(
            border: Border.all(color: Color(0xff003E52)),
            borderRadius: BorderRadius.all(Radius.circular(25))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Image.asset('assets/sub.png',
                  width: getwidth(context, 24), height: gethight(context, 20)),
              SizedBox(width: getwidth(context, 10)),
              Text(
                language.lblPlans,
                style: theme.bodyMedium!.copyWith(
                  fontSize: getwidth(context, 17),
                  color: const Color(0xff467eca),
                  fontWeight: FontWeight.w500,
                  height: 0.058823529411764705,
                ),
                textHeightBehavior:
                    TextHeightBehavior(applyHeightToFirstAscent: false),
                softWrap: false,
              ),
            ]),
            Row(
              children: <Widget>[
                Text(
                  '...'.toString(),
                  style: theme.bodyMedium!.copyWith(
                    fontSize: getwidth(context, 68),
                    color: const Color(0xff003e52),
                    letterSpacing: -0.9444444732666016,
                    fontWeight: FontWeight.w600,
                    height: 0.7794117647058824,
                  ),
                  textHeightBehavior:
                      TextHeightBehavior(applyHeightToFirstAscent: false),
                  softWrap: false,
                ),
                SizedBox(
                  width: getwidth(context, 10),
                ),
                Column(
                  children: [
                    Text(
                      'AED'.toString(),
                      style: theme.bodyMedium!.copyWith(
                        fontSize: getwidth(context, 22),
                        color: const Color(0xff003e52),
                        letterSpacing: -0.9166666946411133,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        height: 2.3181818181818183,
                      ),
                      textHeightBehavior:
                          TextHeightBehavior(applyHeightToFirstAscent: false),
                      softWrap: false,
                    ),
                    SizedBox(
                      height: gethight(context, 5),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: gethight(context, 20),
            ),
            planTitle(language.featuresPlan),
            SizedBox(
              height: gethight(context, 20),
            ),
            SizedBox(
              height: gethight(context, 40),
            ),
            InkWell(
              onTap: () {
                // crud firebase add push data to requestChat collection firebase realtime database here
                // setState(() {
                //   isButtonLoading = true;
                // });
                // selectedPlan = plan.id;
                // subscribePlan(selectedPlan.toString(), plan.type.toString())
                //     .then((value) => {
                //           if (value == false)
                //             {
                //               showSnackBar(
                //                 context,
                //                 'Error',
                //               ),
                //               setState(() {
                //                 isButtonLoading = false;
                //               })
                //             }
                //           else
                //             {
                //               print('succesd subscribe plan'),
                //               setState(() {
                //                 isButtonLoading = false;
                //               }),
                //               Navigator.pushReplacementNamed(
                //                   context, Routes.chosePlanScreen),
                //               // go to pay mentod
                //             }
                //         });
                //  Navigator.pushNamed(context, Routes.chosePlanScreenRoute);
              },
              child: Container(
                  width: getwidth(context, 256.58),
                  height: gethight(context, 52.02),
                  decoration: BoxDecoration(
                    color: const Color(0xff4178C3),
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Center(
                    child: Text(
                      language.choosePlan,
                      style: theme.bodyMedium!.copyWith(
                        fontSize: getwidth(context, 15),
                        color: const Color(0xffffffff),
                        fontWeight: FontWeight.w600,
                        height: 1.3333333333333333,
                      ),
                      textHeightBehavior:
                          TextHeightBehavior(applyHeightToFirstAscent: false),
                      textAlign: TextAlign.center,
                    ),
                  )),
            ),
          ],
        ));
  }

  void showThankYouDialog(bool payStatus) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
                    payStatus
                        ? language.paymentSuccesss
                        : language.orderSuccess,
                    textAlign: TextAlign.center,
                    style: primaryTextStyle(size: 16),
                  ),
                  20.height,
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                width: 160,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                child: Center(
                                  child: Text(
                                    language.close,
                                    style: primaryTextStyle(
                                        color: Colors.white,
                                        weight: FontWeight.bold),
                                  ),
                                ))),
                        if (!payStatus) 10.width,
                        if (!payStatus)
                          InkWell(
                              onTap: () {
                                push(PlansScreen(allPlans: false),
                                    isNewTask: false,
                                    pageRouteAnimation:
                                        PageRouteAnimation.Fade);
                              },
                              child: Container(
                                  width: 160,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      language.lblPlans,
                                      style: primaryTextStyle(
                                          color: Colors.white,
                                          weight: FontWeight.bold),
                                    ),
                                  ))),
                      ])
                ],
              ),
            ));
      },
    );
  }

  Widget PlanWidget(context, PlansData plan) {
    var theme = Theme.of(context).textTheme;
    bool isExpanded = true;

    return Stack(
        alignment: Alignment
            .topRight, // Align badge to the top right corner of the container
        children: [
          Container(
              width: getwidth(context, 380.6),
              padding: EdgeInsetsDirectional.symmetric(
                  vertical: gethight(context, 40),
                  horizontal: getwidth(context, 30)),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: appStore.isDarkMode ? Colors.white : primaryColor),
                  borderRadius: BorderRadius.all(Radius.circular(25))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShowUp(
                      delay: 200,
                      child: Row(children: [
                        Image.asset('assets/sub.png',
                            color: primaryColor,
                            width: getwidth(context, 24),
                            height: gethight(context, 20)),
                        SizedBox(width: getwidth(context, 10)),
                        Text(
                          plan.title.toString(),
                          style: primaryTextStyle(
                            size: 20,
                            color: appStore.isDarkMode
                                ? Colors.white
                                : primaryColor,
                            weight: FontWeight.w700,
                            height: 0.058823529411764705,
                          ),
                        )
                      ])),
                  SizedBox(
                    height: gethight(context, 20),
                  ),
                  ShowUp(
                      delay: 400,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                              // Wrap the text in an Expanded widget to give it the opportunity to fit the space
                              child: FittedBox(
                                  fit: BoxFit
                                      .scaleDown, // Will only scale down if needed
                                  child: Text(
                                    double.parse(plan.amount.toString())
                                        .toStringAsFixed(0),
                                    style: primaryTextStyle(
                                      size: 68,
                                      color: appStore.isDarkMode
                                          ? Colors.white
                                          : const Color(0xff003e52),
                                      letterSpacing: -0.9444444732666016,
                                      weight: FontWeight.w600,
                                      height: 0.7794117647058824,
                                    ),
                                    textHeightBehavior: TextHeightBehavior(
                                        applyHeightToFirstAscent: false),
                                    softWrap: false,
                                  ))),
                          SizedBox(
                            width: getwidth(context, 70),
                          ),
                          Column(
                            children: [
                              Text(
                                appStore.currencyCode,
                                style: primaryTextStyle(
                                  size: 22,
                                  color: appStore.isDarkMode
                                      ? Colors.white
                                      : const Color(0xff003e52),
                                  letterSpacing: -0.9166666946411133,
                                  fontStyle: FontStyle.italic,
                                  weight: FontWeight.w700,
                                  height: 2.3181818181818183,
                                ),
                                textHeightBehavior: TextHeightBehavior(
                                    applyHeightToFirstAscent: false),
                                softWrap: false,
                              ),
                              SizedBox(
                                height: gethight(context, 5),
                              ),
                              Text(
                                plan.planType.toString(),
                                style: primaryTextStyle(
                                  size: 17,
                                  color: appStore.isDarkMode
                                      ? Colors.white
                                      : const Color(0xff003e52),
                                  weight: FontWeight.w700,
                                  height: 1.5294117647058822,
                                ),
                                textHeightBehavior: TextHeightBehavior(
                                    applyHeightToFirstAscent: false),
                                textAlign: TextAlign.center,
                                softWrap: false,
                              ),
                            ],
                          ),
                        ],
                      )),
                  SizedBox(
                    height: gethight(context, 20),
                  ),
                  SizedBox(
                      width: getwidth(context, 332),
                      child: Padding(
                          padding: EdgeInsetsDirectional.only(
                            bottom: gethight(context, 10),
                            top: gethight(context, 10),
                          ),
                          child: ExpansionTile(
                              title: ShowUp(
                                  delay: 600,
                                  child: planTitle(language.featuresPlan)),
                              initiallyExpanded: isExpanded,
                              children: <Widget>[
                                planDescpition(
                                  plan.description.toString(),
                                )
                              ]))),
                  SizedBox(
                    height: gethight(context, 5),
                  ),
                  if (historysPlan!
                      .where((historyPlan) => historyPlan.plan_id == plan.id)
                      .isEmpty)
                    InkWell(
                      onTap: () async {
                        // paymentType = 'stripe';
                        // // currentPaymentMethod = paymentList.firstWhere(
                        // //     (element) => element.type == PAYMENT_METHOD_STRIPE);
                        // // StripeServiceNew stripeServiceNew = StripeServiceNew(
                        // //   paymentSetting: currentPaymentMethod!,
                        // //   totalAmount: plan.amount.validate(),
                        // //   onComplete: (p0) {
                        // //     savePay(
                        // //       plan.id.toString() ?? 0.toString(),
                        // //       paymentMethod: PAYMENT_METHOD_STRIPE,
                        // //       paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
                        // //       txnId: p0['transaction_id'],
                        // //     );
                        // //   },
                        // // );
                        // // stripeServiceNew.stripePay();
                        if (appStore.isLoggedIn) {
                          setState(() {
                            isloading = true;
                          });
                          await createSubscribtion(planId: plan.id ?? 0);
                          showThankYouDialog(false);
                          init();
                          setState(() {
                            isloading = false;
                          });
                        } else {
                          SignInScreen(returnExpected: false).launch(context);
                        }
                      },
                      child: Container(
                          width: getwidth(context, 256.58),
                          height: gethight(context, 52.02),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          child: Center(
                            child: Text(
                              language.choosePlan,
                              style: primaryTextStyle(
                                size: 15,
                                color: const Color(0xffffffff),
                                weight: FontWeight.w600,
                                height: 1.3333333333333333,
                              ),
                              textHeightBehavior: TextHeightBehavior(
                                  applyHeightToFirstAscent: false),
                              textAlign: TextAlign.center,
                            ),
                          )),
                    ),
                  if (historysPlan!
                          .where(
                              (historyPlan) => historyPlan.plan_id == plan.id)
                          .isNotEmpty &&
                      historysPlan!
                              .firstWhere((historyPlan) =>
                                  historyPlan.plan_id == plan.id)
                              .status !=
                          'pending' &&
                      historysPlan!
                              .firstWhere((historyPlan) =>
                                  historyPlan.plan_id == plan.id)
                              .status !=
                          'completed' &&
                      historysPlan!
                              .firstWhere((historyPlan) =>
                                  historyPlan.plan_id == plan.id)
                              .status !=
                          'rejected' &&
                      historysPlan!
                              .firstWhere((historyPlan) =>
                                  historyPlan.plan_id == plan.id)
                              .status !=
                          'cancelled' &&
                      historysPlan!
                              .firstWhere((historyPlan) =>
                                  historyPlan.plan_id == plan.id)
                              .status !=
                          'cancel')
                    InkWell(
                      onTap: () async {
                        paymentType = 'stripe';
                        currentPaymentMethod = paymentList.firstWhere(
                            (element) => element.type == PAYMENT_METHOD_STRIPE);
                        currentPaymentMethod!.isTest = 1;
                        StripeServiceNew stripeServiceNew = StripeServiceNew(
                          paymentSetting: currentPaymentMethod!,
                          totalAmount: plan.amount.validate() +
                              (plan.amount.validate() * 0.05), //tax
                          onComplete: (p0) {
                            savePay(
                              historysPlan!
                                      .firstWhere((historyPlan) =>
                                          historyPlan.plan_id == plan.id)
                                      .id
                                      .toString() ??
                                  0.toString(),
                              paymentMethod: PAYMENT_METHOD_STRIPE,
                              paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
                              txnId: p0['transaction_id'],
                            );
                            showThankYouDialog(true);

                            //init();
                          },
                        );
                        stripeServiceNew.stripePay();
                        // await createSubscribtion(planId: plan.id ?? 0)
                        //     .then((value) {
                        //   init();
                        // });
                      },
                      child: Container(
                          width: getwidth(context, 256.58),
                          height: gethight(context, 52.02),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          child: Center(
                            child: Text(
                              language.proceedToCheckout,
                              style: primaryTextStyle(
                                size: 15,
                                color: const Color(0xffffffff),
                                weight: FontWeight.w600,
                                height: 1.3333333333333333,
                              ),
                              textHeightBehavior: TextHeightBehavior(
                                  applyHeightToFirstAscent: false),
                              textAlign: TextAlign.center,
                            ),
                          )),
                    ),
                ],
              )),
          if (historysPlan!
              .any((historyPlan) => historyPlan.plan_id == plan.id))
            PositionedDirectional(
              end: 10,
              top: 10,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: historysPlan!
                              .firstWhere((historyPlan) =>
                                  historyPlan.plan_id == plan.id)
                              .status ==
                          'pending'
                      ? Colors.deepOrange
                      : Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  historysPlan!
                      .firstWhere(
                          (historyPlan) => historyPlan.plan_id == plan.id)
                      .status
                      .toString()
                      .toUpperCase(),
                  style: primaryTextStyle(
                    color: Colors.white,
                    size: 12,
                    weight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ]);
  }

  Widget planTitle(content) {
    var theme = Theme.of(context).textTheme;

    return Text(
      content,
      style: primaryTextStyle(
        size: 18,
        color: const Color(0xff003e52),
        weight: FontWeight.w600,
        height: 1.5555555555555556,
      ),
      textHeightBehavior: TextHeightBehavior(applyHeightToFirstAscent: false),
    );
  }

  Widget planDescpition(content) {
    var theme = Theme.of(context).textTheme;
    return FittedBox(
        fit: BoxFit.scaleDown, // Will only scale down if needed
        child: Row(
          children: [
            Text(
              '✓',
              style: primaryTextStyle(
                size: 18,
                color: appStore.isDarkMode
                    ? Colors.white
                    : const Color(0xff4178c3),
                letterSpacing: 0.75,
              ),
              textAlign: TextAlign.center,
              softWrap: false,
            ),
            SizedBox(
              width: getwidth(context, 10),
            ),
            SizedBox(
                width: getwidth(context, 220),
                child: Text(
                  content,
                  style: primaryTextStyle(
                    size: 13,
                    color: appStore.isDarkMode
                        ? Colors.white
                        : const Color(0xff000000),
                    letterSpacing: 0.39,
                    weight: FontWeight.w500,
                  ),
                ))
          ],
        ));
  }
}
