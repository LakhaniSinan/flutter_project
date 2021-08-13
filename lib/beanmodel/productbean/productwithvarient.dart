import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/whatsnew/whatsnew.dart';

// class ProductModel{
//   dynamic status;
//   dynamic message;
//   List<ProductDataModel> data;
//
//   ProductModel(this.status, this.message, this.data);
//
//   factory ProductModel.fromJson(dynamic json) {
//     var subc = json['data'] as List;
//     List<ProductDataModel> subchildRe = [];
//     if (subc.length > 0) {
//       subchildRe = subc.map((e) => ProductDataModel.fromJson(e)).toList();
//     }
//     return ProductModel(json['status'], json['message'], subchildRe);
//   }
//
//   @override
//   dynamic toString() {
//     return '{status: $status, message: $message, data: $data}';
//   }
// }
//
// class ProductDataModel{
//
//   dynamic p_id;
//   dynamic varient_id;
//   dynamic stock;
//   dynamic store_id;
//   dynamic mrp;
//   dynamic price;
//   dynamic product_id;
//   dynamic quantity;
//   dynamic unit;
//   dynamic base_mrp;
//   dynamic base_price;
//   dynamic description;
//   dynamic varient_image;
//   dynamic ean;
//   dynamic approved;
//   dynamic added_by;
//   dynamic cat_id;
//   dynamic product_name;
//   dynamic product_image;
//   dynamic hide;
//   List<ProductVarient> varients;
//
//   ProductDataModel(
//       this.p_id,
//       this.varient_id,
//       this.stock,
//       this.store_id,
//       this.mrp,
//       this.price,
//       this.product_id,
//       this.quantity,
//       this.unit,
//       this.base_mrp,
//       this.base_price,
//       this.description,
//       this.varient_image,
//       this.ean,
//       this.approved,
//       this.added_by,
//       this.cat_id,
//       this.product_name,
//       this.product_image,
//       this.hide,
//       this.varients);
//
//   factory ProductDataModel.fromJson(dynamic json){
//
//     var subc = json['varients'] as List;
//     List<ProductVarient> subchildRe = [];
//     if (subc.length > 0) {
//       subchildRe = subc.map((e) => ProductVarient.fromJson(e)).toList();
//     }
//
//     return ProductDataModel(json['p_id'], json['varient_id'], json['stock'], json['store_id'], json['mrp'], json['price'], json['product_id'], json['quantity'], json['unit'], json['base_mrp'], json['base_price'], json['description'], json['varient_image'], json['ean'], json['approved'], json['added_by'], json['cat_id'], json['product_name'], '$imagebaseUrl${json['product_image']}', json['hide'], subchildRe);
//   }
//
//   @override
//   dynamic toString() {
//     return '{p_id: $p_id, varient_id: $varient_id, stock: $stock, store_id: $store_id, mrp: $mrp, price: $price, product_id: $product_id, quantity: $quantity, unit: $unit, base_mrp: $base_mrp, base_price: $base_price, description: $description, varient_image: $varient_image, ean: $ean, approved: $approved, added_by: $added_by, cat_id: $cat_id, product_name: $product_name, product_image: $product_image, hide: $hide, varients: $varients}';
//   }
// }
//
// class ProductVarient{
//   dynamic store_id;
//   dynamic stock;
//   dynamic varient_id;
//   dynamic description;
//   dynamic price;
//   dynamic mrp;
//   dynamic varient_image;
//   dynamic unit;
//   dynamic quantity;
//   dynamic deal_price;
//   dynamic valid_from;
//   dynamic valid_to;
//
//   ProductVarient(
//       this.store_id,
//       this.stock,
//       this.varient_id,
//       this.description,
//       this.price,
//       this.mrp,
//       this.varient_image,
//       this.unit,
//       this.quantity,
//       this.deal_price,
//       this.valid_from,
//       this.valid_to);
//
//   factory ProductVarient.fromJson(dynamic json){
//     return ProductVarient(json['store_id'], json['stock'], json['varient_id'], json['description'], json['price'], json['mrp'], '$imagebaseUrl${json['varient_image']}', json['unit'], json['quantity'], json['deal_price'], json['valid_from'], json['valid_to']);
//   }
//
//   @override
//   dynamic toString() {
//     return '{store_id: $store_id, stock: $stock, varient_id: $varient_id, description: $description, price: $price, mrp: $mrp, varient_image: $varient_image, unit: $unit, quantity: $quantity, deal_price: $deal_price, valid_from: $valid_from, valid_to: $valid_to}';
//   }
// }

class ProductModel {
  dynamic status;
  dynamic message;
  List<ProductDataModel> data;

  ProductModel({this.status, this.message, this.data});

  ProductModel.fromJson(Map<String, dynamic> json) {
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

  @override
  String toString() {
    return 'ProductModel{status: $status, message: $message, data: $data}';
  }
}

class ProductDataModel {
  dynamic pId;
  dynamic varientId;
  dynamic stock;
  dynamic storeId;
  dynamic mrp;
  dynamic price;
  dynamic productId;
  dynamic quantity;
  dynamic unit;
  dynamic baseMrp;
  dynamic basePrice;
  dynamic description;
  dynamic varientImage;
  dynamic ean;
  dynamic approved;
  dynamic addedBy;
  dynamic catId;
  dynamic productName;
  dynamic productImage;
  dynamic hide;
  dynamic validTo;
  dynamic validFrom;
  dynamic qty;
  int selectedIndex;
  List<Tags> tags;
  List<ProductVarient> varients;
  List<PImages> images;
  dynamic type;

  ProductDataModel(
      {this.pId,
        this.varientId,
        this.stock,
        this.storeId,
        this.mrp,
        this.price,
        this.productId,
        this.quantity,
        this.unit,
        this.baseMrp,
        this.basePrice,
        this.description,
        this.varientImage,
        this.ean,
        this.approved,
        this.addedBy,
        this.catId,
        this.productName,
        this.productImage,
        this.hide,
        this.validTo,
        this.validFrom,
        this.qty,
        this.tags,
        this.varients,this.selectedIndex,this.images,this.type});

  ProductDataModel.fromJson(Map<String, dynamic> json) {
    pId = json['id'];
    varientId = json['varient_id'];
    stock = json['stock']!=null?json['stock']:0;
    storeId = json['store_id'];
    mrp = json['mrp'];
    price = json['price'];
    productId = json['product_id'];
    quantity = json['quantity'];
    unit = json['unit'];
    baseMrp = json['base_mrp'];
    basePrice = json['base_price'];
    description = json['description'];
    varientImage = '$imagebaseUrl${json['varient_image']}';
    ean = json['ean'];
    approved = json['approved'];
    addedBy = json['added_by'];
    catId = json['cat_id'];
    productName = json['product_name'];
    productImage = '$imagebaseUrl${json['product_image']}';
    validTo = json['valid_to'];
    validFrom = json['valid_from'];
    hide = json['hide'];
    qty = 0;
    selectedIndex = 0;
    if (json['tags'] != null) {
      tags = [];
      json['tags'].forEach((v) {
        tags.add(new Tags.fromJson(v));
      });
    }
    if (json['varients'] != null) {
      varients = [];
      json['varients'].forEach((v) {
        varients.add(new ProductVarient.fromJson(v));
      });
    }else if(json['varient']!=null){
      varients = [];
      json['varient'].forEach((v) {
        varients.add(new ProductVarient.fromJson(v));
      });
    }
    if(json['images'] != null){
      images = [];
      json['images'].forEach((v){
        images.add(new PImages.fromJson(v));
      });
    }
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['p_id'] = this.pId;
    data['varient_id'] = this.varientId;
    data['stock'] = this.stock;
    data['store_id'] = this.storeId;
    data['mrp'] = this.mrp;
    data['price'] = this.price;
    data['product_id'] = this.productId;
    data['quantity'] = this.quantity;
    data['unit'] = this.unit;
    data['base_mrp'] = this.baseMrp;
    data['base_price'] = this.basePrice;
    data['description'] = this.description;
    data['varient_image'] = this.varientImage;
    data['ean'] = this.ean;
    data['approved'] = this.approved;
    data['added_by'] = this.addedBy;
    data['cat_id'] = this.catId;
    data['product_name'] = this.productName;
    data['product_image'] = this.productImage;
    data['hide'] = this.hide;
    data['valid_to'] = this.validTo;
    data['valid_from'] = this.validFrom;
    data['qty'] = this.qty;
    data['selectedindex'] = this.selectedIndex;
    if (this.tags != null) {
      data['tags'] = this.tags.map((v) => v.toJson()).toList();
    }
    if (this.varients != null) {
      data['varients'] = this.varients.map((v) => v.toJson()).toList();
    }
    if(this.images!=null){
      data['images'] = this.images;
    }
    data['type'] = this.type;
    return data;
  }

  @override
  String toString() {
    return 'ProductDataModel{pId: $pId, varientId: $varientId, stock: $stock, storeId: $storeId, mrp: $mrp, price: $price, productId: $productId, quantity: $quantity, unit: $unit, baseMrp: $baseMrp, basePrice: $basePrice, description: $description, varientImage: $varientImage, ean: $ean, approved: $approved, addedBy: $addedBy, catId: $catId, productName: $productName, productImage: $productImage, hide: $hide, validTo: $validTo, validFrom: $validFrom, qty: $qty, selectedIndex: $selectedIndex, tags: $tags, varients: $varients, images: $images}';
  }
}


class ProductVarient {
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

  ProductVarient(
      {this.storeId,
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
        this.validTo});

  ProductVarient.fromJson(Map<String, dynamic> json) {
    storeId = json['store_id'];
    stock = json['stock'];
    varientId = json['varient_id'];
    description = json['description'];
    price = json['price'];
    mrp = json['mrp'];
    varientImage = '$imagebaseUrl${json['varient_image']}';
    unit = json['unit'];
    quantity = json['quantity'];
    dealPrice = json['deal_price'];
    validFrom = json['valid_from'];
    validTo = json['valid_to'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['store_id'] = this.storeId;
    data['stock'] = this.stock;
    data['varient_id'] = this.varientId;
    data['description'] = this.description;
    data['price'] = this.price;
    data['mrp'] = this.mrp;
    data['varient_image'] = this.varientImage;
    data['unit'] = this.unit;
    data['quantity'] = this.quantity;
    data['deal_price'] = this.dealPrice;
    data['valid_from'] = this.validFrom;
    data['valid_to'] = this.validTo;
    return data;
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductVarient &&
          runtimeType == other.runtimeType &&
          '$varientId' == '${other.varientId}';

  @override
  int get hashCode => varientId.hashCode;

  @override
  String toString() {
    return 'ProductVarient{storeId: $storeId, stock: $stock, varientId: $varientId, description: $description, price: $price, mrp: $mrp, varientImage: $varientImage, unit: $unit, quantity: $quantity, dealPrice: $dealPrice, validFrom: $validFrom, validTo: $validTo}';
  }
}

class PImages {
  String image;

  PImages({this.image});

  PImages.fromJson(Map<String, dynamic> json) {
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image'] = this.image;
    return data;
  }
}