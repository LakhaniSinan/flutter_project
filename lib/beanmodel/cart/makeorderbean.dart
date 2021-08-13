class MakeOrderBean{
  dynamic status;
  dynamic message;
  MakeOrderData data;

  MakeOrderBean(this.status, this.message, this.data);

  factory MakeOrderBean.fromJson(dynamic json){
    if(json['data']!=null && '${json['data']}'!='[]'){
      MakeOrderData makeOrderData = MakeOrderData.fromJson(json['data']);
      return MakeOrderBean(json['status'], json['message'], makeOrderData);
    }else{
      return MakeOrderBean(json['status'], json['message'], null);
    }

  }

  @override
  String toString() {
    return '{status: $status, message: $message, data: $data}';
  }
}

class MakeOrderData{
  dynamic order_id;
  dynamic user_id;
  dynamic store_id;
  dynamic address_id;
  dynamic cart_id;
  dynamic total_price;
  dynamic price_without_delivery;
  dynamic total_products_mrp;
  dynamic payment_method;
  dynamic paid_by_wallet;
  dynamic rem_price;
  dynamic order_date;
  dynamic delivery_date;
  dynamic delivery_charge;
  dynamic time_slot;
  dynamic dboy_id;
  dynamic order_status;
  dynamic user_signature;
  dynamic cancelling_reason;
  dynamic coupon_id;
  dynamic coupon_discount;
  dynamic payment_status;
  dynamic cancel_by_store;
  dynamic dboy_incentive;
  dynamic updated_at;

  MakeOrderData(
      this.order_id,
      this.user_id,
      this.store_id,
      this.address_id,
      this.cart_id,
      this.total_price,
      this.price_without_delivery,
      this.total_products_mrp,
      this.payment_method,
      this.paid_by_wallet,
      this.rem_price,
      this.order_date,
      this.delivery_date,
      this.delivery_charge,
      this.time_slot,
      this.dboy_id,
      this.order_status,
      this.user_signature,
      this.cancelling_reason,
      this.coupon_id,
      this.coupon_discount,
      this.payment_status,
      this.cancel_by_store,
      this.dboy_incentive,
      this.updated_at);

  factory MakeOrderData.fromJson(dynamic json){
    return MakeOrderData(json['order_id'], json['user_id'], json['store_id'], json['address_id'], json['cart_id'], json['total_price'],
        json['price_without_delivery'], json['total_products_mrp'], json['payment_method'], json['paid_by_wallet'],
        json['rem_price'], json['order_date'], json['delivery_date'], json['delivery_charge'], json['time_slot'],
        json['dboy_id'], json['order_status'], json['user_signature'], json['cancelling_reason'],
        json['coupon_id'], json['coupon_discount'], json['payment_status'], json['cancel_by_store'], json['dboy_incentive'], json['updated_at']);
  }

  @override
  String toString() {
    return '{order_id: $order_id, user_id: $user_id, store_id: $store_id, address_id: $address_id, cart_id: $cart_id, total_price: $total_price, price_without_delivery: $price_without_delivery, total_products_mrp: $total_products_mrp, payment_method: $payment_method, paid_by_wallet: $paid_by_wallet, rem_price: $rem_price, order_date: $order_date, delivery_date: $delivery_date, delivery_charge: $delivery_charge, time_slot: $time_slot, dboy_id: $dboy_id, order_status: $order_status, user_signature: $user_signature, cancelling_reason: $cancelling_reason, coupon_id: $coupon_id, coupon_discount: $coupon_discount, payment_status: $payment_status, cancel_by_store: $cancel_by_store, dboy_incentive: $dboy_incentive, updated_at: $updated_at}';
  }
}