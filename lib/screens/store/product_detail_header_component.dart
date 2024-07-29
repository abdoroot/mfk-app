import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/component/price_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/product_data_model.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/screens/auth/sign_in_screen.dart';
import 'package:booking_system_flutter/screens/gallery/gallery_component.dart';
import 'package:booking_system_flutter/screens/gallery/gallery_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class ProductDetailHeaderComponent extends StatefulWidget {
  final ProductModel ProductDetail;

  const ProductDetailHeaderComponent({required this.ProductDetail, Key? key})
      : super(key: key);

  @override
  State<ProductDetailHeaderComponent> createState() =>
      _ProductDetailHeaderComponentState();
}

class _ProductDetailHeaderComponentState
    extends State<ProductDetailHeaderComponent> {
  Future<void> onTapFavourite() async {
    if (widget.ProductDetail.isFeatured == '1') {
      widget.ProductDetail.isFeatured = '0';
      setState(() {});

      await removeToWishList(serviceId: widget.ProductDetail.id.validate())
          .then((value) {
        if (!value) {
          widget.ProductDetail.isFeatured = '1';
          setState(() {});
        }
      });
    } else {
      widget.ProductDetail.isFeatured = '1';
      setState(() {});

      await addToWishList(serviceId: widget.ProductDetail.id.validate())
          .then((value) {
        if (!value) {
          widget.ProductDetail.isFeatured = '0';
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 475,
      width: context.width(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (widget.ProductDetail.attachments.isNotEmpty)
            SizedBox(
              height: 400,
              width: context.width(),
              child: CachedNetworkImage(
                imageUrl: widget.ProductDetail.attachments!.first,
                fit: BoxFit.cover,
                height: 400,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => Image.network(
                  'https://via.assets.so/shoe.png?id=1&q=95&w=360&h=360&fit=fill',
                  fit: BoxFit.cover,
                  height: 400,
                ),
              ),
            ),
          if (widget.ProductDetail.attachments.isEmpty)
            SizedBox(
              height: 400,
              width: context.width(),
              child: CachedNetworkImage(
                imageUrl:
                    'https://via.assets.so/shoe.png?id=1&q=95&w=360&h=360&fit=fill',
                fit: BoxFit.cover,
                height: 400,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => Image.network(
                  'https://via.assets.so/shoe.png?id=1&q=95&w=360&h=360&fit=fill',
                  fit: BoxFit.cover,
                  height: 400,
                ),
              ),
            ),
          Positioned(
            top: context.statusBarHeight + 8,
            left: 16,
            child: Container(
              child: BackWidget(iconColor: context.iconColor),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.cardColor.withOpacity(0.7)),
            ),
          ),
          // Positioned(
          //   top: context.statusBarHeight + 8,
          //   child: Container(
          //     padding: EdgeInsets.all(10),
          //     margin: EdgeInsets.only(right: 8),
          //     decoration: boxDecorationWithShadow(
          //         boxShape: BoxShape.circle,
          //         backgroundColor: context.cardColor),
          //     child: widget.ProductDetail.isFeatured == '1'
          //         ? ic_fill_heart.iconImage(color: favouriteColor, size: 24)
          //         : ic_heart.iconImage(color: unFavouriteColor, size: 24),
          //   ).onTap(() async {
          //     if (appStore.isLoggedIn) {
          //       onTapFavourite();
          //     } else {
          //       push(SignInScreen(returnExpected: true)).then((value) {
          //         setStatusBarColor(transparentColor,
          //             delayInMilliSeconds: 1000);
          //         if (value) {
          //           onTapFavourite();
          //         }
          //       });
          //     }
          //   },
          //       highlightColor: Colors.transparent,
          //       splashColor: Colors.transparent,
          //       hoverColor: Colors.transparent),
          //   right: 8,
          // ),
          Positioned(
            bottom: 0,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Row(
                  children: [
                    if (widget.ProductDetail.attachments!.length > 1)
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: List.generate(
                          widget.ProductDetail.attachments!.take(2).length,
                          (i) => Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: white, width: 2),
                                borderRadius: radius()),
                            child: GalleryComponent(
                                images: widget.ProductDetail.attachments!,
                                index: i,
                                padding: 32,
                                height: 60,
                                width: 60),
                          ),
                        ),
                      ),
                    16.width,
                    if (widget.ProductDetail.attachments!.length > 2)
                      Blur(
                        borderRadius: radius(),
                        padding: EdgeInsets.zero,
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            border: Border.all(color: white, width: 2),
                            borderRadius: radius(),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                              '+'
                              '${widget.ProductDetail.attachments!.length - 2}',
                              style: boldTextStyle(color: white)),
                        ),
                      ).onTap(() {
                        GalleryScreen(
                          serviceName: widget.ProductDetail.name.validate(),
                          attachments:
                              widget.ProductDetail.attachments.validate(),
                        ).launch(context);
                      }),
                  ],
                ),
                16.height,
                Container(
                  width: context.width(),
                  padding: EdgeInsets.all(16),
                  decoration: boxDecorationDefault(
                    color: context.scaffoldBackgroundColor,
                    border: Border.all(color: context.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.ProductDetail.subcategoryName
                          .validate()
                          .isNotEmpty)
                        Marquee(
                          child: Row(
                            children: [
                              Text('${widget.ProductDetail.categoryName}',
                                  style: boldTextStyle(
                                      color: textSecondaryColorGlobal,
                                      size: 12)),
                              Text('  >  ',
                                  style: boldTextStyle(
                                      color: textSecondaryColorGlobal)),
                              Text('${widget.ProductDetail.subcategoryName}',
                                  style: boldTextStyle(
                                      color: primaryColor, size: 12)),
                            ],
                          ),
                        )
                      else
                        Text('${widget.ProductDetail.categoryName}',
                            style:
                                boldTextStyle(size: 14, color: primaryColor)),
                      8.height,
                      Marquee(
                        child: Text('${widget.ProductDetail.name.validate()}',
                            style: boldTextStyle(size: 18)),
                        directionMarguee: DirectionMarguee.oneDirection,
                      ),
                      8.height,
                      Row(
                        children: [
                          PriceWidget(
                            price: widget.ProductDetail.price.validate(),
                            isHourlyService: false,
                            hourlyTextColor: textSecondaryColorGlobal,
                            isFreeService: false,
                          ),
                          4.width,
                          if (widget.ProductDetail.discount.validate() != 0)
                            Text(
                              '(${widget.ProductDetail.discount.validate()}% ${language.lblOff})',
                              style: boldTextStyle(color: Colors.green),
                            ),
                        ],
                      ),

                      // TextIcon(
                      //   text: '${language.lblRating}',
                      //   textStyle: secondaryTextStyle(size: 14),
                      //   edgeInsets: EdgeInsets.symmetric(vertical: 4),
                      //   expandedText: true,
                      //   suffix: Row(
                      //     children: [
                      //       Image.asset(ic_star_fill,
                      //           height: 18,
                      //           color: getRatingBarColor(widget
                      //               .ProductDetail.totalRating
                      //               .validate()
                      //               .toInt())),
                      //       4.width,
                      //       Text(
                      //           "${widget.serviceDetail.totalRating.validate().toStringAsFixed(1)}",
                      //           style: boldTextStyle()),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
