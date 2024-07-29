import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/component/disabled_rating_bar_widget.dart';
import 'package:booking_system_flutter/component/image_border_component.dart';
import 'package:booking_system_flutter/component/price_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/package_data_model.dart';
import 'package:booking_system_flutter/model/product_data_model.dart';
import 'package:booking_system_flutter/screens/booking/provider_info_screen.dart';
import 'package:booking_system_flutter/screens/service/service_detail_screen.dart';
import 'package:booking_system_flutter/screens/store/product_detail_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class ProductComponent extends StatefulWidget {
  final ProductModel? ProductData;
  final BookingPackage? selectedPackage;
  final double? width;
  final bool? isBorderEnabled;
  final VoidCallback? onUpdate;
  final bool isFavouriteProduct;

  ProductComponent(
      {this.ProductData,
      this.width,
      this.isBorderEnabled,
      this.isFavouriteProduct = false,
      this.onUpdate,
      this.selectedPackage});

  @override
  ProductComponentState createState() => ProductComponentState();
}

class ProductComponentState extends State<ProductComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        hideKeyboard(context);
        ProductDetailScreen(
                product: widget.ProductData,
                productId: widget.isFavouriteProduct
                    ? widget.ProductData!.id.validate().toInt()
                    : widget.ProductData!.id.validate())
            .launch(context)
            .then((value) {
          setStatusBarColor(context.primaryColor);
        });
      },
      child: Container(
        decoration: boxDecorationWithRoundedCorners(
          borderRadius: radius(),
          backgroundColor: context.cardColor,
          border: widget.isBorderEnabled.validate(value: false)
              ? appStore.isDarkMode
                  ? Border.all(color: context.dividerColor)
                  : null
              : null,
        ),
        width: widget.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 205,
              width: context.width(),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CachedImageWidget(
                    url: widget.isFavouriteProduct
                        ? widget.ProductData!.attachments.validate().isNotEmpty
                            ? widget.ProductData!.attachmentsArray!.first.url
                                .validate()
                            : ''
                        : widget.ProductData!.attachments.validate().isNotEmpty
                            ? widget.ProductData!.attachments!.first.validate()
                            : '',
                    fit: BoxFit.cover,
                    height: 180,
                    width: context.width(),
                    circle: false,
                  ).cornerRadiusWithClipRRectOnly(
                      topRight: defaultRadius.toInt(),
                      topLeft: defaultRadius.toInt()),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                      constraints:
                          BoxConstraints(maxWidth: context.width() * 0.3),
                      decoration: boxDecorationWithShadow(
                        backgroundColor: context.cardColor.withOpacity(0.9),
                        borderRadius: radius(24),
                      ),
                      child: Marquee(
                        directionMarguee: DirectionMarguee.oneDirection,
                        child: Text(
                          "${widget.ProductData!.subcategoryName.validate().isNotEmpty ? widget.ProductData!.subcategoryName.validate() : widget.ProductData!.categoryName.validate()}"
                              .toUpperCase(),
                          style: boldTextStyle(
                              color: appStore.isDarkMode ? white : primaryColor,
                              size: 12),
                        ).paddingSymmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 12,
                    child: Icon(Icons.circle, color: Colors.green, size: 12),
                  ),
                  if (widget.isFavouriteProduct)
                    Positioned(
                      top: 8,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(right: 8),
                        decoration: boxDecorationWithShadow(
                            boxShape: BoxShape.circle,
                            backgroundColor: context.cardColor),
                        child: widget.ProductData!.isFeatured == '0'
                            ? ic_fill_heart.iconImage(
                                color: favouriteColor, size: 18)
                            : ic_heart.iconImage(
                                color: unFavouriteColor, size: 18),
                      ).onTap(() async {
                        if (widget.ProductData!.isFeatured == '0') {
                          widget.ProductData!.isFeatured = '1';
                          setState(() {});

                          await removeToWishList(
                                  serviceId:
                                      widget.ProductData!.id.validate().toInt())
                              .then((value) {
                            if (!value) {
                              widget.ProductData!.isFeatured = '0';
                              setState(() {});
                            }
                          });
                        } else {
                          widget.ProductData!.isFeatured = '0';
                          setState(() {});

                          await addToWishList(
                                  serviceId:
                                      widget.ProductData!.id.validate().toInt())
                              .then((value) {
                            if (!value) {
                              widget.ProductData!.isFeatured = '1';
                              setState(() {});
                            }
                          });
                        }
                        widget.onUpdate?.call();
                      }),
                    ),
                  Positioned(
                    bottom: 12,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: boxDecorationWithShadow(
                        backgroundColor: primaryColor,
                        borderRadius: radius(24),
                        border: Border.all(color: context.cardColor, width: 2),
                      ),
                      child: PriceWidget(
                        price: widget.ProductData!.price.validate(),
                        color: Colors.white,
                        hourlyTextColor: Colors.white,
                        size: 14,
                        isFreeService: false,
                      ),
                    ),
                  ),
                  // Positioned(
                  //   bottom: 0,
                  //   left: 16,
                  //   child: DisabledRatingBarWidget(
                  //       rating: widget.ProductData!.,
                  //       size: 14),
                  // ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                8.height,
                Marquee(
                  directionMarguee: DirectionMarguee.oneDirection,
                  child: Text(widget.ProductData!.name.validate(),
                          style: boldTextStyle())
                      .paddingSymmetric(horizontal: 16),
                ),
                8.height,
                Row(
                  children: [
                    ImageBorder(
                        src: widget.ProductData!.providerImage.validate(),
                        height: 30),
                    8.width,
                    if (widget.ProductData!.providerName.validate().isNotEmpty)
                      Text(
                        widget.ProductData!.providerName.validate(),
                        style: secondaryTextStyle(
                            size: 12,
                            color: appStore.isDarkMode
                                ? Colors.white
                                : appTextSecondaryColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ).expand()
                  ],
                ).onTap(() async {
                  if (widget.ProductData!.providerId !=
                      appStore.userId.validate()) {
                    await ProviderInfoScreen(
                            providerId: int.parse(widget.ProductData!.providerId
                                .toString()
                                .validate()))
                        .launch(context);
                    setStatusBarColor(Colors.transparent);
                  } else {
                    //
                  }
                }).paddingSymmetric(horizontal: 16),
                16.height,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
