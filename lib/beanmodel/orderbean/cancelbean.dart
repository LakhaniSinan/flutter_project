class CancelMain{
  dynamic status;
  dynamic message;
  List<CancelData> data;

  CancelMain(this.status, this.message, this.data);

  factory CancelMain.fromJson(dynamic json){
    var jd = json['data'] as List;
    List<CancelData> jdata = [];
    if (jd != null && jd.length > 0) {
      jdata = jd.map((e) => CancelData.fromJson(e)).toList();
    }
    return CancelMain(json['status'], json['message'], jdata);
  }

  @override
  String toString() {
    return '{status: $status, message: $message, data: $data}';
  }
}

class CancelData{
  dynamic reason;
  dynamic res_id;

  CancelData(this.reason, this.res_id);

  factory CancelData.fromJson(dynamic json){
    return CancelData(json['reason'], json['res_id']);
  }

  @override
  String toString() {
    return '{reason: $reason, res_id: $res_id}';
  }
}