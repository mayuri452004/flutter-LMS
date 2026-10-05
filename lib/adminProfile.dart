import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? adminData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAdminProfile();
  }

  Future<void> loadAdminProfile() async {
    try {
      final User? user = _auth.currentUser;

      if (user == null) {
        return;
      }

      final DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection("users").doc(user.uid).get();

      if (!mounted) return;

      if (doc.exists) {
        setState(() {
          adminData = doc.data();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Admin Profile Error: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    await _auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const loginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name = adminData?["name"] ?? "Admin";
    final String email = adminData?["email"] ?? "-";
    final String phone = adminData?["phone"] ?? "-";
    final String role = adminData?["role"] ?? "ADMIN";

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),

      appBar: AppBar(
        title: const Text(
          "Admin Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [

                  // PROFILE IMAGE
                  const CircleAvatar(
                    radius: 55,
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 60,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // NAME
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // ROLE
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.red.withOpacity(0.1),
                    ),
                    child: Text(
                      role,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // EMAIL
                  profileItem(
                    icon: Icons.email,
                    title: "Email",
                    value: email,
                  ),

                  const SizedBox(height: 15),

                  // PHONE
                  profileItem(
                    icon: Icons.phone,
                    title: "Phone",
                    value: phone,
                  ),

                  const SizedBox(height: 15),

                  // ROLE
                  profileItem(
                    icon: Icons.security,
                    title: "Role",
                    value: role,
                  ),

                  const SizedBox(height: 35),

                  // LOGOUT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: logout,
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget profileItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            color: Colors.black.withOpacity(0.08),
          ),
        ],
      ),

      child: Row(
        children: [

          CircleAvatar(
            backgroundColor: Colors.red.withOpacity(0.1),
            child: Icon(
              icon,
              color: Colors.red,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}