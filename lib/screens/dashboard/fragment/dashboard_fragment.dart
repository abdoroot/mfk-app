import 'package:booking_system_flutter/app_theme.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/dashboard_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/dashboard/component/category_component.dart';
import 'package:booking_system_flutter/screens/dashboard/component/featured_service_list_component.dart';
import 'package:booking_system_flutter/screens/dashboard/component/service_list_component.dart';
import 'package:booking_system_flutter/screens/dashboard/component/slider_and_location_component.dart';
import 'package:booking_system_flutter/screens/dashboard/shimmer/dashboard_shimmer.dart';
import 'package:booking_system_flutter/screens/service/plans_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/empty_error_state_widget.dart';
import '../../../component/loader_widget.dart';
import '../component/booking_confirmed_component.dart';
import '../component/new_job_request_component.dart';

class DashboardFragment extends StatefulWidget {
  @override
  _DashboardFragmentState createState() => _DashboardFragmentState();
}

class _DashboardFragmentState extends State<DashboardFragment> {
  Future<DashboardResponse>? future;

  @override
  void initState() {
    super.initState();
    init();
    _triggerSubscriptionOffer();

    setStatusBarColor(transparentColor, delayInMilliSeconds: 800);

    LiveStream().on(LIVESTREAM_UPDATE_DASHBOARD, (p0) {
      init();
      setState(() {});
    });
  }

  void init() async {
    future = userDashboard(
        isCurrentLocation: appStore.isCurrentLocation,
        lat: getDoubleAsync(LATITUDE),
        long: getDoubleAsync(LONGITUDE));
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    LiveStream().dispose(LIVESTREAM_UPDATE_DASHBOARD);
  }

  void _triggerSubscriptionOffer() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _showSubscriptionOffer = true;
    });
  }

  void _hideSubscriptionOffer() async {
    setState(() {
      _showSubscriptionOffer = false;
    });
    await Future.delayed(Duration(milliseconds: 300));
    // Perform any additional actions after hiding the offer, if necessary
  }

  bool _showSubscriptionOffer = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SnapHelperWidget<DashboardResponse>(
            initialData: cachedDashboardResponse,
            future: future,
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                imageWidget: ErrorStateWidget(),
                retryText: language.reload,
                onRetry: () {
                  appStore.setLoading(true);
                  init();

                  setState(() {});
                },
              );
            },
            loadingWidget: DashboardShimmer(),
            onSuccess: (snap) {
              return Observer(builder: (context) {
                return AnimatedScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  listAnimationType: ListAnimationType.FadeIn,
                  fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                  onSwipeRefresh: () async {
                    appStore.setLoading(true);
                    init();
                    setState(() {});

                    return await 2.seconds.delay;
                  },
                  children: [
                    Stack(
                      children: [
                        SliderLocationComponent(
                          sliderList: snap.slider.validate(),
                          featuredList: snap.featuredServices.validate(),
                          callback: () async {
                            appStore.setLoading(true);

                            init();
                            setState(() {});
                          },
                        ),
                        PositionedDirectional(
                            bottom: gethight(context, 40),
                            start: getwidth(context, 0),
                            end: getwidth(context, 0),
                            child: AnimtedContainer2(
                                On: _showSubscriptionOffer,
                                widget: InkWell(
                                  onTap: () {
                                    PlansScreen(
                                      allPlans: true,
                                    ).launch(context);
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    height: _showSubscriptionOffer ? 100 : 0,
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: _showSubscriptionOffer
                                        ? Stack(
                                            children: [
                                              Center(
                                                child: Text(
                                                  language
                                                      .specialSubscriptionOffers,
                                                  style: primaryTextStyle(
                                                      color: Colors.white,
                                                      size: 16,
                                                      weight: FontWeight.bold),
                                                ),
                                              ),
                                              Positioned(
                                                right: 10,
                                                top: 10,
                                                child: GestureDetector(
                                                  onTap: _hideSubscriptionOffer,
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : null,
                                  ),
                                ))),
                      ],
                    ),
                    30.height,
                    PendingBookingComponent(upcomingData: snap.upcomingData),
                    CategoryComponent(categoryList: snap.category.validate()),
                    16.height,
                    FeaturedServiceListComponent(
                        serviceList: snap.featuredServices.validate()),
                    ServiceListComponent(serviceList: snap.service.validate()),
                    16.height,
                    if (otherSettingStore.postJobRequestEnable.getBoolInt())
                      NewJobRequestComponent(),
                  ],
                );
              });
            },
          ),
          Observer(
              builder: (context) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
