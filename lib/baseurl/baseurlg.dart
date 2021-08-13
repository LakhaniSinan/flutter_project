import 'package:shared_preferences/shared_preferences.dart';
// var imagebaseUrl1 = 'http://thecodecafe.in/gogrocerver3.0/';
var imagebaseUrl1 = 'https://cloud.solicitous.in/grocery_app/';
var imagebaseUrl;
void getImageBaseUrl() async{
  SharedPreferences.getInstance().then((value){
    if(value.containsKey('imagebaseurl')){
      imagebaseUrl = value.getString('imagebaseurl')+'/';
    }else{
      imagebaseUrl = imagebaseUrl1;
    }
  });
}
var apibaseUrl = imagebaseUrl1+'api/';
var cityUri = Uri.parse('${apibaseUrl}city');
var appInfoUri = Uri.parse('${apibaseUrl}app_info');
var checkOtpOnOffUri = Uri.parse('${apibaseUrl}checkotponoff');
var firebaseCheckUri = Uri.parse('${apibaseUrl}firebase');
var societyUri = Uri.parse('${apibaseUrl}society');
var signupUri = Uri.parse('${apibaseUrl}signup');
var verifyPhoneRefferalUri = Uri.parse('${apibaseUrl}verify_phone');
var verifyViaFirebaseUri = Uri.parse('${apibaseUrl}verify_via_firebase');
var loginUri = Uri.parse('${apibaseUrl}login');
var socialLoginUri = Uri.parse('${apibaseUrl}social_login');
var checkNumUri = Uri.parse('${apibaseUrl}checknum');
var loginVerifyPhoneUri = Uri.parse('${apibaseUrl}loginverify_phone');
var loginVerifyViaFirebaseUri = Uri.parse('${apibaseUrl}loginverify_via_firebase');
var categoryUri = Uri.parse('${apibaseUrl}catee');
var storeBannerUri = Uri.parse('${apibaseUrl}store_banner');
var whatsNewUri = Uri.parse('${apibaseUrl}whatsnew');
var dealProductUri = Uri.parse('${apibaseUrl}dealproduct');
var topCatUri = Uri.parse('${apibaseUrl}topcat');
var topSellingUri = Uri.parse('${apibaseUrl}top_selling');
var recentSellingUri = Uri.parse('${apibaseUrl}recentselling');
var addToCartUri = Uri.parse('${apibaseUrl}add_to_cart');
var catProductUri = Uri.parse('${apibaseUrl}cat_product');
var myProfileUri = Uri.parse('${apibaseUrl}myprofile');
var showWishlistUri = Uri.parse('${apibaseUrl}show_wishlist');
var addRemWishlistUri = Uri.parse('${apibaseUrl}add_rem_wishlist');
var getNearestStoreUri = Uri.parse('${apibaseUrl}getneareststore');
var showCartUri = Uri.parse('${apibaseUrl}show_cart');
var appAboutusUri = Uri.parse('${apibaseUrl}appaboutus');
var appTermsUri = Uri.parse('${apibaseUrl}appterms');
var paymentGatewaysUri = Uri.parse('${apibaseUrl}payment_gateways');
var addAddressUri = Uri.parse('${apibaseUrl}add_address');
var editAddressUri = Uri.parse('${apibaseUrl}edit_address');
var myOrdersUri = Uri.parse('${apibaseUrl}my_orders');
var showAddressUri = Uri.parse('${apibaseUrl}show_address');
var showAllAddressUri = Uri.parse('${apibaseUrl}show_all_address');
var searchUri = Uri.parse('${apibaseUrl}search');
var checkoutUri = Uri.parse('${apibaseUrl}checkout');
var selectAddressUri = Uri.parse('${apibaseUrl}select_address');
var storeCouponsUri = Uri.parse('${apibaseUrl}storecoupons');
var applyCouponUri = Uri.parse('${apibaseUrl}apply_coupon');
var timeSlotUri = Uri.parse('${apibaseUrl}timeslot');
var callbackReqUri = Uri.parse('${apibaseUrl}callback_req');
var userFeedbackUri = Uri.parse('${apibaseUrl}user_feedback');
var makeOrderUri = Uri.parse('${apibaseUrl}make_order');
var getProductRatingUri = Uri.parse('${apibaseUrl}get_product_rating');
var resendOtpUri = Uri.parse('${apibaseUrl}resendotp');
var walletAmountUri = Uri.parse('${apibaseUrl}walletamount');
var rechargeWalletUri = Uri.parse('${apibaseUrl}recharge_wallet');
var searchByStoreUri = Uri.parse('${apibaseUrl}searchbystore');
var forGetPasswordByPhoneUri = Uri.parse('${apibaseUrl}forget_password');
var forGetPasswordByEmailUri = Uri.parse('${apibaseUrl}forgot_password');
var verifyOtpPPhoneUri = Uri.parse('${apibaseUrl}verify_otp');
var verifyOtpPFirebaseUri = Uri.parse('${apibaseUrl}firebase_otp_ver');
var changePasswordUri = Uri.parse('${apibaseUrl}change_password');
var walletRechargeHistoryUri = Uri.parse('${apibaseUrl}wallet_recharge_history');
var cancellingReasonsUri = Uri.parse('${apibaseUrl}cancelling_reasons');
var deleteOrderUri = Uri.parse('${apibaseUrl}delete_order');
var tagProductUri = Uri.parse('${apibaseUrl}tag_product');
var paidByWalletUri = Uri.parse('${apibaseUrl}paid_by_wallet');
var addProductRatingUri = Uri.parse('${apibaseUrl}add_product_rating');
var profileEditUri = Uri.parse('${apibaseUrl}profile_edit');
var wishlistToCartUri = Uri.parse('${apibaseUrl}wishlist_to_cart');
var appNoticeUri = Uri.parse('${apibaseUrl}app_notice');
var mapbyUri = Uri.parse('${apibaseUrl}mapby');
var googleMapUri = Uri.parse('${apibaseUrl}google_map');
var mapboxUri = Uri.parse('${apibaseUrl}mapbox');
var notificationListUri = Uri.parse('${apibaseUrl}notificationlist');
var redeemRewardsUri = Uri.parse('${apibaseUrl}redeem_rewards');
var oneApiUri = Uri.parse('${apibaseUrl}oneapi');
var topCatPrductUri = Uri.parse('${apibaseUrl}top_cat_prduct');
var clearCartUri = Uri.parse('${apibaseUrl}clear_cart');

// note donot alter this one at any cost
var paymentApiUrl = Uri.parse('https://api.stripe.com/v1/payment_intents');
var orderApiRazorpay = Uri.parse('https://api.razorpay.com/v1/orders');

//payment fail or success after page.
var paymentLoadURI = Uri.parse('${apibaseUrl}payment_load');

//new api
var notifyByUri = Uri.parse('${apibaseUrl}notifyby');
var updateNotifyByUri = Uri.parse('${apibaseUrl}updatenotifyby');


var appname = 'Bdukan';
