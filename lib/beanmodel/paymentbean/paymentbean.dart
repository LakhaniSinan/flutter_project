class PaymentMain{

  dynamic status;
  dynamic message;
  RazorPayBean razorpay;
  PayPalBean paypal;
  StripeBean stripe;
  PaystackBean paystack;

  PaymentMain(this.status, this.message, this.razorpay, this.paypal,
      this.stripe, this.paystack);

  factory PaymentMain.fromJson(dynamic json){
    RazorPayBean razorPayBean = RazorPayBean.fromJson(json['razorpay']);
    PayPalBean paypalBean = PayPalBean.fromJson(json['paypal']);
    StripeBean stripeBean = StripeBean.fromJson(json['stripe']);
    PaystackBean paystackBean = PaystackBean.fromJson(json['paystack']);
    return PaymentMain(json['status'], json['message'], razorPayBean, paypalBean, stripeBean, paystackBean);
  }

  @override
  String toString() {
    return '{status: $status, message: $message, razorpay: $razorpay, paypal: $paypal, stripe: $stripe, paystack: $paystack}';
  }
}

class RazorPayBean{
  dynamic razorpay_status;
  dynamic razorpay_secret;
  dynamic razorpay_key;

  RazorPayBean(this.razorpay_status, this.razorpay_secret, this.razorpay_key);

  factory RazorPayBean.fromJson(dynamic json){
    return RazorPayBean(json['razorpay_status'], json['razorpay_secret'], json['razorpay_key']);
  }

  @override
  String toString() {
    return '{razorpay_status: $razorpay_status, razorpay_secret: $razorpay_secret, razorpay_key: $razorpay_key}';
  }
}

class PaystackBean{
  dynamic paystack_status;
  dynamic paystack_public_key;
  dynamic paystack_secret_key;

  PaystackBean(this.paystack_status, this.paystack_public_key, this.paystack_secret_key);

  factory PaystackBean.fromJson(dynamic json){
    return PaystackBean(json['paystack_status'], json['paystack_public_key'], json['paystack_secret_key']);
  }

  @override
  String toString() {
    return '{razorpay_status: $paystack_status, razorpay_secret: $paystack_public_key, razorpay_key: $paystack_secret_key}';
  }
}

class PayPalBean{
  dynamic paypal_status;
  dynamic paypal_client_id;
  dynamic paypal_secret;

  PayPalBean(this.paypal_status, this.paypal_client_id, this.paypal_secret);

  factory PayPalBean.fromJson(dynamic json){
    return PayPalBean(json['paypal_status'], json['paypal_client_id'], json['paypal_secret']);
  }

  @override
  String toString() {
    return '{razorpay_status: $paypal_status, razorpay_secret: $paypal_client_id, razorpay_key: $paypal_secret}';
  }
}

class StripeBean{
  dynamic stripe_status;
  dynamic stripe_secret;
  dynamic stripe_publishable;
  dynamic stripe_merchant_id;

  StripeBean(this.stripe_status, this.stripe_secret, this.stripe_publishable,this.stripe_merchant_id);

  factory StripeBean.fromJson(dynamic json){
    return StripeBean(json['stripe_status'], json['stripe_secret'], json['stripe_publishable'], json['stripe_merchant_id']);
  }

  @override
  String toString() {
    return '{razorpay_status: $stripe_status, razorpay_secret: $stripe_secret, razorpay_key: $stripe_publishable, stripe_merchant_id: $stripe_merchant_id}';
  }
}