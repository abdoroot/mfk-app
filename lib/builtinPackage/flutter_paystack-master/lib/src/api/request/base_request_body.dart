import 'package:booking_system_flutter/builtinPackage/flutter_paystack-master/lib/src/common/paystack.dart';

 
abstract class BaseRequestBody {
  final fieldDevice = 'device';
  String? _device;

  BaseRequestBody() {
    _setDeviceId();
  }

  Map<String, String?> paramsMap();

  String? get device => _device;

  _setDeviceId() {
    String deviceId = PaystackPlugin.platformInfo.deviceId;
    this._device = deviceId;
  }
}
