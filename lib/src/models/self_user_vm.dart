class SelfUserVm {
  late int id;
  late String username;
  String? phoneNumber;
  String? email;
  String? birthday;
  double? balance;
  int? roleEnum;
  String? firstName;
  int? age;
  int? totalGames;
  String? photoUrl;
  String? expiresSubscription;
  String? uid;
  bool? learnReminderEnabled;

  SelfUserVm({
    required this.username,
    this.phoneNumber,
    this.email,
    this.birthday,
    required this.id,
    required this.uid,
    this.balance,
    this.roleEnum,
    this.firstName,
    this.age,
    this.totalGames,
    this.photoUrl,
    this.expiresSubscription,
    this.learnReminderEnabled,
  });

  SelfUserVm.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 2;
    uid = json['uid'];
    username = json['username'] ?? '';
    phoneNumber = json['phoneNumber'];
    email = json['email'];
    birthday = json['birthday'];
    balance = json['balance'];
    roleEnum = json['roleEnum'];
    firstName = json['firstName'];
    age = json['age'];
    totalGames = json['totalGames'];
    photoUrl = json['photoUrl'];
    expiresSubscription = json['expiresSubscription'];
    learnReminderEnabled = json['learnReminderEnabled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['uid'] = this.uid;
    data['phoneNumber'] = this.phoneNumber;
    data['email'] = this.email;
    data['birthday'] = this.birthday;
    data['balance'] = this.balance;
    data['roleEnum'] = this.roleEnum;
    data['firstName'] = this.firstName;
    data['age'] = this.age;
    data['totalGames'] = this.totalGames;
    data['id'] = this.id;
    data['photoUrl'] = this.photoUrl;
    data['expiresSubscription'] = this.expiresSubscription;
    data['learnReminderEnabled'] = this.learnReminderEnabled;
    return data;
  }
}
