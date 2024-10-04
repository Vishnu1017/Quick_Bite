import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quick_bite/service/database.dart';
import 'package:quick_bite/service/shared_pref.dart';
import 'package:quick_bite/widget/widget_support.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  String? id, wallet;
  double total = 0.0;
  Stream? foodStream;

  void startTimer() {
    Timer(Duration(milliseconds: 50), () {
      setState(() {});
    });
  }

  // Get user ID and wallet balance from shared preferences
  getthesharedpref() async {
    id = await SharedPreferenceHelper().getUserId();
    wallet = await SharedPreferenceHelper().getUserWallet();
    setState(() {});
  }

  // Load the food cart from the database
  ontheload() async {
    await getthesharedpref();
    foodStream = DatabaseMethods().getFoodCart(id!);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ontheload();
    startTimer();
  }

  Widget foodCart() {
    return StreamBuilder(
        stream: foodStream,
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator.adaptive());
          }

          // Reset total for new calculation
          total = 0;
          List<DocumentSnapshot> cartItems = snapshot.data.docs;

          return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: cartItems.length,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = cartItems[index];

                // Calculate item total here
                double itemTotal =
                    double.tryParse(ds["Total"].toString()) ?? 0.0;
                total += itemTotal; // Update overall total here

                return Dismissible(
                  key: Key(ds.id),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.redAccent, Colors.red],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 36,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Remove',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) async {
                    // Remove item from Firestore
                    await DatabaseMethods().removeItemFromCart(id!, ds.id);

                    // Show a snackbar for feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "${ds["Name"]} removed from cart",
                          style: TextStyle(fontSize: 18),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );

                    setState(() {
                      foodStream = DatabaseMethods().getFoodCart(id!);
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300), // Animation duration
                    curve: Curves.easeInOut, // Animation curve
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.teal, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Quantity Container with a unique design
                            Container(
                              height: 70,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.teal,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  ds["Quantity"],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Diamond-shaped image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                ds["Image"],
                                height: 70,
                                width: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ds["Name"],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "₹${itemTotal.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.teal[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
        });
  }

  // New method to clear all items from the cart
  Future<void> clearCart() async {
    if (foodStream != null) {
      QuerySnapshot cartSnapshot =
          await DatabaseMethods().getFoodCartSnapshot(id!);
      for (DocumentSnapshot ds in cartSnapshot.docs) {
        await DatabaseMethods().removeItemFromCart(id!, ds.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              "Food Cart",
              style: AppWidget.HeadLineTextFeildStyle(),
            ),
          ],
        ),
        elevation: 5,
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.55,
              child: foodCart(),
            ),
            const Spacer(),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Price",
                    style: AppWidget.boldTextFeildStyle(),
                  ),
                  Text(
                    "₹${total.toStringAsFixed(2)}",
                    style: AppWidget.semiboldTextFeildStyle(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 35),
              child: ElevatedButton(
                onPressed: () async {
                  double currentWallet =
                      double.parse(wallet!); // Get the current wallet balance

                  if (currentWallet < total) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Insufficient balance. Please recharge your wallet.",
                          style: TextStyle(fontSize: 18),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    double amount =
                        currentWallet - total; // Calculate the new balance
                    await DatabaseMethods()
                        .UpdateUserWallet(id!, amount.toString());
                    await SharedPreferenceHelper()
                        .saveUserWallet(amount.toString());

                    // Clear the cart items after checkout
                    await clearCart();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Checkout successful! Your new balance is ₹${amount.toStringAsFixed(2)}",
                          style: TextStyle(fontSize: 18),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Refresh the food cart
                    foodStream = DatabaseMethods().getFoodCart(id!);
                    setState(() {});
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  "CheckOut",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
