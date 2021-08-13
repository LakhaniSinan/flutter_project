class WalletGet{
  dynamic status;
  dynamic message;
  dynamic data;

  WalletGet(this.status, this.message, this.data);

  factory WalletGet.fromJson(dynamic json){
  return WalletGet(json['status'], json['message'], json['data']);
  }

  @override
  String toString() {
  return '{status: $status, message: $message}';
  }
}