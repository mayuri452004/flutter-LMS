
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login.dart';

class registration extends StatefulWidget {
  const registration({super.key});

  @override
  State<registration> createState() => _registrationState();
}

class _registrationState extends State<registration> {

  // ================= CONTROLLERS =================

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController password = TextEditingController();

  // ================= VARIABLES =================

  String selectedRole = "STUDENT";

  bool isPasswordVisible = false;
  bool isLoading = false;

  // ================= REGISTER METHOD =================

  Future<void> register() async {

    // ---------- NAME VALIDATION ----------

    if (name.text.trim().isEmpty) {
      showError("Please enter your name");
      return;
    }

    if (name.text.trim().length < 3) {
      showError("Name must be at least 3 characters");
      return;
    }

    // ---------- EMAIL VALIDATION ----------

    if (email.text.trim().isEmpty) {
      showError("Please enter your email");
      return;
    }

    final emailPattern =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailPattern.hasMatch(email.text.trim())) {
      showError("Please enter a valid email");
      return;
    }

    // ---------- PHONE VALIDATION ----------

    if (phone.text.trim().isEmpty) {
      showError("Please enter your phone number");
      return;
    }

    if (!RegExp(r'^[0-9]{10}$').hasMatch(phone.text.trim())) {
      showError("Phone number must be exactly 10 digits");
      return;
    }

    // ---------- PASSWORD VALIDATION ----------

    if (password.text.isEmpty) {
      showError("Please enter your password");
      return;
    }

    if (password.text.length < 6) {
      showError("Password must be at least 6 characters");
      return;
    }

    

   

    // ---------- ROLE VALIDATION ----------

    if (selectedRole != "STUDENT" &&
        selectedRole != "ADMIN") {
      showError("Please select a valid role");
      return;
    }

    // ---------- START LOADING ----------

    setState(() {
      isLoading = true;
    });

    try {

      // ================= FIREBASE AUTH =================

      UserCredential userCredential =
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      // Firebase UID
      String uid = userCredential.user!.uid;

      // ================= FIRESTORE =================

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set({

        "name": name.text.trim(),
        "email": email.text.trim(),
        "phone": phone.text.trim(),
        "role": selectedRole,
        "createdAt": FieldValue.serverTimestamp(),

      });

      // ---------- CHECK WIDGET ----------

      if (!mounted) return;

      // ---------- SUCCESS MESSAGE ----------

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Registration successful!",
          ),
          backgroundColor: Colors.green,
        ),
      );

      // ---------- CLEAR FIELDS ----------

      name.clear();
      email.clear();
      phone.clear();
      password.clear();

      // ---------- GO TO LOGIN ----------

      await Future.delayed(
        const Duration(milliseconds: 800),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const loginScreen(),
        ),
      );

    }

    // ================= FIREBASE AUTH ERROR =================

    on FirebaseAuthException catch (e) {

      String message = "Registration failed";

      if (e.code == "email-already-in-use") {

        message =
            "This email is already registered";

      } else if (e.code == "invalid-email") {

        message =
            "Invalid email address";

      } else if (e.code == "weak-password") {

        message =
            "Password is too weak";

      } else if (e.code == "operation-not-allowed") {

        message =
            "Email/password registration is disabled";

      } else if (e.code == "network-request-failed") {

        message =
            "Please check your internet connection";

      }

      if (mounted) {
        showError(message);
      }
    }

    // ================= OTHER ERROR =================

    catch (e) {

      print("Registration Error: $e");

      if (mounted) {
        showError(
          "Something went wrong. Please try again.",
        );
      }
    }

    // ---------- STOP LOADING ----------

    finally {

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ================= ERROR METHOD =================

  void showError(String message) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ================= DISPOSE =================

  @override
  void dispose() {

    name.dispose();
    email.dispose();
    phone.dispose();
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
            vertical: 20,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              // ================= TITLE =================

              const SizedBox(height: 20),

              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1F2937),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Register to get started",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 35),

              // ================= NAME =================

              const Text(
                "Full Name",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: name,

                textCapitalization:
                    TextCapitalization.words,

                decoration: InputDecoration(
                  hintText: "Enter your full name",

                  prefixIcon: const Icon(
                    Icons.person_outline,
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(
                      color: Color(0xff4F46E5),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

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

                keyboardType:
                    TextInputType.emailAddress,

                decoration: InputDecoration(
                  hintText: "Enter your email",

                  prefixIcon: const Icon(
                    Icons.email_outlined,
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(
                      color: Color(0xff4F46E5),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= PHONE =================

              const Text(
                "Phone Number",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: phone,

                keyboardType:
                    TextInputType.phone,

                maxLength: 10,

                decoration: InputDecoration(
                  hintText: "Enter 10 digit phone number",

                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                  ),

                  counterText: "",

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(
                      color: Color(0xff4F46E5),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

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

                obscureText:
                    !isPasswordVisible,

                decoration: InputDecoration(
                  hintText: "Enter password",

                  prefixIcon: const Icon(
                    Icons.lock_outline,
                  ),

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
                    borderRadius:
                        BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(
                      color: Color(0xff4F46E5),
                      width: 2,
                    ),
                  ),
                ),
              ),

           
          
              // ================= ROLE =================

              const Text(
                "Select Role",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [

                  // ---------- STUDENT ----------

                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedRole =
                              "STUDENT";
                        });
                      },

                      borderRadius:
                          BorderRadius.circular(12),

                      child: Container(
                        height: 55,

                        decoration:
                            BoxDecoration(
                          color:
                              selectedRole ==
                                      "STUDENT"
                                  ? const Color(
                                      0xff4F46E5,
                                    )
                                  : Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),

                          border: Border.all(
                            color:
                                const Color(
                              0xff4F46E5,
                            ),
                          ),
                        ),

                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [

                            Icon(
                              Icons.school_outlined,

                              color:
                                  selectedRole ==
                                          "STUDENT"
                                      ? Colors.white
                                      : const Color(
                                          0xff4F46E5,
                                        ),
                            ),

                            const SizedBox(width: 8),

                            Text(
                              "STUDENT",

                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,

                                color:
                                    selectedRole ==
                                            "STUDENT"
                                        ? Colors.white
                                        : const Color(
                                            0xff4F46E5,
                                          ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  // ---------- ADMIN ----------

                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedRole =
                              "ADMIN";
                        });
                      },

                      borderRadius:
                          BorderRadius.circular(12),

                      child: Container(
                        height: 55,

                        decoration:
                            BoxDecoration(
                          color:
                              selectedRole ==
                                      "ADMIN"
                                  ? const Color(
                                      0xff4F46E5,
                                    )
                                  : Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),

                          border: Border.all(
                            color:
                                const Color(
                              0xff4F46E5,
                            ),
                          ),
                        ),

                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [

                            Icon(
                              Icons.admin_panel_settings_outlined,

                              color:
                                  selectedRole ==
                                          "ADMIN"
                                      ? Colors.white
                                      : const Color(
                                          0xff4F46E5,
                                        ),
                            ),

                            const SizedBox(width: 8),

                            Text(
                              "ADMIN",

                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,

                                color:
                                    selectedRole ==
                                            "ADMIN"
                                        ? Colors.white
                                        : const Color(
                                            0xff4F46E5,
                                          ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              // ================= REGISTER BUTTON =================

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : register,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xff4F46E5,
                    ),

                    disabledBackgroundColor:
                        Colors.grey,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),

                  child: isLoading
                      ? const SizedBox(
                          height: 25,
                          width: 25,

                          child:
                              CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 25),

              // ================= LOGIN LINK =================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  const Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),

                  GestureDetector(
                    onTap: () {

                      Navigator.pushReplacement(
                        context,

                        MaterialPageRoute(
                          builder: (_) =>
                              const loginScreen(),
                        ),
                      );
                    },

                    child: const Text(
                      "Login",

                      style: TextStyle(
                        color:
                            Color(0xff4F46E5),
                        fontSize: 15,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
