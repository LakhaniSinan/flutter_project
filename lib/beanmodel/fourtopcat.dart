import 'package:grocery/beanmodel/productbean/productwithvarient.dart';

class TopCategoryProduct {
  dynamic status;
  dynamic message;
  List<TopCategoryProductData> data;

  TopCategoryProduct({this.status, this.message, this.data});

  TopCategoryProduct.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<TopCategoryProductData>();
      json['data'].forEach((v) {
        data.add(new TopCategoryProductData.fromJson(v));
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

class TopCategoryProductData {
  dynamic title;
  dynamic catId;
  dynamic count;
  List<ProductDataModel> products;

  TopCategoryProductData({this.title, this.catId, this.count, this.products});

  TopCategoryProductData.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    catId = json['cat_id'];
    count = json['count'];
    if (json['products'] != null) {
      products = new List<ProductDataModel>();
      json['products'].forEach((v) {
        products.add(new ProductDataModel.fromJson(v));
      });
      if(products!=null && products.length>0){
        products.add(ProductDataModel(productName: 'See all'));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['cat_id'] = this.catId;
    data['count'] = this.count;
    if (this.products != null) {
      data['products'] = this.products.map((v) => v.toJson()).toList();
    }
    return data;
  }
}