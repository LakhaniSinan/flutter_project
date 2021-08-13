import 'package:grocery/baseurl/baseurlg.dart';

class CartItemMainBean{
  dynamic status;
  dynamic message;
  dynamic total_price;
  dynamic total_mrp;
  dynamic total_items;
  dynamic delivery_charge;
  CartStoreDetails store_details;
  List<CartItemData> data;

  CartItemMainBean(
      this.status, this.message, this.total_price, this.total_mrp,this.total_items, this.delivery_charge,this.store_details,this.data);

  factory CartItemMainBean.fromJson(dynamic json){
    var ds = json['data'] as List;
    List<CartItemData> daF = [];
    if(ds!=null && ds.length>0){
      daF = ds.map((e) => CartItemData.fromJson(e)).toList();
    }
    CartStoreDetails details;
    if(json['store_details']!=null){
      details = CartStoreDetails.fromJson(json['store_details']);
    }

    return CartItemMainBean(json['status'], json['message'], json['total_price'], json['total_mrp'], json['total_items'], json['delivery_charge'],details,daF);
  }

  @override
  String toString() {
    return '{status: $status, message: $message, total_price: $total_price, total_items: $total_items, delivery_charge: $delivery_charge, store_details: $store_details, data: $data}';
  }
}

class CartStoreDetails{
  dynamic store_id;
  dynamic store_name;
  dynamic employee_name;
  dynamic phone_number;
  dynamic store_photo;
  dynamic city;
  dynamic admin_share;
  dynamic device_id;
  dynamic email;
  dynamic password;
  dynamic del_range;
  dynamic lat;
  dynamic lng;
  dynamic address;
  dynamic admin_approval;
  dynamic store_status;
  dynamic store_opening_time;
  dynamic store_closing_time;
  dynamic time_interval;
  dynamic inactive_reason;

  CartStoreDetails(
      this.store_id,
      this.store_name,
      this.employee_name,
      this.phone_number,
      this.store_photo,
      this.city,
      this.admin_share,
      this.device_id,
      this.email,
      this.password,
      this.del_range,
      this.lat,
      this.lng,
      this.address,
      this.admin_approval,
      this.store_status,
      this.store_opening_time,
      this.store_closing_time,
      this.time_interval,
      this.inactive_reason);

  factory CartStoreDetails.fromJson(dynamic json){
    return CartStoreDetails(json['id'], json['store_name'], json['employee_name'], json['phone_number'],
        json['store_photo'], json['city'], json['admin_share'], json['device_id'],
        json['email'], json['password'], json['del_range'], json['lat'], json['lng'],
        json['address'], json['admin_approval'], json['store_status'], json['store_opening_time'],
        json['store_closing_time'], json['time_interval'], json['inactive_reason']);
  }

  @override
  String toString() {
    return '{store_id: $store_id, store_name: $store_name, employee_name: $employee_name, phone_number: $phone_number, store_photo: $store_photo, city: $city, admin_share: $admin_share, device_id: $device_id, email: $email, password: $password, del_range: $del_range, lat: $lat, lng: $lng, address: $address, admin_approval: $admin_approval, store_status: $store_status, store_opening_time: $store_opening_time, store_closing_time: $store_closing_time, time_interval: $time_interval, inactive_reason: $inactive_reason}';
  }
}

class CartItemData{
  dynamic store_order_id;
  dynamic product_name;
  dynamic varient_image;
  dynamic quantity;
  dynamic unit;
  dynamic varient_id;
  dynamic qty;
  dynamic price;
  dynamic total_mrp;
  dynamic order_cart_id;
  dynamic order_date;
  dynamic store_approval;
  dynamic store_id;
  dynamic description;
  dynamic stock;
  dynamic productid;

  CartItemData(
      {this.store_order_id,
        this.product_name,
        this.varient_image,
        this.quantity,
        this.unit,
        this.varient_id,
        this.qty,
        this.price,
        this.total_mrp,
        this.order_cart_id,
        this.order_date,
        this.store_approval,
        this.store_id,
        this.description,this.stock,this.productid});

  CartItemData.fromJson(dynamic json) {
    this.store_order_id = json['store_order_id'];
    this.product_name = json['product_name'];
    this.varient_image = '$imagebaseUrl${json['varient_image']}';
    this.quantity = json['quantity'];
    this.unit = json['unit'];
    this.varient_id = json['varient_id'];
    this.qty = json['qty'];
    this.price = json['price'];
    this.total_mrp = json['total_mrp'];
    this.order_cart_id = json['order_cart_id'];
    this.order_date = json['order_date'];
    this.store_approval = json['store_approval'];
    this.store_id = json['store_id'];
    this.description = json['description'];
    this.stock = json['stock'];
    this.productid = json['product_id'];
  }

  @override
  String toString() {
    return '{store_order_id: $store_order_id, product_name: $product_name, varient_image: $varient_image, quantity: $quantity, unit: $unit, varient_id: $varient_id, qty: $qty, price: $price, total_mrp: $total_mrp, order_cart_id: $order_cart_id, order_date: $order_date, store_approval: $store_approval, store_id: $store_id, description: $description}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemData &&
          runtimeType == other.runtimeType &&
          '${varient_id}' == '${other.varient_id}';

  @override
  int get hashCode => varient_id.hashCode;
}