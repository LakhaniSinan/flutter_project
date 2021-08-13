import 'package:grocery/beanmodel/category/topcategory.dart';
import 'package:grocery/beanmodel/storefinder/storefinderbean.dart';

class CategorySearchBean{
  bool isSearching;
  StoreFinderData storeFinderData;
  List<TopCategoryDataModel> data;

  CategorySearchBean({this.isSearching, this.data, this.storeFinderData});

}