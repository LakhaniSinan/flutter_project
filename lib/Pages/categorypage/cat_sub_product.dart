import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:grocery/beanmodel/category/categorymodel.dart';
import 'package:grocery/beanmodel/category/topcategory.dart';
import 'package:grocery/beanmodel/productbean/productwithvarient.dart';
import 'package:grocery/beanmodel/storefinder/storefinderbean.dart';
import 'package:grocery/beanmodel/wishlist/wishdata.dart';
import 'package:grocery/providergrocery/cartcountprovider.dart';
import 'package:grocery/providergrocery/cartlistprovider.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toast/toast.dart';

class CategorySubProduct extends StatefulWidget {
  CategorySubProduct();

  @override
  _CategorySubProductState createState() => _CategorySubProductState();
}

class _CategorySubProductState extends State<CategorySubProduct> {
  CategoryDataModel dataModel;
  List<ProductDataModel> products = [];
  dynamic title;
  dynamic store_id;
  bool enterFirst = false;
  bool isLoading = false;
  StoreFinderData storedetail;
  List<WishListDataModel> wishModel = [];
  dynamic apCurrency;

  List<CartItemData> cartItemd = [];
  int _counter = 0;
  int selectedIndi = 0;
  bool progressadd = false;

  CartCountProvider cartCounterProvider;
  CartListProvider cartListPro;

  @override
  void initState() {
    super.initState();
    cartCounterProvider = BlocProvider.of<CartCountProvider>(context);
    cartListPro = BlocProvider.of<CartListProvider>(context);
    getSharedValue();
  }

  // void hitAppInfo() async{
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var http = Client();
  //   http.post(appInfoUri,body: {
  //     'user_id':'${(prefs.containsKey('user_id'))?prefs.getInt('user_id'):''}'
  //   }).then((value) {
  //     print(value.body);
  //     if (value.statusCode == 200) {
  //       AppInfoModel data1 = AppInfoModel.fromJson(jsonDecode(value.body));
  //       print('data - ${data1.toString()}');
  //       if (data1.status == "1" || data1.status == 1) {
  //         setState(() {
  //           apCurrency = '${data1.currencySign}';
  //           _counter = int.parse('${data1.totalItems}');
  //         });
  //         prefs.setString('app_currency', '${data1.currencySign}');
  //         prefs.setString('app_referaltext', '${data1.refertext}');
  //         prefs.setString('app_name', '${data1.appName}');
  //         prefs.setString('country_code', '${data1.countryCode}');
  //         prefs.setString('numberlimit', '${data1.phoneNumberLength}');
  //         prefs.setInt('last_loc', int.parse('${data1.lastLoc}'));
  //       }
  //     }
  //   }).catchError((e) {
  //     print(e);
  //   });
  // }

  void getSharedValue() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      apCurrency = pref.getString('app_currency');
    });
  }

  void getWislist(dynamic storeid) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic userId = prefs.getInt('user_id');
    var url = showWishlistUri;
    var http = Client();
    http.post(url, body: {
      'user_id': '${userId}',
      'store_id':'${storeid}'
    }, headers: {
      'Authorization': 'Bearer ${prefs.getString('accesstoken')}'
    }).then((value){
      print('resp - ${value.body}');
      if(value.statusCode == 200){
        WishListModel data1 = WishListModel.fromJson(jsonDecode(value.body));
        if(data1.status=="1" || data1.status==1){
          setState(() {
            wishModel.clear();
            wishModel = List.from(data1.data);
          });
        }
      }
    }).catchError((e){
    });
  }

  void getCategory(dynamic catid, dynamic storeid) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    var http = Client();
    http.post(catProductUri,body: {
      'cat_id':'${catid}',
      'store_id':'${storeid}'
    }, headers: {
      'Authorization': 'Bearer ${pref.getString('accesstoken')}'
    }).then((value){
      print('${value.body}');
      if(value.statusCode == 200){
        ProductModel data1 = ProductModel.fromJson(jsonDecode(value.body));
        if(data1.status=="1" || data1.status==1){
          setState(() {
            products.clear();
            products = List.from(data1.data);
          });
        }
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((e){
      print(e);
      setState(() {
        isLoading = false;
      });
    });
  }

  // void getCartList() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   setState(() {
  //     apCurrency = preferences.getString('app_currency');
  //   });
  //   var http = Client();
  //   http.post(showCartUri,
  //       body: {'user_id': '${preferences.getInt('user_id')}'}).then((value) {
  //     print('cart - ${value.body}');
  //     if (value.statusCode == 200) {
  //       CartItemMainBean data1 =
  //       CartItemMainBean.fromJson(jsonDecode(value.body));
  //       if ('${data1.status}' == '1') {
  //         cartItemd.clear();
  //         cartItemd = List.from(data1.data);
  //         _counter = cartItemd.length;
  //       } else {
  //         setState(() {
  //           cartItemd.clear();
  //           _counter = 0;
  //         });
  //       }
  //     }
  //   }).catchError((e) {
  //     print(e);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    Map<String,dynamic> receivedData = ModalRoute.of(context).settings.arguments;
    setState(() {
      title = receivedData['title'];
      if(!enterFirst){
        enterFirst = true;
        isLoading = true;
        storedetail = receivedData['storedetail'];
        dataModel = receivedData['categories'];
        store_id = storedetail.store_id;
        getWislist(store_id);
        getCategory(dataModel.subcategory[0].cat_id, store_id);
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(color: kMainTextColor),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<CartCountProvider, int>(
              builder: (context,cartCount){
                return Badge(
                  position: BadgePosition.topEnd(top: 5, end: 5),
                  padding: EdgeInsets.all(5),
                  animationDuration: Duration(milliseconds: 300),
                  animationType: BadgeAnimationType.slide,
                  badgeContent: Text(
                    cartCount.toString(),
                    style: TextStyle(color: Colors.white,fontSize: 10),
                  ),
                  child: IconButton(
                      onPressed: () async {
                        SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                        if (prefs.containsKey('islogin') &&
                            prefs.getBool('islogin')) {

                          Navigator.pushNamed(context, PageRoutes.cartPage).then((value) {
                            print('value d');
                            // getCartList();
                          }).catchError((e) {
                            print('dd');
                            // getCartList();
                          });
                          // Navigator.pushNamed(context, PageRoutes.cart)

                        } else {
                          Toast.show(locale.loginfirst, context,
                              gravity: Toast.CENTER,
                              duration: Toast.LENGTH_SHORT);
                        }
                      },
                      icon: ImageIcon(AssetImage('assets/ic_cart.png'))),
                );
              }),
        ],
      ),
      body: BlocBuilder<CartListProvider,List<CartItemData>>(
        builder: (context,cartList){
          cartItemd = List.from(cartList);
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
                child: Text(
                  locale.chooseCategory,
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6
                      .copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
              ),
              SizedBox(height: 6),
              Container(
                height: 52,
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: dataModel.subcategory.length,
                    itemBuilder: (context, index) {
                      return buildCategoryRow(
                          context, dataModel.subcategory[index], storedetail,(id){
                        setState(() {
                          isLoading = true;
                          selectedIndi = index;
                        });
                        getCategory(id, storedetail.store_id);
                      },index);
                    }),
              ),
              Expanded(
                child: SingleChildScrollView(
                  primary: true,
                  physics: ScrollPhysics(),
                  child: (isLoading)?buildGridShView():buildGridView(products,wishModel,'$apCurrency',storedetail, locale,callback: (){
                    getWislist(storedetail.store_id);
                  }),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  GestureDetector buildCategoryRow(BuildContext context,
      SuBCategoryModel categories, StoreFinderData storeFinderData, void callback(value), int indd) {
    return GestureDetector(
      onTap: () {
        callback(categories.cat_id);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          elevation: 0.4,
          color: (selectedIndi==indd)?kMainColor:kWhiteColor,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: (selectedIndi==indd)?kMainColor:kWhiteColor,
                // image: DecorationImage(
                //     image: NetworkImage(categories.image), fit: BoxFit.fill)
            ),
            child: Text(
              categories.title,
              style: TextStyle(color: (selectedIndi==indd)?kWhiteColor:kMainTextColor, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  GridView buildGridView(List<ProductDataModel> listName, List<WishListDataModel> wishModel,String apCurrency,StoreFinderData storedetail, AppLocalizations locale,{bool favourites = false, Function callback}) {
    return GridView.builder(
        padding: EdgeInsets.only(top: 5,bottom: 10, right: 10, left: 10),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        primary: false,
        itemCount: listName.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 16,
            mainAxisSpacing: 5
        ),
        itemBuilder: (context, index) {
          return buildProductCard(
              context,
              listName[index],
              wishModel,
              '$apCurrency',
              storedetail,
              locale,
              favourites: favourites,
              callback: callback);
        });
  }

  Widget buildProductCard(
      BuildContext context,ProductDataModel product,
      List<WishListDataModel> wishModel,String apCurrency,StoreFinderData storedetail, AppLocalizations locale,
      {bool favourites = false, Function callback}) {
    int qty = 0;
    if (cartItemd != null && cartItemd.length > 0) {
      int ind1 = cartItemd.indexOf(CartItemData(varient_id:'${product.varientId}'));
      if (ind1 >= 0) {
        qty = cartItemd[ind1].qty;
      }
    }
    return GestureDetector(
      onTap: () {
        int idd = wishModel.indexOf(WishListDataModel('', '',
            '${product.varientId}', '', '', '', '', '', '', '', '', '', '','','',''));
        product.qty = qty;
        Navigator.pushNamed(context, PageRoutes.product, arguments: {
          'pdetails': product,
          'storedetails': storedetail,
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
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10)
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stack(
                    //   children: [
                    //
                    //   ],
                    // ),
                    Container(
                      width: MediaQuery.of(context).size.width/2.5,
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
                              imageUrl: '${product.productImage}',
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
                    Expanded(
                        child: Column(
                          children: [
                            Align(alignment: Alignment.centerLeft,
                              child: Text(product.productName,
                                  maxLines: 1, style: TextStyle(fontWeight: FontWeight.w500)),),
                            SizedBox(height: 4),
                            Container(
                              width: MediaQuery.of(context).size.width / 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('$apCurrency ${product.price}',
                                      style:
                                      TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                  Visibility(
                                    visible:
                                    ('${product.price}' == '${product.mrp}') ? false : true,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text('$apCurrency ${product.mrp}',
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w300,
                                              fontSize: 13,
                                              decoration: TextDecoration.lineThrough)),
                                    ),
                                  ),
                                  // buildRating(context),
                                ],
                              ),
                            ),
                          ],
                        )),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('${product.quantity} ${product.unit}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ),
                    SizedBox(height: 5),
                    (int.parse('${product.stock}') > 0)
                        ? Container(
                      width: MediaQuery.of(context).size.width / 2,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildIconButton(Icons.remove, context,
                              onpressed: () {
                                if (qty > 0 && !progressadd) {
                                  int idd = products.indexOf(product);
                                  addtocart2(
                                      '${product.storeId}',
                                      '${product.varientId}',
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
                              style: Theme.of(context).textTheme.subtitle1),
                          SizedBox(
                            width: 8,
                          ),
                          buildIconButton(Icons.add, context,
                              type: 1,
                              onpressed: () {
                                if ((qty + 1) <=
                                    int.parse('${product.stock}') && !progressadd) {
                                  int idd = products.indexOf(product);
                                  addtocart2(
                                      '${product.storeId}',
                                      '${product.varientId}',
                                      (qty + 1),
                                      '0',
                                      context,
                                      idd);
                                } else {
                                  Toast.show(locale.outstock2, context,
                                      duration: Toast.LENGTH_SHORT,
                                      gravity: Toast.CENTER);
                                }
                              }),
                        ],
                      ),
                    )
                        :
                    Container(
                      height: 15,
                      width: MediaQuery.of(context).size.width / 2,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: kCardBackgroundColor,
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)),
                      ),
                      child: Text(
                        locale.outstock,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: TextStyle(fontSize: 13,color: kRedColor),
                      ),
                    ),
                    SizedBox(height: 5),
                  ],
                ),
                ((((double.parse('${product.mrp}') - double.parse('${product.price}'))/double.parse('${product.mrp}'))*100)>0)?Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: const EdgeInsets.all(3.0),
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: kPercentageBackC,
                      borderRadius: BorderRadius.only(topRight: Radius.circular(10),bottomRight: Radius.circular(10)),
                    ),
                    child: Text('${(((double.parse('${product.mrp}') - double.parse('${product.price}'))/double.parse('${product.mrp}'))*100).toStringAsFixed(2)} %',style: TextStyle(color:kWhiteColor,fontWeight: FontWeight.w500,fontSize: 12),),),
                ):SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void addtocart2(String storeid, String varientid, dynamic qnty, String special,
      BuildContext context, int index) async {
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


  void addtocart(String storeid, String varientid, dynamic qnty, String special,
      BuildContext context, int index) async {
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
              int dii = data1.cart_items.indexOf(CartItemData(varient_id: '$varientid'));
              print('cart add${dii} \n $storeid \n $varientid');
              setState(() {
                if (dii >= 0) {
                  products[index].qty = data1.cart_items[dii].qty;
                } else {
                  products[index].qty = 0;
                }
                _counter = data1.cart_items.length;
                cartCounterProvider.hitCartCounter(_counter);
              });
            } else {
              setState(() {
                products[index].qty = 0;
                _counter = 0;
              });
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


