import 'package:booking_system_flutter/component/app_common_dialog.dart';
import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/component/price_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/booking_data_model.dart';
import 'package:booking_system_flutter/model/booking_list_model.dart';
import 'package:booking_system_flutter/screens/booking/component/edit_booking_service_dialog.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/extensions/num_extenstions.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/service_detail_response.dart';
import '../../../network/rest_apis.dart';
import 'booking_slots.dart';

class OrderItemComponent extends StatefulWidget {
  final OrderData orderData;

  OrderItemComponent({required this.orderData});

  @override
  State<OrderItemComponent> createState() => OrderItemComponentState();
}

class OrderItemComponentState extends State<OrderItemComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(bottom: 16),
      width: context.width(),
      decoration: BoxDecoration(
        border: Border.all(color: context.dividerColor),
        borderRadius: radius(),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedImageWidget(
                url: widget.orderData.items.first.attachments
                        .validate()
                        .isNotEmpty
                    ? widget.orderData.items.first.attachments.first.validate()
                    : '',
                fit: BoxFit.cover,
                width: 80,
                height: 80,
                radius: defaultRadius,
              ),
              16.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.orderData.status
                            .validate()
                            .getPaymentStatusBackgroundColor
                            .withOpacity(0.1),
                        borderRadius: radius(8),
                      ),
                      child: Text(
                        widget.orderData.status.validate().toBookingStatus(),
                        style: boldTextStyle(
                          color: widget.orderData.status
                              .validate()
                              .getPaymentStatusBackgroundColor,
                          size: 12,
                        ),
                      ),
                    ),
                    8.height,
                    Text(
                      '${widget.orderData.items.first.name.validate()}',
                      style: boldTextStyle(size: 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    8.height,
                    Row(
                      children: [
                        PriceWidget(
                          isFreeService: false,
                          price: widget.orderData.totalAmount,
                          color: primaryColor,
                        ),
                        if (widget.orderData.discount != null &&
                            widget.orderData.discount!.validate() != 0)
                          Row(
                            children: [
                              4.width,
                              Text(
                                '(${widget.orderData.discount!}%',
                                style: boldTextStyle(
                                  size: 12,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                ' ${language.lblOff})',
                                style: boldTextStyle(
                                  size: 12,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            decoration: boxDecorationWithRoundedCorners(
              backgroundColor: context.cardColor,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${language.lblDate} & ${language.lblTime}',
                      style: secondaryTextStyle(),
                    ),
                    8.width,
                    Text(
                      "${formatDate(widget.orderData.createdAt.validate(), format: DATE_FORMAT_2)} ${language.at} ",
                      style: boldTextStyle(size: 12),
                      maxLines: 2,
                      textAlign: TextAlign.right,
                    ).expand(),
                  ],
                ).paddingAll(8),
                Column(
                  children: [
                    Divider(height: 0, color: context.dividerColor),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          language.paymentStatus,
                          style: secondaryTextStyle(),
                        ).expand(),
                        Text(
                          buildPaymentStatusWithMethod(
                            widget.orderData.paymentStatus.validate() ??
                                'Pending',
                            widget.orderData.paymentMethod.validate(),
                          ),
                          style: boldTextStyle(
                            size: 12,
                            color: widget.orderData.paymentStatus ==
                                        SERVICE_PAYMENT_STATUS_ADVANCE_PAID ||
                                    widget.orderData.paymentStatus ==
                                        SERVICE_PAYMENT_STATUS_PAID ||
                                    widget.orderData.paymentStatus ==
                                        PENDING_BY_ADMIN
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ).paddingAll(8),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
