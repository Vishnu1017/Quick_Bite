import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quick_bite/service/database.dart';
import 'package:quick_bite/service/shared_pref.dart';

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

  getthesharedpref() async {
    id = await SharedPreferenceHelper().getUserId();
    wallet = await SharedPreferenceHelper().getUserWallet();
    setState(() {});
  }

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
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          total = 0;
          List<DocumentSnapshot> cartItems = snapshot.data.docs;

          return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: cartItems.length,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = cartItems[index];

                double itemTotal =
                    double.tryParse(ds["Total"].toString()) ?? 0.0;
                total += itemTotal;

                return Stack(
                  children: [
                    // Neon swipe-to-delete background
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [Colors.red[900]!, Colors.red[300]!],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(
                              Icons.delete_forever,
                              color: Colors.white,
                              size: 40,
                            ),
                            const SizedBox(width: 10),
                            const Text(
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
                    ),
                    // Neon glow card with vertical layout
                    Dismissible(
                      key: Key(ds.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) async {
                        await DatabaseMethods().removeItemFromCart(id!, ds.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "${ds["Name"]} removed from cart",
                              style: const TextStyle(fontSize: 18),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );

                        setState(() {
                          foodStream = DatabaseMethods().getFoodCart(id!);
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.blue[600]!, width: 2),
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.blue[50],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Quantity Badge
                                Container(
                                  height: 50,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                    child: Text(
                                      ds["Quantity"],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Food image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    ds["Image"],
                                    height: 60,
                                    width: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Food Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ds["Name"],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "₹${itemTotal.toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[900],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              });
        });
  }

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          title: const Text(
            "My Cart",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blue[700],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
        ),
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "₹${total.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
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
                  double currentWallet = double.parse(wallet!);

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
                    double amount = currentWallet - total;
                    await DatabaseMethods()
                        .UpdateUserWallet(id!, amount.toString());
                    await SharedPreferenceHelper()
                        .saveUserWallet(amount.toString());

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

                    foodStream = DatabaseMethods().getFoodCart(id!);
                    setState(() {});
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
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
