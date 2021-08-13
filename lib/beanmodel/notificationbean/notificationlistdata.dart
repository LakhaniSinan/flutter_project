class NotificationList {
  dynamic status;
  dynamic message;
  List<NotificationListData> data;

  NotificationList({this.status, this.message, this.data});

  NotificationList.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<NotificationListData>();
      json['data'].forEach((v) {
        data.add(new NotificationListData.fromJson(v));
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

class NotificationListData {
  dynamic notiId;
  dynamic userId;
  dynamic notiTitle;
  dynamic image;
  dynamic notiMessage;
  dynamic readByUser;
  dynamic createdAt;

  NotificationListData(
      {this.notiId,
        this.userId,
        this.notiTitle,
        this.image,
        this.notiMessage,
        this.readByUser,
        this.createdAt});

  NotificationListData.fromJson(Map<String, dynamic> json) {
    notiId = json['noti_id'];
    userId = json['user_id'];
    notiTitle = json['noti_title'];
    image = json['image'];
    notiMessage = json['noti_message'];
    readByUser = json['read_by_user'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['noti_id'] = this.notiId;
    data['user_id'] = this.userId;
    data['noti_title'] = this.notiTitle;
    data['image'] = this.image;
    data['noti_message'] = this.notiMessage;
    data['read_by_user'] = this.readByUser;
    data['created_at'] = this.createdAt;
    return data;
  }
}