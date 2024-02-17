import 'package:drive/src/models/data_model.dart';
import 'package:drive/src/models/success_response.dart';

class LoginModel extends SuccessResponseModel {
  AuthSuccessData? data;
  LoginModel({this.data, statusCode, message});

  LoginModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null
        ? new AuthSuccessData.fromJson(json['data'])
        : null;
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['StatusCode'] = this.statusCode;
    data['Message'] = this.message;
    return data;
  }
}
