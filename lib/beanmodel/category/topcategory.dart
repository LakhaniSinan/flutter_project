import 'package:grocery/baseurl/baseurlg.dart';

class TopCategoryModel{
  dynamic status;
  dynamic message;
  List<TopCategoryDataModel> data;

  TopCategoryModel(this.status, this.message, this.data);

  factory TopCategoryModel.fromJson(dynamic json) {
    var subc = json['data'] as List;
    List<TopCategoryDataModel> subchildRe = [];
    if (subc.length > 0) {
      subchildRe = subc.map((e) => TopCategoryDataModel.fromJson(e)).toList();
    }
    return TopCategoryModel(json['status'], json['message'], subchildRe);
  }

  @override
  String toString() {
    return '{status: $status, message: $message, data: $data}';
  }
}

class TopCategoryDataModel{
  dynamic del_range;
  dynamic store_id;
  dynamic title;
  dynamic image;
  dynamic description;
  dynamic cat_id;
  dynamic count;

  TopCategoryDataModel(this.del_range, this.store_id, this.title, this.image,
      this.description, this.cat_id, this.count);

  factory TopCategoryDataModel.fromJson(dynamic json){
    return TopCategoryDataModel(json['del_range'], json['id'], json['title'], '$imagebaseUrl${json['image']}', json['description'], json['cat_id'], json['count']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['del_range'] = this.del_range;
    data['store_id'] = this.store_id;
    data['title'] = this.title;
    data['image'] = this.image;
    data['description'] = this.description;
    data['cat_id'] = this.cat_id;
    data['count'] = this.count;
    return data;
  }

  @override
  String toString() {
    return '{del_range: $del_range, store_id: $store_id, title: $title, image: $image, description: $description, cat_id: $cat_id, count: $count}';
  }
}