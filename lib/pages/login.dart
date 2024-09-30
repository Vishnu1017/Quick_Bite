import 'package:firebase_auth/firebase_auth.dart';
// ignore: unused_import
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quick_bite/Admin/admin_login.dart';
import 'package:quick_bite/pages/bottomnav.dart';
import 'package:quick_bite/pages/forgotpassword.dart';
import 'package:quick_bite/pages/signup.dart';
import 'package:quick_bite/service/database.dart';
import 'package:quick_bite/service/shared_pref.dart';
import 'package:quick_bite/widget/widget_support.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String email = '', password = '';
  bool _isPasswordVisible = false;

  final _formkey = GlobalKey<FormState>();

  TextEditingController useremailcontroller = new TextEditingController();
  TextEditingController userpasswordcontroller = new TextEditingController();

  userLogin() async {
    // Check if email and password are not empty
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.orangeAccent,
        content: Text(
          "Email and password cannot be empty",
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
      ));
      return; // Exit the method if validation fails
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Login Successfully",
            style: TextStyle(fontSize: 20),
          )));

      // Retrieve user ID
      String userId = userCredential.user!.uid;

      // Fetch user details from Firestore
      Map<String, dynamic>? userDetails =
          await DatabaseMethods().getUserDetails(userId);
      if (userDetails != null) {
        // Store user info in shared preferences
        await SharedPreferenceHelper().saveUserName(userDetails["Name"]);
        await SharedPreferenceHelper().saveUserEmail(userDetails["Email"]);
        await SharedPreferenceHelper().saveUserWallet(userDetails["Wallet"]);
        await SharedPreferenceHelper().saveUserId(userId);
      }

      // Navigate to BottomNav page
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const BottomNav()));
    } on FirebaseAuthException catch (e) {
      // Check for specific error codes
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "User not found",
              style: TextStyle(fontSize: 18, color: Colors.black),
            )));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Wrong password provided by user",
              style: TextStyle(fontSize: 18, color: Colors.black),
            )));
      } else {
        // Handle other potential errors
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              e.message ?? "An error occurred",
              style: TextStyle(fontSize: 18, color: Colors.black),
            )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2.5,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF42a5f5), Color(0xFF1e88e5)])),
            ),
            Container(
              margin:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
              height: MediaQuery.of(context).size.height / 1.85,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
              child: const Text(""),
            ),
            Container(
              margin: const EdgeInsets.only(top: 55, right: 20, left: 20),
              child: Form(
                key: _formkey,
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        "images/logo.png",
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width / 1.5,
                      ),
                    ),
                    const SizedBox(height: 50),
                    Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 2,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            Text("Login",
                                style: AppWidget.HeadLineTextFeildStyle()),
                            const SizedBox(height: 40),
                            TextFormField(
                              controller: useremailcontroller,
                              decoration: InputDecoration(
                                hintText: "Email",
                                hintStyle: AppWidget.semiboldTextFeildStyle(),
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an email';
                                } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),
                            TextFormField(
                              controller: userpasswordcontroller,
                              obscureText:
                                  !_isPasswordVisible, // Control visibility
                              decoration: InputDecoration(
                                hintText: "Password",
                                hintStyle: AppWidget.semiboldTextFeildStyle(),
                                prefixIcon: const Icon(Icons.password_outlined),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: const Color(
                                        0xFF42a5f5), // Change color as needed
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible =
                                          !_isPasswordVisible; // Toggle visibility
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                } else if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ForgotPassword()));
                              },
                              child: Container(
                                alignment: Alignment.topRight,
                                child: Text("Forget password?",
                                    style: AppWidget.semiboldTextFeildStyle()),
                              ),
                            ),
                            const SizedBox(height: 80),
                            ElevatedButton(
                              onPressed: () {
                                if (_formkey.currentState!.validate()) {
                                  setState(() {
                                    email = useremailcontroller.text;
                                    password = userpasswordcontroller.text;
                                  });
                                  userLogin();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 60),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                backgroundColor:
                                    const Color(0xFF42a5f5), // Background color
                              ),
                              child: const Text(
                                "LOGIN",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w700),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 70),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppWidget.semiboldTextFeildStyle(),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUp()),
                            );
                          },
                          child: Text(
                            "Sign Up",
                            style: AppWidget.semiboldTextFeildStyle().copyWith(
                              color: Colors
                                  .blue, // Optional: change color for emphasis
                              fontWeight:
                                  FontWeight.bold, // Optional: make it bold
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Are you an admin? ",
                          style: AppWidget.semiboldTextFeildStyle(),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AdminLogin(), // Admin Login page
                              ),
                            );
                          },
                          child: Text(
                            "Admin Login",
                            style: AppWidget.semiboldTextFeildStyle().copyWith(
                              color: const Color.fromARGB(255, 10, 135,
                                  237), // Change color for emphasis
                              fontWeight: FontWeight.bold, // Make it bold
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
