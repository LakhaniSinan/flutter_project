import 'package:grocery/baseurl/baseurlg.dart';

class CategoryModel {
  dynamic status;
  dynamic message;
  List<CategoryDataModel> data;

  CategoryModel(this.status, this.message, this.data);

  factory CategoryModel.fromJson(dynamic json) {
    var subc = json['data'] as List;
    List<CategoryDataModel> subchildRe = [];
    if (subc.length > 0) {
      subchildRe = subc.map((e) => CategoryDataModel.fromJson(e)).toList();
    }
    return CategoryModel(json['status'], json['message'], subchildRe);
  }
}

class CategoryDataModel {
  dynamic title;
  dynamic cat_id;
  dynamic image;
  dynamic description;
  List<SuBCategoryModel> subcategory;

  CategoryDataModel(
      this.title, this.cat_id, this.image, this.description, this.subcategory);

  factory CategoryDataModel.fromJson(dynamic json) {
    var subc = json['subcategory'] as List;
    List<SuBCategoryModel> subchildRe = [];
    if (subc.length > 0) {
      subchildRe = subc.map((e) => SuBCategoryModel.fromJson(e)).toList();
    }
    return CategoryDataModel(json['title'], json['cat_id'], '$imagebaseUrl${json['image']}',
        json['description'], subchildRe);
  }

  @override
  String toString() {
    return '{title: $title, cat_id: $cat_id, image: $image, description: $description, subcategory: $subcategory}';
  }
}

class SuBCategoryModel {
  dynamic cat_id;
  dynamic title;
  dynamic slug;
  dynamic image;
  dynamic parent;
  dynamic level;
  dynamic description;
  dynamic status;
  dynamic added_by;
  List<SubSubCategoryModel> subchild;

  SuBCategoryModel(this.cat_id, this.title, this.slug, this.image, this.parent,
      this.level, this.description, this.status, this.added_by, this.subchild);

  factory SuBCategoryModel.fromJson(dynamic json) {
    var subc = json['subchild'] as List;
    List<SubSubCategoryModel> subchildRe = [];
    if (subc.length > 0) {
      subchildRe = subc.map((e) => SubSubCategoryModel.fromJson(e)).toList();
    }
    return SuBCategoryModel(
        json['cat_id'],
        json['title'],
        json['slug'],
        '$imagebaseUrl${json['image']}',
        json['parent'],
        json['level'],
        json['description'],
        json['status'],
        json['added_by'],
        subchildRe);
  }

  @override
  String toString() {
    return '{cat_id: $cat_id, title: $title, slug: $slug, image: $image, parent: $parent, level: $level, description: $description, status: $status, added_by: $added_by, subchild: $subchild}';
  }
}

class SubSubCategoryModel {
  dynamic cat_id;
  dynamic title;
  dynamic slug;
  dynamic image;
  dynamic parent;
  dynamic level;
  dynamic description;
  dynamic status;
  dynamic added_by;

  SubSubCategoryModel(this.cat_id, this.title, this.slug, this.image,
      this.parent, this.level, this.description, this.status, this.added_by);

  factory SubSubCategoryModel.fromJson(dynamic json) {
    return SubSubCategoryModel(
        json['cat_id'],
        json['title'],
        json['slug'],
        '$imagebaseUrl${json['image']}',
        json['parent'],
        json['level'],
        json['description'],
        json['status'],
        json['added_by']);
  }

  @override
  String toString() {
    return '{cat_id: $cat_id, title: $title, slug: $slug, image: $image, parent: $parent, level: $level, description: $description, status: $status, added_by: $added_by}';
  }
}
