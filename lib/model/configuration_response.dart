import 'dart:convert';

import 'package:booking_system_flutter/model/country_list_model.dart';
import 'package:nb_utils/nb_utils.dart';

class ConfigurationResponse {
  List<Configuration>? configurations;
  List<PaymentSetting>? paymentSettings;
  OtherSettings? otherSettings;

  ConfigurationResponse({
    this.configurations,
    this.paymentSettings,
    this.otherSettings,
  });

  factory ConfigurationResponse.fromJson(Map<String, dynamic> json) {
    return ConfigurationResponse(
      configurations: json['configurations'] != null ? (json['configurations'] as List).map((i) => Configuration.fromJson(i)).toList() : null,
      paymentSettings: json['payment_settings'] != null ? (json['payment_settings'] as List).map((i) => PaymentSetting.fromJson(i)).toList() : null,
      otherSettings: json['other_settings'] != null ? OtherSettings.fromJson(json['other_settings']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    if (this.configurations != null) {
      data['configurations'] = this.configurations!.map((v) => v.toJson()).toList();
    }
    if (this.paymentSettings != null) {
      data['payment_settings'] = this.paymentSettings!.map((v) => v.toJson()).toList();
    }
    if (this.otherSettings != null) {
      data['other_settings'] = this.otherSettings;
    }

    return data;
  }
}

class OtherSettings {
  int? appleLogin;
  int? blog;
  int? forceUpdateAdminApp;
  int? forceUpdateProviderApp;
  int? forceUpdateUserApp;
  int? googleLogin;
  int? maintenanceMode;
  String? maintenanceModeSecretCode;
  int? otpLogin;
  int? postJobRequest;
  int? socialLogin;
  int? userAppLatestVersion;
  int? userAppMinimumVersion;
  int? enableChatGpt;
  int? testWithoutKey;
  String? chatGptKey;
  String? firebaseKey;
  bool? enableUserWallet;
  bool? isAdvancedPaymentAllowed;

  OtherSettings({
    this.appleLogin,
    this.blog,
    this.forceUpdateAdminApp,
    this.forceUpdateProviderApp,
    this.forceUpdateUserApp,
    this.googleLogin,
    this.maintenanceMode,
    this.maintenanceModeSecretCode,
    this.otpLogin,
    this.postJobRequest,
    this.socialLogin,
    this.userAppLatestVersion,
    this.userAppMinimumVersion,
    this.enableChatGpt,
    this.testWithoutKey,
    this.chatGptKey,
    this.firebaseKey,
    this.enableUserWallet = false,
    this.isAdvancedPaymentAllowed,
  });

  factory OtherSettings.fromJson(Map<String, dynamic> json) {
    return OtherSettings(
      appleLogin: json['apple_login'],
      blog: json['blog'],
      forceUpdateAdminApp: json['force_update_admin_app'],
      forceUpdateProviderApp: json['force_update_provider_app'],
      forceUpdateUserApp: json['force_update_user_app'],
      googleLogin: json['google_login'],
      maintenanceMode: json['maintenance_mode'],
      maintenanceModeSecretCode: json['maintenance_mode_secret_code'] != null ? json['maintenance_mode_secret_code'] : null,
      otpLogin: json['otp_login'],
      postJobRequest: json['post_job_request'],
      socialLogin: json['social_login'],
      enableChatGpt: json['enable_chat_gpt'],
      testWithoutKey: json['test_without_key'],
      chatGptKey: json['chat_gpt_key'] != null ? json['chat_gpt_key'] : null,
      firebaseKey: json['firebase_key'] != null ? json['firebase_key'] : null,
      userAppLatestVersion: json["user_app_latest_version"] is int
          ? json["user_app_latest_version"]
          : json["user_app_latest_version"] is String
              ? json["user_app_latest_version"].toString().toInt(defaultValue: 0)
              : 0,
      userAppMinimumVersion: json["user_app_minimum_version"] is int
          ? json["user_app_minimum_version"]
          : json["user_app_minimum_version"] is String
              ? json["user_app_minimum_version"].toString().toInt(defaultValue: 0)
              : 0,
      enableUserWallet: json["wallet"] is int
          ? json["wallet"] == 1
          : json["wallet"] is String
              ? json["wallet"] == "1"
              : false,
      isAdvancedPaymentAllowed: json["advanced_payment_setting"] is int
          ? json["advanced_payment_setting"] == 1
          : json["advanced_payment_setting"] is String
              ? json["advanced_payment_setting"] == "1"
              : false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['apple_login'] = this.appleLogin;
    data['blog'] = this.blog;
    data['force_update_admin_app'] = this.forceUpdateAdminApp;
    data['force_update_provider_app'] = this.forceUpdateProviderApp;
    data['force_update_user_app'] = this.forceUpdateUserApp;
    data['google_login'] = this.googleLogin;
    data['maintenance_mode'] = this.maintenanceMode;
    data['otp_login'] = this.otpLogin;
    data['post_job_request'] = this.postJobRequest;
    data['social_login'] = this.socialLogin;
    data['enable_chat_gpt'] = this.enableChatGpt;
    data['test_without_key'] = this.testWithoutKey;
    if (this.chatGptKey != null) {
      data['chat_gpt_key'] = this.chatGptKey;
    }
    if (this.firebaseKey != null) {
      data['firebase_key'] = this.firebaseKey;
    }
    if (this.maintenanceModeSecretCode != null) {
      data['maintenance_mode_secret_code'] = this.maintenanceModeSecretCode;
    }
    if (this.userAppLatestVersion != null) {
      data['user_app_latest_version'] = this.userAppLatestVersion;
    }
    if (this.userAppMinimumVersion != null) {
      data['user_app_minimum_version'] = this.userAppMinimumVersion;
    }
    if (this.enableUserWallet != null) {
      data['wallet'] = this.enableUserWallet;
    }
    if (this.isAdvancedPaymentAllowed != null) {
      data['advanced_payment_setting'] = this.isAdvancedPaymentAllowed;
    }
    return data;
  }
}

class Configuration {
  CountryListResponse? country;
  int? id;
  String? key;
  String? type;
  String? value;

  Configuration({this.country, this.id, this.key, this.type, this.value});

  factory Configuration.fromJson(Map<String, dynamic> json) {
    return Configuration(
      country: json['country'] != null ? CountryListResponse.fromJson(json['country']) : null,
      id: json['id'],
      key: json['key'],
      type: json['type'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['key'] = this.key;
    data['type'] = this.type;
    data['value'] = this.value;
    if (this.country != null) {
      data['country'] = this.country!.toJson();
    }
    return data;
  }
}

class PaymentSetting {
  int? id;
  int? isTest;
  LiveValue? liveValue;
  int? status;
  String? title;
  String? type;
  LiveValue? testValue;

  PaymentSetting({this.id, this.isTest, this.liveValue, this.status, this.title, this.type, this.testValue});

  static String encode(List<PaymentSetting> paymentList) {
    return json.encode(paymentList.map<Map<String, dynamic>>((payment) => payment.toJson()).toList());
  }

  static List<PaymentSetting> decode(String musics) {
    return (json.decode(musics) as List<dynamic>).map<PaymentSetting>((item) => PaymentSetting.fromJson(item)).toList();
  }

  factory PaymentSetting.fromJson(Map<String, dynamic> json) {
    return PaymentSetting(
      id: json['id'],
      isTest: json['is_test'],
      liveValue: json['live_value'] != null ? LiveValue.fromJson(json['live_value']) : LiveValue(),
      status: json['status'],
      title: json['title'],
      type: json['type'],
      testValue: json['value'] != null ? LiveValue.fromJson(json['value']) : LiveValue(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['is_test'] = this.isTest;
    data['status'] = this.status;
    data['title'] = this.title;
    data['type'] = this.type;
    if (this.liveValue != null) {
      data['live_value'] = this.liveValue?.toJson();
    }
    if (this.testValue != null) {
      data['value'] = this.testValue?.toJson();
    }
    return data;
  }
}

class LiveValue {
  /// For Stripe
  String? stripeUrl;
  String? stripeKey;
  String? stripePublickey;

  /// For Razor Pay
  String? razorUrl;
  String? razorKey;
  String? razorSecret;

  /// For Flutter Wave
  String? flutterwavePublic;
  String? flutterwaveSecret;
  String? flutterwaveEncryption;

  /// For Paypal
  String? payPalClientId;
  String? payPalSecretKey;

  /// For Sadad
  String? sadadId;
  String? sadadKey;
  String? sadadDomain;

  /// For CinetPay
  String? cinetId;
  String? cinetKey;
  String? cinetPublicKey;

  /// For AirtelMoney
  String? airtelClientId;
  String? airtelSecretKey;

  /// For Paystack
  String? paystackPublicKey;

  /// For PhonePe
  String? phonePeAppID;
  String? phonePeMerchantID;
  String? phonePeSaltKey;
  String? phonePeSaltIndex;

  /// For Midtrans
  String? midtransClientId;

  LiveValue({
    this.stripeUrl,
    this.stripeKey,
    this.stripePublickey,
    this.razorUrl,
    this.razorKey,
    this.razorSecret,
    this.flutterwavePublic,
    this.flutterwaveSecret,
    this.flutterwaveEncryption,
    this.payPalClientId,
    this.payPalSecretKey,
    this.sadadId,
    this.sadadKey,
    this.sadadDomain,
    this.cinetId,
    this.cinetKey,
    this.cinetPublicKey,
    this.airtelClientId,
    this.airtelSecretKey,
    this.phonePeAppID,
    this.phonePeMerchantID,
    this.phonePeSaltKey,
    this.phonePeSaltIndex,
    this.paystackPublicKey,
    this.midtransClientId,
  });

  factory LiveValue.fromJson(Map<String, dynamic> json) {
    return LiveValue(
      stripeUrl: json['stripe_url'],
      stripeKey: json['stripe_key'],
      stripePublickey: json['stripe_publickey'],
      razorUrl: json['razor_url'],
      razorKey: json['razor_key'],
      razorSecret: json['razor_secret'],
      flutterwavePublic: json['flutterwave_public'],
      flutterwaveSecret: json['flutterwave_secret'],
      flutterwaveEncryption: json['flutterwave_encryption'],
      payPalClientId: json['paypal_client_id'],
      payPalSecretKey: json['paypal_secret_key'],
      sadadId: json['sadad_id'],
      sadadKey: json['sadad_key'],
      sadadDomain: json['sadad_domain'],
      cinetId: json['cinet_id'],
      cinetKey: json['cinet_key'],
      cinetPublicKey: json['cinet_publickey'],
      airtelClientId: json['client_id'] is String ? json['client_id'] : "",
      airtelSecretKey: json['secret_key'] is String ? json['secret_key'] : "",
      phonePeAppID: json['app_id'] is String ? json['app_id'] : "",
      phonePeMerchantID: json['merchant_id'] is String ? json['merchant_id'] : "",
      phonePeSaltKey: json['salt_key'] is String ? json['salt_key'] : "",
      phonePeSaltIndex: json["salt_index"] is String ? json["salt_index"] : "1",
      paystackPublicKey: json['paystack_public'] is String ? json['paystack_public'] : "",
      midtransClientId: json['client_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stripe_url'] = this.stripeUrl;
    data['stripe_key'] = this.stripeKey;
    data['stripe_publickey'] = this.stripePublickey;
    data['razor_url'] = this.razorUrl;
    data['razor_key'] = this.razorKey;
    data['razor_secret'] = this.razorSecret;
    data['flutterwave_public'] = this.flutterwavePublic;
    data['flutterwave_secret'] = this.flutterwaveSecret;
    data['flutterwave_encryption'] = this.flutterwaveEncryption;
    data['paypal_client_id'] = this.payPalClientId;
    data['paypal_secret_key'] = this.payPalSecretKey;
    data['sadad_id'] = this.sadadId;
    data['sadad_key'] = this.sadadKey;
    data['sadad_domain'] = this.sadadDomain;
    data['cinet_id'] = this.cinetId;
    data['cinet_key'] = this.cinetKey;
    data['cinet_publickey'] = this.cinetPublicKey;
    data['client_id'] = this.airtelClientId;
    data['secret_key'] = this.airtelSecretKey;
    data['app_id'] = this.phonePeAppID;
    data['merchant_id'] = this.phonePeMerchantID;
    data['salt_key'] = this.phonePeSaltKey;
    data['salt_index'] = this.phonePeSaltIndex;
    data['paystack_public'] = this.paystackPublicKey;
    data['client_id'] = this.midtransClientId;

    return data;
  }
}
