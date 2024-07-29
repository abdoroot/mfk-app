import 'package:booking_system_flutter/builtinPackage/flutter_paystack-master/lib/src/api/request/base_request_body.dart';
 
class ValidateRequestBody extends BaseRequestBody {
  String _fieldTrans = 'trans';
  String _fieldToken = 'token';
  String? trans;
  String? token;

  @override
  Map<String, String?> paramsMap() {
    Map<String, String?> params = {_fieldTrans: trans, _fieldToken: token};
    if (device != null) {
      params[fieldDevice] = device;
    }
    return params;
  }
}
