
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lms/addCourse.dart';
import 'package:lms/enrolledStudents.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int totalCourses = 0;
  int totalStudents = 0;
  int totalEnrollments = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  // =========================
  // LOAD DASHBOARD DATA
  // =========================

  Future<void> loadDashboardData() async {
    try {
      final courseSnapshot =
          await FirebaseFirestore.instance
              .collection("course")
              .get();

      final studentSnapshot =
          await FirebaseFirestore.instance
              .collection("users")
              .where("role", isEqualTo: "STUDENT")
              .get();

      final enrollmentSnapshot =
          await FirebaseFirestore.instance
              .collection("enrollments")
              .get();

      if (!mounted) return;

      setState(() {
        totalCourses = courseSnapshot.docs.length;
        totalStudents = studentSnapshot.docs.length;
        totalEnrollments = enrollmentSnapshot.docs.length;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Dashboard Error: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // =========================
  // LOGOUT
  // =========================

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  // =========================
  // STAT CARD
  // =========================

  Widget statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: const Color(0xffEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xff4F46E5),
            ),
          ),

          const SizedBox(height: 15),

          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // QUICK ACTION
  // =========================

  Widget quickAction({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: const Color(0xffEEF2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xff4F46E5),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 15,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,

        title: const Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              "Admin Dashboard",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 2),

            Text(
              "Manage your LMS",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: loadDashboardData,
            icon: const Icon(Icons.refresh),
          ),

          IconButton(
            onPressed: () async {
              final shouldLogout =
                  await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Logout"),
                    content: const Text(
                      "Are you sure you want to logout?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            false,
                          );
                        },
                        child: const Text("Cancel"),
                      ),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            true,
                          );
                        },
                        child: const Text("Logout"),
                      ),
                    ],
                  );
                },
              );

              if (shouldLogout == true) {
                await logout();
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: loadDashboardData,

        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              // =========================
              // WELCOME CARD
              // =========================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xff4F46E5),
                      Color(0xff6366F1),
                    ],
                  ),

                  borderRadius:
                      BorderRadius.circular(20),
                ),

                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome Admin 👋",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            user?.email ??
                                "Administrator",
                            style:
                                const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 15),

                          const Text(
                            "Manage courses, students and learning activities from one place.",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Icon(
                      Icons.admin_panel_settings,
                      size: 65,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // =========================
              // OVERVIEW
              // =========================

             
           

              const SizedBox(height: 30),

              // =========================
              // QUICK ACTIONS
              // =========================

              const Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              quickAction(
                title: "Manage Courses",
                subtitle:
                    "Add, edit or delete courses",
                icon: Icons.menu_book_rounded,
                onTap: () {
                  // Later connect with AdminCourses
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>addCourse()));
                },
              ),

              const SizedBox(height: 12),

              quickAction(
                title: "View Students",
                subtitle:
                    "Check registered students",
                icon: Icons.people_rounded,
                onTap: () {
                  // Later connect with AdminStudents
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>AdminStudents()));
                },
              ),

              const SizedBox(height: 12),

              quickAction(
                title: "View Enrollments",
                subtitle:
                    "Check student course enrollments",
                icon:
                    Icons.assignment_rounded,
                onTap: () {
                  // Later connect with enrollment page
                },
              ),

              const SizedBox(height: 30),

              // =========================
              // SYSTEM INFO
              // =========================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),

                child: Row(
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        color:
                            const Color(0xffECFDF5),
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(width: 14),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            "System Status",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            "LMS is running normally",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Text(
                      "Active",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
