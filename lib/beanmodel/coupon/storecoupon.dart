class StoreCouponMain{
  dynamic status;
  dynamic message;
  List<StoreCouponData> data;

  StoreCouponMain(this.status, this.message, this.data);

  factory StoreCouponMain.fromJson(dynamic json){
    var js = json['data'] as List;
    List<StoreCouponData> jsdata = [];
    if(js!=null && js.length>0){
      jsdata = js.map((e) => StoreCouponData.fromJson(e)).toList();
    }
    return StoreCouponMain(json['status'], json['message'], jsdata);
  }

  @override
  String toString() {
    return '{status: $status, message: $message, data: $data}';
  }
}

class StoreCouponData{
  dynamic coupon_id;
  dynamic coupon_name;
  dynamic coupon_code;
  dynamic coupon_description;
  dynamic start_date;
  dynamic end_date;
  dynamic cart_value;
  dynamic amount;
  dynamic type;
  dynamic uses_restriction;
  dynamic store_id;

  StoreCouponData(this.coupon_id, this.coupon_name, this.coupon_code,
      this.coupon_description, this.start_date, this.end_date, this.cart_value,
      this.amount, this.type, this.uses_restriction, this.store_id);

  factory StoreCouponData.fromJson(dynamic json){
    return StoreCouponData(json['coupon_id'], json['coupon_name'], json['coupon_code'], json['coupon_description'], json['start_date'], json['end_date'], json['cart_value'], json['amount'], json['type'], json['uses_restriction'], json['store_id']);
  }

  @override
  String toString() {
    return '{coupon_id: $coupon_id, coupon_name: $coupon_name, coupon_code: $coupon_code, coupon_description: $coupon_description, start_date: $start_date, end_date: $end_date, cart_value: $cart_value, amount: $amount, type: $type, uses_restriction: $uses_restriction, store_id: $store_id}';
  }


}