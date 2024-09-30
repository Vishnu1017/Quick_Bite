import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:quick_bite/pages/home.dart';
import 'package:quick_bite/pages/order.dart';
import 'package:quick_bite/pages/profile.dart';
import 'package:quick_bite/pages/wallet.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav>
    with SingleTickerProviderStateMixin {
  int currentTabIndex = 0;

  late List<Widget> pages;
  late Widget currentPage;
  late Home homepage;
  late Profile profile;
  late Wallet wallet;
  late Order order;

  @override
  void initState() {
    super.initState();
    homepage = const Home();
    order = Order();
    profile = const Profile();
    wallet = const Wallet();
    pages = [homepage, order, wallet, profile];
    currentPage = homepage; // Initialize the currentPage with homepage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentPage, // Display the current page
      bottomNavigationBar: CurvedNavigationBar(
        height: 70,
        backgroundColor: Colors.transparent,
        color: Colors.blueAccent, // Navigation bar color
        animationDuration: const Duration(milliseconds: 300),
        onTap: (int index) {
          setState(() {
            currentTabIndex = index;
            currentPage =
                pages[currentTabIndex]; // Update currentPage on tab change
          });
        },
        items: [
          _buildNavIcon(Icons.home, 0),
          _buildNavIcon(Icons.shopping_cart, 1),
          _buildNavIcon(Icons.wallet, 2),
          _buildNavIcon(Icons.person, 3),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    return AnimatedScale(
      scale: currentTabIndex == index
          ? 1.2
          : 1.0, // Scale effect for the selected icon
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          color:
              currentTabIndex == index ? Colors.blue[100] : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            if (currentTabIndex == index)
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8.0,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Padding around the icon
          child: Icon(
            icon,
            size: 30, // Slightly larger icon size
            color: currentTabIndex == index
                ? Colors.blueAccent
                : const Color.fromARGB(223, 255, 255, 255),
          ),
        ),
      ),
    );
  }
}
