import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quick_bite/widget/widget_support.dart';

class ManageOrders extends StatelessWidget {
  const ManageOrders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Orders',
          style: AppWidget.HeadLineTextFeildStyle(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          // Debugging: Check if data is received
          if (snapshot.connectionState == ConnectionState.active) {
            print('Connection state is active');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            print('Waiting for data...');
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('Error fetching orders: ${snapshot.error}');
            return const Center(child: Text('Error fetching orders'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print('No orders found');
            return const Center(child: Text('No orders found'));
          }

          final orders = snapshot.data!.docs;
          print('Orders retrieved: ${orders.length}');

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;

              // Debugging: Check order data
              print('Order ${index + 1}: $order');

              final String userId = order['userId'];
              print('Fetching user data for userId: $userId');

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!userSnapshot.hasData || userSnapshot.data == null) {
                    print('User data not found for userId: $userId');
                    return const Text('User data not found');
                  }

                  if (userSnapshot.hasError) {
                    print('Error fetching user data: ${userSnapshot.error}');
                    return const Text('Error fetching user data');
                  }

                  final user =
                      userSnapshot.data!.data() as Map<String, dynamic>;

                  // Debugging: Check user data
                  print('User: $user');

                  return ListTile(
                    title: Text('Order ID: ${order['Cart']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('User: ${user['Name']}'),
                        Text('Total Price: \$${order['Total']}'),
                      ],
                    ),
                    trailing: Text(order['status']),
                    onTap: () {
                      // Navigate to order details or update status
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
