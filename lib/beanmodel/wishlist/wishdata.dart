import 'package:grocery/baseurl/baseurlg.dart';

class WishListModel{

  dynamic status;
  dynamic message;
  List<WishListDataModel> data;

  WishListModel(this.status, this.message, this.data);

  factory WishListModel.fromJson(dynamic json){
    var subc = json['data'] as List;
    List<WishListDataModel> subchildRe = [];
    if (subc.length > 0) {
    subchildRe = subc.map((e) => WishListDataModel.fromJson(e)).toList();
    }
    return WishListModel(json['status'], json['message'], subchildRe);
  }

  @override
  String toString() {
    return '{status: $status, message: $message, data: $data}';
  }
}

class WishListDataModel{

  dynamic wish_id;
  dynamic user_id;
  dynamic varient_id;
  dynamic quantity;
  dynamic unit;
  dynamic price;
  dynamic mrp;
  dynamic product_name;
  dynamic description;
  dynamic varient_image;
  dynamic store_id;
  dynamic created_at;
  dynamic updated_at;
  dynamic qty;
  dynamic stock;
  dynamic product_id;

  WishListDataModel(
      this.wish_id,
      this.user_id,
      this.varient_id,
      this.quantity,
      this.unit,
      this.price,
      this.mrp,
      this.product_name,
      this.description,
      this.varient_image,
      this.store_id,
      this.created_at,
      this.updated_at,
      this.qty,
      this.stock,
      this.product_id);

  factory WishListDataModel.fromJson(dynamic json){
    return WishListDataModel(json['wish_id'], json['user_id'], json['varient_id'], json['quantity'], json['unit'], json['price'], json['mrp'], json['product_name'], json['description'], '$imagebaseUrl${json['varient_image']}', json['store_id'], json['created_at'], json['updated_at'],0,json['stock'],json['product_id']);
  }


  @override
  String toString() {
    return 'WishListDataModel{wish_id: $wish_id, user_id: $user_id, varient_id: $varient_id, quantity: $quantity, unit: $unit, price: $price, mrp: $mrp, product_name: $product_name, description: $description, varient_image: $varient_image, store_id: $store_id, created_at: $created_at, updated_at: $updated_at, qty: $qty, stock: $stock}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WishListDataModel &&
          runtimeType == other.runtimeType &&
          '${varient_id}' == '${other.varient_id}';

  @override
  int get hashCode => varient_id.hashCode;
}