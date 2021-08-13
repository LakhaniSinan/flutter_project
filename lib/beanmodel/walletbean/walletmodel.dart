class WalletModel{
  dynamic status;
  dynamic message;

  WalletModel(this.status, this.message);

  factory WalletModel.fromJson(dynamic json){
    return WalletModel(json['status'], json['message']);
  }

  @override
  String toString() {
    return '{status: $status, message: $message}';
  }
}