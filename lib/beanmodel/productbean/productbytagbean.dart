import 'package:grocery/beanmodel/whatsnew/whatsnew.dart';

class ProductsByTagModel {
  dynamic status;
  dynamic message;
  List<Data> data;

  ProductsByTagModel({this.status, this.message, this.data});

  ProductsByTagModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<Data>();
      json['data'].forEach((v) {
        data.add(new Data.fromJson(v));
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

class Data {
  dynamic tagId;
  dynamic productId;
  dynamic tag;
  dynamic catId;
  dynamic productName;
  dynamic productImage;
  dynamic hide;
  dynamic addedBy;
  dynamic approved;
  dynamic varientId;
  dynamic quantity;
  dynamic unit;
  dynamic baseMrp;
  dynamic basePrice;
  dynamic description;
  dynamic varientImage;
  dynamic ean;
  dynamic pId;
  dynamic stock;
  dynamic storeId;
  dynamic mrp;
  dynamic price;
  List<Tags> tags;
  List<Varients> varients;

  Data(
      {this.tagId,
        this.productId,
        this.tag,
        this.catId,
        this.productName,
        this.productImage,
        this.hide,
        this.addedBy,
        this.approved,
        this.varientId,
        this.quantity,
        this.unit,
        this.baseMrp,
        this.basePrice,
        this.description,
        this.varientImage,
        this.ean,
        this.pId,
        this.stock,
        this.storeId,
        this.mrp,
        this.price,
        this.tags,
        this.varients});

  Data.fromJson(Map<String, dynamic> json) {
    tagId = json['tag_id'];
    productId = json['product_id'];
    tag = json['tag'];
    catId = json['cat_id'];
    productName = json['product_name'];
    productImage = json['product_image'];
    hide = json['hide'];
    addedBy = json['added_by'];
    approved = json['approved'];
    varientId = json['varient_id'];
    quantity = json['quantity'];
    unit = json['unit'];
    baseMrp = json['base_mrp'];
    basePrice = json['base_price'];
    description = json['description'];
    varientImage = json['varient_image'];
    ean = json['ean'];
    pId = json['p_id'];
    stock = json['stock'];
    storeId = json['store_id'];
    mrp = json['mrp'];
    price = json['price'];
    if (json['tags'] != null) {
      tags = new List<Tags>();
      json['tags'].forEach((v) {
        tags.add(new Tags.fromJson(v));
      });
    }
    if (json['varients'] != null) {
      varients = new List<Varients>();
      json['varients'].forEach((v) {
        varients.add(new Varients.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tag_id'] = this.tagId;
    data['product_id'] = this.productId;
    data['tag'] = this.tag;
    data['cat_id'] = this.catId;
    data['product_name'] = this.productName;
    data['product_image'] = this.productImage;
    data['hide'] = this.hide;
    data['added_by'] = this.addedBy;
    data['approved'] = this.approved;
    data['varient_id'] = this.varientId;
    data['quantity'] = this.quantity;
    data['unit'] = this.unit;
    data['base_mrp'] = this.baseMrp;
    data['base_price'] = this.basePrice;
    data['description'] = this.description;
    data['varient_image'] = this.varientImage;
    data['ean'] = this.ean;
    data['p_id'] = this.pId;
    data['stock'] = this.stock;
    data['store_id'] = this.storeId;
    data['mrp'] = this.mrp;
    data['price'] = this.price;
    if (this.tags != null) {
      data['tags'] = this.tags.map((v) => v.toJson()).toList();
    }
    if (this.varients != null) {
      data['varients'] = this.varients.map((v) => v.toJson()).toList();
    }
    return data;
  }
}


class Varients {
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

  Varients(
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

  Varients.fromJson(Map<String, dynamic> json) {
    storeId = json['store_id'];
    stock = json['stock'];
    varientId = json['varient_id'];
    description = json['description'];
    price = json['price'];
    mrp = json['mrp'];
    varientImage = json['varient_image'];
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
}