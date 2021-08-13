class WalletRechargeHistory {
  dynamic status;
  dynamic message;
  List<RechargeData> data;

  WalletRechargeHistory({this.status, this.message, this.data});

  WalletRechargeHistory.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<RechargeData>();
      json['data'].forEach((v) {
        data.add(new RechargeData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RechargeData {
  dynamic walletRechargeHistory;
  dynamic userId;
  dynamic rechargeStatus;
  dynamic amount;
  dynamic paymentGateway;
  dynamic dateOfRecharge;
  dynamic userName;
  dynamic userPhone;
  dynamic userEmail;
  dynamic deviceId;
  dynamic userImage;
  dynamic userCity;
  dynamic userArea;
  dynamic userPassword;
  dynamic otpValue;
  dynamic status;
  dynamic wallet;
  dynamic rewards;
  dynamic isVerified;
  dynamic block;
  dynamic regDate;
  dynamic appUpdate;
  dynamic facebookId;
  dynamic referralCode;

  RechargeData(
      {this.walletRechargeHistory,
        this.userId,
        this.rechargeStatus,
        this.amount,
        this.paymentGateway,
        this.dateOfRecharge,
        this.userName,
        this.userPhone,
        this.userEmail,
        this.deviceId,
        this.userImage,
        this.userCity,
        this.userArea,
        this.userPassword,
        this.otpValue,
        this.status,
        this.wallet,
        this.rewards,
        this.isVerified,
        this.block,
        this.regDate,
        this.appUpdate,
        this.facebookId,
        this.referralCode});

  RechargeData.fromJson(Map<String, dynamic> json) {
    walletRechargeHistory = json['wallet_recharge_history'];
    userId = json['user_id'];
    rechargeStatus = json['recharge_status'];
    amount = json['amount'];
    paymentGateway = json['payment_gateway'];
    dateOfRecharge = json['date_of_recharge'];
    userName = json['user_name'];
    userPhone = json['user_phone'];
    userEmail = json['user_email'];
    deviceId = json['device_id'];
    userImage = json['user_image'];
    userCity = json['user_city'];
    userArea = json['user_area'];
    userPassword = json['user_password'];
    otpValue = json['otp_value'];
    status = json['status'];
    wallet = json['wallet'];
    rewards = json['rewards'];
    isVerified = json['is_verified'];
    block = json['block'];
    regDate = json['reg_date'];
    appUpdate = json['app_update'];
    facebookId = json['facebook_id'];
    referralCode = json['referral_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['wallet_recharge_history'] = this.walletRechargeHistory;
    data['user_id'] = this.userId;
    data['recharge_status'] = this.rechargeStatus;
    data['amount'] = this.amount;
    data['payment_gateway'] = this.paymentGateway;
    data['date_of_recharge'] = this.dateOfRecharge;
    data['user_name'] = this.userName;
    data['user_phone'] = this.userPhone;
    data['user_email'] = this.userEmail;
    data['device_id'] = this.deviceId;
    data['user_image'] = this.userImage;
    data['user_city'] = this.userCity;
    data['user_area'] = this.userArea;
    data['user_password'] = this.userPassword;
    data['otp_value'] = this.otpValue;
    data['status'] = this.status;
    data['wallet'] = this.wallet;
    data['rewards'] = this.rewards;
    data['is_verified'] = this.isVerified;
    data['block'] = this.block;
    data['reg_date'] = this.regDate;
    data['app_update'] = this.appUpdate;
    data['facebook_id'] = this.facebookId;
    data['referral_code'] = this.referralCode;
    return data;
  }
}