// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:convert';
// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:quick_bite/service/database.dart';
import 'package:quick_bite/service/shared_pref.dart';
import 'package:quick_bite/widget/app_constant.dart';
import 'package:quick_bite/widget/widget_support.dart';
import 'package:http/http.dart' as http;

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  String? wallet, id;
  int? add;
  TextEditingController amountcontroller = new TextEditingController();

  getthesharedpref() async {
    wallet = await SharedPreferenceHelper().getUserWallet();
    id = await SharedPreferenceHelper().getUserId();
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  Map<String, dynamic>? paymentIntent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              "Wallet",
              style: AppWidget.HeadLineTextFeildStyle(),
            ),
          ],
        ),
        elevation: 5,
      ),
      body: wallet == null
          ? const Center(child: CircularProgressIndicator.adaptive())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF2F2F2),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "images/wallet.png",
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your Wallet",
                            style: AppWidget.LightTextFeildStyle(),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "₹$wallet",
                            style: AppWidget.boldTextFeildStyle(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    "Add Money",
                    style: AppWidget.semiboldTextFeildStyle(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        makePayment('100');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE9E2E2)),
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          "₹100",
                          style: AppWidget.semiboldTextFeildStyle(),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        makePayment('500');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE9E2E2)),
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          "₹500",
                          style: AppWidget.semiboldTextFeildStyle(),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        makePayment('1000');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE9E2E2)),
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          "₹1000",
                          style: AppWidget.semiboldTextFeildStyle(),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        makePayment('2000');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE9E2E2)),
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          "₹2000",
                          style: AppWidget.semiboldTextFeildStyle(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                GestureDetector(
                  onTap: () {
                    openEdit();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: const Color(0xFF008080),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Center(
                      child: Text(
                        "Add Money",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'poppins',
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Future<void> makePayment(String amount) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'INR');
      await Stripe.instance
          .initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret:
                  paymentIntent!['client_secret'], // Fix the key name
              style: ThemeMode.dark,
              merchantDisplayName: 'Vishnu Chandan',
            ),
          )
          .then((value) {});

      displayPaymentSheet(amount);
    } catch (e, s) {
      print('exception: $e$s');
      showSnackBar("Error: $e", context);
    }
  }

  Future<void> displayPaymentSheet(String amount) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        add = (double.parse(wallet!) + double.parse(amount)).toInt();
        await SharedPreferenceHelper().saveUserWallet(add.toString());
        await DatabaseMethods().UpdateUserWallet(id!, add.toString());
        showDialog(
            // ignore: duplicate_ignore
            // ignore: use_build_context_synchronously
            context: context,
            builder: (_) => const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          Text("Payment Successfully"),
                        ],
                      ),
                    ],
                  ),
                ));

        await getthesharedpref();
        paymentIntent = null;
        // ignore: avoid_types_as_parameter_names
      }).onError((error, StackTrace) {
        print("Error is: -------> $error $StackTrace");
      });
    } on StripeException catch (e) {
      print("Error is: -------> $e");
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          content: Text("Cancelled"),
        ),
      );
    } catch (e) {
      print("$e");
    }
  }

  Future<Map<String, dynamic>?> createPaymentIntent(
      String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
        Uri.parse(
            'https://api.stripe.com/v1/payment_intents'), // Fix the URL to HTTPS
        headers: {
          'Authorization': 'Bearer $secretkey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      print("Payment Intent Body->>> ${response.body.toString()}");
      return jsonDecode(response.body);
    } catch (err) {
      print("Error creating payment intent: ${err.toString()}");
    }
    return null;
  }

  String calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount) * 100);
    return calculatedAmount.toString();
  }

  void showSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      message,
      style: TextStyle(fontSize: 18),
    )));
  }

  Future openEdit() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            content: SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.cancel),
                        ),
                        const SizedBox(width: 60),
                        const Center(
                          child: Text(
                            "Add Money",
                            style: TextStyle(
                                color: Color(0xFF008080),
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Amount",
                      style: AppWidget.semiboldTextFeildStyle(),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38, width: 2),
                          borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        controller: amountcontroller,
                        decoration: const InputDecoration(
                            border: InputBorder.none, hintText: "Enter Amount"),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          makePayment(amountcontroller.text);
                        },
                        child: Container(
                          width: 100,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 2, vertical: 10),
                          decoration: BoxDecoration(
                              color: const Color(0xFF008080),
                              borderRadius: BorderRadius.circular(10)),
                          child: const Center(
                            child: Text(
                              "Pay",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ));
}
