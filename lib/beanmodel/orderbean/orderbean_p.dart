import 'package:grocery/baseurl/baseurlg.dart';

class MyOrderBeanMain {
  dynamic storeName;
  dynamic storeOwner;
  dynamic storePhone;
  dynamic storeEmail;
  dynamic storeAddress;
  dynamic orderStatus;
  dynamic deliveryDate;
  dynamic timeSlot;
  dynamic paymentMethod;
  dynamic paymentStatus;
  dynamic paidByWallet;
  dynamic cartId;
  dynamic price;
  dynamic delCharge;
  dynamic remainingAmount;
  dynamic couponDiscount;
  dynamic dboyName;
  dynamic dboyPhone;
  dynamic userName;
  dynamic userAddress;
  List<MyOrderDataMain> data;


  MyOrderBeanMain(
      {this.storeName,
        this.storeOwner,
        this.storePhone,
        this.storeEmail,
        this.storeAddress,
        this.orderStatus,
        this.deliveryDate,
        this.timeSlot,
        this.paymentMethod,
        this.paymentStatus,
        this.paidByWallet,
        this.cartId,
        this.price,
        this.delCharge,
        this.remainingAmount,
        this.couponDiscount,
        this.dboyName,
        this.dboyPhone,
        this.userName,
        this.userAddress,
        this.data});

  MyOrderBeanMain.fromJson(Map<String, dynamic> json) {
    storeName = json['store_name'];
    storeOwner = json['store_owner'];
    storePhone = json['store_phone'];
    storeEmail = json['store_email'];
    storeAddress = json['store_address'];
    orderStatus = json['order_status'];
    deliveryDate = json['delivery_date'];
    timeSlot = json['time_slot'];
    paymentMethod = json['payment_method'];
    paymentStatus = json['payment_status'];
    paidByWallet = json['paid_by_wallet'];
    cartId = json['cart_id'];
    price = json['price'];
    delCharge = json['del_charge'];
    remainingAmount = json['remaining_amount'];
    couponDiscount = json['coupon_discount'];
    dboyName = json['dboy_name'];
    dboyPhone = json['dboy_phone'];
    userName = json['user_name'];
    userAddress = json['delivery_address'];
    if (json['data'] != null) {
      data = new List<MyOrderDataMain>();
      json['data'].forEach((v) {
        data.add(new MyOrderDataMain.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['store_name'] = this.storeName;
    data['store_owner'] = this.storeOwner;
    data['store_phone'] = this.storePhone;
    data['store_email'] = this.storeEmail;
    data['store_address'] = this.storeAddress;
    data['order_status'] = this.orderStatus;
    data['delivery_date'] = this.deliveryDate;
    data['time_slot'] = this.timeSlot;
    data['payment_method'] = this.paymentMethod;
    data['payment_status'] = this.paymentStatus;
    data['paid_by_wallet'] = this.paidByWallet;
    data['cart_id'] = this.cartId;
    data['price'] = this.price;
    data['del_charge'] = this.delCharge;
    data['remaining_amount'] = this.remainingAmount;
    data['coupon_discount'] = this.couponDiscount;
    data['dboy_name'] = this.dboyName;
    data['dboy_phone'] = this.dboyPhone;
    data['user_name'] = this.userName;
    data['delivery_address'] = this.userAddress;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MyOrderDataMain {
  dynamic storeOrderId;
  dynamic productName;
  dynamic varientImage;
  dynamic quantity;
  dynamic unit;
  dynamic varientId;
  dynamic qty;
  dynamic price;
  dynamic totalMrp;
  dynamic orderCartId;
  dynamic orderDate;
  dynamic storeApproval;
  dynamic storeId;
  dynamic description;

  MyOrderDataMain(
      {this.storeOrderId,
        this.productName,
        this.varientImage,
        this.quantity,
        this.unit,
        this.varientId,
        this.qty,
        this.price,
        this.totalMrp,
        this.orderCartId,
        this.orderDate,
        this.storeApproval,
        this.storeId,
        this.description});

  MyOrderDataMain.fromJson(Map<String, dynamic> json) {
    storeOrderId = json['store_order_id'];
    productName = json['product_name'];
    varientImage = '$imagebaseUrl${json['varient_image']}';
    quantity = json['quantity'];
    unit = json['unit'];
    varientId = json['varient_id'];
    qty = json['qty'];
    price = json['price'];
    totalMrp = json['total_mrp'];
    orderCartId = json['order_cart_id'];
    orderDate = json['order_date'];
    storeApproval = json['store_approval'];
    storeId = json['store_id'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['store_order_id'] = this.storeOrderId;
    data['product_name'] = this.productName;
    data['varient_image'] = this.varientImage;
    data['quantity'] = this.quantity;
    data['unit'] = this.unit;
    data['varient_id'] = this.varientId;
    data['qty'] = this.qty;
    data['price'] = this.price;
    data['total_mrp'] = this.totalMrp;
    data['order_cart_id'] = this.orderCartId;
    data['order_date'] = this.orderDate;
    data['store_approval'] = this.storeApproval;
    data['store_id'] = this.storeId;
    data['description'] = this.description;
    return data;
  }
}