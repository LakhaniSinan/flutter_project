// class SignInModel {
//   dynamic status;
//   dynamic message;
//   SignInDataModel data;
//
//   SignInModel(this.status, this.message, this.data);
//
//   factory SignInModel.fromJson(dynamic json) {
//     var data1 = json['data'];
//     SignInDataModel dd;
//     if(data1!=null){
//        dd = SignInDataModel.fromJson(data1);
//        return SignInModel(json['status'], json['message'], dd);
//     }else{
//       return SignInModel(json['status'], json['message'], null);
//     }
//     // SignInDataModel dd = SignInDataModel.fromJson(json['data']);
//
//
//   }
// }

class LoginModel {
  dynamic status;
  dynamic message;
  SignInDataModel data;

  LoginModel(this.status, this.message, this.data);

  factory LoginModel.fromJson(dynamic json) {
    if(json['data']!=null){
      SignInDataModel dd = SignInDataModel.fromJson(json['data']);
      return LoginModel(json['status'], json['message'], dd);
    }else{
      return LoginModel(json['status'], json['message'], null);
    }
  }
}

// class SignInDataModel {
//   dynamic user_id;
//   dynamic user_name;
//   dynamic user_phone;
//   dynamic user_email;
//   dynamic device_id;
//   dynamic user_image;
//   dynamic user_city;
//   dynamic user_area;
//   dynamic user_password;
//   dynamic otp_value;
//   dynamic status;
//   dynamic wallet;
//   dynamic rewards;
//   dynamic is_verified;
//   dynamic block;
//   dynamic reg_date;
//   dynamic app_update;
//   dynamic facebook_id;
//   dynamic referral_code;
//
//   SignInDataModel(
//   {
//     this.user_id,
//     this.user_name,
//     this.user_phone,
//     this.user_email,
//     this.device_id,
//     this.user_image,
//     this.user_city,
//     this.user_area,
//     this.user_password,
//     this.otp_value,
//     this.status,
//     this.wallet,
//     this.rewards,
//     this.is_verified,
//     this.block,
//     this.reg_date,
//     this.app_update,
//     this.facebook_id,
//     this.referral_code
// }
//       );
//
//   SignInDataModel.fromJson(dynamic json) {
//
//     this.user_id=json['user_id'];
//     this.user_name=json['user_name'];
//     this.user_phone=json['user_phone'];
//     this.user_email=json['user_email'];
//     this.device_id=json['device_id'];
//     this.user_image=json['user_image'];
//     this.user_city=json['user_city'];
//     this.user_area=json['user_area'];
//     this.user_password=json['user_password'];
//     this.otp_value=json['otp_value'];
//     this.status=json['status'];
//     this.wallet=json['wallet'];
//     this.rewards=json['rewards'];
//     this.is_verified=json['is_verified'];
//     this.block=json['block'];
//     this.reg_date=json['reg_date'];
//     this.app_update=json['app_update'];
//     this.facebook_id=json['facebook_id'];
//     this.referral_code=json['referral_code'];
//   }
//
//   @override
//   dynamic toString() {
//     return 'SignInDataModel{user_id: $user_id, user_name: $user_name, user_phone: $user_phone, user_email: $user_email, device_id: $device_id, user_image: $user_image, user_city: $user_city, user_area: $user_area, user_password: $user_password, otp_value: $otp_value, status: $status, wallet: $wallet, rewards: $rewards, is_verified: $is_verified, block: $block, reg_date: $reg_date, app_update: $app_update, facebook_id: $facebook_id, referral_code: $referral_code}';
//   }
// }


class SignInModel {
  dynamic status;
  dynamic message;
  SignInDataModel data;
  dynamic token;

  SignInModel({this.status, this.message, this.data, this.token});

  SignInModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new SignInDataModel.fromJson(json['data']) : null;
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    data['token'] = this.token;
    return data;
  }
}

class SignInDataModel {
  dynamic id;
  dynamic name;
  dynamic email;
  dynamic emailVerifiedAt;
  dynamic password;
  dynamic rememberToken;
  dynamic userPhone;
  dynamic deviceId;
  dynamic userImage;
  dynamic userCity;
  dynamic userArea;
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
  dynamic createdAt;
  dynamic updatedAt;

  SignInDataModel(
      {this.id,
        this.name,
        this.email,
        this.emailVerifiedAt,
        this.password,
        this.rememberToken,
        this.userPhone,
        this.deviceId,
        this.userImage,
        this.userCity,
        this.userArea,
        this.otpValue,
        this.status,
        this.wallet,
        this.rewards,
        this.isVerified,
        this.block,
        this.regDate,
        this.appUpdate,
        this.facebookId,
        this.referralCode,
        this.createdAt,
        this.updatedAt});

  SignInDataModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    password = json['password'];
    rememberToken = json['remember_token'];
    userPhone = json['user_phone'];
    deviceId = json['device_id'];
    userImage = json['user_image'];
    userCity = json['user_city'];
    userArea = json['user_area'];
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
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['password'] = this.password;
    data['remember_token'] = this.rememberToken;
    data['user_phone'] = this.userPhone;
    data['device_id'] = this.deviceId;
    data['user_image'] = this.userImage;
    data['user_city'] = this.userCity;
    data['user_area'] = this.userArea;
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
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
