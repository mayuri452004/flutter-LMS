import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lms/adminHome.dart';
import 'package:lms/userDashboard.dart';
import 'package:lms/userHome.dart';

import 'registration.dart';

class loginScreen extends StatefulWidget {
  const loginScreen({super.key});

  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  // Controllers
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  // Password visibility
  bool isPasswordVisible = false;

  // ================= LOGIN METHOD =================
Future<void> login() async {
  if (email.text.trim().isEmpty) {
    showError("Please enter your email");
    return;
  }

  if (password.text.isEmpty) {
    showError("Please enter your password");
    return;
  }

  try {
    // ==============================
    // Firebase Authentication
    // ==============================
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.text.trim(),
      password: password.text.trim(),
    );

    // ==============================
    // Firebase UID
    // ==============================
    String uid = userCredential.user!.uid;

    print("LOGIN SUCCESS");
    print("UID: $uid");

    // ==============================
    // Get User Data From Firestore
    // ==============================
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .get();

    if (!userDoc.exists) {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      showError("User data not found in Firestore");
      return;
    }

    // ==============================
    // Get Role
    // ==============================
    Map<String, dynamic> data = userDoc.data()!;

    String role = data["role"] ?? "";

    print("USER DATA: $data");
    print("USER ROLE: $role");

    // ==============================
    // Clear Fields
    // ==============================
    email.clear();
    password.clear();

    if (!mounted) return;

    // ==============================
    // STUDENT
    // ==============================
    if (role == "STUDENT") {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>UserHome(),
        ),
        (route) => false,
      );

      return;
    }

    // ==============================
    // ADMIN
    // ==============================
    if (role == "ADMIN") {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => AdminHome(),
        ),
        (route) => false,
      );

      return;
    }

    // ==============================
    // Invalid Role
    // ==============================
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    showError("Invalid user role");
  } on FirebaseAuthException catch (e) {
    String message = "Login failed";

    if (e.code == "user-not-found") {
      message = "No account found with this email";
    } else if (e.code == "wrong-password") {
      message = "Incorrect password";
    } else if (e.code == "invalid-credential") {
      message = "Invalid email or password";
    } else if (e.code == "invalid-email") {
      message = "Invalid email address";
    } else if (e.code == "user-disabled") {
      message = "This account has been disabled";
    }

    showError(message);
  } catch (e) {
    print("LOGIN ERROR: $e");

    if (!mounted) return;

    showError(
      "Something went wrong. Please try again.",
    );
  }
}


  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ================= DISPOSE =================

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FF),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 40,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ================= TITLE =================

              const SizedBox(height: 30),

              const Text(
                "Welcome Back!",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1F2937),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Login to continue to your account",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 45),

              // ================= EMAIL =================

              const Text(
                "Email",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,

                decoration: InputDecoration(
                  hintText: "Enter your email",
                  prefixIcon: const Icon(Icons.email_outlined),

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xff4F46E5),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ================= PASSWORD =================

              const Text(
                "Password",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: password,

                obscureText: !isPasswordVisible,

                decoration: InputDecoration(
                  hintText: "Enter your password",

                  prefixIcon: const Icon(
                    Icons.lock_outline,
                  ),

                  // Show / Hide Password
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),

                    onPressed: () {
                      setState(() {
                        isPasswordVisible =
                            !isPasswordVisible;
                      });
                    },
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xff4F46E5),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // ================= LOGIN BUTTON =================

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed: login,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff4F46E5),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  child: const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ================= REGISTER =================

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const registration(),
                        ),
                      );
                    },

                    child: const Text(
                      "Register",
                      style: TextStyle(
                        color: Color(0xff4F46E5),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}