class StateBeanModel{
  dynamic status;
  dynamic message;
  List<StateDataBean> data;

  StateBeanModel(this.status, this.message, this.data);

  factory StateBeanModel.fromJson(dynamic json){
    var tagListJson = json['data'] as List;
    var listD = [];
    if(tagListJson!=null){
      listD = tagListJson.map((e) => StateDataBean.fromJson(e)).toList();
    }
    return StateBeanModel(json['status'], json['message'], listD);
  }
}

class StateDataBean{
  dynamic society_id;
  dynamic society_name;
  dynamic city_id;
  dynamic city_name;

  StateDataBean(this.society_id, this.society_name, this.city_id, this.city_name);

  factory StateDataBean.fromJson(dynamic json){
    return StateDataBean(json['society_id'], json['society_name'], json['city_id'], json['city_name']);
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StateDataBean &&
          runtimeType == other.runtimeType &&
          (('$society_id' == '${other.society_id}') || ('$society_name' == '${other.society_name}'));

  @override
  int get hashCode => society_id.hashCode;

  @override
  String toString() {
    return '{society_id: $society_id, society_name: $society_name, city_id: $city_id, city_name: $city_name}';
  }
}