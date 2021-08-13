import 'package:grocery/baseurl/baseurlg.dart';

class SearchProductByKeyword{

dynamic status;
dynamic message;
List<SearchProductData> data;

SearchProductByKeyword({this.status, this.message, this.data});

factory SearchProductByKeyword.fromJson(dynamic json) {
  var js = json['data'] as List;
  List<SearchProductData> vs = [];
  if (js != null && js.length>0) {
    vs = js.map((e) => SearchProductData.fromJson(e)).toList();
  }
  return SearchProductByKeyword(status: json['status'],message: json['message'],data: vs);

}

@override
  String toString() {
    return '{status: $status, message: $message, data: $data}';
  }
}

class SearchProductData{
dynamic product_name;
dynamic product_id;
List<SearchPVarients> varients;

SearchProductData({this.product_name, this.product_id, this.varients});

factory SearchProductData.fromJson(dynamic json) {
  var js = json['varients'] as List;
  List<SearchPVarients> vs = [];
  if (js != null && js.length>0) {
    vs = js.map((e) => SearchPVarients.fromJson(e)).toList();
  }
  return SearchProductData(product_name: json['product_name'],product_id: json['product_id'],varients: vs);

}

@override
  String toString() {
    return '{product_name: $product_name, product_id: $product_id, varients: $varients}';
  }
}


class SearchPVarients {
  dynamic storeId;
  dynamic stock;
  dynamic varientId;
  dynamic description;
  dynamic price;
  dynamic mrp;
  dynamic varientImage;
  dynamic unit;
  dynamic quantity;
  dynamic dealPrice;
  dynamic validFrom;
  dynamic validTo;

  SearchPVarients(
      this.storeId,
      this.stock,
      this.varientId,
      this.description,
      this.price,
      this.mrp,
      this.varientImage,
      this.unit,
      this.quantity,
      this.dealPrice,
      this.validFrom,
      this.validTo);

  factory SearchPVarients.fromJson(dynamic json) {

    return SearchPVarients(json['store_id'], json['stock'], json['varient_id'], json['description'], json['price'], json['mrp'], '$imagebaseUrl${json['varient_image']}', json['unit'], json['quantity'], json['deal_price'], json['valid_from'], json['valid_to']);
  }

  @override
  String toString() {
    return '{storeId: $storeId, stock: $stock, varientId: $varientId, description: $description, price: $price, mrp: $mrp, varientImage: $varientImage, unit: $unit, quantity: $quantity, dealPrice: $dealPrice, validFrom: $validFrom, validTo: $validTo}';
  }


}