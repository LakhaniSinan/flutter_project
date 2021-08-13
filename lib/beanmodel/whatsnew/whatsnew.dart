import 'package:grocery/beanmodel/productbean/productwithvarient.dart';

class WhatsNewModel {
  dynamic status;
  dynamic message;
  List<ProductDataModel> data;

  WhatsNewModel({this.status, this.message, this.data});

  WhatsNewModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data.add(new ProductDataModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// class WhatsNewDataModel {
//   dynamic storeId;
//   dynamic stock;
//   dynamic varientId;
//   dynamic productId;
//   dynamic productName;
//   dynamic productImage;
//   dynamic description;
//   dynamic price;
//   dynamic mrp;
//   dynamic varientImage;
//   dynamic unit;
//   dynamic quantity;
//   dynamic qty;
//   List<Tags> tags;
//
//   WhatsNewDataModel(
//       {this.storeId,
//         this.stock,
//         this.varientId,
//         this.productId,
//         this.productName,
//         this.productImage,
//         this.description,
//         this.price,
//         this.mrp,
//         this.varientImage,
//         this.unit,
//         this.quantity,
//         this.qty,
//         this.tags});
//
//   WhatsNewDataModel.fromJson(Map<String, dynamic> json) {
//     storeId = json['store_id'];
//     stock = json['stock'];
//     varientId = json['varient_id'];
//     productId = json['product_id'];
//     productName = json['product_name'];
//     productImage = '$imagebaseUrl${json['product_image']}';
//     description = json['description'];
//     price = json['price'];
//     mrp = json['mrp'];
//     varientImage = '$imagebaseUrl${json['varient_image']}';
//     unit = json['unit'];
//     quantity = json['quantity'];
//     qty = 0;
//     if (json['tags'] != null) {
//       tags = new List<Tags>();
//       json['tags'].forEach((v) {
//         tags.add(new Tags.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['store_id'] = this.storeId;
//     data['stock'] = this.stock;
//     data['varient_id'] = this.varientId;
//     data['product_id'] = this.productId;
//     data['product_name'] = this.productName;
//     data['product_image'] = this.productImage;
//     data['description'] = this.description;
//     data['price'] = this.price;
//     data['mrp'] = this.mrp;
//     data['varient_image'] = this.varientImage;
//     data['unit'] = this.unit;
//     data['quantity'] = this.quantity;
//     data['qty'] = this.qty;
//     if (this.tags != null) {
//       data['tags'] = this.tags.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is WhatsNewDataModel &&
//           runtimeType == other.runtimeType &&
//           '$varientId' == '${other.varientId}';
//
//   @override
//   int get hashCode => varientId.hashCode;
//
//   @override
//   String toString() {
//     return 'WhatsNewDataModel{storeId: $storeId, stock: $stock, varientId: $varientId, productId: $productId, productName: $productName, productImage: $productImage, description: $description, price: $price, mrp: $mrp, varientImage: $varientImage, unit: $unit, quantity: $quantity, qty: $qty, tags: $tags}';
//   }
// }

class Tags {
  dynamic tagId;
  dynamic productId;
  dynamic tag;

  Tags({this.tagId, this.productId, this.tag});

  Tags.fromJson(Map<String, dynamic> json) {
    tagId = json['tag_id'];
    productId = json['product_id'];
    tag = json['tag'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tag_id'] = this.tagId;
    data['product_id'] = this.productId;
    data['tag'] = this.tag;
    return data;
  }

  @override
  String toString() {
    return 'Tags{tagId: $tagId, productId: $productId, tag: $tag}';
  }
}