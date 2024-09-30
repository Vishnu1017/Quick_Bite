import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quick_bite/service/database.dart';
import 'package:quick_bite/widget/widget_support.dart';

class ManageUsers extends StatelessWidget {
  const ManageUsers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Users',
          style: AppWidget.HeadLineTextFeildStyle(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseMethods().getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Error fetching users: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userDoc = users[index]; // Document snapshot
              final user = userDoc.data() as Map<String, dynamic>;

              // Debugging: Log user data
              print('User Data: $user');

              return Card(
                elevation: 4,
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(
                            user['profileImage'] ?? '',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: user['profileImage'] == null ||
                              user['profileImage'] == ''
                          ? const CircleAvatar(
                              backgroundColor: Colors.blueGrey,
                              child: Icon(Icons.person, color: Colors.white),
                            )
                          : null,
                    ),
                    title: Text(
                      user['Name'] ?? 'No Name',
                      style: AppWidget.boldTextFeildStyle(),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['Email'] ?? 'No Email',
                          style: AppWidget.LightTextFeildStyle(),
                        ),
                        Text(
                          user['PhoneNumber'] ?? 'No Phone Number',
                          style: AppWidget.LightTextFeildStyle(),
                        ),
                        Text(
                          user['Address'] ?? 'No Address',
                          style: AppWidget.LightTextFeildStyle(),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _showEditDialog(context, userDoc.id, user);
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, String userId, Map<String, dynamic> user) {
    final TextEditingController nameController =
        TextEditingController(text: user['Name']);
    final TextEditingController emailController =
        TextEditingController(text: user['Email']);
    final TextEditingController phoneController =
        TextEditingController(text: user['PhoneNumber']);
    final TextEditingController addressController =
        TextEditingController(text: user['Address']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit User Info'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without saving
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateUser(
                  userId,
                  nameController.text,
                  emailController.text,
                  phoneController.text,
                  addressController.text,
                );
                Navigator.of(context).pop(); // Close dialog after saving
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _updateUser(String userId, String newName, String newEmail,
      String newPhone, String newAddress) {
    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'Name': newName,
      'Email': newEmail,
      'PhoneNumber': newPhone,
      'Address': newAddress,
    }).then((_) {
      print('User updated successfully');
    }).catchError((error) {
      print('Failed to update user: $error');
    });
  }
}
