class ProductRating {
  dynamic status;
  dynamic message;
  List<ProductRatingData> data;

  ProductRating({this.status, this.message, this.data});

  ProductRating.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<ProductRatingData>();
      json['data'].forEach((v) {
        data.add(new ProductRatingData.fromJson(v));
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

class ProductRatingData {
  dynamic rateId;
  dynamic userName;
  dynamic storeId;
  dynamic varientId;
  dynamic rating;
  dynamic description;
  dynamic userId;
  dynamic createdAt;
  dynamic updatedAt;

  ProductRatingData(
      {this.rateId,
        this.userName,
        this.storeId,
        this.varientId,
        this.rating,
        this.description,
        this.userId,
        this.createdAt,
        this.updatedAt});

  ProductRatingData.fromJson(Map<String, dynamic> json) {
    rateId = json['rate_id'];
    userName = json['user_name'];
    storeId = json['store_id'];
    varientId = json['varient_id'];
    rating = json['rating'];
    description = json['description'];
    userId = json['user_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rate_id'] = this.rateId;
    data['user_name'] = this.userName;
    data['store_id'] = this.storeId;
    data['varient_id'] = this.varientId;
    data['rating'] = this.rating;
    data['description'] = this.description;
    data['user_id'] = this.userId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}