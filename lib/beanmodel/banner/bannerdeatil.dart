import 'package:grocery/baseurl/baseurlg.dart';

class BannerModel{
  dynamic status;
  dynamic message;
  List<BannerDataModel> data;


  BannerModel(this.status, this.message, this.data);

  factory BannerModel.fromJson(dynamic json) {
    var subc = json['data'] as List;
    List<BannerDataModel> subchildRe = [];
    if (subc.length > 0) {
      subchildRe = subc.map((e) => BannerDataModel.fromJson(e)).toList();
    }
    return BannerModel(json['status'], json['message'], subchildRe);
  }

}

class BannerDataModel{
  dynamic banner_id;
  dynamic banner_name;
  dynamic banner_image;
  dynamic store_id;
  dynamic cat_id;
  dynamic type;
  dynamic title;

  BannerDataModel(this.banner_id, this.banner_name, this.banner_image,
      this.store_id, this.cat_id, this.type, this.title);

  factory BannerDataModel.fromJson(dynamic json){
    return BannerDataModel(json['banner_id'], json['banner_name'], '$imagebaseUrl${json['banner_image']}', json['id'], json['cat_id'], json['type'], json['title']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['banner_id'] = this.banner_id;
    data['banner_name'] = this.banner_name;
    data['banner_image'] = this.banner_image;
    data['store_id'] = this.store_id;
    data['cat_id'] = this.cat_id;
    data['type'] = this.type;
    data['title'] = this.title;
    return data;
  }

  @override
  String toString() {
    return '{banner_id: $banner_id, banner_name: $banner_name, banner_image: $banner_image, store_id: $store_id, cat_id: $cat_id, type: $type, title: $title}';
  }
}