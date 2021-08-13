import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:grocery/Locale/languages.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static Languages languaged = Languages();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': languaged.english(),
    'ar': languaged.arabic(),
    'pt': languaged.portuguese(),
    'fr': languaged.french(),
    'id': languaged.indonesian(),
    'es': languaged.spanish(),
  };

  String get yb1 {
    return _localizedValues[locale.languageCode]['yb1'];
  }

  String get yb2 {
    return _localizedValues[locale.languageCode]['yb2'];
  }

  String get yb3 {
    return _localizedValues[locale.languageCode]['yb3'];
  }

  String get yb4 {
    return _localizedValues[locale.languageCode]['yb4'];
  }

  String get yb5 {
    return _localizedValues[locale.languageCode]['yb5'];
  }

  String get yb6 {
    return _localizedValues[locale.languageCode]['yb6'];
  }

  String get yb7{
    return _localizedValues[locale.languageCode]['yb7'];
  }

  String get nocatfount1 {
    return _localizedValues[locale.languageCode]['nocatfount1'];
  }

  String get ac1 {
    return _localizedValues[locale.languageCode]['ac1'];
  }

  String get ac2 {
    return _localizedValues[locale.languageCode]['ac2'];
  }

  String get ac3 {
    return _localizedValues[locale.languageCode]['ac3'];
  }

  String get ac4 {
    return _localizedValues[locale.languageCode]['ac4'];
  }

  String get ac5 {
    return _localizedValues[locale.languageCode]['ac5'];
  }

  String get ac6 {
    return _localizedValues[locale.languageCode]['ac6'];
  }

  String get ac7{
    return _localizedValues[locale.languageCode]['ac7'];
  }

  String get ac8 {
    return _localizedValues[locale.languageCode]['ac8'];
  }

  String get ac9 {
    return _localizedValues[locale.languageCode]['ac9'];
  }

  String get ac10 {
    return _localizedValues[locale.languageCode]['ac10'];
  }

  String get ac11 {
    return _localizedValues[locale.languageCode]['ac11'];
  }

  String get ac12 {
    return _localizedValues[locale.languageCode]['ac12'];
  }

  String get ac13 {
    return _localizedValues[locale.languageCode]['ac13'];
  }


  String get ac14 {
    return _localizedValues[locale.languageCode]['ac14'];
  }

  String get ac15 {
    return _localizedValues[locale.languageCode]['ac15'];
  }

  String get ac16 {
    return _localizedValues[locale.languageCode]['ac16'];
  }

  String get ac17 {
    return _localizedValues[locale.languageCode]['ac17'];
  }

  String get ac18 {
    return _localizedValues[locale.languageCode]['ac18'];
  }

  String get ac19 {
    return _localizedValues[locale.languageCode]['ac19'];
  }

  //
  String get do1 {
    return _localizedValues[locale.languageCode]['do1'];
  }

  String get do2 {
    return _localizedValues[locale.languageCode]['do2'];
  }

  String get do3 {
    return _localizedValues[locale.languageCode]['do3'];
  }

  String get do4 {
    return _localizedValues[locale.languageCode]['do4'];
  }

  String get do5 {
    return _localizedValues[locale.languageCode]['do5'];
  }

  String get do6 {
    return _localizedValues[locale.languageCode]['do6'];
  }

  String get do7{
    return _localizedValues[locale.languageCode]['do7'];
  }

  String get do8 {
    return _localizedValues[locale.languageCode]['do8'];
  }

  String get do9 {
    return _localizedValues[locale.languageCode]['do9'];
  }

  String get do10 {
    return _localizedValues[locale.languageCode]['do10'];
  }

  String get do11 {
    return _localizedValues[locale.languageCode]['do11'];
  }

  String get do12 {
    return _localizedValues[locale.languageCode]['do12'];
  }

  String get do13 {
    return _localizedValues[locale.languageCode]['do13'];
  }


  String get do14 {
    return _localizedValues[locale.languageCode]['do14'];
  }

  String get do15 {
    return _localizedValues[locale.languageCode]['do15'];
  }

  String get do16 {
    return _localizedValues[locale.languageCode]['do16'];
  }

  String get do17 {
    return _localizedValues[locale.languageCode]['do17'];
  }

  String get do18 {
    return _localizedValues[locale.languageCode]['do18'];
  }

  ///

  String get signin {
    return _localizedValues[locale.languageCode]['signin'];
  }

  String get pcurprogress {
    return _localizedValues[locale.languageCode]['pcurprogress'];
  }

  String get prddetails {
    return _localizedValues[locale.languageCode]['prddetails'];
  }

  String get pqty {
    return _localizedValues[locale.languageCode]['pqty'];
  }

  String get ptype {
    return _localizedValues[locale.languageCode]['ptype'];
  }

  String get inseason {
    return _localizedValues[locale.languageCode]['inseason'];
  }

  String get ok {
    return _localizedValues[locale.languageCode]['ok'];
  }

  String get notice1 {
    return _localizedValues[locale.languageCode]['notice1'];
  }

  String get notice2 {
    return _localizedValues[locale.languageCode]['notice2'];
  }

  String get od1 {
    return _localizedValues[locale.languageCode]['od1'];
  }

  String get od2 {
    return _localizedValues[locale.languageCode]['od2'];
  }

  String get od3 {
    return _localizedValues[locale.languageCode]['od3'];
  }

  String get od4 {
    return _localizedValues[locale.languageCode]['od4'];
  }

  String get od5 {
    return _localizedValues[locale.languageCode]['od5'];
  }

  String get od6 {
    return _localizedValues[locale.languageCode]['od6'];
  }

  String get od7{
    return _localizedValues[locale.languageCode]['od7'];
  }

  String get od8 {
    return _localizedValues[locale.languageCode]['od8'];
  }

  String get od9 {
    return _localizedValues[locale.languageCode]['od9'];
  }

  String get od10 {
    return _localizedValues[locale.languageCode]['od10'];
  }

  String get od11 {
    return _localizedValues[locale.languageCode]['od11'];
  }

  String get od12 {
    return _localizedValues[locale.languageCode]['od12'];
  }

  String get od13 {
    return _localizedValues[locale.languageCode]['od13'];
  }

  String get od14 {
    return _localizedValues[locale.languageCode]['od14'];
  }

  String get od15 {
    return _localizedValues[locale.languageCode]['od15'];
  }

  String get cnfo1 {
    return _localizedValues[locale.languageCode]['cnfo1'];
  }

  String get cnfo2 {
    return _localizedValues[locale.languageCode]['cnfo2'];
  }

  String get cnfo3 {
    return _localizedValues[locale.languageCode]['cnfo3'];
  }

  String get cnfo4 {
    return _localizedValues[locale.languageCode]['cnfo4'];
  }

  String get outstock2 {
    return _localizedValues[locale.languageCode]['outstock2'];
  }

  String get outstock {
    return _localizedValues[locale.languageCode]['outstock'];
  }

  String get carth {
    return _localizedValues[locale.languageCode]['carth'];
  }

  String get drawer1 {
    return _localizedValues[locale.languageCode]['drawer1'];
  }

  String get drawer2 {
    return _localizedValues[locale.languageCode]['drawer2'];
  }

  String get drawer3{
    return _localizedValues[locale.languageCode]['drawer3'];
  }

  String get blockmsg {
    return _localizedValues[locale.languageCode]['blockmsg'];
  }

  String get veri1 {
    return _localizedValues[locale.languageCode]['veri1'];
  }

  String get veri2{
    return _localizedValues[locale.languageCode]['veri2'];
  }

  String get veri3 {
    return _localizedValues[locale.languageCode]['veri3'];
  }

  String get veri4 {
    return _localizedValues[locale.languageCode]['veri4'];
  }

  String get veri5 {
    return _localizedValues[locale.languageCode]['veri5'];
  }

  String get veri6 {
    return _localizedValues[locale.languageCode]['veri6'];
  }


  String get Continuel1 {
    return _localizedValues[locale.languageCode]['Continuel1'];
  }

  String get Continuel2 {
    return _localizedValues[locale.languageCode]['Continuel2'];
  }

  String get googlel {
    return _localizedValues[locale.languageCode]['googlel'];
  }

  String get facebookl {
    return _localizedValues[locale.languageCode]['facebookl'];
  }

  String get login1 {
    return _localizedValues[locale.languageCode]['login1'];
  }

  String get login2 {
    return _localizedValues[locale.languageCode]['login2'];
  }

  String get hellol {
    return _localizedValues[locale.languageCode]['hellol'];
  }

  String get hellol2 {
    return _localizedValues[locale.languageCode]['hellol2'];
  }

  String get mobilenuml {
    return _localizedValues[locale.languageCode]['mobilenuml'];
  }

  String get productnotfound {
    return _localizedValues[locale.languageCode]['productnotfound'];
  }

  String get taptosave {
    return _localizedValues[locale.languageCode]['taptosave'];
  }

  String get somethingwentwrong {
    return _localizedValues[locale.languageCode]['somethingwentwrong'];
  }

  String get nowhatsappinstalled {
    return _localizedValues[locale.languageCode]['nowhatsappinstalled'];
  }

  String get collectReward {
    return _localizedValues[locale.languageCode]['collectReward'];
  }

  String get rewardtitle {
    return _localizedValues[locale.languageCode]['rewardtitle'];
  }

  String get noReward {
    return _localizedValues[locale.languageCode]['noReward'];
  }

  String get notificaitonh {
    return _localizedValues[locale.languageCode]['notificaitonh'];
  }

  String get nonotificaiton {
    return _localizedValues[locale.languageCode]['nonotificaiton'];
  }

  String get creditdebit {
    return _localizedValues[locale.languageCode]['creditdebit'];
  }

  String get rateourproduct {
    return _localizedValues[locale.languageCode]['rateourproduct'];
  }

  String get invoiceno {
    return _localizedValues[locale.languageCode]['invoiceno'];
  }

  String get locateyourself {
    return _localizedValues[locale.languageCode]['locateyourself'];
  }

  String get nooffernow {
    return _localizedValues[locale.languageCode]['nooffernow'];
  }

  String get mincartvalue {
    return _localizedValues[locale.languageCode]['mincartvalue'];
  }

  String get varient {
    return _localizedValues[locale.languageCode]['varient'];
  }

  String get noaddressfound {
    return _localizedValues[locale.languageCode]['noaddressfound'];
  }

  String get noprodwishlist {
    return _localizedValues[locale.languageCode]['noprodwishlist'];
  }

  String get shopbycategory {
    return _localizedValues[locale.languageCode]['shopbycategory'];
  }

  String get tags {
    return _localizedValues[locale.languageCode]['tags'];
  }

  String get nomorcategory {
    return _localizedValues[locale.languageCode]['nomorcategory'];
  }

  String get resend {
    return _localizedValues[locale.languageCode]['resend'];
  }

  String get photolibrary {
    return _localizedValues[locale.languageCode]['photolibrary'];
  }

  String get camera {
    return _localizedValues[locale.languageCode]['camera'];
  }

  String get shareheading {
    return _localizedValues[locale.languageCode]['shareheading'];
  }

  String get sharetext {
    return _localizedValues[locale.languageCode]['sharetext'];
  }

  String get commingsoon {
    return _localizedValues[locale.languageCode]['commingsoon'];
  }

  String get profileedit {
    return _localizedValues[locale.languageCode]['profileedit'];
  }

  String get update {
    return _localizedValues[locale.languageCode]['update'];
  }

  String get password1 {
    return _localizedValues[locale.languageCode]['password1'];
  }

  String get password2 {
    return _localizedValues[locale.languageCode]['password2'];
  }

  String get loginotp {
    return _localizedValues[locale.languageCode]['loginotp'];
  }

  String get selectsocity1 {
    return _localizedValues[locale.languageCode]['selectsocity1'];
  }

  String get selectsocity2 {
    return _localizedValues[locale.languageCode]['selectsocity2'];
  }

  String get selectycity1 {
    return _localizedValues[locale.languageCode]['selectycity1'];
  }

  String get selectycity2 {
    return _localizedValues[locale.languageCode]['selectycity2'];
  }

  String get incorectPassword{
    return _localizedValues[locale.languageCode]['incorectPassword'];
  }

  String get incorectEmail{
    return _localizedValues[locale.languageCode]['incorectEmail'];
  }

  String get incorectUserName{
    return _localizedValues[locale.languageCode]['incorectUserName'];
  }

  String get incorectMobileNumber{
    return _localizedValues[locale.languageCode]['incorectMobileNumber'];
  }

  String get referalcode1{
    return _localizedValues[locale.languageCode]['referalcode1'];
  }
  String get referalcode2{
    return _localizedValues[locale.languageCode]['referalcode2'];
  }
  String get uploadpictext{
    return _localizedValues[locale.languageCode]['uploadpictext'];
  }

  String get skiptext{
    return _localizedValues[locale.languageCode]['skiptext'];
  }

  String get goToCart{
    return _localizedValues[locale.languageCode]['goToCart'];
  }

  String get profileclickupdate{
    return _localizedValues[locale.languageCode]['profileclickupdate'];
  }

  String get rechargeDate{
    return _localizedValues[locale.languageCode]['rechargeDate'];
  }

  String get continueText {
    return _localizedValues[locale.languageCode]['continueText'];
  }

  String get clickToAddCart {
    return _localizedValues[locale.languageCode]['clickToAddCart'];
  }

  String get clearcartto {
    return _localizedValues[locale.languageCode]['clearcartto'];
  }

  String get hey {
    return _localizedValues[locale.languageCode]['hey'];
  }

  String get home {
    return _localizedValues[locale.languageCode]['home'];
  }

  String get myProfile {
    return _localizedValues[locale.languageCode]['myProfile'];
  }

  String get myOrders {
    return _localizedValues[locale.languageCode]['myOrders'];
  }

  String get offers {
    return _localizedValues[locale.languageCode]['offers'];
  }

  String get myWishList {
    return _localizedValues[locale.languageCode]['myWishList'];
  }

  String get aboutUs {
    return _localizedValues[locale.languageCode]['aboutUs'];
  }

  String get tnc {
    return _localizedValues[locale.languageCode]['tnc'];
  }

  String get helpCentre {
    return _localizedValues[locale.languageCode]['helpCentre'];
  }

  String get language {
    return _localizedValues[locale.languageCode]['language'];
  }

  String get logout {
    return _localizedValues[locale.languageCode]['logout'];
  }

  String get login {
    return _localizedValues[locale.languageCode]['login'];
  }

  String get office {
    return _localizedValues[locale.languageCode]['office'];
  }

  String get other {
    return _localizedValues[locale.languageCode]['other'];
  }

  String get selectAddress {
    return _localizedValues[locale.languageCode]['selectAddress'];
  }

  String get yourOrderHasBeenPlacedSuccessfully {
    return _localizedValues[locale.languageCode]
        ['yourOrderHasBeenPlacedSuccessfully'];
  }

  String get youCanCheckYourOrderProcessInMyOrdersSection {
    return _localizedValues[locale.languageCode]
        ['youCanCheckYourOrderProcessInMyOrdersSection'];
  }

  String get continueShopping {
    return _localizedValues[locale.languageCode]['continueShopping'];
  }

  String get jonathanfarms {
    return _localizedValues[locale.languageCode]['jonathanfarms '];
  }

  String get greencityfarm {
    return _localizedValues[locale.languageCode]['greencityfarm'];
  }

  String get operummarket {
    return _localizedValues[locale.languageCode]['operummarket'];
  }

  String get cashOnDelivery {
    return _localizedValues[locale.languageCode]['cashOnDelivery'];
  }

  String get dispatched {
    return _localizedValues[locale.languageCode]['dispatched'];
  }

  String get placed {
    return _localizedValues[locale.languageCode]['placed'];
  }

  String get packing {
    return _localizedValues[locale.languageCode]['packing'];
  }

  String get track {
    return _localizedValues[locale.languageCode]['track'];
  }

  String get delivered {
    return _localizedValues[locale.languageCode]['delivered'];
  }

  String get orderedItems {
    return _localizedValues[locale.languageCode]['orderedItems'];
  }

  String get deliveryFee {
    return _localizedValues[locale.languageCode]['deliveryFee'];
  }

  String get promoCode {
    return _localizedValues[locale.languageCode]['promoCode'];
  }

  String get paidbywallet {
    return _localizedValues[locale.languageCode]['paidbywallet'];
  }

  String get amountToPay {
    return _localizedValues[locale.languageCode]['amountToPay'];
  }

  String get amount {
    return _localizedValues[locale.languageCode]['amount'];
  }

  String get payment {
    return _localizedValues[locale.languageCode]['payment'];
  }

  String get paymentstatus {
    return _localizedValues[locale.languageCode]['paymentstatus'];
  }


  String get paymentMode {
    return _localizedValues[locale.languageCode]['paymentMode'];
  }

  String get orderDetails {
    return _localizedValues[locale.languageCode]['orderDetails'];
  }

  String get orderStatus {
    return _localizedValues[locale.languageCode]['orderStatus'];
  }

  String get orderedOn {
    return _localizedValues[locale.languageCode]['orderedOn'];
  }

  String get orderID {
    return _localizedValues[locale.languageCode]['orderID'];
  }

  String get cards {
    return _localizedValues[locale.languageCode]['cards'];
  }

  String get creditCard {
    return _localizedValues[locale.languageCode]['creditCard'];
  }

  String get debitCard {
    return _localizedValues[locale.languageCode]['debitCard'];
  }

  String get cash {
    return _localizedValues[locale.languageCode]['cash'];
  }

  String get otherMethods {
    return _localizedValues[locale.languageCode]['otherMethods'];
  }

  String get welcomeTo {
    return _localizedValues[locale.languageCode]['welcomeTo'];
  }

  String get selectCountry {
    return _localizedValues[locale.languageCode]['selectCountry'];
  }

  String get phoneNumber {
    return _localizedValues[locale.languageCode]['phoneNumber'];
  }

  String get enterPhoneNumber {
    return _localizedValues[locale.languageCode]['enterPhoneNumber'];
  }

  String get wellSendOTPForVerification {
    return _localizedValues[locale.languageCode]['wellSendOTPForVerification'];
  }

  String get orContinueWith {
    return _localizedValues[locale.languageCode]['orContinueWith'];
  }

  String get register {
    return _localizedValues[locale.languageCode]['register'];
  }

  String get fullName {
    return _localizedValues[locale.languageCode]['fullName'];
  }

  String get enterFullName {
    return _localizedValues[locale.languageCode]['enterFullName'];
  }

  String get emailAddress {
    return _localizedValues[locale.languageCode]['emailAddress'];
  }

  String get enterEmailAddress {
    return _localizedValues[locale.languageCode]['enterEmailAddress'];
  }

  String get verification {
    return _localizedValues[locale.languageCode]['verification'];
  }

  String get pleaseEnterVerificationCodeSentGivenNumber {
    return _localizedValues[locale.languageCode]
        ['pleaseEnterVerificationCodeSentGivenNumber'];
  }

  String get enterVerificationCode {
    return _localizedValues[locale.languageCode]['enterVerificationCode'];
  }

  String get yourCart {
    return _localizedValues[locale.languageCode]['yourCart'];
  }

  String get addPromocode {
    return _localizedValues[locale.languageCode]['addPromocode'];
  }

  String get apply {
    return _localizedValues[locale.languageCode]['apply'];
  }

  String get cartTotal {
    return _localizedValues[locale.languageCode]['cartTotal'];
  }

  String get checkoutNow {
    return _localizedValues[locale.languageCode]['checkoutNow'];
  }

  String get total {
    return _localizedValues[locale.languageCode]['total'];
  }

  String get vegetables {
    return _localizedValues[locale.languageCode]['vegetables'];
  }

  String get bakery {
    return _localizedValues[locale.languageCode]['bakery'];
  }

  String get foodgrain {
    return _localizedValues[locale.languageCode]['foodgrain'];
  }

  String get household {
    return _localizedValues[locale.languageCode]['household'];
  }

  String get searchOnGoGrocer {
    return _localizedValues[locale.languageCode]['searchOnGoGrocer'];
  }

  String get recentlySearched {
    return _localizedValues[locale.languageCode]['recentlySearched'];
  }

  String get chooseCategory {
    return _localizedValues[locale.languageCode]['chooseCategory'];
  }

  String get freshRedOnios {
    return _localizedValues[locale.languageCode]['freshRedOnios'];
  }

  String get freshRedTomatoes {
    return _localizedValues[locale.languageCode]['freshRedTomatoes'];
  }

  String get mediumPotatoes {
    return _localizedValues[locale.languageCode]['mediumPotatoes'];
  }

  String get freshLadiesFinger {
    return _localizedValues[locale.languageCode]['freshLadiesFinger'];
  }

  String get freshGarlic {
    return _localizedValues[locale.languageCode]['freshGarlic'];
  }

  String get cauliFlower {
    return _localizedValues[locale.languageCode]['cauliFlower'];
  }

  String get fresh {
    return _localizedValues[locale.languageCode]['fresh'];
  }

  String get resultsFound {
    return _localizedValues[locale.languageCode]['resultsFound'];
  }

  String get aboutCompany {
    return _localizedValues[locale.languageCode]['aboutCompany'];
  }

  String get addAddress {
    return _localizedValues[locale.languageCode]['addAddress'];
  }

  String get addressTitle {
    return _localizedValues[locale.languageCode]['addressTitle'];
  }

  String get addReview {
    return _localizedValues[locale.languageCode]['addReview'];
  }

  String get howWasYourExperience {
    return _localizedValues[locale.languageCode]['howWasYourExperience'];
  }

  String get writeYourFeedback {
    return _localizedValues[locale.languageCode]['writeYourFeedback'];
  }

  String get enterYourReview {
    return _localizedValues[locale.languageCode]['enterYourReview'];
  }

  String get contactUs {
    return _localizedValues[locale.languageCode]['contactUs'];
  }

  String get letUsKnowYourFeedbackQueriesIssueRegardingAppFeatures {
    return _localizedValues[locale.languageCode]
        ['letUsKnowYourFeedbackQueriesIssueRegardingAppFeatures'];
  }

  String get enterYourMessage {
    return _localizedValues[locale.languageCode]['enterYourMessage'];
  }

  String get yourFeedback {
    return _localizedValues[locale.languageCode]['yourFeedback'];
  }

  String get submit {
    return _localizedValues[locale.languageCode]['submit'];
  }

  String get fresharrived {
    return _localizedValues[locale.languageCode]['fresharrived'];
  }

  String get featuredProducts {
    return _localizedValues[locale.languageCode]['featuredProducts'];
  }

  String get englishh {
    return _localizedValues[locale.languageCode]['englishh'];
  }

  String get spanishh {
    return _localizedValues[locale.languageCode]['spanishh'];
  }

  String get portuguesee {
    return _localizedValues[locale.languageCode]['portuguesee'];
  }

  String get frenchh {
    return _localizedValues[locale.languageCode]['frenchh'];
  }

  String get arabicc {
    return _localizedValues[locale.languageCode]['arabicc'];
  }

  String get indonesiann {
    return _localizedValues[locale.languageCode]['indonesiann'];
  }

  String get languages {
    return _localizedValues[locale.languageCode]['languages'];
  }

  String get selectPreferredLanguage {
    return _localizedValues[locale.languageCode]['selectPreferredLanguage'];
  }

  String get save {
    return _localizedValues[locale.languageCode]['save'];
  }

  String get myAccount {
    return _localizedValues[locale.languageCode]['myAccount'];
  }

  String get myAddresses {
    return _localizedValues[locale.languageCode]['myAddresses'];
  }

  String get offer1 {
    return _localizedValues[locale.languageCode]['offer1'];
  }

  String get offer2 {
    return _localizedValues[locale.languageCode]['offer2'];
  }

  String get offer3 {
    return _localizedValues[locale.languageCode]['offer3'];
  }

  String get readAllReviews1 {
    return _localizedValues[locale.languageCode]['readAllReviews1'];
  }

  String get readAllReviews2 {
    return _localizedValues[locale.languageCode]['readAllReviews2'];
  }

  String get addToCart {
    return _localizedValues[locale.languageCode]['addToCart'];
  }

  String get moreBy {
    return _localizedValues[locale.languageCode]['moreBy'];
  }

  String get seller {
    return _localizedValues[locale.languageCode]['seller'];
  }

  String get viewAll {
    return _localizedValues[locale.languageCode]['viewAll'];
  }

  String get avgRatings {
    return _localizedValues[locale.languageCode]['avgRatings'];
  }

  String get ratings {
    return _localizedValues[locale.languageCode]['ratings'];
  }

  String get recentReviews {
    return _localizedValues[locale.languageCode]['recentReviews'];
  }

  String get discountedItems {
    return _localizedValues[locale.languageCode]['discountedItems'];
  }

  String get topRated {
    return _localizedValues[locale.languageCode]['topRated'];
  }

  String get confirmOrder {
    return _localizedValues[locale.languageCode]['confirmOrder'];
  }

  String get saveLoc {
    return _localizedValues[locale.languageCode]['saveLoc'];
  }

  String get notext {
    return _localizedValues[locale.languageCode]['notext'];
  }

  String get fetchingTimeSlotText {
    return _localizedValues[locale.languageCode]['fetchingTimeSlotText'];
  }

  String get noTimeSlotText {
    return _localizedValues[locale.languageCode]['noTimeSlotText'];
  }
  String get applied {
    return _localizedValues[locale.languageCode]['applied'];
  }
  String get or {
    return _localizedValues[locale.languageCode]['or'];
  }

  String get resetpassword {
    return _localizedValues[locale.languageCode]['resetpassword'];
  }

  String get mobilerp {
    return _localizedValues[locale.languageCode]['mobilerp'];
  }

  String get emailrp {
    return _localizedValues[locale.languageCode]['emailrp'];
  }

  String get selectrp {
    return _localizedValues[locale.languageCode]['selectrp'];
  }

  String get newpassword1 {
    return _localizedValues[locale.languageCode]['newpassword1'];
  }

  String get newpassword2 {
    return _localizedValues[locale.languageCode]['newpassword2'];
  }

  String get confirmpassword1 {
    return _localizedValues[locale.languageCode]['confirmpassword1'];
  }

  String get confirmpassword2 {
    return _localizedValues[locale.languageCode]['confirmpassword2'];
  }

  String get changepassword {
    return _localizedValues[locale.languageCode]['changepassword'];
  }

  String get passwordheading {
    return _localizedValues[locale.languageCode]['passwordheading'];
  }

  String get mywallet {
    return _localizedValues[locale.languageCode]['mywallet'];
  }

  String get loginfirst {
    return _localizedValues[locale.languageCode]['loginfirst'];
  }

  String get sn {
    return _localizedValues[locale.languageCode]['sn'];
  }

  String get walletrecharge {
    return _localizedValues[locale.languageCode]['walletrecharge'];
  }

  String get spentanalysis {
    return _localizedValues[locale.languageCode]['spentanalysis'];
  }

  String get rechargehistory {
    return _localizedValues[locale.languageCode]['rechargehistory'];
  }

  String get advancevalue {
    return _localizedValues[locale.languageCode]['advancevalue'];
  }

  String get nohistory {
    return _localizedValues[locale.languageCode]['nohistory'];
  }

  String get cancelreason {
    return _localizedValues[locale.languageCode]['cancelreason'];
  }

  String get cancelorder {
    return _localizedValues[locale.languageCode]['cancelorder'];
  }

  String get subtotal {
    return _localizedValues[locale.languageCode]['subtotal'];
  }

  String get callBackReq1{
    return _localizedValues[locale.languageCode]['callBackReq1'];
  }

  String get callBackReq2{
    return _localizedValues[locale.languageCode]['callBackReq2'];
  }

  String get reason{
    return _localizedValues[locale.languageCode]['reason'];
  }

  String get cart1{
    return _localizedValues[locale.languageCode]['cart1'];
  }

  String get shownow{
    return _localizedValues[locale.languageCode]['shownow'];
  }

  String get timedate{
    return _localizedValues[locale.languageCode]['timedate'];
  }

  String get nosaveaddress{
    return _localizedValues[locale.languageCode]['nosaveaddress'];
  }

  String get name{
    return _localizedValues[locale.languageCode]['name'];
  }

  String get cnumber{
    return _localizedValues[locale.languageCode]['cnumber'];
  }

  String get orderdetail1{
    return _localizedValues[locale.languageCode]['orderdetail1'];
  }

  String get orderdetail2{
    return _localizedValues[locale.languageCode]['orderdetail2'];
  }

  String get orderdetail3{
    return _localizedValues[locale.languageCode]['orderdetail3'];
  }

  String get orderdetail4{
    return _localizedValues[locale.languageCode]['orderdetail4'];
  }

  String get orderdetail5{
    return _localizedValues[locale.languageCode]['orderdetail5'];
  }

  String get orderdetail6{
    return _localizedValues[locale.languageCode]['orderdetail6'];
  }

  String get orderdetail7{
    return _localizedValues[locale.languageCode]['orderdetail7'];
  }

  String get paymentmethod1{
    return _localizedValues[locale.languageCode]['paymentmethod1'];
  }

  String get paypal{
    return _localizedValues[locale.languageCode]['paypal'];
  }

  String get paystack{
    return _localizedValues[locale.languageCode]['paystack'];
  }

  String get razorpay{
    return _localizedValues[locale.languageCode]['razorpay'];
  }

  String get stripe{
    return _localizedValues[locale.languageCode]['stripe'];
  }

  String get payumoney{
    return _localizedValues[locale.languageCode]['payumoney'];
  }

  String get locpermission{
    return _localizedValues[locale.languageCode]['locpermission'];
  }

  String get locpage1{
    return _localizedValues[locale.languageCode]['locpage1'];
  }

  String get locpage2{
    return _localizedValues[locale.languageCode]['locpage2'];
  }

  String get locpage3{
    return _localizedValues[locale.languageCode]['locpage3'];
  }

  String get inviteNEarn{
    return _localizedValues[locale.languageCode]['Invite n Earn'];
  }
  String get sahreYourCode{
    return _localizedValues[locale.languageCode]['Share your the code below or ask them to enter it during they signup. Earn when your friends signup on our app.'];
  }
  String get codeCpied{
    return _localizedValues[locale.languageCode]['Code Copied'];
  }
  String get tapTOCopy{
    return _localizedValues[locale.languageCode]['Tap to copy'];
  }
  String get generateYourSharedCodeFirst{
    return _localizedValues[locale.languageCode]['Generate your shared code first.'];
  }
  String get inviteFriends{
    return _localizedValues[locale.languageCode]['Invite Friends'];
  }
  String get referEarnText {
    return _localizedValues[locale.languageCode]['referEarnText'];
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ar', 'pt', 'fr', 'id', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of AppLocalizations.
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
