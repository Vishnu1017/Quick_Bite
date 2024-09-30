import 'package:flutter/material.dart';
import 'package:quick_bite/Admin/add_food.dart';
import 'package:quick_bite/Admin/manage_orders.dart';
import 'package:quick_bite/Admin/manage_users.dart';
import 'package:quick_bite/widget/widget_support.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Admin Dashboard",
          style: AppWidget.HeadLineTextFeildStyle(),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Stretch buttons to full width
          children: [
            // Add Food Button
            buildDashboardButton(
              context: context,
              label: "Add Food Items",
              imagePath: "images/food.jpg",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddFood()),
                );
              },
            ),
            const SizedBox(height: 20),
            // Manage Orders Button
            buildDashboardButton(
              context: context,
              label: "Manage Orders",
              imagePath: "images/6243599.jpg",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageOrders()),
                );
              },
            ),
            const SizedBox(height: 20),
            // Manage Users Button
            buildDashboardButton(
              context: context,
              label: "Manage Users",
              imagePath: "images/44658.jpg",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageUsers()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Reusable dashboard button widget
  Widget buildDashboardButton({
    required BuildContext context,
    required String label,
    required String imagePath,
    required VoidCallback onPressed,
  }) {
    return MaterialButton(
      onPressed: onPressed,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.black,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(
                imagePath,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 40),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
