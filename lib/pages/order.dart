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
  int total = 0;
  Stream<QuerySnapshot>? foodStream;

  void startTimer() {
    Timer(const Duration(seconds: 2), () {
      setState(() {});
    });
  }

  Future<void> getSharedPref() async {
    id = await SharedPreferenceHelper().getUserId();
    wallet = await SharedPreferenceHelper().getUserWallet();
    setState(() {});
  }

  Future<void> loadData() async {
    await getSharedPref();
    foodStream = DatabaseMethods().getFoodCart(id!);
    total = 0; // Reset total before calculating again
    setState(() {});
  }

  Future<void> clearCart() async {
    if (id != null) {
      await DatabaseMethods().clearUserCart(id!); // Clear the user's cart
      await loadData(); // Refresh data and recalculate total
    }
  }

  Future<void> removeCartItem(String itemId) async {
    await DatabaseMethods()
        .removeCartItem(id!, itemId); // Remove the item from the cart
    recalculateTotal(); // Update the total after removing the item
  }

  void showSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ));
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    if (quantity <= 0) return;
    await DatabaseMethods().updateCartItemQuantity(id!, itemId, quantity);
    recalculateTotal(); // Ensure recalculating after updating quantity
  }

  void recalculateTotal() async {
    total = 0; // Reset total
    if (id != null) {
      final foodItems = await DatabaseMethods().getFoodCart(id!);
      final snapshot = await foodItems.first;
      for (var doc in snapshot.docs) {
        // Debugging: Print the entire document
        print("Document data: ${doc.data()}");

        int quantity = num.tryParse(doc["Quantity"].toString())?.toInt() ?? 1;
        int itemTotal = num.tryParse(doc["Total"].toString())?.toInt() ?? 0;

        // Fallback logic if Total is 0
        if (itemTotal == 0) {
          int price = num.tryParse(doc["Price"].toString())?.toInt() ??
              0; // Ensure price exists
          itemTotal =
              price * quantity; // Calculate total from price and quantity
        }

        total += itemTotal; // Update total price
        print(
            "Item: ${doc["Name"]}, Quantity: $quantity, ItemTotal: $itemTotal");
      }
      print("Total Price: $total");
      setState(() {}); // Update the UI with the new total
    }
  }

  Future<void> placeOrder() async {
    if (wallet != null && total > 0) {
      if (int.tryParse(wallet!)! < total) {
        showSnackBar("Insufficient balance to complete the checkout.", context);
      } else {
        int amount = int.parse(wallet!) - total;
        await DatabaseMethods().UpdateUserWallet(id!, amount.toString());
        await SharedPreferenceHelper().saveUserWallet(amount.toString());

        // Create the order in Firestore
        List<Map<String, dynamic>> cartItems =
            await DatabaseMethods().getCartItems(id!);
        await DatabaseMethods()
            .addOrder(id!, cartItems, total); // Add order to Firestore

        await clearCart(); // Clear the cart after successful checkout
        showSnackBar("Order placed successfully!", context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    loadData();
  }

  Widget foodCart() {
    return StreamBuilder<QuerySnapshot>(
      stream: foodStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data!.docs.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data!.docs[index];
            int quantity = num.tryParse(ds["Quantity"].toString())?.toInt() ??
                1; // Ensure this is an int
            int itemTotal = num.tryParse(ds["Total"].toString())?.toInt() ??
                0; // Ensure total is parsed

            // Fallback logic if Total is 0
            if (itemTotal == 0) {
              int price = num.tryParse(ds["Price"].toString())?.toInt() ??
                  0; // Ensure price exists
              itemTotal =
                  price * quantity; // Calculate total from price and quantity
            }

            return Container(
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      // Quantity Container
                      Container(
                        height: 90,
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                            child: Text(
                                quantity.toString())), // Quantity as string
                      ),
                      const SizedBox(width: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          ds["Image"],
                          height: 90,
                          width: 90,
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
                              style: AppWidget.semiboldTextFeildStyle(),
                            ),
                            Text(
                              "₹${itemTotal * quantity}", // Display total for the item based on quantity
                              style: AppWidget.semiboldTextFeildStyle(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    if (quantity > 1) {
                                      // Decrease the quantity
                                      updateQuantity(ds.id, quantity - 1);
                                    } else {
                                      // Optionally, confirm before removing
                                      removeCartItem(ds
                                          .id); // Remove the item completely from the cart
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    updateQuantity(ds.id, quantity + 1);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
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
              height: MediaQuery.of(context).size.height / 1.6,
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
                    "₹$total", // Display the total price
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
                  await placeOrder(); // Call placeOrder here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
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
