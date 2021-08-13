import 'package:grocery/beanmodel/storefinder/storefinderbean.dart';

class LocEmitterModel{
  double lat;
  double lng;
  String address;
  bool isSearching;
  StoreFinderData storeFinderData;

  LocEmitterModel(this.lat, this.lng, this.address, this.isSearching, this.storeFinderData);

  @override
  String toString() {
    return 'LocEmitterModel{lat: $lat, lng: $lng, address: $address, isSearching: $isSearching, storeFinderData: $storeFinderData}';
  }
}