import 'package:firebase_auth/firebase_auth.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Method to get the current user
  Future<User?> getCurrentUser() async {
    return auth.currentUser;
  }

  // New method to get the current user's ID
  String getCurrentUserId() {
    User? user = auth.currentUser; // Get the current user
    return user != null ? user.uid : ''; // Return user ID or empty string
  }

  // Method to sign out
  Future<void> SignOut() async {
    await auth.signOut();
  }

  // Method to delete user account
  Future<void> deleteuser() async {
    User? user = auth.currentUser;
    await user?.delete();
  }
}
