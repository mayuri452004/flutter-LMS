import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:lms/adminHome.dart';
import 'package:lms/firebase_options.dart';
import 'package:lms/login.dart';
import 'package:lms/userDashboard.dart';
import 'package:lms/userHome.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ==============================
  // Supabase Initialize
  // ==============================
  await Supabase.initialize(
    url: "https://ndomhtludxvpkgrmefin.supabase.co",
    publishableKey:
        "sb_publishable_OAgTOQSa_WUFCAsTktSsug_ebUIbgFh",
  );

  // ==============================
  // Firebase Initialize
  // ==============================
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "LMS",

      home: StreamBuilder<firebase_auth.User?>(
        stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),

        builder: (context, snapshot) {

          // ==============================
          // Firebase Loading
          // ==============================
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // ==============================
          // User Not Logged In
          // ==============================
          if (!snapshot.hasData) {
            return const loginScreen();
          }

          // ==============================
          // Logged-in Firebase User
          // ==============================
          final firebase_auth.User user = snapshot.data!;

          final String uid = user.uid;

          // ==============================
          // Get User Data from Firestore
          // ==============================
          return FutureBuilder<
              DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance
                .collection("users")
                .doc(uid)
                .get(),

            builder: (context, userSnapshot) {

              // ==============================
              // Firestore Loading
              // ==============================
              if (userSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // ==============================
              // Firestore Error
              // ==============================
              if (userSnapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Text(
                      "Firestore Error:\n${userSnapshot.error}",
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              // ==============================
              // Document Does Not Exist
              // ==============================
              if (!userSnapshot.hasData ||
                  !userSnapshot.data!.exists) {
                return const Scaffold(
                  body: Center(
                    child: Text(
                      "User data not found in Firestore",
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              // ==============================
              // Get Firestore Data
              // ==============================
              final data = userSnapshot.data!.data();

              if (data == null) {
                return const Scaffold(
                  body: Center(
                    child: Text(
                      "User data is empty",
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final String role = data["role"] ?? "";

              // ==============================
              // STUDENT
              // ==============================
              if (role == "STUDENT") {
                return UserHome();
              }

              // ==============================
              // ADMIN
              // ==============================
              if (role == "ADMIN") {
                return AdminHome();
              }

              // ==============================
              // Invalid Role
              // ==============================
              return const Scaffold(
                body: Center(
                  child: Text(
                    "Invalid user role",
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}