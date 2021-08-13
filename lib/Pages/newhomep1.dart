import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery/Components/constantfile.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/cart/addtocartbean.dart';
import 'package:grocery/beanmodel/cart/cartitembean.dart';
import 'package:grocery/beanmodel/coupon/storecoupon.dart';
import 'package:grocery/beanmodel/productbean/productwithvarient.dart';
import 'package:grocery/beanmodel/singleapibean.dart';
import 'package:grocery/beanmodel/tablist.dart';
import 'package:grocery/providergrocery/add2cartsnap.dart';
import 'package:grocery/providergrocery/benprovider/singleapiemittermodel.dart';
import 'package:grocery/providergrocery/benprovider/trndproviderbean.dart';
import 'package:grocery/providergrocery/bottomnavigationnavigator.dart';
import 'package:grocery/providergrocery/cartcountprovider.dart';
import 'package:grocery/providergrocery/cartlistprovider.dart';
import 'package:grocery/providergrocery/categoryprovider.dart';
import 'package:grocery/providergrocery/locemittermodel.dart';
import 'package:grocery/providergrocery/pagesnap.dart';
import 'package:grocery/providergrocery/singleapiemiter.dart';
import 'package:grocery/providergrocery/trndlistemitter.dart';
import 'package:http/http.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toast/toast.dart';

class NewHomeView1 extends StatefulWidget {
  LocEmitterModel locModel;
  List<CartItemData> cartItemd;

  NewHomeView1(this.locModel, this.cartItemd);

  @override
  State<StatefulWidget> createState() {
    return NewHomeView1State();
  }
}

class NewHomeView1State extends State<NewHomeView1> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var http = Client();
  bool isEnteredFirst = false;
  List<Tablist> tabList = [];
  List<TabsD> tabDataList = [];
  int selectTabt = 0;
  PageSnapReview pageSnap;
  String shownMessage = '--';

  String store_id = '';
  String storeName = '--';
  bool loci = false;
  bool progressadd = false;
  CartListProvider cartListPro;
  CartCountProvider cartCounterProvider;
  A2CartSnap a2cartSnap;
  SingleApiEmitter singleApiEmitter;
  TopRecentNewDealProvider trndProvider;
  BottomNavigationEmitter navBottomProvider;
  dynamic apCurrency = '-';
  CategoryProvider cateP;
  bool isCouponLoading = false;
  List<StoreCouponData> offers = [];

  @override
  void initState() {
    getapCurrency();
    super.initState();

  }

  void getapCurrency() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    apCurrency = preferences.getString('app_currency');
  }

  void getCouponList(String storeid) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      isCouponLoading = true;
    });
    var http = Client();
    http.post(storeCouponsUri, body: {
      'store_id': '$storeid',
      'cart_id': ''
    }, headers: {
      'Authorization': 'Bearer ${pref.getString('accesstoken')}'
    }).then((value) {
      print('vv - ${value.body}');
      if (value.statusCode == 200) {
        StoreCouponMain couponData =
            StoreCouponMain.fromJson(jsonDecode(value.body));
        if (couponData.status == '1' || couponData.status == 1) {
          setState(() {
            offers.clear();
            if (couponData.data.length > 5) {
              List<StoreCouponData> offersd = couponData.data.sublist(0, 5);
              offers = List.from(offersd);
            } else {
              offers = List.from(couponData.data);
            }
          });
        }
      }
      setState(() {
        isCouponLoading = false;
      });
    }).catchError((e) {
      print(e);
      setState(() {
        isCouponLoading = false;
      });
    });
  }

  void _onRefresh() async {
    print('onrefresh');
    singleApiEmitter.hitSingleApiEmitter(
        '${widget.locModel.storeFinderData.store_id}', _refreshController);
    getCouponList('${widget.locModel.storeFinderData.store_id}');
  }

  void _onLoading() async {
    print('onloading');
  }

// void getStoreId() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   // setState(() {
  //   //   bannerLoading = true;
  //   // });
  //
  //   http.post(getNearestStoreUri, body: {
  //     'lat': '${widget.locModel.lat}',
  //     'lng': '${widget.locModel.lng}',
  //   }, headers: {
  //     // 'Content-Type': 'application/x-www-form-urlencoded',
  //     'Authorization': 'Bearer ${prefs.getString('accesstoken')}'
  //   }).then((value) {
  //     print('loc - ${value.body}');
  //     if (value.statusCode == 200) {
  //       StoreFinderBean data1 =
  //           StoreFinderBean.fromJson(jsonDecode(value.body));
  //       setState(() {
  //         shownMessage = '${data1.message}';
  //       });
  //       if ('${data1.status}' == '1') {
  //         setState(() {
  //           store_id = '${data1.data.store_id}';
  //           storeName = '${data1.data.store_name}';
  //           storeFinderData = data1.data;
  //           if (prefs.containsKey('storelist') &&
  //               prefs.getString('storelist').length > 0) {
  //             var storeListpf =
  //                 jsonDecode(prefs.getString('storelist')) as List;
  //             List<StoreFinderData> dataFinderL = [];
  //             dataFinderL = List.from(
  //                 storeListpf.map((e) => StoreFinderData.fromJson(e)).toList());
  //             int idd1 = dataFinderL.indexOf(data1.data);
  //             if (idd1 < 0) {
  //               dataFinderL.add(data1.data);
  //             }
  //             prefs.setString('storelist', dataFinderL.toString());
  //           } else {
  //             List<StoreFinderData> dataFinderLd = [];
  //             dataFinderLd.add(data1.data);
  //             prefs.setString('storelist', dataFinderLd.toString());
  //           }
  //           prefs.setString('store_id_last', '${storeFinderData.store_id}');
  //         });
  //       } else {
  //         Toast.show(data1.message, context,
  //             gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
  //       }
  //     }
  //     if (store_id != null && store_id.toString().length > 0) {
  //       setState(() {
  //         loci = true;
  //       });
  //       getSingleAPi();
  //       // hitAsyncList();
  //     } else {
  //       setState(() {
  //         loci = false;
  //         // bannerLoading = false;
  //         // topCatLoading = false;
  //         singleLoading = false;
  //       });
  //     }
  //   }).catchError((e) {
  //     print(e);
  //     if (store_id != null && store_id.toString().length > 0) {
  //       setState(() {
  //         loci = true;
  //       });
  //       getSingleAPi();
  //     } else {
  //       setState(() {
  //         loci = false;
  //         // bannerLoading = false;
  //         // topCatLoading = false;
  //         singleLoading = false;
  //       });
  //     }
  //   });
  // }
  //
  // void getSingleAPi() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     singleLoading = true;
  //   });
  //   var http = Client();
  //   http.post(oneApiUri, body: {'store_id': '$store_id'}, headers: {
  //     // 'Content-Type': 'application/x-www-form-urlencoded',
  //     'Authorization': 'Bearer ${prefs.getString('accesstoken')}'
  //   }).then((value) {
  //     if (value.statusCode == 200) {
  //       print('rt - ${value.body}');
  //       SingleApiHomePage data1 =
  //           SingleApiHomePage.fromJson(jsonDecode(value.body));
  //       if ('${data1.status}' == '1') {
  //         setState(() {
  //           // bannerList.clear();
  //           // bannerList = List.from(data1.banner);
  //           bannerB.emit(data1.banner);
  //           // topCategoryList.clear();
  //           // topCategoryList = List.from(data1.topCat);
  //           // if (topCategoryList != null && topCategoryList.length > 0) {
  //           //   topCategoryList.add(TopCategoryDataModel('', '', 'See all', '', '', '', ''));
  //           // }
  //           categoryP.emit(data1.topCat);
  //           tabList.clear();
  //           if (data1.tabs != null && data1.tabs.length > 0) {
  //             for (int i = 0; i < data1.tabs.length; i++) {
  //               tabList.add(Tablist('${data1.tabs[i].type}', i));
  //             }
  //           }
  //           if (tabList != null && tabList.length > 0) {
  //             selectTabt = tabList[0].identifier;
  //           }
  //           tabDataList.clear();
  //           tabDataList = List.from(data1.tabs);
  //         });
  //       }
  //     }
  //     setState(() {
  //       singleLoading = false;
  //     });
  //   }).catchError((e) {
  //     setState(() {
  //       singleLoading = false;
  //     });
  //     print(e);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    print('ty ty1 -> $isEnteredFirst');
    if (!isEnteredFirst) {
      isEnteredFirst = true;
      pageSnap = BlocProvider.of<PageSnapReview>(context);
      cartListPro = BlocProvider.of<CartListProvider>(context);
      cartCounterProvider = BlocProvider.of<CartCountProvider>(context);
      a2cartSnap = BlocProvider.of<A2CartSnap>(context);
      singleApiEmitter = BlocProvider.of<SingleApiEmitter>(context);
      trndProvider = BlocProvider.of<TopRecentNewDealProvider>(context);
      print('${widget.locModel.storeFinderData.store_id}');
      navBottomProvider = BlocProvider.of<BottomNavigationEmitter>(context);
      cateP = BlocProvider.of<CategoryProvider>(context);
      singleApiEmitter.hitSingleApiEmitter(
          '${widget.locModel.storeFinderData.store_id}', _refreshController);
      getCouponList('${widget.locModel.storeFinderData.store_id}');
      print('ty ty -> $isEnteredFirst');
    }

    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: false,
      header: WaterDropHeader(),
      footer: CustomFooter(builder: (context, mode) {
        return Text('');
      }),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: Container(
        color: Color(0xfff8f8f8),
        child: BlocBuilder<SingleApiEmitter, SingleApiEmitterBeanModel>(
          builder: (context, apiData) {
            print('d enter -> ${apiData.isSearching}');
            if (apiData.isSearching) {
              print('is enter');
              return buildSingleScreenView(context);
            } else {
              print(apiData.dataModel.toString());
              if (apiData != null && apiData.dataModel.status == '1') {
                tabList = [];
                if (apiData.dataModel.tabs != null &&
                    apiData.dataModel.tabs.length > 0) {
                  for (int i = 0; i < apiData.dataModel.tabs.length; i++) {
                    tabList
                        .add(Tablist('${apiData.dataModel.tabs[i].type}', i));
                  }
                  tabDataList = List.from(apiData.dataModel.tabs);
                  trndProvider.hitTopRecentNewDealPro(
                      tabDataList[selectTabt].data, selectTabt);
                }
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      (apiData.dataModel.banner != null &&
                              apiData.dataModel.banner.length > 0)
                          ? Container(
                              height: 100,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.centerRight,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: (){
                                      Navigator.pushNamed(
                                          context, PageRoutes.cat_product,
                                          arguments: {
                                            'title': apiData.dataModel.banner[index].title,
                                            'storeid': apiData.dataModel.banner[index].store_id,
                                            'cat_id': apiData.dataModel.banner[index].cat_id,
                                            'storedetail': widget.locModel.storeFinderData,
                                          });
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.40,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      height: 120,
                                      decoration: BoxDecoration(
                                          color: kWhiteColor,
                                          borderRadius: BorderRadius.circular(5)),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              '${apiData.dataModel.banner[index].banner_image}',
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
                                              Image.asset(
                                            'assets/icon.png',
                                            fit: BoxFit.fill,
                                          ),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                itemCount: apiData.dataModel.banner.length,
                              ),
                            )
                          : SizedBox.shrink(),
                      // Visibility(
                      //   visible: false,
                      //   child: Container(
                      //     height: 100,
                      //     margin: const EdgeInsets.symmetric(
                      //         vertical: 10, horizontal: 10),
                      //     decoration: BoxDecoration(
                      //         borderRadius: BorderRadius.circular(5),
                      //         color: kWhiteColor),
                      //     child: Row(
                      //       children: [
                      //         ClipRRect(
                      //           borderRadius: BorderRadius.only(
                      //               bottomLeft: Radius.circular(5),
                      //               topLeft: Radius.circular(5)),
                      //           child: Container(
                      //             width: 120,
                      //             height: 100,
                      //             child: Image.asset(
                      //               'assets/seller1.png',
                      //               fit: BoxFit.fill,
                      //             ),
                      //           ),
                      //         ),
                      //         Expanded(
                      //           child: Column(
                      //             crossAxisAlignment: CrossAxisAlignment.center,
                      //             mainAxisAlignment: MainAxisAlignment.center,
                      //             children: [
                      //               RichText(
                      //                   text: TextSpan(
                      //                       text: 'Truck\'s Current Location\n',
                      //                       style: TextStyle(
                      //                         color: kLightTextColor,
                      //                         fontSize: 14,
                      //                       ),
                      //                       children: [
                      //                     TextSpan(
                      //                         text: 'Lagpat Nagar, New Delhi',
                      //                         style: TextStyle(
                      //                             color: kMainTextColor,
                      //                             fontSize: 14))
                      //                   ])),
                      //               SizedBox(
                      //                 height: 5,
                      //               ),
                      //               Row(
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment.center,
                      //                 mainAxisAlignment: MainAxisAlignment.center,
                      //                 children: [
                      //                   Text('View Today\'s Schedule',
                      //                       style: TextStyle(
                      //                           color: kMainColor, fontSize: 14)),
                      //                   SizedBox(
                      //                     width: 5,
                      //                   ),
                      //                   Icon(
                      //                     Icons.arrow_forward_ios,
                      //                     size: 15,
                      //                     color: kMainColor,
                      //                   )
                      //                 ],
                      //               )
                      //             ],
                      //           ),
                      //         )
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      (tabList != null && tabList.length > 0)
                          ? BlocBuilder<TopRecentNewDealProvider,
                              TopRecentNewDataBean>(
                              builder: (context, showindex) {
                                selectTabt = showindex.index;
                                return (showindex != null &&
                                        showindex.data != null &&
                                        showindex.data.length > 0 &&
                                        showindex.index != -1)
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Container(
                                            height: 52,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: kWhiteColor),
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              shrinkWrap: true,
                                              itemCount: tabList.length,
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                  child: Container(
                                                    height: 52,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                    child: Stack(
                                                      children: [
                                                        Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                              '${tabList[index].tabString}',
                                                              style: TextStyle(
                                                                  color: (tabList[index]
                                                                              .identifier ==
                                                                          showindex
                                                                              .index)
                                                                      ? kMainColor
                                                                      : kMainTextColor,
                                                                  fontSize:
                                                                      14)),
                                                        ),
                                                        Align(
                                                          alignment: Alignment
                                                              .bottomCenter,
                                                          child: Divider(
                                                            thickness: 1.5,
                                                            height: 1.5,
                                                            color: (tabList[index]
                                                                        .identifier ==
                                                                    showindex
                                                                        .index)
                                                                ? kMainColor
                                                                : kWhiteColor,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    // setState(() {
                                                    //   // selectTabt = tabList[index].identifier;
                                                    // });
                                                    print(showindex.index);
                                                    print(tabList[index]
                                                        .identifier);
                                                    trndProvider
                                                        .hitTopRecentNewDealPro(
                                                            tabDataList[tabList[
                                                                        index]
                                                                    .identifier]
                                                                .data,
                                                            tabList[index]
                                                                .identifier);
                                                  },
                                                  behavior:
                                                      HitTestBehavior.opaque,
                                                );
                                              },
                                            ),
                                          ),
                                          BlocBuilder<A2CartSnap, AddtoCartB>(
                                              builder: (_, dVal) {
                                            return ListView.builder(
                                                itemCount:
                                                    showindex.data.length,
                                                shrinkWrap: true,
                                                primary: false,
                                                // physics: NeverScrollableScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  int qty = 0;
                                                  int selectedIndexd = 0;
                                                  if (widget.cartItemd !=
                                                          null &&
                                                      widget.cartItemd.length >
                                                          0) {
                                                    int indd = widget.cartItemd
                                                        .indexOf(CartItemData(
                                                            varient_id:
                                                                '${showindex.data[index].varientId}'));
                                                    if (indd >= 0) {
                                                      qty = widget
                                                          .cartItemd[indd].qty;
                                                    }
                                                  }

                                                  int iddV = showindex
                                                      .data[index].varients
                                                      .indexOf(ProductVarient(
                                                          varientId: showindex
                                                              .data[index]
                                                              .varientId));
                                                  if (iddV >= 0) {
                                                    selectedIndexd = iddV;
                                                  }
                                                  print(
                                                      'id = $selectedIndexd, ${showindex.data[index].varientId}');

                                                  return GestureDetector(
                                                    onTap: () {
                                                      // int idd = wishModel.indexOf(WishListDataModel('', '',
                                                      //     '${listModel.searchdata[index].varientId}', '', '', '', '', '', '', '', '', '', '','',''));
                                                      Navigator.pushNamed(
                                                          context,
                                                          PageRoutes.product,
                                                          arguments: {
                                                            'pdetails':
                                                                showindex.data[
                                                                    index],
                                                            'storedetails': widget
                                                                .locModel
                                                                .storeFinderData,
                                                            'isInWish': false,
                                                          });
                                                    },
                                                    behavior:
                                                        HitTestBehavior.opaque,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xffffffff),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5)),
                                                      margin: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 10,
                                                          vertical: 10),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            width: 120,
                                                            child: Stack(
                                                              fit: StackFit
                                                                  .passthrough,
                                                              children: [
                                                                Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          100,
                                                                      child: Image
                                                                          .network(
                                                                        '${showindex.data[index].productImage}',
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                      // Image.asset(
                                                                      //   'assets/ProductImages/Cauliflower.png',
                                                                      //   fit: BoxFit.cover,
                                                                      // ),
                                                                    )),
                                                                Visibility(
                                                                  visible:
                                                                      (int.parse('${showindex.data[index].stock}') >
                                                                              0)
                                                                          ? false
                                                                          : true,
                                                                  child:
                                                                      Positioned
                                                                          .fill(
                                                                    child:
                                                                        Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      decoration: BoxDecoration(
                                                                          color: kButtonBorderColor.withOpacity(
                                                                              0.5),
                                                                          borderRadius:
                                                                              BorderRadius.circular(5)),
                                                                      child:
                                                                          Container(
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                kWhiteColor,
                                                                            borderRadius:
                                                                                BorderRadius.circular(5)),
                                                                        padding: const EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                10,
                                                                            vertical:
                                                                                5),
                                                                        child:
                                                                            Text(
                                                                          locale.outstock,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                kMainTextColor,
                                                                            fontSize:
                                                                                11,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topRight,
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            5,
                                                                        vertical:
                                                                            5),
                                                                    child: Row(
                                                                      children: [
                                                                        ((((double.parse('${showindex.data[index].mrp}') - double.parse('${showindex.data[index].price}')) / double.parse('${showindex.data[index].mrp}')) * 100) >
                                                                                0)
                                                                            ? Container(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1.5),
                                                                                child: Text(
                                                                                  '${(((double.parse('${showindex.data[index].mrp}') - double.parse('${showindex.data[index].price}')) / double.parse('${showindex.data[index].mrp}')) * 100).toStringAsFixed(2)} %',
                                                                                  style: TextStyle(
                                                                                    color: kWhiteColor,
                                                                                    fontSize: 10,
                                                                                  ),
                                                                                ),
                                                                                decoration: BoxDecoration(color: kMainColor, borderRadius: BorderRadius.circular(3)),
                                                                              )
                                                                            : SizedBox.shrink(),
                                                                        Visibility(
                                                                          visible: ('${showindex.data[index].type}'!='Regular'),
                                                                          child: Container(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            padding: const EdgeInsets.symmetric(
                                                                                horizontal: 3,
                                                                                vertical: 1.5),
                                                                            margin:
                                                                                const EdgeInsets.only(left: 5),
                                                                            child:
                                                                                Text(
                                                                              locale.inseason,
                                                                              style:
                                                                                  TextStyle(
                                                                                color: kMainTextColor,
                                                                                fontSize: 10,
                                                                              ),
                                                                            ),
                                                                            decoration: BoxDecoration(
                                                                                color: kButtonBorderColor,
                                                                                borderRadius: BorderRadius.circular(3)),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal: 5,
                                                                  vertical: 5),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .stretch,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceEvenly,
                                                                children: [
                                                                  Text(
                                                                      '${showindex.data[index].productName}',
                                                                      maxLines:
                                                                          2,
                                                                      style: TextStyle(
                                                                          color:
                                                                              kMainTextColor,
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.w700)),
                                                                  SizedBox(
                                                                    height: 8,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                          child:
                                                                              Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.stretch,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                              locale.ptype,
                                                                              style: TextStyle(color: kLightTextColor, fontSize: 11)),
                                                                          Text(
                                                                              '${showindex.data[index].type}',
                                                                              style: TextStyle(color: kMainTextColor, fontSize: 13, fontWeight: FontWeight.w400)),
                                                                        ],
                                                                      )),
                                                                      Expanded(
                                                                          child:
                                                                              Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.stretch,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                              locale.pqty,
                                                                              style: TextStyle(color: kLightTextColor, fontSize: 11)),
                                                                          (showindex.data[index].varients != null && showindex.data[index].varients.length > 1)
                                                                              ? Container(
                                                                                  height: 20,
                                                                                  child: DropdownButton<ProductVarient>(
                                                                                    elevation: 0,
                                                                                    dropdownColor: kWhiteColor,
                                                                                    hint: Text('${showindex.data[index].quantity} ${showindex.data[index].unit}', overflow: TextOverflow.clip, maxLines: 1, textAlign: TextAlign.start, style: TextStyle(color: kMainTextColor, fontSize: 11)),
                                                                                    isExpanded: false,
                                                                                    icon: Icon(
                                                                                      Icons.keyboard_arrow_down,
                                                                                      size: 15,
                                                                                    ),
                                                                                    underline: Container(
                                                                                      height: 0.0,
                                                                                      color: kWhiteColor,
                                                                                    ),
                                                                                    items: showindex.data[index].varients.map((value) {
                                                                                      return DropdownMenuItem<ProductVarient>(
                                                                                        value: value,
                                                                                        child: Text('${value.quantity} ${value.unit}', textAlign: TextAlign.start, overflow: TextOverflow.clip, style: TextStyle(color: kLightTextColor, fontSize: 11)),
                                                                                      );
                                                                                    }).toList(),
                                                                                    onChanged: (value) {
                                                                                      int iddV = showindex.data[index].varients.indexOf(ProductVarient(varientId: value.varientId));
                                                                                      if (iddV >= 0) {
                                                                                        setState(() {
                                                                                          selectedIndexd = iddV;
                                                                                          showindex.data[index].varientId = value.varientId;
                                                                                          showindex.data[index].price = value.price;
                                                                                          showindex.data[index].mrp = value.mrp;
                                                                                          showindex.data[index].quantity = value.quantity;
                                                                                          showindex.data[index].unit = value.unit;
                                                                                          showindex.data[index].stock = value.stock;
                                                                                        });
                                                                                      }
                                                                                      // print(value);
                                                                                      // print(iddV);
                                                                                      // print(selectedIndexd);
                                                                                      // print(listModel.searchdata[index].varientId);
                                                                                      // print(listModel.searchdata[index].price);
                                                                                      // print(listModel.searchdata[index].mrp);
                                                                                      // print(listModel.searchdata[index].quantity);
                                                                                      // print(listModel.searchdata[index].unit);
                                                                                    },
                                                                                  ),
                                                                                )
                                                                              : Text('${showindex.data[index].quantity} ${showindex.data[index].unit}', overflow: TextOverflow.clip, maxLines: 1, textAlign: TextAlign.start, style: TextStyle(color: kMainTextColor, fontSize: 11)),
                                                                          // Row(
                                                                          //   children: [
                                                                          //     Text('${showindex.data[index].quantity} ${showindex.data[index].unit}',
                                                                          //         overflow: TextOverflow.ellipsis,
                                                                          //         style: TextStyle(
                                                                          //             color: kMainTextColor,
                                                                          //             fontSize: 13,
                                                                          //             fontWeight:
                                                                          //             FontWeight.w400)),
                                                                          //     SizedBox(
                                                                          //       width: 5,
                                                                          //     ),
                                                                          //     Icon(
                                                                          //       Icons.keyboard_arrow_down,
                                                                          //       size: 15,
                                                                          //     )
                                                                          //   ],
                                                                          // )
                                                                        ],
                                                                      )),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                          child:
                                                                              Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          Visibility(
                                                                            visible: ('${showindex.data[index].price}' == '${showindex.data[index].mrp}')
                                                                                ? false
                                                                                : true,
                                                                            child:
                                                                                Text('$apCurrency ${showindex.data[index].mrp}', style: TextStyle(color: kLightTextColor, fontSize: 14, decoration: TextDecoration.lineThrough)),
                                                                          ),
                                                                          Text(
                                                                              '$apCurrency ${showindex.data[index].price}',
                                                                              style: TextStyle(color: kMainColor, fontSize: 16, fontWeight: FontWeight.w400)),
                                                                        ],
                                                                      )),
                                                                      Expanded(
                                                                        child:
                                                                            Visibility(
                                                                          visible: (int.parse('${showindex.data[index].stock}') > 0)
                                                                              ? true
                                                                              : false,
                                                                          child:
                                                                              Stack(
                                                                            children: [
                                                                              Align(
                                                                                child: qty > 0
                                                                                    ? Container(
                                                                                        height: 33,
                                                                                        alignment: Alignment.center,
                                                                                        decoration: BoxDecoration(color: kMainColor.withOpacity(0.4), borderRadius: BorderRadius.circular(30)),
                                                                                        padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                                        child: Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                                          children: [
                                                                                            buildIconButton(Icons.remove, context, onpressed: () {
                                                                                              if (qty > 0 && dVal.status == false) {
                                                                                                a2cartSnap.hitSnap(int.parse('${showindex.data[index].productId}'), true);
                                                                                                addtocart2('${showindex.data[index].storeId}', '${showindex.data[index].varientId}', (qty - 1), '0', context, 0);
                                                                                              } else {
                                                                                                Toast.show(locale.pcurprogress, context, duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                                                                                              }
                                                                                            }),
                                                                                            SizedBox(
                                                                                              width: 8,
                                                                                            ),
                                                                                            (dVal.status == true && '${dVal.prodId}' == '${showindex.data[index].productId}')
                                                                                                ? SizedBox(
                                                                                                    height: 10,
                                                                                                    width: 10,
                                                                                                    child: CircularProgressIndicator(
                                                                                                      strokeWidth: 1,
                                                                                                    ),
                                                                                                  )
                                                                                                : Text('x$qty', style: Theme.of(context).textTheme.subtitle1),
                                                                                            SizedBox(
                                                                                              width: 8,
                                                                                            ),
                                                                                            buildIconButton(Icons.add, context, type: 1, onpressed: () {
                                                                                              if ((qty + 1) <= int.parse('${showindex.data[index].stock}') && dVal.status == false) {
                                                                                                a2cartSnap.hitSnap(int.parse('${showindex.data[index].productId}'), true);
                                                                                                addtocart2('${showindex.data[index].storeId}', '${showindex.data[index].varientId}', (qty + 1), '0', context, 0);
                                                                                              } else {
                                                                                                if (dVal.status == false) {
                                                                                                  Toast.show(locale.outstock2, context, duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                                                                                                } else {
                                                                                                  Toast.show(locale.pcurprogress, context, duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                                                                                                }
                                                                                              }
                                                                                            }),
                                                                                          ],
                                                                                        ),
                                                                                      )
                                                                                    : (dVal.status == true && '${dVal.prodId}' == '${showindex.data[index].productId}')
                                                                                        ? SizedBox(
                                                                                            height: 10,
                                                                                            width: 10,
                                                                                            child: CircularProgressIndicator(
                                                                                              strokeWidth: 1,
                                                                                            ),
                                                                                          )
                                                                                        : MaterialButton(
                                                                                            onPressed: () {
                                                                                              if (int.parse('${showindex.data[index].stock}') > 0 && dVal.status == false) {
                                                                                                a2cartSnap.hitSnap(int.parse('${showindex.data[index].productId}'), true);
                                                                                                addtocart2('${showindex.data[index].storeId}', '${showindex.data[index].varientId}', (qty + 1), '0', context, 0);
                                                                                              } else {
                                                                                                if (dVal.status == false) {
                                                                                                  Toast.show(locale.outstock2, context, duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                                                                                                } else {
                                                                                                  Toast.show(locale.pcurprogress, context, duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                                                                                                }
                                                                                              }
                                                                                            },
                                                                                            splashColor: kMainColor,
                                                                                            color: kMainColor.withOpacity(0.4),
                                                                                            child: Row(
                                                                                              children: [
                                                                                                Expanded(
                                                                                                    child: Text(
                                                                                                  'ADD',
                                                                                                  textAlign: TextAlign.center,
                                                                                                  style: TextStyle(color: kMainColor, fontSize: 15, fontWeight: FontWeight.w600),
                                                                                                )),
                                                                                                Icon(Icons.add_sharp, size: 15, color: kMainColor)
                                                                                              ],
                                                                                            ),
                                                                                            elevation: 0,
                                                                                            height: 33,
                                                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                                                                          ),
                                                                                alignment: Alignment.bottomCenter,
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                });
                                          }),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 10),
                                            child: MaterialButton(
                                              onPressed: () {
                                                int typed;
                                                if ('${tabDataList[selectTabt].type}'
                                                        .toUpperCase() ==
                                                    'RECENT SELLING') {
                                                  typed = 1;
                                                } else if ('${tabDataList[selectTabt].type}'
                                                        .toUpperCase() ==
                                                    'TOP SELLING') {
                                                  typed = 0;
                                                } else if ('${tabDataList[selectTabt].type}'
                                                        .toUpperCase() ==
                                                    'WHATS NEW') {
                                                  typed = 2;
                                                } else if ('${tabDataList[selectTabt].type}'
                                                        .toUpperCase() ==
                                                    'DEAL PRODUCTS') {
                                                  typed = 3;
                                                }
                                                Navigator.pushNamed(
                                                    context, PageRoutes.viewall,
                                                    arguments: {
                                                      'title': tabDataList[
                                                              selectTabt]
                                                          .type,
                                                      'type': typed,
                                                      'storedetail': widget
                                                          .locModel
                                                          .storeFinderData,
                                                    });
                                              },
                                              splashColor: kMainColor,
                                              color: kMainColor,
                                              child: Text(
                                                'View All Popular Products',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: kWhiteColor,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              elevation: 0,
                                              height: 45,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30)),
                                            ),
                                          ),
                                        ],
                                      )
                                    : SizedBox.shrink();
                              },
                              buildWhen: (pre, current) {
                                return pre != current;
                              },
                            )
                          : SizedBox.shrink(),
                      SizedBox(
                        height: 10,
                      ),
                      (offers != null && offers.length > 0)
                          ? Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: kWhiteColor),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'OFFER ZONE',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: kMainTextColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w300),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (widget.locModel.storeFinderData !=
                                              null) {
                                            Navigator.pushNamed(
                                                context, PageRoutes.offerpage,
                                                arguments: {
                                                  'store_id':
                                                      '${widget.locModel.storeFinderData.store_id}',
                                                  'cart_id': '--'
                                                });
                                          }
                                        },
                                        behavior: HitTestBehavior.opaque,
                                        child: Text(
                                          'View All',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: kMainColor,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Divider(
                                    thickness: 1.5,
                                    height: 1.5,
                                    color: kButtonBorderColor.withOpacity(0.5),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  CarouselSlider(
                                    options: CarouselOptions(
                                        height: 150.0,
                                        viewportFraction: 0.90,
                                        onPageChanged: (index, reason) {
                                          // setState(() {
                                          //   pageIndex = index;
                                          pageSnap.emit(index);
                                          // });
                                          // print(index);
                                        },
                                        autoPlay: true),
                                    items: offers.map((i) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            // padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: kMainColor,
                                              image: DecorationImage(
                                                image: AssetImage('assets/offerback.png'),
                                                fit: BoxFit.fill
                                              )
                                            ),
                                            child: Stack(
                                              children: [
                                                Align(
                                                  alignment: Alignment.topCenter,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(i.coupon_description,
                                                        style: TextStyle(
                                                            color: kMainTextColor,
                                                            letterSpacing: 1.3,
                                                            wordSpacing: 1.0,
                                                            fontSize: 13)),
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.center,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Text(
                                                        '${i.coupon_code}',
                                                        style: TextStyle(
                                                            color: kMainTextColor,
                                                            letterSpacing: 2.5,
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: 25)),
                                                  ),
                                                ),
                                                Positioned(
                                                  right: 5,
                                                  bottom: 10,
                                                  child: Container(
                                                    padding:
                                                      const EdgeInsets.all(
                                                      8.0),
                                                    decoration: BoxDecoration(
                                                      color: kMainColor.withOpacity(0.3),
                                                      borderRadius: BorderRadius.only(
                                                        topLeft: Radius.circular(20),
                                                        bottomLeft: Radius.circular(20),
                                                      )
                                                    ),
                                                    child: Text(
                                                        'Min Pur. - $apCurrency ${i.cart_value}',
                                                        style: TextStyle(
                                                            color:
                                                            kMainTextColor,
                                                            letterSpacing:
                                                            0.3,
                                                            fontSize: 16)),
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: BlocBuilder<PageSnapReview, int>(
                                        builder: (context, pageI) {
                                      return Container(
                                        height: 20,
                                        alignment: Alignment.center,
                                        child: ListView.separated(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: offers.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Card(
                                                // type: MaterialType.circle,
                                                color: (pageI == index)
                                                    ? kMainColor
                                                    : kCardBackgroundColor,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Container(
                                                  height: (pageI == index)
                                                      ? 15
                                                      : 10,
                                                  width: (pageI == index)
                                                      ? 15
                                                      : 10,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: (pageI == index)
                                                        ? kMainColor
                                                        : kCardBackgroundColor,
                                                    // borderRadius: BorderRadius.circular(10)
                                                    // shape: BoxShape.circle,
                                                    // border: Border.all(color: (index==pageIndex)?kMainColor:kLightTextColor)
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          separatorBuilder: (context, index) {
                                            return SizedBox(
                                              width: 5,
                                            );
                                          },
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox.shrink(),
                      SizedBox(
                        height: 10,
                      ),
                      (apiData.dataModel.topCat != null &&
                              apiData.dataModel.topCat.length > 0)
                          ? Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: kWhiteColor),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'TOP CATEGORIES',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: kMainTextColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w300),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          navBottomProvider.hitBottomNavigation(
                                              1,
                                              'Category',
                                              'what are you looking for (e.g. mango, onion)');
                                          if (widget.locModel.storeFinderData !=
                                              null) {
                                            if (!cateP.state.isSearching) {
                                              cateP.hitBannerDetails(
                                                  '${widget.locModel.storeFinderData.store_id}',
                                                  widget.locModel
                                                      .storeFinderData);
                                            } else {
                                              Toast.show(
                                                  'currently in progress',
                                                  context,
                                                  duration: Toast.LENGTH_SHORT,
                                                  gravity: Toast.CENTER);
                                            }
                                          }
                                        },
                                        behavior: HitTestBehavior.opaque,
                                        child: Text(
                                          'View All',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: kMainColor,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Divider(
                                    thickness: 1.5,
                                    height: 1.5,
                                    color: kButtonBorderColor.withOpacity(0.5),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        mainAxisSpacing: 10,
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 20,
                                        childAspectRatio: 0.65,
                                      ),
                                      itemCount:
                                          apiData.dataModel.topCat.length,
                                      shrinkWrap: true,
                                      primary: false,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, PageRoutes.cat_product,
                                                arguments: {
                                                  'title': apiData.dataModel
                                                      .topCat[index].title,
                                                  'storeid': apiData.dataModel
                                                      .topCat[index].store_id,
                                                  'cat_id': apiData.dataModel
                                                      .topCat[index].cat_id,
                                                  'storedetail': widget
                                                      .locModel.storeFinderData,
                                                });
                                          },
                                          behavior: HitTestBehavior.opaque,
                                          child: Column(
                                            children: [
                                              Container(
                                                height: 100,
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    color: kWhiteColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        '${apiData.dataModel.topCat[index].image}',
                                                    placeholder:
                                                        (context, url) => Align(
                                                      widthFactor: 50,
                                                      heightFactor: 50,
                                                      alignment:
                                                          Alignment.center,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5.0),
                                                        width: 50,
                                                        height: 50,
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                    ),
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        Image.asset(
                                                            'assets/icon.png'),
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                                //   child:Image.asset('assets/icon.png'),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                '${apiData.dataModel.topCat[index].title}',
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                              )
                                            ],
                                          ),
                                        );
                                      }),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            )
                          : SizedBox.shrink(),
                      // BlocBuilder<CategoryProvider, List<TopCategoryDataModel>>(
                      //     builder: (context, listModel) {
                      //       if (listModel != null && listModel.length > 0) {
                      //         return Container(
                      //           margin: const EdgeInsets.symmetric(vertical: 10),
                      //           padding: const EdgeInsets.symmetric(
                      //               horizontal: 10, vertical: 10),
                      //           decoration: BoxDecoration(
                      //               borderRadius: BorderRadius.circular(5),
                      //               color: kWhiteColor),
                      //           child: Column(
                      //             crossAxisAlignment: CrossAxisAlignment.stretch,
                      //             children: [
                      //               Row(
                      //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //                 children: [
                      //                   Text(
                      //                     'TOP CATEGORIES',
                      //                     textAlign: TextAlign.center,
                      //                     style: TextStyle(
                      //                         color: kMainTextColor,
                      //                         fontSize: 13,
                      //                         fontWeight: FontWeight.w300),
                      //                   ),
                      //                   Text(
                      //                     'View All',
                      //                     textAlign: TextAlign.center,
                      //                     style: TextStyle(
                      //                         color: kMainColor,
                      //                         fontSize: 13,
                      //                         fontWeight: FontWeight.w300),
                      //                   )
                      //                 ],
                      //               ),
                      //               SizedBox(
                      //                 height: 8,
                      //               ),
                      //               Divider(
                      //                 thickness: 1.5,
                      //                 height: 1.5,
                      //                 color: kButtonBorderColor.withOpacity(0.5),
                      //               ),
                      //               SizedBox(
                      //                 height: 8,
                      //               ),
                      //               GridView.builder(
                      //                   gridDelegate:
                      //                   SliverGridDelegateWithFixedCrossAxisCount(
                      //                     mainAxisSpacing: 10,
                      //                     crossAxisCount: 3,
                      //                     crossAxisSpacing: 20,
                      //                     childAspectRatio: 0.65,
                      //                   ),
                      //                   itemCount: listModel.length,
                      //                   shrinkWrap: true,
                      //                   primary: false,
                      //                   physics: NeverScrollableScrollPhysics(),
                      //                   itemBuilder: (context, index) {
                      //                     return GestureDetector(
                      //                       onTap: () {},
                      //                       behavior: HitTestBehavior.opaque,
                      //                       child: Column(
                      //                         children: [
                      //                           Container(
                      //                             height: 100,
                      //                             padding: EdgeInsets.all(5),
                      //                             decoration: BoxDecoration(
                      //                                 color: kWhiteColor,
                      //                                 borderRadius:
                      //                                 BorderRadius.circular(10)),
                      //                             child: ClipRRect(
                      //                               borderRadius: BorderRadius.circular(10),
                      //                               child: CachedNetworkImage(
                      //                                 imageUrl: '${listModel[index].image}',
                      //                                 placeholder: (context, url) => Align(
                      //                                   widthFactor: 50,
                      //                                   heightFactor: 50,
                      //                                   alignment: Alignment.center,
                      //                                   child: Container(
                      //                                     padding:
                      //                                     const EdgeInsets.all(5.0),
                      //                                     width: 50,
                      //                                     height: 50,
                      //                                     child:
                      //                                     CircularProgressIndicator(),
                      //                                   ),
                      //                                 ),
                      //                                 errorWidget: (context, url, error) =>
                      //                                     Image.asset('assets/icon.png'),
                      //                                 fit: BoxFit.fill,
                      //                               ),
                      //                             ),
                      //                           ),
                      //                           SizedBox(
                      //                             height: 10,
                      //                           ),
                      //                           Text(
                      //                             '${listModel[index].title}',
                      //                             textAlign: TextAlign.center,
                      //                             maxLines: 1,
                      //                           )
                      //                         ],
                      //                       ),
                      //                     );
                      //                   }),
                      //               SizedBox(
                      //                 height: 10,
                      //               ),
                      //             ],
                      //           ),
                      //         );
                      //       }
                      //       else {
                      //         return SizedBox.shrink();
                      //       }
                      //     }),
                    ],
                  ),
                );
              } else {
                return Container(
                  alignment: Alignment.center,
                  child: Text((apiData.dataModel != null &&
                          apiData.dataModel.message != null)
                      ? apiData.dataModel.message
                      : 'No item found at your location we are comming soon in your area.',textAlign: TextAlign.center,),
                );
              }
            }
          },
          buildWhen: (pre, current) {
            return pre != current;
          },
        ),
      ),
    );
  }

  Widget buildIconButton(IconData icon, BuildContext context,
      {Function onpressed, int type}) {
    return GestureDetector(
      onTap: () {
        onpressed();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 25,
        height: 25,
        alignment: Alignment.center,
        // decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(20),
        //     border: Border.all(color: type==1?kMainColor:kRedColor, width: 0)),
        child: Icon(
          icon,
          color: type == 1 ? kMainColor : kRedColor,
          size: 16,
        ),
      ),
    );
  }

  //
  // Future<List<TopCategoryDataModel>> getCategoryFuture() async {
  //   return await _memoizer.runOnce(() async {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     Response bodyRes = await http.post(topCatUri, body: {
  //       'store_id': '$store_id'
  //     }, headers: {
  //       // 'Content-Type': 'application/x-www-form-urlencoded',
  //       'Authorization': 'Bearer ${prefs.getString('accesstoken')}'
  //     });
  //     TopCategoryModel cateData =
  //         TopCategoryModel.fromJson(jsonDecode(bodyRes.body));
  //     print('io  - - > ${cateData.data}');
  //     return cateData.data;
  //   });
  // }
  //
  // Future<List<BannerDataModel>> getBannerFuture() async {
  //   return await _memoizer2.runOnce(() async {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     Response bodyRes = await http.post(storeBannerUri, body: {
  //       'store_id': '$store_id'
  //     }, headers: {
  //       // 'Content-Type': 'application/x-www-form-urlencoded',
  //       'Authorization': 'Bearer ${prefs.getString('accesstoken')}'
  //     });
  //     BannerModel cateData = BannerModel.fromJson(jsonDecode(bodyRes.body));
  //     print('io  - - > ${cateData.data}');
  //     return cateData.data;
  //   });
  //
  //   // return await _memoizer.runOnce(() async {
  //   //
  //   // });
  // }

  void addtocart2(String storeid, String varientid, dynamic qnty,
      String special, BuildContext context, int index) async {
    var locale = AppLocalizations.of(context);
    // setState(() {
    //   progressadd = true;
    // });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey('islogin') && preferences.getBool('islogin')) {
      if (preferences.getString('block') == '1') {
        a2cartSnap.hitSnap(-1, false);
        // setState(() {
        //   progressadd = false;
        // });
        Toast.show(
            locale.blockmsg,
            context,
            gravity: Toast.CENTER,
            duration: Toast.LENGTH_SHORT);
      } else {
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
          a2cartSnap.hitSnap(-1, false);
          if (value.statusCode == 200) {
            AddToCartMainModel data1 =
                AddToCartMainModel.fromJson(jsonDecode(value.body));
            if ('${data1.status}' == '1') {
              cartListPro.emitCartList(data1.cart_items,data1.total_price);
              cartCounterProvider.hitCartCounter(data1.cart_items.length);
            } else {
              cartListPro.emitCartList([],0.0);
              // _counter = 0;
              cartCounterProvider.hitCartCounter(0);
            }
            Toast.show(data1.message, context,
                gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
          }
          // setState(() {
          //   progressadd = false;
          // });
        }).catchError((e) {
          a2cartSnap.hitSnap(-1, false);
          // setState(() {
          //   progressadd = false;
          // });
          print(e);
        });
      }
    } else {
      a2cartSnap.hitSnap(-1, false);
      // setState(() {
      //   progressadd = false;
      // });
      Toast.show(locale.loginfirst, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
    }
  }
}
