import 'package:flutter/material.dart';
import 'package:grocery/Auth/Login/lang_selection.dart';
import 'package:grocery/Auth/Login/sign_in.dart';
import 'package:grocery/Auth/Login/sign_up.dart';
import 'package:grocery/Auth/Login/verification.dart';
import 'package:grocery/Components/cardstripe.dart';
import 'package:grocery/Pages/About/about_us.dart';
import 'package:grocery/Pages/About/contact_us.dart';
import 'package:grocery/Pages/Checkout/ConfirmOrder.dart';
import 'package:grocery/Pages/Checkout/my_orders.dart';
import 'package:grocery/Pages/DrawerPages/invoicepage.dart';
import 'package:grocery/Pages/DrawerPages/my_orders_drawer.dart';
import 'package:grocery/Pages/Other/add_address.dart';
import 'package:grocery/Pages/Other/category_products.dart';
import 'package:grocery/Pages/Other/edit_address.dart';
import 'package:grocery/Pages/Other/offers.dart';
import 'package:grocery/Pages/Other/product_info.dart';
import 'package:grocery/Pages/Other/productbytags.dart';
import 'package:grocery/Pages/Other/reviews.dart';
import 'package:grocery/Pages/Other/seller_info.dart';
import 'package:grocery/Pages/Search/searchean.dart';
import 'package:grocery/Pages/User/my_account.dart';
import 'package:grocery/Pages/User/myaddres.dart';
import 'package:grocery/Pages/User/wishlist.dart';
import 'package:grocery/Pages/categorypage/cat_sub_product.dart';
import 'package:grocery/Pages/deliveryOptions.dart';
import 'package:grocery/Pages/newhomeview.dart';
import 'package:grocery/Pages/notificationactvity/notificaitonact.dart';
import 'package:grocery/Pages/order_details.dart';
import 'package:grocery/Pages/payment_option.dart';
import 'package:grocery/Pages/paymentwebviewmongo.dart';
import 'package:grocery/Pages/productpage.dart';
import 'package:grocery/Pages/reffernearn.dart';
import 'package:grocery/Pages/settingpage.dart';
import 'package:grocery/Pages/tncpage/tnc_page.dart';
import 'package:grocery/Pages/track_orders.dart';
import 'package:grocery/Pages/wallet/walletui.dart';
import 'package:grocery/Pages/your_basket.dart';
import 'package:grocery/forgotpassword/changepassword.dart';
import 'package:grocery/forgotpassword/otpverifity.dart';
import 'package:grocery/forgotpassword/resetpasswordNumber.dart';

class PageRoutes {
  static const String signInRoot = 'signIn/';
  static const String signUp = 'signUp';
  static const String verification = 'verification';
  static const String restpassword1 = 'restpassword1';
  static const String restpassword2 = 'restpassword2';
  static const String restpassword3 = 'restpassword3';

  static const String sidebar = '/side_bar';
  static const String viewall = '/viewall';
  static const String homePage = '/home_page';
  // static const String all_category = '/all_category';
  static const String cat_product = '/cat_product';
  static const String product = '/product';

  // static const String cart = '/cart';
  static const String search = '/search';
  // static const String searchhistory = '/searchhistory';
  static const String cat_sub_p = '/catsubp';
  static const String tagproduct = '/tagproduct';
  static const String reviewsall = '/reviewsall';

//  static const String confirmOrder = 'confirm_order';
  static const String cartPage = 'checkout';
  static const String selectAddress = 'selectAddress';
  static const String editAddress = 'editAddress';
  static const String paymentMode = 'paymentMode';
  static const String confirmOrder = 'confirmOrder';
  static const String orderdetailspage = 'orderdetailspage';
  static const String myorder = 'myorder';
  static const String addaddressp = 'addaddressp';
  static const String stripecard = 'stripecard';
  static const String invoice = 'invoice';
  static const String langnewf = '/langnewf';
  static const String sellerinfo = '/sellerinfo';
  static const String offerpage = '/offerpage';
  static const String yourbasket = '/yourbasket';
  static const String deliveryoption = '/deliveryoption';
  static const String support = '/support';
  static const String sharescreen = '/sharescreen';
  static const String tncPage = '/tncpage';
  static const String aboutusscreen = '/aboutusscreen';
  static const String favouriteitem = '/favouriteitem';
  static const String myaccount = '/myaccount';
  static const String orderscreen = '/orderscreen';
  static const String walletscreen = '/walletscreen';
  static const String paymentOption = '/paymentoption';
  static const String orderdetails = '/orderdetials';
  static const String trackorder = '/trackorder';
  static const String myaddress = '/myaddress';
  static const String notification = '/notification';
  static const String paymentdoned = '/paymentdoned';
  static const String settingsAccount = '/settingaccount';

  Map<String, WidgetBuilder> routes() {
    return {
      homePage: (context) => NewHomeView(),
      // all_category: (context) => AllCategory(),
      cat_product: (context) => CategoryProduct(),
      product: (context) => ProductInfo(),
      // cart: (context) => CheckOutNavigator(),
      search: (context) => SearchEan(),
      // searchhistory: (context) => SearchHistory(),
      cat_sub_p: (context) => CategorySubProduct(),
      tagproduct: (context) => TagsProduct(),
      reviewsall: (context) => Reviews(),
      cartPage: (context) => YourBasket(),
      // selectAddress: (context) => AddressPage(),
      editAddress: (context) => EditAddressPage(),
      // orderdetailspage: (context) => OrderDeatilsPage(),
      // paymentMode: (context) => PaymentModePage(),
      confirmOrder: (context) => ConfirmOrderPage(),
      myorder: (context) => MyOrders(),
      addaddressp: (context) => AddAddressPage(),
      stripecard: (context) => MyStripeCard(),
      invoice: (context) => MyInvoicePdf(),
      signInRoot: (context) => SignIn(),
      signUp: (context) => SignUp(),
      verification: (context) => VerificationPage(),
      restpassword1: (context) => NumberScreenRestPassword(),
      restpassword2: (context) => ResetOtpVerify(),
      restpassword3: (context) => ChangePassword(),
      viewall: (context) => ViewAllProduct(),
      langnewf: (context) => ChooseLanguageNew(),
      sellerinfo: (context) => SellerInfo(),
      offerpage: (context) => OffersPage(),
      yourbasket: (context) => YourBasket(),
      deliveryoption: (context) => DeliveryOption(),
      support: (context) => ContactUsPage(),
      sharescreen: (context) => RefferScreen(),
      tncPage: (context) => TNCPage(),
      aboutusscreen: (context) => AboutUsPage(),
      favouriteitem: (context) => MyWishList(),
      myaccount: (context) => MyAccount(),
      myaddress: (context) => MyAddress(),
      orderscreen: (context) => MyOrdersDrawer(),
      walletscreen: (context) => Wallet(),
      paymentOption: (context) => PaymentOption(),
      orderdetails: (context) => OrderDetails(),
      trackorder: (context) => TrackOrders(),
      notification: (context) => NotificationShow(),
      paymentdoned: (context) => PaymentDoneWebView(),
      settingsAccount: (context) => SettingPage(),
    };
  }
}
