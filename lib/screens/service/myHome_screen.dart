import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/my_home_data_model.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/service/component/service_component.dart';
import 'package:booking_system_flutter/screens/service/shimmer/favourite_service_shimmer.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/empty_error_state_widget.dart';
import '../../utils/constant.dart';

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({Key? key}) : super(key: key);

  @override
  _MyHomeScreenState createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen>
    with SingleTickerProviderStateMixin {
  Future<MyHomeData>? future;

  MyHomeData? myHome;

  int page = 1;

  bool isLastPage = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
    init();
  }

  Widget buildAnimatedContainer(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: appStore.isDarkMode ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: primaryTextStyle(
                size: 16,
                weight: FontWeight.w600,
                color: appStore.isDarkMode ? Colors.white : primaryColor,
              ),
            ),
            SizedBox(height: 5),
            Text(
              value,
              style: primaryTextStyle(
                size: 14,
                color: appStore.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> init() async {
    future = getMyhome(page, myHome: myHome ?? null, lastPageCallBack: (p0) {
      isLastPage = p0;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language.myHome,
        color: context.primaryColor,
        textColor: white,
        backWidget: BackWidget(),
        textSize: APP_BAR_TEXT_SIZE,
      ),
      body: Stack(
        children: [
          FutureBuilder<MyHomeData>(
            future: future,
            initialData: cachedmyHome,
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
                  fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
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
                        return FadeTransition(
                          opacity: _animation,
                          child: Container(
                            height: gethight(context, 700),
                            width: getwidth(context, 375),
                            child: ListView(
                              children: [
                                buildAnimatedContainer(
                                    language.StartDate, snap.data!.startDate),
                                buildAnimatedContainer(
                                    language.EndDate, snap.data!.endDate),
                                buildAnimatedContainer(
                                    language.Address, snap.data!.address),
                                buildAnimatedContainer(
                                    language.BuildingNo, snap.data!.buildingNo),
                                buildAnimatedContainer(
                                    language.FlatNo, snap.data!.flatNo),
                                buildAnimatedContainer(
                                    language.MaintenanceBorne,
                                    snap.data!.maintenanceBorne),
                                buildAnimatedContainer(
                                    language.BorneType, snap.data!.borneType),
                                buildAnimatedContainer(language.BorneAmount,
                                    snap.data!.borneAmount),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  ],
                );
              }

              return snapWidgetHelper(
                snap,
                loadingWidget: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Title Loading..',
                          style: primaryTextStyle(
                            size: 16,
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'loading',
                          style: primaryTextStyle(
                            size: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
              builder: (context) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
