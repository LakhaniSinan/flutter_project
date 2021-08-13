import 'package:grocery/beanmodel/productbean/productwithvarient.dart';
import 'package:grocery/beanmodel/storefinder/storefinderbean.dart';

class SearchProviderBean{
  bool isSearching;
  List<ProductDataModel> searchdata;
  StoreFinderData storeData;

  SearchProviderBean(this.isSearching, this.searchdata, this.storeData);
}