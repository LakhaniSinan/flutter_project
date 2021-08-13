class AppNotice {
  dynamic status;
  dynamic message;
  AppNoticeData data;

  AppNotice({this.status, this.message, this.data});

  AppNotice.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new AppNoticeData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return '{status: $status, message: $message, data: $data}';
  }
}

class AppNoticeData {
  dynamic appNoticeId;
  dynamic status;
  dynamic notice;

  AppNoticeData({this.appNoticeId, this.status, this.notice});

  AppNoticeData.fromJson(Map<String, dynamic> json) {
    appNoticeId = json['app_notice_id'];
    status = json['status'];
    notice = json['notice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['app_notice_id'] = this.appNoticeId;
    data['status'] = this.status;
    data['notice'] = this.notice;
    return data;
  }

  @override
  String toString() {
    return '{appNoticeId: $appNoticeId, status: $status, notice: $notice}';
  }
}