import 'package:grocery/beanmodel/category/topcategory.dart';
import 'package:grocery/beanmodel/deal/dealproduct.dart';
import 'package:grocery/beanmodel/productbean/productwithvarient.dart';
import 'package:grocery/beanmodel/whatsnew/whatsnew.dart';

import 'banner/bannerdeatil.dart';

class SingleApiHomePage {
  String status;
  String message;
  List<BannerDataModel> banner;
  List<TopCategoryDataModel> topCat;
  List<TabsD> tabs;

  SingleApiHomePage(
      {this.status,
      this.message,
      this.banner,
      this.topCat,
      this.tabs});

  SingleApiHomePage.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['banner'] != null) {
      banner = [];
      json['banner'].forEach((v) {
        banner.add(new BannerDataModel.fromJson(v));
      });
    }
    if (json['top_cat'] != null) {
      topCat = [];
      json['top_cat'].forEach((v) {
        topCat.add(new TopCategoryDataModel.fromJson(v));
      });
    }
    if (json['tabs'] != null) {
      tabs = [];
      json['tabs'].forEach((v) {
        var jd = v['data'] as List;
        if(jd!=null && jd.length>0){
          tabs.add(new TabsD.fromJson(v));
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.banner != null) {
      data['banner'] = this.banner.map((v) => v.toJson()).toList();
    }
    if (this.topCat != null) {
      data['top_cat'] = this.topCat.map((v) => v.toJson()).toList();
    }
    if (this.tabs != null) {
      data['tabs'] = this.tabs.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return 'SingleApiHomePage{status: $status, message: $message, banner: $banner, topCat: $topCat, tabs: $tabs}';
  }
}

class TabsD {
  String type;
  List<ProductDataModel> data;

  TabsD({this.type, this.data});

  TabsD.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data.add(new ProductDataModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return 'TabsD{type: $type, data: $data}';
  }
}
