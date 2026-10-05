
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class userProfile extends StatefulWidget {
  const userProfile({super.key});

  @override
  State<userProfile> createState() => _userProfileState();
}

class _userProfileState extends State<userProfile> {
  bool isLoading = true;

  String name = "";
  String email = "";
  String phone = "";
  String role = "";

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  Future<void> getProfile() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .get();

      if (userDoc.exists) {
        final data = userDoc.data();

        if (!mounted) return;

        setState(() {
          name = data?["name"] ?? "";
          email = data?["email"] ?? user.email ?? "";
          phone = data?["phone"] ?? "";
          role = data?["role"] ?? "STUDENT";
          isLoading = false;
        });
      } else {
        if (!mounted) return;

        setState(() {
          email = user.email ?? "";
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Profile Error: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> logout()async{
   await FirebaseAuth.instance.signOut();
  }

  String getInitials() {
    if (name.trim().isEmpty) {
      return "S";
    }

    final List<String> words = name.trim().split(" ");

    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }

    return "${words[0][0]}${words[1][0]}".toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "My Profile",
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xff4F46E5),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  // ================= PROFILE HEADER =================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [

                        // Profile Avatar
                        Container(
                          width: 95,
                          height: 95,
                          decoration: const BoxDecoration(
                            color: Color(0xffEEF2FF),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              getInitials(),
                              style: const TextStyle(
                                color: Color(0xff4F46E5),
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Name
                        Text(
                          name.isEmpty ? "Student" : name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        // Email
                        Text(
                          email,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Role
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffEEF2FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            role,
                            style: const TextStyle(
                              color: Color(0xff4F46E5),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= PERSONAL INFORMATION =================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Personal Information",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 18),

                        profileItem(
                          icon: Icons.person_outline,
                          title: "Full Name",
                          value: name.isEmpty
                              ? "Not available"
                              : name,
                        ),

                        const Divider(height: 25),

                        profileItem(
                          icon: Icons.email_outlined,
                          title: "Email Address",
                          value: email.isEmpty
                              ? "Not available"
                              : email,
                        ),

                        const Divider(height: 25),

                        profileItem(
                          icon: Icons.phone_outlined,
                          title: "Phone Number",
                          value: phone.isEmpty
                              ? "Not available"
                              : phone,
                        ),

                        const Divider(height: 25),

                        profileItem(
                          icon: Icons.school_outlined,
                          title: "Account Type",
                          value: role,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= EDIT PROFILE =================

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Edit Profile coming soon",
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.edit_outlined,
                      ),
                      label: const Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xff4F46E5),
                        side: const BorderSide(
                          color: Color(0xff4F46E5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ================= LOGOUT =================

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: logout,
                      icon: const Icon(
                        Icons.logout_rounded,
                      ),
                      label: const Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
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
    return Row(
      children: [

        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xffEEF2FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xff4F46E5),
            size: 21,
          ),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
