import 'package:grocery/baseurl/baseurlg.dart';

class RecentSaleModel{
  dynamic status;
  dynamic message;
  List<RecentSaleDataModel> data;

  RecentSaleModel(this.status, this.message, this.data);

  factory RecentSaleModel.fromJson(dynamic json) {
    var subc = json['data'] as List;
    List<RecentSaleDataModel> subchildRe = [];
    if (subc.length > 0) {
      subchildRe = subc.map((e) => RecentSaleDataModel.fromJson(e)).toList();
    }
    return RecentSaleModel(json['status'], json['message'], subchildRe);
  }
}

class RecentSaleDataModel{
  dynamic store_id;
  dynamic stock;
  dynamic varient_id;
  dynamic product_id;
  dynamic product_name;
  dynamic product_image;
  dynamic description;
  dynamic price;
  dynamic mrp;
  dynamic varient_image;
  dynamic unit;
  dynamic quantity;
  dynamic count;

  RecentSaleDataModel(
      this.store_id,
      this.stock,
      this.varient_id,
      this.product_id,
      this.product_name,
      this.product_image,
      this.description,
      this.price,
      this.mrp,
      this.varient_image,
      this.unit,
      this.quantity,
      this.count);

  factory RecentSaleDataModel.fromJson(dynamic json){
    return RecentSaleDataModel(json['store_id'], json['stock'], json['varient_id'], json['product_id'], json['product_name'], '$imagebaseUrl${json['product_image']}', json['description'], json['price'], json['mrp'], '$imagebaseUrl${json['varient_image']}', json['unit'], json['quantity'], json['count']);
  }

  @override
  String toString() {
    return '{store_id: $store_id, stock: $stock, varient_id: $varient_id, product_id: $product_id, product_name: $product_name, product_image: $product_image, description: $description, price: $price, mrp: $mrp, varient_image: $varient_image, unit: $unit, quantity: $quantity, count: $count}';
  }
}