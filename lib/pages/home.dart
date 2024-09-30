import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quick_bite/pages/details.dart';
import 'package:quick_bite/pages/order.dart' as order_page;
import 'package:quick_bite/service/database.dart';
import 'package:quick_bite/service/shared_pref.dart';
import 'package:quick_bite/widget/widget_support.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool icecream = false, pizza = false, salad = false, burger = false;
  Stream? fooditemStream;
  String? name, id;
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  void ontheload() async {
    id = await SharedPreferenceHelper().getUserId();
    name = await SharedPreferenceHelper().getUserName();
    updateCartCount(); // Update cart count after getting user ID
    fooditemStream = await DatabaseMethods().getFoodItem("Salad");
    setState(() {});
  }

  void updateCartCount() async {
    Stream cartStream = await DatabaseMethods().getFoodCart(id!);
    cartStream.listen((snapshot) {
      setState(() {
        _cartItemCount = snapshot.docs.length; // Update the count
      });
    });
  }

  Widget allItemsVertically() {
    return StreamBuilder(
        stream: fooditemStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Details(
                                      detail: ds["Detail"],
                                      name: ds["Name"],
                                      image: ds["Image"],
                                      price: ds["Price"],
                                    )));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 30),
                        child: Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    ds["Image"],
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  children: [
                                    Container(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      child: Text(
                                        ds["Name"],
                                        style:
                                            AppWidget.semiboldTextFeildStyle(),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      child: Text(
                                        "Honey goot cheese",
                                        style: AppWidget.LightTextFeildStyle(),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      child: Text(
                                        "₹${ds["Price"]}",
                                        style:
                                            AppWidget.semiboldTextFeildStyle(),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  })
              : Center(child: CircularProgressIndicator.adaptive());
        });
  }

  Widget allItems() {
    return StreamBuilder(
        stream: fooditemStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Details(
                                      detail: ds["Detail"],
                                      name: ds["Name"],
                                      image: ds["Image"],
                                      price: ds["Price"],
                                    )));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(
                            right: 10, left: 10, bottom: 10),
                        child: Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    ds["Image"],
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  ds["Name"],
                                  style: AppWidget.semiboldTextFeildStyle(),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Fresh and Healthy",
                                  style: AppWidget.LightTextFeildStyle(),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "₹${ds["Price"]}",
                                  style: AppWidget.semiboldTextFeildStyle(),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  })
              : Center(child: CircularProgressIndicator.adaptive());
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Hello $name,", style: AppWidget.boldTextFeildStyle()),
            Stack(
              children: [
                IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        Icon(Icons.shopping_cart_outlined, color: Colors.white),
                  ),
                  onPressed: () {
                    // Reset the cart item count to zero (optional logic based on your app)
                    setState(() {
                      _cartItemCount = 0; // Hide the badge
                    });

                    // Navigate to the Order page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const order_page.Order(),
                      ),
                    );
                  },
                ),
                if (_cartItemCount >
                    0) // Only show the badge if count is greater than 0
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        '$_cartItemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Delicious Food",
                style: AppWidget.HeadLineTextFeildStyle(),
              ),
              Text(
                "Discover and Get Great Food",
                style: AppWidget.LightTextFeildStyle(),
              ),
              const SizedBox(height: 20),
              showItem(),
              const SizedBox(height: 30),
              SizedBox(height: 300, child: allItems()),
              const SizedBox(height: 30),
              allItemsVertically(),
            ],
          ),
        ),
      ),
    );
  }

  Widget showItem() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () async {
            icecream = true;
            pizza = false;
            salad = false;
            burger = false;
            fooditemStream = await DatabaseMethods().getFoodItem("Ice-cream");
            setState(() {});
          },
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: icecream ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                "images/ice-cream.png",
                height: 40,
                width: 40,
                fit: BoxFit.cover,
                color: icecream ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            icecream = false;
            pizza = true;
            salad = false;
            burger = false;
            fooditemStream = await DatabaseMethods().getFoodItem("Pizza");
            setState(() {});
          },
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: pizza ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                "images/pizza.png",
                height: 40,
                width: 40,
                fit: BoxFit.cover,
                color: pizza ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            icecream = false;
            pizza = false;
            salad = true;
            burger = false;
            fooditemStream = await DatabaseMethods().getFoodItem("Salad");
            setState(() {});
          },
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: salad ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                "images/salad.png",
                height: 40,
                width: 40,
                fit: BoxFit.cover,
                color: salad ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            icecream = false;
            pizza = false;
            salad = false;
            burger = true;
            fooditemStream = await DatabaseMethods().getFoodItem("Burger");
            setState(() {});
          },
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: burger ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                "images/burger.png",
                height: 40,
                width: 40,
                fit: BoxFit.cover,
                color: burger ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
