import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery/Components/constantfile.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/appinfo.dart';
import 'package:grocery/beanmodel/cart/addtocartbean.dart';
import 'package:grocery/beanmodel/cart/cartitembean.dart';
import 'package:grocery/beanmodel/productbean/productwithvarient.dart';
import 'package:grocery/beanmodel/storefinder/storefinderbean.dart';
import 'package:grocery/beanmodel/whatsnew/whatsnew.dart';
import 'package:grocery/beanmodel/wishlist/wishdata.dart';
import 'package:grocery/providergrocery/cartcountprovider.dart';
import 'package:grocery/providergrocery/cartlistprovider.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class SellerInfo extends StatefulWidget {

  @override
  _SellerInfoState createState() => _SellerInfoState();
}

class _SellerInfoState extends State<SellerInfo> {
  List<ProductDataModel> sellerProducts = [];
  List<WishListDataModel> wishModel = [];
  StoreFinderData storedetails;
  dynamic apCurrency;
  bool progressadd = false;
  bool enterFirst = false;
  List<CartItemData> cartItemd = [];
  int _counter = 0;
  CartCountProvider cartCounterProvider;
  CartListProvider cartListPro;

  @override
  void initState() {
    super.initState();
    cartCounterProvider = BlocProvider.of<CartCountProvider>(context);
    cartListPro = BlocProvider.of<CartListProvider>(context);
    // getCartList();
  }

  void getCartList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      apCurrency = preferences.getString('app_currency');
    });
    // var http = Client();
    // http.post(showCartUri,
    //     body: {'user_id': '${preferences.getInt('user_id')}'}).then((value) {
    //   print('cart - ${value.body}');
    //   if (value.statusCode == 200) {
    //     CartItemMainBean data1 =
    //         CartItemMainBean.fromJson(jsonDecode(value.body));
    //     if ('${data1.status}' == '1') {
    //       cartItemd.clear();
    //       cartItemd = List.from(data1.data);
    //       _counter = cartItemd.length;
    //     } else {
    //       setState(() {
    //         cartItemd.clear();
    //         _counter = 0;
    //       });
    //     }
    //   }
    // }).catchError((e) {
    //   print(e);
    // });
  }

  void getTopSellingList(dynamic storeid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apCurrency = prefs.getString('app_currency');
    });
    var http = Client();
    http.post(topSellingUri, body: {'store_id': '${storeid}'}, headers: {
      'Authorization': 'Bearer ${prefs.getString('accesstoken')}'
    }).then((value) {
      if (value.statusCode == 200) {
        WhatsNewModel data1 = WhatsNewModel.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            sellerProducts.clear();
            sellerProducts = List.from(data1.data);
          });
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    if(!enterFirst){
      Map<String,dynamic> receivedData = ModalRoute.of(context).settings.arguments;
      setState(() {
        enterFirst = true;
        progressadd = true;
        storedetails = receivedData['storedetail'];
        wishModel = receivedData['wishmodel'];
      });
      getCartList();
      getTopSellingList(storedetails.store_id);
    }


    return SafeArea(
      top: true,
      left: false,
      right: false,
      bottom: false,
      child: Scaffold(
        body: BlocBuilder<CartListProvider,List<CartItemData>>(
          builder: (context,cartList){
            cartItemd = List.from(cartList);
            return SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          image: new DecorationImage(
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.75), BlendMode.dstATop),
                            image: AssetImage('assets/seller1.png'),
                          ),
                        ),
                      ),
                      Positioned.directional(
                        textDirection: Directionality.of(context),
                        top: 20,
                        start: 10,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back_ios,
                            size: 24,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                      ),
                      Positioned.directional(
                        textDirection: Directionality.of(context),
                        top: 15,
                        end: 10,
                        child: BlocBuilder<CartCountProvider,int>(builder: (context,cartCount){
                          return Badge(
                            position: BadgePosition.topEnd(top: 5, end: 5),
                            padding: EdgeInsets.all(5),
                            animationDuration: Duration(milliseconds: 300),
                            animationType: BadgeAnimationType.slide,
                            badgeContent: Text(
                              cartCount.toString(),
                              style: TextStyle(color: Colors.white, fontSize: 10),
                            ),
                            child: IconButton(
                              icon: ImageIcon(AssetImage(
                                'assets/ic_cart.png',
                              ),color: kWhiteColor,),
                              onPressed: () async {
                                SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                                if (prefs.containsKey('islogin') &&
                                    prefs.getBool('islogin')) {
                                  Navigator.pushNamed(context, PageRoutes.cartPage);
                                } else {
                                  Toast.show(locale.loginfirst, context,
                                      gravity: Toast.CENTER,
                                      duration: Toast.LENGTH_SHORT);
                                }
                              },
                            ),
                          );
                        }),
                      ),
                      Positioned.directional(
                        bottom: 20,
                        start: 20,
                        textDirection: TextDirection.ltr,
                        child: Text('${storedetails.store_name}',
                            style: Theme.of(context).textTheme.bodyText1.copyWith(
                                fontSize: 24,
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: buildGridViewP(
                        sellerProducts, apCurrency, wishModel, storedetails,locale),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  GridView buildGridViewP(List<ProductDataModel> products, apCurrency,
      List<WishListDataModel> wishModel, StoreFinderData storeFinderData, AppLocalizations locale,
      {bool favourites = false}) {
    return GridView.builder(
        padding: EdgeInsets.symmetric(vertical: 20),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          return buildProductCard(
              context, products[index], apCurrency, wishModel, storeFinderData,locale);
        });
  }

  Widget buildProductCard(
    BuildContext context,
    ProductDataModel products,
    dynamic apCurrency,
    List<WishListDataModel> wishModel,
    StoreFinderData storeFinderData, AppLocalizations locale,
  ) {
    int qty = 0;
    if (cartItemd != null && cartItemd.length > 0) {
      // int ind1 = cartItemd.indexOf(CartItemData('', '', '', '', '',
      //     '${products.varientId}', '', '', '', '', '', '', '', ''));
      int ind1 = cartItemd.indexOf(CartItemData(varient_id:'${products.varientId}'));
      if (ind1 >= 0) {
        qty = cartItemd[ind1].qty;
      }
    }
    return GestureDetector(
      onTap: () {
        int idd = wishModel.indexOf(WishListDataModel(
            '',
            '',
            '${products.varientId}',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',''));
        products.qty=qty;
        Navigator.pushNamed(context, PageRoutes.product, arguments: {
          'pdetails': products,
          'storedetails': storeFinderData,
          'isInWish': (idd >= 0),
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Material(
          elevation: 1,
          color: kWhiteColor,
          borderRadius: BorderRadius.circular(10),
          clipBehavior: Clip.antiAlias,
          child: Container(
            width: MediaQuery.of(context).size.width / 2.5,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 2.5,
                      height: 100,
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 90,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Card(
                            elevation: 0.5,
                            color: kWhiteColor,
                            clipBehavior: Clip.hardEdge,
                            child: CachedNetworkImage(
                              width: 80,
                              imageUrl: '${products.productImage}',
                              placeholder: (context, url) => Align(
                                widthFactor: 50,
                                heightFactor: 50,
                                alignment: Alignment.center,
                                child: Container(
                                  padding: const EdgeInsets.all(5.0),
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  Image.asset('assets/icon.png'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(products.productName,
                              maxLines: 1,
                              style: TextStyle(fontWeight: FontWeight.w500)),
                        ),
                        SizedBox(height: 4),
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('$apCurrency ${products.price}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16)),
                              Visibility(
                                visible:
                                    ('${products.price}' == '${products.mrp}')
                                        ? false
                                        : true,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text('$apCurrency ${products.mrp}',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w300,
                                          fontSize: 13,
                                          decoration:
                                              TextDecoration.lineThrough)),
                                ),
                              ),
                              // buildRating(context),
                            ],
                          ),
                        ),
                      ],
                    )),
                    Align(alignment: Alignment.centerRight, child: Text('${products.quantity} ${products.unit}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),),
                    SizedBox(height: 5),
                    (int.parse('${products.stock}') > 0) ? Container(
                            width: MediaQuery.of(context).size.width / 2,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                buildIconButton(Icons.remove, context,
                                    onpressed: () {
                                  if (qty > 0 &&
                                      !progressadd) {
                                    int idd = sellerProducts.indexOf(products);
                                    addtocart2(
                                        '${products.storeId}',
                                        '${products.varientId}',
                                        (qty - 1),
                                        '0',
                                        context,
                                        idd);
                                  }
                                }),
                                SizedBox(
                                  width: 8,
                                ),
                                Text('$qty',
                                    style:
                                        Theme.of(context).textTheme.subtitle1),
                                SizedBox(
                                  width: 8,
                                ),
                                buildIconButton(Icons.add, context, type: 1,
                                    onpressed: () {
                                  if ((qty + 1) <=
                                          int.parse('${products.stock}') &&
                                      !progressadd) {
                                    int idd = sellerProducts.indexOf(products);
                                    addtocart2(
                                        '${products.storeId}',
                                        '${products.varientId}',
                                        (qty + 1),
                                        '0',
                                        context,
                                        idd);
                                  } else {
                                    Toast.show(locale.outstock2,
                                        context,
                                        duration: Toast.LENGTH_SHORT,
                                        gravity: Toast.CENTER);
                                  }
                                }),
                              ],
                            ),
                          ) : Container(
                            height: 15,
                            width: MediaQuery.of(context).size.width / 2,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: kCardBackgroundColor,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                            ),
                            child: Text(
                              'Out of stock',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: TextStyle(fontSize: 13, color: kRedColor),
                            ),
                          ),
                    SizedBox(height: 5),
                  ],
                ),
                ((((double.parse('${products.mrp}') -
                                    double.parse('${products.price}')) /
                                double.parse('${products.mrp}')) *
                            100) >
                        0)
                    ? Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: const EdgeInsets.all(3.0),
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: kPercentageBackC,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                          ),
                          child: Text(
                            '${(((double.parse('${products.mrp}') - double.parse('${products.price}')) / double.parse('${products.mrp}')) * 100).toStringAsFixed(2)} %',
                            style: TextStyle(
                                color: kWhiteColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 12),
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void addtocart2(String storeid, String varientid, dynamic qnty,
      String special, BuildContext context, int index) async {
    var locale = AppLocalizations.of(context);
    setState(() {
      progressadd = true;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey('islogin') && preferences.getBool('islogin')) {
      if(preferences.getString('block')=='1'){
        setState(() {
          progressadd = false;
        });
        Toast.show(locale.blockmsg, context,
            gravity: Toast.CENTER,
            duration: Toast.LENGTH_SHORT);
      }else{
        var http = Client();
        http.post(addToCartUri, body: {
          'user_id': '${preferences.getInt('user_id')}',
          'qty': '${int.parse('$qnty')}',
          'store_id': '${int.parse('$storeid')}',
          'varient_id': '${int.parse('$varientid')}',
          'special': '${special}',
        }, headers: {
          'Authorization': 'Bearer ${preferences.getString('accesstoken')}'
        }).then((value) {
          print('cart add${value.body}');
          if (value.statusCode == 200) {
            AddToCartMainModel data1 =
            AddToCartMainModel.fromJson(jsonDecode(value.body));
            if ('${data1.status}' == '1') {
              // int dii = data1.cart_items.indexOf(AddToCartItem(
              //   '',
              //   '',
              //   '',
              //   '',
              //   '',
              //   '$varientid',
              //   '',
              //   '',
              //   '',
              //   '',
              //   '',
              //   '',
              //   '',
              //   '',
              // ));
              // int dii = data1.cart_items.indexOf(CartItemData(varient_id: '$varientid'));
              // print('cart add${dii} \n $storeid \n $varientid');
              // setState(() {
              //   if (dii >= 0) {
              //     sellerProducts[index].qty = data1.cart_items[dii].qty;
              //   } else {
              //     sellerProducts[index].qty = 0;
              //   }
              //
              // });
              cartListPro.emitCartList(data1.cart_items,data1.total_price);
              _counter = data1.cart_items.length;
              cartCounterProvider.hitCartCounter(_counter);
            } else {
              cartListPro.emitCartList([],0.0);
              _counter = 0;
              cartCounterProvider.hitCartCounter(_counter);
            }
            Toast.show(data1.message, context,
                gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
          }
          setState(() {
            progressadd = false;
          });
        }).catchError((e) {
          setState(() {
            progressadd = false;
          });
          print(e);
        });
      }
    } else {
      setState(() {
        progressadd = false;
      });
      Toast.show(locale.loginfirst, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
    }

  }
}
