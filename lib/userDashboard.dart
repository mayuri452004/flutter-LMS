
import 'package:flutter/material.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==============================
              // HEADER
              // ==============================

              Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,

                    decoration: BoxDecoration(
                      color: const Color(0xffEEF2FF),
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: const Icon(
                      Icons.school_rounded,
                      color: Color(0xff4F46E5),
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          "Welcome back 👋",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),

                        SizedBox(height: 3),

                        Text(
                          "Student",
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1F2937),
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () {},

                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      size: 27,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ==============================
              // BANNER
              // ==============================

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color: const Color(0xff4F46E5),
                  borderRadius: BorderRadius.circular(22),
                ),

                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          const Text(
                            "Start Learning Today",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            "Explore courses and improve your skills.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 18),

                          ElevatedButton(
                            onPressed: () {
                              // Courses tab
                              // navigation UserHome मधून handle होईल
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor:
                                  const Color(0xff4F46E5),

                              elevation: 0,

                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 11,
                              ),

                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                            ),

                            child: const Text(
                              "Explore Courses",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Icon(
                      Icons.auto_stories_rounded,
                      size: 85,
                      color: Colors.white24,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ==============================
              // YOUR LEARNING
              // ==============================

              const Text(
                "Your Learning",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1F2937),
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: statCard(
                      icon: Icons.menu_book_rounded,
                      title: "My Courses",
                      value: "0",
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: statCard(
                      icon:
                          Icons.play_circle_outline_rounded,
                      title: "In Progress",
                      value: "0",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: statCard(
                      icon:
                          Icons.check_circle_outline_rounded,
                      title: "Completed",
                      value: "0",
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: statCard(
                      icon: Icons.trending_up_rounded,
                      title: "Progress",
                      value: "0%",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ==============================
              // EXPLORE NEW COURSES
              // ==============================

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),

                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),

                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        color: const Color(0xffEEF2FF),
                        borderRadius:
                            BorderRadius.circular(12),
                      ),

                      child: const Icon(
                        Icons.explore_outlined,
                        color: Color(0xff4F46E5),
                      ),
                    ),

                    const SizedBox(width: 14),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Text(
                            "Explore New Courses",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            "Find something new to learn",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 17,
                      color: Color(0xff4F46E5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================
  // STAT CARD
  // ==============================

  Widget statCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Container(
            padding: const EdgeInsets.all(9),

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

          const SizedBox(height: 13),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xff1F2937),
            ),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}