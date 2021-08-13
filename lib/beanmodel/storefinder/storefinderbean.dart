class StoreFinderBean{
  dynamic status;
  dynamic message;
  StoreFinderData data;

  StoreFinderBean(this.status, this.message, this.data);

  factory StoreFinderBean.fromJson(dynamic json){
    StoreFinderData finderData;
    if('${json['status']}' == "1"){
      finderData = StoreFinderData.fromJson(json['data']);
    }
    return StoreFinderBean(json['status'], json['message'], finderData);
  }

  @override
  String toString() {
    return '{status: $status, message: $message, data: $data}';
  }
}

class StoreFinderData{
  dynamic del_range;
  dynamic store_id;
  dynamic store_name;
  dynamic store_status;
  dynamic inactive_reason;
  dynamic distance;
  dynamic store_number;
  dynamic store_opening_time;
  dynamic store_closing_time;

  StoreFinderData(this.del_range, this.store_id, this.store_name,
      this.store_status, this.inactive_reason, this.distance,this.store_number,this.store_opening_time,this.store_closing_time);

  factory StoreFinderData.fromJson(dynamic json){
    return StoreFinderData(json['del_range'], json['id'], json['store_name'], json['store_status'], json['inactive_reason'], json['distance'], json['phone_number'], json['store_opening_time'],json['store_closing_time']);
  }

  @override
  String toString() {
    return '{\"del_range\": \"$del_range\", \"id\": \"$store_id\", \"store_name\": \"$store_name\", \"store_status\": \"$store_status\", \"inactive_reason\": \"$inactive_reason\", \"distance\": \"$distance\", \"phone_number\": \"$store_number\"}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreFinderData &&
          runtimeType == other.runtimeType &&
          '$store_id' == '${other.store_id}';

  @override
  int get hashCode => store_id.hashCode;
}