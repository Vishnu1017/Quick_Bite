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
    double iconSize =
        MediaQuery.of(context).size.width * 0.075; // Dynamic icon size
    double navBarHeight = MediaQuery.of(context).size.height * 0.09;

    // Ensure the height doesn't exceed 75.0
    navBarHeight = navBarHeight > 75.0 ? 75.0 : navBarHeight;

    return Scaffold(
      body: currentPage, // Display the current page
      bottomNavigationBar: CurvedNavigationBar(
        height: navBarHeight, // Height limited to 75
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
          _buildNavIcon(Icons.home, 0, iconSize),
          _buildNavIcon(Icons.shopping_cart, 1, iconSize),
          _buildNavIcon(Icons.wallet, 2, iconSize),
          _buildNavIcon(Icons.person, 3, iconSize),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, double iconSize) {
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
          padding: EdgeInsets.all(
              MediaQuery.of(context).size.width * 0.02), // Dynamic padding
          child: Icon(
            icon,
            size: iconSize, // Dynamic icon size
            color: currentTabIndex == index ? Colors.blueAccent : Colors.white,
          ),
        ),
      ),
    );
  }
}
