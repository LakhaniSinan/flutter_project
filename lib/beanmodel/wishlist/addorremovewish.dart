class AddRemoveWishList{

  dynamic status;
  dynamic message;
  dynamic wishlist_count;

  AddRemoveWishList(this.status, this.message, this.wishlist_count);

  factory AddRemoveWishList.fromJson(dynamic json){
    return AddRemoveWishList(json['status'], json['message'], json['wishlist_count']);
  }

  @override
  String toString() {
    return '{status: $status, message: $message, wishlist_count: $wishlist_count}';
  }
}