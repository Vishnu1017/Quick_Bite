import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quick_bite/pages/bottomnav.dart';
import 'package:quick_bite/pages/login.dart';
import 'package:quick_bite/service/database.dart';
import 'package:quick_bite/service/shared_pref.dart';
import 'package:quick_bite/widget/widget_support.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = "", password = "", name = "";
  bool _isObscure = true; // Initial password visibility state

  TextEditingController namecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  Future<void> registration() async {
    if (password.isNotEmpty) {
      try {
        // Create user with email and password
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Registered Successfully",
              style: TextStyle(fontSize: 20),
            )));

        String userId = userCredential.user!.uid; // Use the generated user ID
        Map<String, dynamic> addUserInfo = {
          "Name": namecontroller.text, // Correctly using text from controller
          "Email": emailcontroller.text,
          "Wallet": "0",
          "Id": userId,
        };

        // Store data in Firestore
        await DatabaseMethods().addUserDetail(addUserInfo, userId);

        // Fetch user details and store them in shared preferences
        Map<String, dynamic>? userDetails =
            await DatabaseMethods().getUserDetails(userId);
        if (userDetails != null) {
          await SharedPreferenceHelper().saveUserName(userDetails["Name"]);
          await SharedPreferenceHelper().saveUserEmail(userDetails["Email"]);
          await SharedPreferenceHelper().saveUserWallet(userDetails["Wallet"]);
          await SharedPreferenceHelper().saveUserId(userId);
        }

        // Navigate to BottomNav page
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const BottomNav()));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Password Provided is too weak",
                style: TextStyle(fontSize: 18),
              )));
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Account Already exists",
                style: TextStyle(fontSize: 18),
              )));
        }
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
              height: MediaQuery.of(context).size.height / 1.9,
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
                      height: MediaQuery.of(context).size.height / 1.8,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      child: Form(
                        key: _formkey,
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            Text("Sign Up",
                                style: AppWidget.HeadLineTextFeildStyle()),
                            const SizedBox(height: 40),
                            TextFormField(
                              controller: namecontroller,
                              decoration: InputDecoration(
                                hintText: "Full Name",
                                hintStyle: AppWidget.semiboldTextFeildStyle(),
                                prefixIcon: const Icon(Icons.person_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),
                            TextFormField(
                              controller: emailcontroller,
                              decoration: InputDecoration(
                                hintText: "Email",
                                hintStyle: AppWidget.semiboldTextFeildStyle(),
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                final emailRegex =
                                    RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                if (!emailRegex.hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),
                            TextFormField(
                              controller: passwordcontroller,
                              obscureText: _isObscure, // Control the visibility
                              decoration: InputDecoration(
                                hintText: "Password",
                                hintStyle: AppWidget.semiboldTextFeildStyle(),
                                prefixIcon: const Icon(Icons.password_outlined),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isObscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: const Color(0xFF42a5f5),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isObscure = !_isObscure;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters long';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 70),
                            ElevatedButton(
                              onPressed: () {
                                if (_formkey.currentState!.validate()) {
                                  setState(() {
                                    name = namecontroller.text;
                                    email = emailcontroller.text;
                                    password = passwordcontroller.text;
                                  });
                                  registration();
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
                                "SIGN UP",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: AppWidget.semiboldTextFeildStyle(),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LogIn()),
                          );
                        },
                        child: Text(
                          "Login",
                          style: AppWidget.semiboldTextFeildStyle().copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
