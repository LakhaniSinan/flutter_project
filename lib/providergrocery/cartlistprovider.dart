import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/cart/cartitembean.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartListProvider extends Cubit<List<CartItemData>> {
  List<CartItemData> cartItemd = [];

  String cartprice = '--';

  CartListProvider() : super([]) {
    hitCartList();
  }

  List<CartItemData> getCartListPro(){
    return cartItemd;
  }

  void emitCartList(List<CartItemData> data,dynamic total_price){
    cartprice = '$total_price';
    cartItemd = List.from(data);
    emit(data);
  }

  void hitCartList() async {
    SharedPreferences.getInstance().then((preferences) {
      Client().post(showCartUri,
          body: {'user_id': '${preferences.getInt('user_id')}'}, headers: {
            'Authorization': 'Bearer ${preferences.getString('accesstoken')}'
          }).then((value) {
        print('cart - ${value.body}');
        if (value.statusCode == 200) {
          CartItemMainBean data1 =
              CartItemMainBean.fromJson(jsonDecode(value.body));
          cartprice = '${data1.total_price}';
          if ('${data1.status}' == '1') {
            cartItemd.clear();
            cartItemd = List.from(data1.data);
            emit(cartItemd);
          } else {
            emit([]);
          }
        }
      }).catchError((e) {
        print(e);
      });
    });
  }
}
