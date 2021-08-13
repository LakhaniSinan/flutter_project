class TimeSlotNewBean {
  dynamic status;
  dynamic message;
  List<TimeSlotNewBeanData> data;

  TimeSlotNewBean({this.status, this.message, this.data});

  TimeSlotNewBean.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data.add(new TimeSlotNewBeanData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TimeSlotNewBeanData {
  dynamic timeslot;
  dynamic availibility;

  TimeSlotNewBeanData({this.timeslot, this.availibility});

  TimeSlotNewBeanData.fromJson(Map<String, dynamic> json) {
    timeslot = json['timeslot'];
    availibility = json['availibility'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['timeslot'] = this.timeslot;
    data['availibility'] = this.availibility;
    return data;
  }
}