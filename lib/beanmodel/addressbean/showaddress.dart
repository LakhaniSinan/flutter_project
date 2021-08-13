class ShowAllAddressMain{
  dynamic type;
  List<AddressData> data;

  ShowAllAddressMain(this.type, this.data);

  factory ShowAllAddressMain.fromJson(dynamic json){
    var js = json['data'] as List;
    List<AddressData> jdata = [];
    if(js!=null && js.length>0){
      jdata = js.map((e) => AddressData.fromJson(e)).toList();
    }
    return ShowAllAddressMain(json['type'], jdata);
  }

  @override
  String toString() {
    return '{type: $type, data: $data}';
  }
}

class AddressData{
  dynamic address_id;
  dynamic type;
  dynamic user_id;
  dynamic receiver_name;
  dynamic receiver_phone;
  dynamic city;
  dynamic society;
  dynamic house_no;
  dynamic landmark;
  dynamic state;
  dynamic pincode;
  dynamic lat;
  dynamic lng;
  dynamic select_status;
  dynamic added_at;
  dynamic updated_at;

  AddressData(
      this.address_id,
      this.type,
      this.user_id,
      this.receiver_name,
      this.receiver_phone,
      this.city,
      this.society,
      this.house_no,
      this.landmark,
      this.state,
      this.pincode,
      this.lat,
      this.lng,
      this.select_status,
      this.added_at,
      this.updated_at);

  factory AddressData.fromJson(dynamic json){
    return AddressData(json['address_id'], json['type'], json['user_id'], json['receiver_name'], json['receiver_phone'], json['city'], json['society'], json['house_no'], json['landmark'], json['state'], json['pincode'], json['lat'], json['lng'], json['select_status'], json['added_at'], json['updated_at']);
  }

  @override
  String toString() {
    return '{address_id: $address_id, type: $type, user_id: $user_id, receiver_name: $receiver_name, receiver_phone: $receiver_phone, city: $city, society: $society, house_no: $house_no, landmark: $landmark, state: $state, pincode: $pincode, lat: $lat, lng: $lng, select_status: $select_status, added_at: $added_at, updated_at: $updated_at}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressData &&
          runtimeType == other.runtimeType &&
          '${select_status}' == '${other.select_status}';

  @override
  int get hashCode => select_status.hashCode;
}