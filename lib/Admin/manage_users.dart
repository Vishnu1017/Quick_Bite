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
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
          ),
        ),
        backgroundColor: Colors.blueAccent,
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

              return _buildUserCard(context, userDoc.id, user);
            },
          );
        },
      ),
    );
  }

  Widget _buildUserCard(
      BuildContext context, String userId, Map<String, dynamic> user) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          leading: _buildUserImage(user),
          title: Text(
            user['Name'] ?? 'No Name',
            style: AppWidget.boldTextFeildStyle().copyWith(fontSize: 18),
          ),
          subtitle: _buildUserDetails(user),
          trailing: _buildUserActions(context, userId, user),
        ),
      ),
    );
  }

  Widget _buildUserImage(Map<String, dynamic> user) {
    return Container(
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
      child: user['profileImage'] == null || user['profileImage'] == ''
          ? const CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.person, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildUserDetails(Map<String, dynamic> user) {
    return Column(
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
    );
  }

  Widget _buildUserActions(
      BuildContext context, String userId, Map<String, dynamic> user) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () {
            _showEditDialog(context, userId, user);
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            _showDeleteConfirmationDialog(context, userId);
          },
        ),
      ],
    );
  }

  void _showEditDialog(
      BuildContext context, String userId, Map<String, dynamic> user) {
    final _formKey = GlobalKey<FormState>(); // Form key for validation
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
          title: Row(
            children: [
              const Icon(Icons.edit, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('Edit User Info'),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey, // Wrap content with Form
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(nameController, 'Name', Icons.person),
                  const SizedBox(height: 10),
                  _buildTextField(emailController, 'Email', Icons.email,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 10),
                  _buildTextField(phoneController, 'Phone Number', Icons.phone,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 10),
                  _buildTextField(addressController, 'Address', Icons.home),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without saving
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // Text color
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _updateUser(
                    userId,
                    nameController.text,
                    emailController.text,
                    phoneController.text,
                    addressController.text,
                  );
                  Navigator.of(context).pop(); // Close dialog after saving
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 8),
              const Text('Confirm Deletion'),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete this user? This action cannot be undone.',
            style: TextStyle(color: Colors.black54),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red, // Text color
              ),
              onPressed: () {
                _deleteUser(userId);
                Navigator.of(context).pop(); // Close dialog after deletion
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(String userId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .delete()
        .then((_) {
      print('User deleted successfully');
    }).catchError((error) {
      print('Failed to delete user: $error');
    });
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
