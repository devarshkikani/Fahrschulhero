import 'package:drive/src/models/self_user_vm.dart';

class AuthSuccessData {
  String? token;
  String? refreshToken;
  SelfUserVm? user;

  AuthSuccessData({this.token, this.refreshToken, this.user});

  AuthSuccessData.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    refreshToken = json['refreshToken'];
    user = json['user'] != null ? new SelfUserVm.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    data['refreshToken'] = this.refreshToken;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}
